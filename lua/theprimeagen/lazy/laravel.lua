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
            command_center = { enable = false },
        },
    },
    cond = function()
        local uv = vim.uv or vim.loop

        local function exists(path)
            return path and uv.fs_stat(path) ~= nil
        end

        local function join(...)
            return table.concat({ ... }, "/")
        end

        local function read_json(path)
            local ok, lines = pcall(vim.fn.readfile, path)
            if not ok or not lines then
                return nil
            end

            local content = table.concat(lines, "\n")
            local ok_decode, decoded = pcall(vim.json.decode, content)
            if not ok_decode then
                return nil
            end

            return decoded
        end

        local function php_ok()
            if vim.fn.executable("php") ~= 1 then
                return false
            end

            local php_version = vim.trim(vim.fn.system("php -r 'echo PHP_MAJOR_VERSION.\".\".PHP_MINOR_VERSION;'"))
            local major, minor = php_version:match("^(%d+)%.(%d+)$")
            major = tonumber(major)
            minor = tonumber(minor)

            if not major or not minor then
                return false
            end

            return major > 8 or (major == 8 and minor >= 0)
        end

        local function find_project_root()
            local cwd = vim.fn.getcwd()

            local root_files = vim.fs.find({ "composer.json", "artisan", "bootstrap/app.php" }, {
                upward = true,
                path = cwd,
                stop = vim.loop.os_homedir(),
            })

            if #root_files == 0 then
                return nil
            end

            -- Use the first found marker and normalize to its directory root
            local first = root_files[1]

            if first:match("/bootstrap/app%.php$") then
                return vim.fs.dirname(vim.fs.dirname(first)) -- bootstrap/app.php -> project root
            end

            return vim.fs.dirname(first)
        end

        local function is_laravel_project(root)
            if not root then
                return false
            end

            local artisan = join(root, "artisan")
            local bootstrap_app = join(root, "bootstrap", "app.php")
            local composer_json = join(root, "composer.json")

            -- Strong Laravel app markers
            if exists(artisan) and exists(bootstrap_app) then
                return true
            end

            -- Fallback: inspect composer.json for Laravel dependencies
            if exists(composer_json) then
                local composer = read_json(composer_json)
                if not composer then
                    return false
                end

                local req = composer.require or {}
                local req_dev = composer["require-dev"] or {}

                if req["laravel/framework"]
                    or req["laravel/octane"]
                    or req["laravel/sanctum"]
                    or req_dev["laravel/pint"]
                    or req_dev["laravel/sail"]
                then
                    return true
                end
            end

            return false
        end

        if not php_ok() then
            return false
        end

        local root = find_project_root()
        return is_laravel_project(root)
    end,
    config = true
}
