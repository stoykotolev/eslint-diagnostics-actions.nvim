---@diagnostic disable: undefined-field
local eca = {}

---@class eca.Diagnostic
---@field source string: The source for this diagnostic
---@field code string: The diagnostic code
---@field message string: The diagnostic message

---@class eca.Action
---@field type "currentLine" | "nextLine" | "file"
---@field command fun()
---@field title string: The title of the current action
---@field source string: The source of the diagnostic
---@field code string: The code for the rule
---@field idx number: The index number for this action

---Creates a new action item
---@param diagnostic eca.Diagnostic
---@param type "currentLine" | "nextLine" | "file"
---@return eca.Action
local create_action = function(diagnostic, type, idx)
	local action = {
		type = type,
		title = diagnostic.message,
		source = diagnostic.source,
		code = diagnostic.code,
		idx = idx

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
			for _, item in ipairs(actions) do
				if format_title(item) == selected then
					print("You selected:", vim.inspect(item))
					-- You can call your custom handler here
					return
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
