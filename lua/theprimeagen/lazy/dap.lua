local js_based_languages = {
    "typescript",
    "javascript",
    "typescriptreact",
    "javascriptreact",
    "vue",
}

local function get_args()
    local args = {}
    local i = 1
    while true do
        local name, value = debug.getlocal(2, i)
        if not name then break end
        args[name] = value
        i = i + 1
    end
    return args
end

local function pick_port(default_port)
    local co = coroutine.running()
    return coroutine.create(function()
        vim.ui.input({
            prompt = "Enter debug port: ",
            default = tostring(default_port),
        }, function(input)
            local port_num = tonumber(input) or default_port
            coroutine.resume(co, port_num)
        end)
    end)
end

return {
    {
        "mfussenegger/nvim-dap",
        keys = {
            { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
            { "<leader>db", function() require("dap").toggle_breakpoint() end,                                    desc = "Toggle Breakpoint" },
            { "<leader>dc", function() require("dap").continue() end,                                             desc = "Run/Continue" },
            { "<leader>da", function() require("dap").continue({ before = get_args }) end,                        desc = "Run with Args" },
            { "<leader>dC", function() require("dap").run_to_cursor() end,                                        desc = "Run to Cursor" },
            { "<leader>dg", function() require("dap").goto_() end,                                                desc = "Go to Line (No Execute)" },
            { "<leader>di", function() require("dap").step_into() end,                                            desc = "Step Into" },
            { "<leader>dj", function() require("dap").down() end,                                                 desc = "Down" },
            { "<leader>dk", function() require("dap").up() end,                                                   desc = "Up" },
            { "<leader>dl", function() require("dap").run_last() end,                                             desc = "Run Last" },
            { "<leader>do", function() require("dap").step_out() end,                                             desc = "Step Out" },
            { "<leader>dO", function() require("dap").step_over() end,                                            desc = "Step Over" },
            { "<leader>dP", function() require("dap").pause() end,                                                desc = "Pause" },
            { "<leader>dr", function() require("dap").repl.toggle() end,                                          desc = "Toggle REPL" },
            { "<leader>ds", function() require("dap").session() end,                                              desc = "Session" },
            { "<leader>dt", function() require("dap").terminate() end,                                            desc = "Terminate" },
            { "<leader>dw", function() require("dap.ui.widgets").hover() end,                                     desc = "Widgets" },
            { "<leader>dQ", function() require("dapui").close() end,                                              desc = "Close all UI" },
        },
        dependencies = {
            {
                "rcarriga/nvim-dap-ui",
                {
                    "theHamsta/nvim-dap-virtual-text",
                    opts = {},
                }
            },
            { "nvim-neotest/nvim-nio" },
            {
                "jay-babu/mason-nvim-dap.nvim",
                config = function()
                    require("mason-nvim-dap").setup({
                        ensure_installed = {
                            "codelldb",
                            "php",
                        },
                    })
                end,
            },
        },
        config = function()
            vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

            local dap, dapui = require("dap"), require("dapui")

            dap.adapters.php = {
                type = 'executable',
                command = 'php-debug-adapter', -- Adjust as needed, must be in PATH
                args = {}
            }
            dap.configurations.php = {
                {
                    type = "php",
                    request = "launch",
                    name = "Listen for Xdebug",
                    port = 9003,
                    stopOnEntry = false,
                    log = true,
                    xdebugSettings = {
                        max_children = 128,
                        max_data = 1024,
                        show_hidden = 1,
                    }
                },
            }

            for _, language in ipairs(js_based_languages) do
                dap.configurations[language] = {
                    -- Debug single nodejs files
                    {
                        type = "pwa-node",
                        request = "launch",
                        name = "Launch file",
                        program = "${file}",
                        cwd = '${workspaceFolder}',
                        sourceMaps = true,
                    },
                    -- Debug nodejs processes (make sure to add --inspect when you run the process)
                    {
                        type = "pwa-node",
                        request = "attach",
                        name = "Attach",
                        processId = require("dap.utils").pick_process,
                        cwd = '${workspaceFolder}',
                        sourceMaps = true,
                        port = pick_port(9229),
                    },
                    -- Debug web applications (client side)
                    {
                        type = "pwa-chrome",
                        request = "launch",
                        name = "Launch & Debug Chrome",
                        url = function()
                            local co = coroutine.running()
                            return coroutine.create(function()
                                vim.ui.input({
                                    prompt = "Enter URL: ",
                                    default = "http://localhost:3000",
                                }, function(url)
                                    if url == nil or url == "" then
                                        return
                                    else
                                        coroutine.resume(co, url)
                                    end
                                end)
                            end)
                        end,
                        webRoot = '${workspaceFolder}',
                        protocol = "inspector",
                        sourceMaps = true,
                        userDataDir = false,
                        port = pick_port(9222),
                    },
                    -- Divider for the launch.json derived configs
                    {
                        name = "----- ↓ launch.json configs ↓ -----",
                        type = "",
                        request = "launch",
                    },
                }
            end

            dapui.setup()

            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.disconnect["dapui_config"] = function()
                dapui.close()
            end
        end,
    },
    {
        'vadimcn/codelldb',
        dependencies = {
            {
                'mfussenegger/nvim-dap',
                {
                    'theHamsta/nvim-dap-virtual-text',
                    opts = {},
                }
            },
        },
        adapter = function()
            return require('dap').adapters.codelldb
        end,
        config = function()
            local dap = require('dap')
            dap.adapters.codelldb = {
                type = 'executable',
                command = 'codelldb',
                name = "codelldb"
            }
            dap.configurations.rust = {
                {
                    type = 'codelldb',
                    name = "Launch",
                    request = "launch",
                    program = function()
                        vim.fn.jobstart("cargo build", { cwd = vim.fn.getcwd() })
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
                    end,
                    cwd = '${workspaceFolder}',
                    stopOnEntry = false,
                    args = function()
                        local arg_string = vim.fn.input("Command line arguments: ", "")
                        return vim.split(arg_string, " ")
                    end,
                    runInTerminal = false,
                    showDisassembly = "never",
                },
                {
                    type = 'codelldb',
                    name = "Debug unit tests",
                    request = "launch",
                    program = "cargo",
                    cwd = '${workspaceFolder}',
                    stopOnEntry = false,
                    args = {
                        "test",
                        "--no-run",
                    },
                    runInTerminal = true,
                    showDisassembly = "never",
                },
                {
                    type = 'codelldb',
                    name = "Attach to process",
                    request = "attach",
                    pid = function()
                        return vim.fn.input("Process ID: ")
                    end,
                    stopOnEntry = false,
                    args = {},
                    runInTerminal = false,
                    showDisassembly = "never",
                },
            }
        end,
    },
    {
        "microsoft/vscode-js-debug",
        -- a pinned version or "latest" is recommended
        version = "1.x",
        build = "npm ci --legacy-peer-deps && npx gulp",
    },
    {
        "mxsdev/nvim-dap-vscode-js",
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            require("dap-vscode-js").setup({
                -- Set this to wherever "vscode-js-debug" was installed.
                -- The line below typically points to the Lazy-managed location:
                debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
                -- The adapters we want to enable:
                adapters = { "pwa-node", "pwa-chrome" },
            })
        end
    },
    -- {
    --     "xdebug/vscode-php-debug",
    --     dependencies = { "mfussenegger/nvim-dap" },
    --     config = function()
    --         require("php-debug-adapter").setup({
    --             -- Set this to wherever "vscode-php-debug" was installed.
    --             -- The line below typically points to the Lazy-managed location:
    --             debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-php-debug",
    --         })
    --     end
    -- }
}
