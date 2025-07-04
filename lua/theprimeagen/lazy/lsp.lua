return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({})

        local lspconfig = require("lspconfig")

        -- rust-analyzer
        vim.lsp.config('rust_analyzer', {
            capabilities = capabilities,
            settings = {
                ["rust-analyzer"] = {
                    cargo = { loadOutDirsFromCheck = true },
                    checkOnSave = false,
                    diagnostics = { enable = false },
                    inlay_hints = {
                        show_parameter_hints = true,
                        parameter_hints_prefix = " » ",
                        type_hints = true,
                        type_hints_prefix = " » ",
                        max_length = 80,
                    },
                    procMacro = { enable = true },
                },
            },
            on_attach = function(client, bufnr)
                vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]
            end
        })

        -- bacon-ls
        lspconfig.bacon_ls.setup {
            capabilities = capabilities,
            init_options = {
                runBaconInBackground = true,
                updateOnSave = true,
                updateOnSaveWaitMilliseconds = 1000,
                updateOnChange = false,
            },
            settings = {
                ["bacon-ls"] = {
                    cargo_command_args =
                    "clippy --tests --all-targets --message-format json-diagnostic-rendered-ansi",
                    bacon = {
                        format = {
                            enable = true,
                            autoFixOnFormat = true,
                            autoFixOnSave = true,
                        },
                        lint = {
                            enable = true,
                            autoFixOnLint = true,
                        },
                    }
                },
            },
            root_dir = function(fname)
                return lspconfig.util.root_pattern("bacon.toml")(fname)
                    or vim.fs.dirname(vim.fs.find({ '.git' }, fname, { upward = true })[1])
                    or vim.loop.cwd()
            end,
            on_attach = function(client, bufnr)
                client.server_capabilities.documentFormattingProvider = false
                vim.lsp.inlay_hint.enable(true)
            end
        }

        -- phpactor
        vim.lsp.config('phpactor', {
            capabilities = capabilities,
            cmd = { "phpactor", "language-server" },
            on_attach = function(client, bufnr)
                client.server_capabilities.hoverProvider = false
                client.server_capabilities.documentSymbolProvider = false
                client.server_capabilities.referencesProvider = false
                client.server_capabilities.completionProvider = false
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.definitionProvider = false
                client.server_capabilities.implementationProvider = true
                client.server_capabilities.typeDefinitionProvider = false
                client.server_capabilities.diagnosticProvider = false
            end
        })

        -- intelephense
        vim.lsp.config('intelephense', {
            capabilities = capabilities,
            settings = {
                php = {
                    completion = {
                        callSnippet = "Replace"
                    }
                },
                intelephense = {
                    files = {
                        maxSize = 1000000
                    }
                }
            },
            cmd = { "intelephense", "--stdio" },
            on_attach = function(client, bufnr)
                vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]
            end
        })

        -- tsserver
        vim.lsp.config('ts_ls', {
            capabilities = capabilities,
            cmd_env = {
                NODE_OPTIONS = "--max_old_space_size=8192"
            },
            inlay_hints = {
                show_parameter_hints = true,
                parameter_hints_prefix = " » ",
                type_hints = true,
                type_hints_prefix = " » ",
                max_length = 80,
            },
            on_attach = function(client, bufnr)
                vim.lsp.inlay_hint.enable(true)
                client.server_capabilities.documentFormattingProvider = false
            end
        })

        -- ts_go
        -- vim.lsp.config('ts_go_ls', {
        --     capabilities = capabilities,
        --     cmd = { vim.loop.os_homedir() .. "/dev/typescript-go/built/local/tsgo", "--lsp", "-stdio" },
        --     filetypes = {
        --         "javascript",
        --         "javascriptreact",
        --         "javascript.jsx",
        --         "typescript",
        --         "typescriptreact",
        --         "typescript.tsx",
        --     },
        --     root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
        --     inlay_hints = {
        --         show_parameter_hints = true,
        --         parameter_hints_prefix = " » ",
        --         type_hints = true,
        --         type_hints_prefix = " » ",
        --         max_length = 80,
        --     },
        --     on_attach = function(client, bufnr)
        --         vim.lsp.inlay_hint.enable(true)
        --         client.server_capabilities.documentFormattingProvider = false
        --     end
        -- })
        -- vim.lsp.enable("ts_go_ls")

        -- eslint
        vim.lsp.config('eslint', {
            -- root_dir = function(fname)
            --     local util = lspconfig.util

            --     local has_biome = util.root_pattern("biome.json", "biome.jsonc")(fname)
            --     local has_eslint = util.root_pattern(".eslintrc", ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json")(
            --         fname)

            --     if has_biome or not has_eslint then
            --         return nil
            --     end

            --     return util.root_pattern("package.json", ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json")(
            --             fname)
            --         or vim.fs.dirname(vim.fs.find({ '.git' }, fname, { upward = true })[1])
            --         or vim.loop.cwd()
            -- end,
            root_dir = function(fname)
                return lspconfig.util.root_pattern("package.json", ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json")(
                        fname)
                    or vim.fs.dirname(vim.fs.find({ '.git' }, fname, { upward = true })[1])
                    or vim.loop.cwd()
            end,
            capabilities = capabilities,
            cmd_env = {
                NODE_OPTIONS = "--max_old_space_size=8192"
            },
            on_attach = function(client, bufnr)
                client.server_capabilities.documentFormattingProvider = true
                vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]
            end
        })

        -- biome
        lspconfig.biome.setup({
            cmd = { "biome", "lsp-proxy" },
            root_dir = function(fname)
                local util = lspconfig.util

                local has_biome = util.root_pattern("biome.json", "biome.jsonc")(fname)
                local has_eslint = util.root_pattern(".eslintrc", ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json")(
                    fname)

                if has_biome or not has_eslint then
                    return has_biome
                        or vim.fs.dirname(vim.fs.find({ '.git' }, fname, { upward = true })[1])
                        or vim.loop.cwd()
                end

                return nil
            end,
            single_file_support = true,
            capabilities = capabilities,
            on_attach = function(client, bufnr)
                vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]
            end
        })

        -- lua_ls
        vim.lsp.config('lua_ls', {
            capabilities = capabilities,
            settings = {
                Lua = {
                    runtime = { version = "Lua 5.1" },
                    diagnostics = {
                        globals = { "vim", "it", "describe", "before_each", "after_each" },
                    }
                }
            },
            on_attach = function(client, bufnr)
                vim.diagnostic.config({
                    virtual_text = false,
                    virtual_lines = { current_line = true },
                }, bufnr)
                vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]
            end
        })

        -- tailwindcss
        vim.lsp.config('tailwindcss', {
            capabilities = capabilities,
            root_pattern = {
                "tailwind.config.js",
                "tailwind.config.ts",
                "postcss.config.js",
                "postcss.config.ts",
                "package.json",
            },
            -- root_dir = function(fname)
            --     return lspconfig.util.root_pattern("tailwind.config.js", "tailwind.config.ts")(fname)
            --         or vim.fs.dirname(vim.fs.find({ '.git' }, fname, { upward = true })[1])
            --         or vim.loop.cwd()
            -- end,
            -- only for some filetypes
            filetypes = {
                "javascriptreact",
                "typescriptreact",
                "html",
                "css",
                "scss",
                "less",
                "vue",
                "svelte",
                "php",
            },
            on_attach = function(client, bufnr)
                client.server_capabilities.documentFormattingProvider = false
                vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]
            end
        })

        require("mason").setup()
        require("mason-tool-installer").setup({
            ensure_installed = {
                "php-cs-fixer",
                "bacon",
            },
        })
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "ts_ls",
                "eslint",
                "tailwindcss",
                "intelephense",
                "phpactor",
                "biome@1.9.4",
                "rust_analyzer",
            },
            automatic_installation = true,
            automatic_enable = {
                "lua_ls",
                "ts_ls",
                -- "ts_go_ls",
                "eslint",
                "tailwindcss",
                "intelephense",
                "phpactor",
                "rust_analyzer",
            }
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = "copilot",  group_index = 2 },
                { name = 'nvim_lsp', group_index = 2 },
                { name = 'luasnip',  group_index = 2 }, -- For luasnip users.
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
