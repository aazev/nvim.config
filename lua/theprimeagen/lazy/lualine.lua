return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        -- local triforce = require('triforce.lualine')
        -- triforce.setup({
        --     level = {
        --         bar = {
        --             chars = { filled = '●', empty = '○' },
        --             length = 5,
        --         }
        --     },
        -- })
        -- local triforce_components = triforce.components()

        require('lualine').setup({
            options = {
                icons_enabled = true,
                theme = 'monokai-pro',
                component_separators = { left = '', right = '' },
                section_separators = { left = '', right = '' },
            },
            sections = {
                lualine_a = { 'mode' },
                lualine_b = { 'branch', 'diff', 'diagnostics' },
                lualine_c = { 'filename' },
                lualine_x = {
                    -- triforce_components.level,
                    -- triforce_components.achievements,
                    -- triforce_components.streak,
                    'encoding',
                    'fileformat',
                    'filetype',
                },
                lualine_y = {
                },
                lualine_z = { 'location' },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { 'filename' },
                lualine_x = { 'location' },
                lualine_y = {},
                lualine_z = {},
            },
            tabline = {},
            extensions = {},
        })
    end
}
