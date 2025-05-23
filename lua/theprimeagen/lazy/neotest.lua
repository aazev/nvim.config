return {
    {
        "nvim-neotest/nvim-nio"
    },
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "marilari88/neotest-vitest",
            "nvim-neotest/neotest-plenary",
            "olimorris/neotest-phpunit",
            "v13Axel/neotest-pest",
        },
        config = function()
            local neotest = require("neotest")
            neotest.setup({
                adapters = {
                    require("neotest-phpunit"),
                    require("neotest-pest"),
                    require("neotest-vitest"),
                    require("neotest-plenary"),
                }
            })

            vim.keymap.set("n", "<leader>tc", function()
                neotest.run.run()
            end)
        end,
    }
}
