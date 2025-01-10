# eslint-diagnostics-actions.nvim

A Neovim plugin that allows for eslint diagnostics to be disabled via a select window. Quickly disable specific eslint rules directly from within Neovim based on the diagnostics shown.

The plugin has 0 external dependencies, but does require having `eslint` or `eslint_d` installed for the diagnostics to be shown

## Features

- Displays eslint diagnostics in a selectable popup window.
- Allows users to quickly disable eslint rules via a single action.
- Supports integration with `eslint_d` for efficient rule management.

## Installation

To install this plugin, use your preferred plugin manager. If you're using **lazy.nvim**, you can add the plugin by adding the following code to your `init.lua` or `plugins.lua` file:

```lua
    {
        "stoykotolev/eslint-code-actions.nvim",
        opts = {}
    },
```

## Usage

Once the plugin is installed, you can use the following command to interact with the diagnostics:

`:GetDiagnostics`: Opens a window displaying the current eslint diagnostics for the current buffer.
The plugin will present a list of available code actions for each diagnostic. Selecting an action will disable the rule for that diagnostic.
You can map :GetDiagnostics to any key of your choice in your Neovim configuration. For example:

```lua
vim.api.nvim_set_keymap('n', '<leader>d', ':GetDiagnostics<CR>', { noremap = true, silent = true })
```

## Contributing

Contributions are welcome! Feel free to submit issues, pull requests, or suggest improvements.

Please ensure your code follows the existing style and includes tests where appropriate.

## License

This project is licensed under the MIT License.
