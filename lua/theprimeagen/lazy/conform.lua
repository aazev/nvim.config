vim.env.ESLINT_D_PPID = vim.fn.getpid()

return {
    {
        "stevearc/conform.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
        },
        lazy = true,
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local lsp_util = require("lspconfig.util")
            local function get_project_root(fname)
                return lsp_util.root_pattern(
                        ".git",
                        "composer.json",
                        ".php-cs-fixer.php",
                        ".php-cs-fixer.dist.php"
                    )(fname)
                    or vim.loop.cwd()
            end
            local conform = require("conform")

            conform.setup({
                formatters = {
                    ["php-cs-fixer"] = function()
                        -- find nearest project root (looks for .git/, etc.)
                        local root        = get_project_root()
                        -- list of possible config filenames
                        local configs     = {
                            root .. "/.php-cs-fixer.php",
                            root .. "/php-cs-fixer.php",
                            root .. "/.php-cs-fixer.dist.php",
                            root .. "/php_cs",
                            root .. "/php_cs.dist",
                        }

                        -- check for any one of them
                        local config_file = nil
                        local has_cfg     = false
                        for _, path in ipairs(configs) do
                            if vim.fn.filereadable(path) == 1 then
                                has_cfg = true
                                config_file = path
                                break
                            end
                        end

                        -- if they have a custom config, just run `fix`; otherwise fall back to PSR12
                        if has_cfg then
                            return {
                                command = "php-cs-fixer",
                                args    = { "fix", "--config=" + config_file, "$FILENAME" },
                                stdin   = false,
                            }
                        else
                            return {
                                command = "php-cs-fixer",
                                args    = { "fix", "--rules=@PSR12", "$FILENAME" },
                                stdin   = false,
                            }
                        end
                    end,
                    ["jsonlint"] = {
                        command = "jsonlint",
                        args = { "--compact", "$FILENAME" },
                        stdin = false,
                    },
                },
                formatters_by_ft = {
                    php = { "php-cs-fixer" },
                    json = { "jsonlint" },
                    blade = {
                        "blade-formatter",
                        prepend_args = { "--wrap-line-length", 240, "--wrap-attributes-min-attrs", 1, "--sort-tailwindcss-classes", true }
                    }
                },
                format_after_save = {
                    timeout = 500,
                    lsp_fallback = true,
                    async = true,
                },
            })

            vim.keymap.set({ "n", "v" }, "<leader>f", function()
                conform.format({
                    lsp_fallback = true,
                    async = true,
                    timeout = 500,
                })
            end, { desc = "Format the current buffer or range (in visual mode)", noremap = true, silent = true })
        end,
    },
    {
        "zapling/mason-conform.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "stevearc/conform.nvim",
        },
        config = function()
            require("mason-conform").setup({
            })
        end
    }
}
