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
        require("mason").setup()
        require("mason-tool-installer").setup({
            ensure_installed = {
                "php-cs-fixer",
            },
        })
        require("mason-lspconfig").setup({
            automatic_enable = { exclude = { "rust_analyzer" } },
            ensure_installed = {
                "lua_ls",
                "ts_ls",
                "eslint",
                "tailwindcss",
                "intelephense",
                "phpactor",
                "biome",
                "rust_analyzer",
            },
            handlers = {
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities,
                    }
                end,

                ["phpactor"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.phpactor.setup {
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
                    }
                end,

                ["intelephense"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.intelephense.setup {
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
                    }
                end,

                ["eslint"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.eslint.setup {
                        root_dir = function(fname)
                            local util = lspconfig.util

                            local has_biome = util.has_file("biome.json", fname) or util.has_file("biome.jsonc", fname)
                            local has_eslint = util.has_file(".eslintrc", fname)
                                or util.has_file(".eslintrc.js", fname)
                                or util.has_file(".eslintrc.cjs", fname)
                                or util.has_file(".eslintrc.json", fname)

                            if has_biome or not has_eslint then
                                return nil
                            end

                            return util.root_pattern("package.json", ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json")(
                                    fname)
                                or util.find_git_ancestor(fname)
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
                    }
                end,

                ["biome"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.biome.setup {
                        cmd = { "biome", "lsp-proxy" },
                        root_dir = function(fname)
                            local util = lspconfig.util

                            local has_biome = util.has_file("biome.json", fname) or util.has_file("biome.jsonc", fname)
                            local has_eslint = util.has_file(".eslintrc", fname)
                                or util.has_file(".eslintrc.js", fname)
                                or util.has_file(".eslintrc.cjs", fname)
                                or util.has_file(".eslintrc.json", fname)

                            if has_biome or not has_eslint then
                                return lspconfig.util.root_pattern("biome.json", "biome.jsonc")(fname)
                                    or lspconfig.util.find_git_ancestor(fname)
                                    or vim.loop.cwd()
                            end

                            return nil
                        end,
                        single_file_support = true,
                        capabilities = capabilities,
                        on_attach = function(client, bufnr)
                            vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]
                        end
                    }
                end,

                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
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
                    }
                end,
            }
        })

        local lspconfig = require("lspconfig")

        -- rust-analyzer
        lspconfig.rust_analyzer.setup({
            capabilities = capabilities,
            -- cmd = { "/home/aazev/.cargo/bin/rust-analyzer" },
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
                }
            },
            on_attach = function(client, bufnr)
                vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]
            end
        })

        -- bacon-ls
        lspconfig.bacon_ls.setup({
            capabilities = capabilities,
            init_options = {
                runBaconInBackground = true,
                updateOnSave = true,
                updateOnSaveWaitMilliseconds = 1000,
                updateOnChange = false,
            },
            settings = {
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
            root_dir = function(fname)
                return lspconfig.util.root_pattern("bacon.toml")(fname)
                    or lspconfig.util.find_git_ancestor(fname)
                    or vim.loop.cwd()
            end,
            on_attach = function(client, bufnr)
                vim.lsp.inlay_hint.enable(true)
            end
        })

        -- tsserver
        lspconfig.ts_ls.setup {
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
        }

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
