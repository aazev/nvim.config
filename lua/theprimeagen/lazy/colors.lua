function ColorMyPencils(color)
    color = color or "rose-pine"
    vim.cmd.colorscheme(color)

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'none' })
end

return {
    -- {
    --     "Mofiqul/dracula.nvim",
    --     name = "dracula",
    --     config = function()
    --         require("dracula").setup({
    --             theme = "dracula",
    --             transparent = true,
    --             term_colors = true,
    --             disable_background = true,
    --             styles = {
    --                 -- Style to be applied to different syntax groups
    --                 -- Value is any valid attr-list value for `:help nvim_set_hl`
    --                 comments = { italic = false },
    --                 keywords = { italic = false },
    --                 -- Background styles. Can be "dark", "transparent" or "normal"
    --                 sidebars = "dark", -- style for sidebars, see below
    --                 floats = "dark",   -- style for floating windows
    --                 functions = "italic,bold",
    --             },
    --         })

    --         vim.cmd("colorscheme dracula")

    --         ColorMyPencils("dracula")
    --     end
    -- },
    -- {
    --     "xiantang/darcula-dark.nvim",
    --     name = "darcula",
    --     config = function()
    --         require("darcula").setup({
    --             override = function()
    --                 return {
    --                     background = "#333333",
    --                     dark = "#000000",
    --                 }
    --             end,
    --             theme = "darcula-dark",
    --             transparent = true,
    --             term_colors = true,
    --             dim_inactive = true,
    --             styles = {
    --                 -- Style to be applied to different syntax groups
    --                 -- Value is any valid attr-list value for `:help nvim_set_hl`
    --                 comments = { italic = false },
    --                 keywords = { italic = false },
    --                 -- Background styles. Can be "dark", "transparent" or "normal"
    --                 sidebars = "dark", -- style for sidebars, see below
    --                 floats = "dark",   -- style for floating windows
    --                 functions = "italic,bold",
    --             },
    --         })

    --         vim.cmd("colorscheme darcula-dark")

    --         ColorMyPencils("darcula-dark")
    --     end
    -- },
    -- {
    --     "folke/tokyonight.nvim",
    --     name = "tokyonight",
    --     config = function()
    --         require("tokyonight").setup({
    --             -- your configuration comes here
    --             -- or leave it empty to use the default settings
    --             style = "storm",        -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
    --             transparent = true,     -- Enable this to disable setting the background color
    --             terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
    --             styles = {
    --                 -- Style to be applied to different syntax groups
    --                 -- Value is any valid attr-list value for `:help nvim_set_hl`
    --                 comments = { italic = false },
    --                 keywords = { italic = false },
    --                 -- Background styles. Can be "dark", "transparent" or "normal"
    --                 floats = "dark",   -- style for floating windows
    --             },
    --         })

    --         -- vim.cmd("colorscheme tokyonight")

    --         -- ColorMyPencils("tokyonight")
    --     end
    -- },
    {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
            require('rose-pine').setup({
                disable_background = true,
                styles = {
                    italic = false,
                },
            })

            vim.cmd("colorscheme rose-pine")

            ColorMyPencils()
        end
    },
    -- {
    --     "EdenEast/nightfox.nvim",
    --     name = "nightfox",
    --     config = function()
    --         require("nightfox").setup({
    --             transparent = true,
    --             terminal_colors = true,
    --             dim_inactive = true,
    --             styles = {
    --                 italic = false,
    --             },
    --         })

    --         vim.cmd("colorscheme carbonfox")

    --         ColorMyPencils("carbonfox")
    --     end
    -- },
    -- {
    --     "metalelf0/black-metal-theme-neovim",
    --     name = "black-metal",
    --     priority = 1000,
    --     config = function()
    --         require("black-metal").setup({
    --             theme = "bathory",
    --             transparent = true,
    --             term_colors = true,
    --             dim_inactive = true,
    --             styles = {
    --                 italic = false,
    --             },
    --         })

    --         -- vim.cmd("colorscheme black-metal")

    --         -- ColorMyPencils("black-metal")
    --         require("black-metal").load("bathory")
    --     end
    -- },
    -- {
    --     "navarasu/onedark.nvim",
    --     name = "onedark",
    --     priority = 1000,
    --     config = function()
    --         require("onedark").setup({
    --             style = "darker",
    --             transparent = true,
    --             term_colors = true,
    --             dim_inactive = true,
    --             styles = {
    --                 italic = false,
    --             },
    --         })

    --         -- vim.cmd("colorscheme onedark")

    --         -- ColorMyPencils("onedark")
    --         require("onedark").load()
    --     end
    -- },
    -- {
    --     "olimorris/onedarkpro.nvim",
    --     name = "onedarkpro",
    --     priority = 1000,
    --     config = function()
    --         require("onedarkpro").setup({
    --             options = {
    --                 transparency = true,
    --                 terminal_colors = true,
    --                 cursorline = true,
    --                 highlight_inactive_windows = true,
    --             },
    --             style = "onedark dark",
    --             highlights = {
    --                 Comment = { italic = false },
    --                 Keyword = { italic = false },
    --                 Function = { italic = false },
    --                 Gutter = { bg = "none" },
    --                 StatusLine = { fg = "black" },
    --             },
    --         })

    --         vim.cmd("colorscheme onedark")

    --         ColorMyPencils("onedark")
    --         -- require("onedarkpro").load("onedark")
    --     end
    -- },
    -- {
    --     "rebelot/kanagawa.nvim",
    --     name = "kanagawa",
    --     priority = 1000,
    --     config = function()
    --         require("kanagawa").setup({
    --             compile = false,
    --             transparent = true,
    --             dimInactive = true,
    --             commentStyle = { italic = false },
    --             functionStyle = { italic = false },
    --             keywordStyle = { italic = false },
    --             theme = "dragon",
    --             colors = {
    --                 theme = {
    --                     all = {
    --                         ui = {
    --                             bg_gutter = "none",
    --                         },
    --                     },
    --                 },
    --             },
    --         })

    --         vim.cmd("colorscheme kanagawa-dragon")

    --         -- ColorMyPencils("kanagawa-dragon")
    --     end
    -- },
}
