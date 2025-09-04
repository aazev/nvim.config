return {
    "adalessa/laravel.nvim",
    dependencies = {
        "tpope/vim-dotenv",
        "MunifTanjim/nui.nvim",
        "nvim-lua/plenary.nvim",
        "nvim-neotest/nvim-nio",
        "kevinhwang91/promise-async",
        "nvim-telescope/telescope.nvim",
        "ravitemer/mcphub.nvim", -- optional
    },
    cmd = { "Laravel" },
    -- keys = {
    --     { "<leader>la", ":Laravel artisan<cr>" },
    --     { "<leader>lr", ":Laravel routes<cr>" },
    --     { "<leader>lm", ":Laravel related<cr>" },
    -- },
    keys = {
        -- { "<leader>ll", function() Laravel.pickers.laravel() end,           desc = "Laravel: Open Laravel Picker" },
        { "<leader>lv", function() Laravel.commands.run("view:finder") end, desc = "Laravel: Open View Finder" },
        { "<leader>la", function() Laravel.pickers.artisan() end,           desc = "Laravel: Open Artisan Picker" },
        { "<leader>lt", function() Laravel.commands.run("actions") end,     desc = "Laravel: Open Actions Picker" },
        { "<leader>lr", function() Laravel.pickers.routes() end,            desc = "Laravel: Open Routes Picker" },
        { "<leader>lh", function() Laravel.run("artisan docs") end,         desc = "Laravel: Open Documentation" },
        { "<leader>lm", function() Laravel.pickers.make() end,              desc = "Laravel: Open Make Picker" },
        { "<leader>lc", function() Laravel.pickers.commands() end,          desc = "Laravel: Open Commands Picker" },
        { "<leader>lo", function() Laravel.pickers.resources() end,         desc = "Laravel: Open Resources Picker" },
        -- { "<leader>lp", function() Laravel.commands.run("command_center") end, desc = "Laravel: Open Command Center" },
        {
            "gf",
            function()
                local ok, res = pcall(function()
                    if Laravel.app("gf").cursorOnResource() then
                        return "<cmd>lua Laravel.commands.run('gf')<cr>"
                    end
                end)
                if not ok or not res then
                    return "gf"
                end
                return res
            end,
            expr = true,
            noremap = true,
        },
    },
    event = { "VeryLazy" },
    opts = {
        lsp_server = "phpactor",
        features = {
            picker = {
                provider = "snacks"
            },
            route_info = {
                enable = true,      --- to enable the laravel.nvim virtual text
                position = 'right', --- where to show the info (available options 'right', 'top')
                middlewares = true, --- wheather to show the middlewares section in the info
                method = true,      --- wheather to show the method section in the info
                uri = true          --- wheather to show the uri section in the info
            },
        },
        extensions = {
            completion = { enable = true },
            composer_dev = { enable = true },
            composer_info = { enable = true },
            diagnostic = { enable = true },
            dump_server = { enable = true },
            model_info = { enable = true },
            override = { enable = true },
            route_info = { enable = true, view = "simple" },
            tinker = { enable = true },
            mcp = { enable = true },
            command_center = { enable = false },
        },
    },
    cond = function()
        -- Check if PHP is available in the system
        local php_installed = vim.fn.executable("php") == 1
        local php_version = vim.fn.system("php -r 'echo PHP_VERSION;'")

        if php_installed then
            local major, minor = php_version:match("^(%d+)%.(%d+)")
            major = tonumber(major)
            minor = tonumber(minor)
            if major < 8 then
                vim.notify("Laravel.nvim requires PHP 8.0 or higher. Detected version: " .. php_version,
                    vim.log.levels.WARN)
                return false
            end
        else
            vim.notify("PHP is not installed or not found in PATH. Laravel.nvim will be disabled")
            return false
        end

        return php_installed
    end,
    config = true
}
