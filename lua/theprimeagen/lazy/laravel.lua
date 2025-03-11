return {
    "adalessa/laravel.nvim",
    cond = function()
        -- Check if PHP is available in the system
        local php_installed = vim.fn.executable("php") == 1
        -- Check if a composer.json file exists in the current working directory
        local composer_exists = vim.fn.filereadable(vim.fn.getcwd() .. "/composer.json") == 1
        return php_installed and composer_exists
    end,
    dependencies = {
        "tpope/vim-dotenv",
        "nvim-telescope/telescope.nvim",
        "MunifTanjim/nui.nvim",
        "kevinhwang91/promise-async",
    },
    cmd = { "Sail", "Artisan", "Composer", "Npm", "Yarn", "Laravel" },
    keys = {
        { "<leader>la", ":Laravel artisan<cr>" },
        { "<leader>lr", ":Laravel routes<cr>" },
        { "<leader>lm", ":Laravel related<cr>" },
    },
    event = { "VeryLazy" },
    opts = {
        features = {
            null_ls = {
                enable = true,
            },
            route_info = {
                enable = true,      --- to enable the laravel.nvim virtual text
                position = 'right', --- where to show the info (available options 'right', 'top')
                middlewares = true, --- wheather to show the middlewares section in the info
                method = true,      --- wheather to show the method section in the info
                uri = true          --- wheather to show the uri section in the info
            },
        },
    },
    config = true,
}
