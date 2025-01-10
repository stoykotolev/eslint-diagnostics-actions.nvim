---@diagnostic disable: undefined-field
local commentToMatch = {
  currentLine = "// eslint%-disable%-next%-line",
  file = "/* eslint%-disable",
}
local commentActions = {
  currentLine = "// eslint-disable-next-line",
  file = "/* eslint-disable ",
}
local eca = {}

---@class eca.Diagnostic
---@field source string: The source for this diagnostic
---@field code string: The diagnostic code
---@field message string: The diagnostic message

---@class eca.Action
---@field type "currentLine" | "file"
---@field command fun()
---@field title string: The title of the current action
---@field source string: The source of the diagnostic
---@field code string: The code for the rule
---@field idx number: The index number for this action

---Disable the rule for the current line only
---@param item eca.Action
local disableCurrentLineRule = function(item)
  local prevLine = vim.fn.line(".") - 1
  local prevLineContent = vim.api.nvim_buf_get_lines(0, prevLine - 1, prevLine, false)[1]
  if string.match(prevLineContent, commentToMatch.currentLine) then
    vim.api.nvim_buf_set_lines(0, prevLine - 1, prevLine, false, {
      prevLineContent .. ", " .. item.code,
    })
    return
  end
  vim.api.nvim_buf_set_lines(0, prevLine, prevLine, false, {
    commentActions.currentLine .. " " .. item.code,
  })
end

---Disable the rule for the whole file
---@param item eca.Action
local disableRuleForFile = function(item)
  local firstLineContent = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
  if string.match(firstLineContent, commentToMatch.file) then
    local updatedRule = firstLineContent:sub(1, -3) .. ", " .. item.code .. " */"
    vim.api.nvim_buf_set_lines(0, 0, 1, false, { updatedRule })
    return
  end
  vim.api.nvim_buf_set_lines(0, 0, 0, false, {
    commentActions.file .. item.code .. " */",
  })
end

---Creates a new action item
---@param diagnostic eca.Diagnostic
---@param type "currentLine" | "file"
---@return eca.Action
local create_action = function(diagnostic, type, idx)
  local action = {
    type = type,
    title = diagnostic.message,
    source = diagnostic.source,
    code = diagnostic.code,
    idx = idx,
    command = type == "currentLine" and disableCurrentLineRule or type == "file" and disableRuleForFile,
  }
  return action
end

---Format the action title
---@param item eca.Action
---@return string
local format_title = function(item)
  return string.format("%d: %s (%s, %s)", item.idx, item.code, item.source, item.type)
end

---Show all of the available actions for selection
---@param actions eca.Action
local show_actions = function(actions)
  local display_names = vim.tbl_map(function(item)
    return format_title(item)
  end, actions)

  vim.ui.select(display_names, {
    prompt = "Select an action:",
  }, function(selected)
    if selected then
      for _, action in ipairs(actions) do
        if format_title(action) == selected then
          action.command(action)
        end
      end
    end
  end)
end

local get_diagnostics = function()
  local diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
  local actions = {}

  local counter = 1
  for _, diagnostic in ipairs(diagnostics) do
    table.insert(actions, create_action(diagnostic, "currentLine", counter))
    counter = counter + 1
    table.insert(actions, create_action(diagnostic, "file", counter))
    counter = counter + 1
  end

  show_actions(actions)
end

eca.setup = function()
  vim.api.nvim_create_user_command("GetDiagnosics", function()
    get_diagnostics()
  end, {})
end

return eca
