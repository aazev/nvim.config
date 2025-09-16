return {
    -- {
    --     "github/copilot.vim"
    -- },
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        build = ":Copilot auth",
        config = function()
            require("copilot").setup({
                suggestion = {
                    enabled = false,
                    debounce = 75,
                },
                panel = {
                    enabled = true,
                    auto_refresh = true,
                },
            })
        end,
    },
    {
        "zbirenbaum/copilot-cmp",
        dependencies = "zbirenbaum/copilot.lua",
        config = function()
            require("copilot_cmp").setup()
        end,
    },
}
