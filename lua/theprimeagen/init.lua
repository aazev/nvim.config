require("theprimeagen.set")
require("theprimeagen.remap")
require("theprimeagen.lazy_init")

local augroup = vim.api.nvim_create_augroup
local ThePrimeagenGroup = augroup('ThePrimeagen', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

function R(name)
    require("plenary.reload").reload_module(name)
end

vim.filetype.add({
    extension = {
        templ = 'templ',
    }
})

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

autocmd({ "BufWritePre" }, {
    group = ThePrimeagenGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

autocmd('LspAttach', {
    group = ThePrimeagenGroup,
    callback = function(e)
        local client = vim.lsp.get_client_by_id(e.data.client_id)
        local ns     = vim.lsp.diagnostic.get_namespace(e.data.client_id)

        vim.diagnostic.config({
            virtual_text = true,
            virtual_lines = false
        })

        if client.name == "copilot" then
            return
        end

        if client.name == "rust_analyzer" or client.name == "bacon" or client.name == "bacon-ls" or client.name == "bacon_ls" then
            vim.diagnostic.config({
                virtual_text = true,
                virtual_lines = false
            }, ns)
        elseif client.name then
            vim.diagnostic.config({
                virtual_text = false,
                virtual_lines = { current_line = true },
            }, ns)
        end

        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration() end, opts)
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    end
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
vim.opt.fileformats = { "unix", "dos", "mac" }

-- local function abbreviateString(s, maxWidth)
--     if #s <= maxWidth then
--         return s
--     end
--
--     local startLength = math.floor((maxWidth - 3) / 2)
--     local endLength = math.ceil((maxWidth - 3) / 2)
--
--     return s:sub(1, startLength) .. "..." .. s:sub(-endLength)
-- end

-- Helper to get StatusLine group's background color as a hex string (or "NONE")
-- local function get_statusline_bg()
--     local ok, hl = pcall(vim.api.nvim_get_hl_by_name, "StatusLine", true)
--     if ok and hl and hl.background then
--         return string.format("#%06x", hl.background)
--     else
--         return "NONE"
--     end
-- end

-- Function to define Git highlight groups based on the current Normal background
-- local function setup_git_highlights()
--     local statusbar_bg = get_statusline_bg()
--     vim.cmd("highlight GitGreen  guifg=green  guibg=" .. statusbar_bg)
--     vim.cmd("highlight GitYellow guifg=yellow guibg=" .. statusbar_bg)
--     vim.cmd("highlight GitRed    guifg=red    guibg=" .. statusbar_bg)
--     vim.cmd("highlight GitBlue   guifg=blue   guibg=" .. statusbar_bg)
--     vim.cmd("highlight GitPurple guifg=purple guibg=" .. statusbar_bg)
--     vim.cmd("highlight GitPink   guifg=pink   guibg=" .. statusbar_bg)
-- end

-- Function to define Vim's highlight groups for Vim modes
-- local function setup_vim_highlights()
--     local statusbar_bg = get_statusline_bg()
--     vim.cmd("highlight VimNormal guifg=" .. statusbar_bg .. " guibg=white")
--     vim.cmd("highlight VimInsert guifg=" .. statusbar_bg .. " guibg=green")
--     vim.cmd("highlight VimVisual guifg=" .. statusbar_bg .. " guibg=blue")
--     vim.cmd("highlight VimReplace guifg=" .. statusbar_bg .. " guibg=red")
--     vim.cmd("highlight VimCommand guifg=" .. statusbar_bg .. " guibg=yellow")
--     vim.cmd("highlight VimSelect guifg=" .. statusbar_bg .. " guibg=purple")
--
--     vim.cmd("highlight VimNormalSeparator guifg=white guibg=" .. statusbar_bg)
--     vim.cmd("highlight VimInsertSeparator guifg=green guibg=" .. statusbar_bg)
--     vim.cmd("highlight VimVisualSeparator guifg=blue guibg=" .. statusbar_bg)
--     vim.cmd("highlight VimReplaceSeparator guifg=red guibg=" .. statusbar_bg)
--     vim.cmd("highlight VimCommandSeparator guifg=yellow guibg=" .. statusbar_bg)
--     vim.cmd("highlight VimSelectSeparator guifg=purple guibg=" .. statusbar_bg)
-- end

-- setup_git_highlights()
-- setup_vim_highlights()

-- Re-setup highlights when a colorscheme is loaded/changed.
-- vim.api.nvim_create_autocmd("ColorScheme", {
--     callback = function()
--         setup_git_highlights()
--     end,
-- })

-- Helper function to determine Git status color
-- local function get_git_status_color()
--     -- Get remote status (commits behind and ahead relative to upstream)
--     local output = vim.fn.system("git rev-list --left-right --count @{u}...HEAD 2>/dev/null")
--     output = vim.trim(output)
--     local behind, ahead = 0, 0
--     if output ~= "" and not output:match("fatal:") then
--         behind, ahead = output:match("^(%d+)%s+(%d+)$")
--         behind        = tonumber(behind) or 0
--         ahead         = tonumber(ahead) or 0
--     end
--
--     -- Check for local changes (unstaged or staged)
--     local diff_status = vim.fn.system("git diff --quiet && git diff --cached --quiet && echo clean || echo dirty")
--     diff_status = vim.trim(diff_status)
--     local local_changes = (diff_status == "dirty")
--
--     if behind == 0 and ahead == 0 then
--         if local_changes then
--             return "%#GitYellow#"
--         else
--             return "%#GitGreen#"
--         end
--     elseif behind > 0 and ahead == 0 then
--         return "%#GitRed#"
--     elseif behind == 0 and ahead > 0 then
--         return "%#GitBlue#"
--     elseif behind > 0 and ahead > 0 then
--         if local_changes then
--             return "%#GitPink#"
--         else
--             return "%#GitPurple#"
--         end
--     end
--     -- Fallback to green if something unexpected happens.
--     return "%#GitGreen#"
-- end

-- Function to get the current vim mode color
-- local function get_vim_mode_color()
--     local mode = vim.fn.mode()
--     if mode == "n" then
--         return "%#VimNormal#"
--     elseif mode == "i" then
--         return "%#VimInsert#"
--     elseif mode == "v" or mode == "V" or mode == "\22" then
--         return "%#VimVisual#"
--     elseif mode == "r" or mode == "Rv" then
--         return "%#VimReplace#"
--     elseif mode == "c" then
--         return "%#VimCommand#"
--     elseif mode == "s" or mode == "S" then
--         return "%#VimSelect#"
--     end
--     return "%#VimNormal#"
-- end

-- Function to get the separator color
-- local function get_vim_separator_color()
--     local mode = vim.fn.mode()
--     if mode == "n" then
--         return "%#VimNormalSeparator#"
--     elseif mode == "i" then
--         return "%#VimInsertSeparator#"
--     elseif mode == "v" or mode == "V" or mode == "\22" then
--         return "%#VimVisualSeparator#"
--     elseif mode == "r" or mode == "Rv" then
--         return "%#VimReplaceSeparator#"
--     elseif mode == "c" then
--         return "%#VimCommandSeparator#"
--     elseif mode == "s" or mode == "S" then
--         return "%#VimSelectSeparator#"
--     end
--     return "%#VimNormalSeparator#"
-- end

-- Function to get colored and formatted Vim mode string
-- local function get_vim_mode_string()
--     local mode = vim.fn.mode()
--     local vimColor = get_vim_mode_color()
--     local vimSeparatorColor = get_vim_separator_color()
--
--     if mode == "n" then
--         return vimColor .. " NORMAL " .. vimSeparatorColor .. " "
--     elseif mode == "i" then
--         return vimColor .. " INSERT " .. vimSeparatorColor .. " "
--     elseif mode == "v" or mode == "V" or mode == "\22" then
--         return vimColor .. " VISUAL " .. vimSeparatorColor .. " "
--     elseif mode == "r" or mode == "Rv" then
--         return vimColor .. " REPLACE " .. vimSeparatorColor .. " "
--     elseif mode == "c" then
--         return vimColor .. " COMMAND " .. vimSeparatorColor .. " "
--     elseif mode == "s" or mode == "S" then
--         return vimColor .. " SELECT " .. vimSeparatorColor .. " "
--     end
--     return vimColor .. " NORMAL " .. vimSeparatorColor .. " "
-- end

-- Define a function to get the current git branch name
-- local function GitGetCurrentBranch()
--     -- Execute the git command and capture its output
--     local branch_name = vim.fn.system("git rev-parse --abbrev-ref HEAD")
--     -- If the output contains "fatal: not a git repository", return an empty string
--     if branch_name:find("fatal: not a git repository") then
--         return ""
--     end
--     -- Trim whitespace/newlines from the branch name
--     branch_name = vim.trim(branch_name)
--     -- Return the branch name formatted with surrounding parentheses and a trailing space
--     return "(" .. branch_name .. ") "
-- end

-- Define a function to set the statusline with Git branch info
-- local function set_statusline()
--     local branch = GitGetCurrentBranch()
--     local vimModeString = get_vim_mode_string()
--
--     if branch ~= "" then
--         local gitColor = get_git_status_color()
--         local abbreviateBranch = abbreviateString(branch, 40)
--
--         vim.opt_local.statusline = vimModeString ..
--             gitColor .. abbreviateBranch .. "%#StatusLine#" .. "%<%f%h%m%r%=%-14.(%l,%c%V%) %P"
--     else
--         vim.opt_local.statusline = vimModeString .. "%<%f%h%m%r%=%-14.(%l,%c%V%) %P"
--     end
-- end

-- Create an autocommand to update the statusline whenever vim status changes
-- vim.api.nvim_create_autocmd("ModeChanged", {
--     group = ThePrimeagenGroup,
--     callback = function()
--         set_statusline()
--     end,
-- })


-- Create an augroup to avoid duplicate autocommands
local group = vim.api.nvim_create_augroup("GitBranchStatusline", { clear = true })

-- Create an autocommand that triggers on BufEnter
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "CursorHold", "FocusGained" }, {
    group = group,
    callback = function()
        -- Change the local directory to the directory of the current file
        --vim.cmd("lcd %:p:h")
    end,
})
