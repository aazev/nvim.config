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
        local opts = { buffer = e.buf }
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

-- Define highlight groups for the Git status colors
vim.cmd("highlight GitGreen  guifg=green  guibg=none")
vim.cmd("highlight GitYellow guifg=yellow guibg=none")
vim.cmd("highlight GitRed    guifg=red    guibg=none")
vim.cmd("highlight GitBlue   guifg=blue   guibg=none")
vim.cmd("highlight GitPurple guifg=purple guibg=none")
vim.cmd("highlight GitPink   guifg=pink   guibg=none")

-- Helper function to determine Git status color
local function get_git_status_color()
    -- Get remote status (commits behind and ahead relative to upstream)
    local output = vim.fn.system("git rev-list --left-right --count @{u}...HEAD 2>/dev/null")
    output = vim.trim(output)
    local behind, ahead = 0, 0
    if output ~= "" and not output:match("fatal:") then
        behind, ahead = output:match("^(%d+)%s+(%d+)$")
        behind        = tonumber(behind) or 0
        ahead         = tonumber(ahead) or 0
    end

    -- Check for local changes (unstaged or staged)
    local diff_status = vim.fn.system("git diff --quiet && git diff --cached --quiet && echo clean || echo dirty")
    diff_status = vim.trim(diff_status)
    local local_changes = (diff_status == "dirty")

    if behind == 0 and ahead == 0 then
        if local_changes then
            return "%#GitYellow#"
        else
            return "%#GitGreen#"
        end
    elseif behind > 0 and ahead == 0 then
        return "%#GitRed#"
    elseif behind == 0 and ahead > 0 then
        return "%#GitBlue#"
    elseif behind > 0 and ahead > 0 then
        if local_changes then
            return "%#GitPink#"
        else
            return "%#GitPurple#"
        end
    end
    -- Fallback to green if something unexpected happens.
    return "%#GitGreen#"
end

-- Define a function to get the current git branch name
local function GitGetCurrentBranch()
    -- Execute the git command and capture its output
    local branch_name = vim.fn.system("git rev-parse --abbrev-ref HEAD")
    -- If the output contains "fatal: not a git repository", return an empty string
    if branch_name:find("fatal: not a git repository") then
        return ""
    end
    -- Trim whitespace/newlines from the branch name
    branch_name = vim.trim(branch_name)
    -- Return the branch name formatted with surrounding parentheses and a trailing space
    return "(" .. branch_name .. ") "
end

-- Define a function to set the statusline with Git branch info
local function set_statusline_with_branch()
    local branch = GitGetCurrentBranch()
    if branch ~= "" then
        local color = get_git_status_color()
        vim.opt_local.statusline = color .. branch .. "%#StatusLine#" .. "%<%f%h%m%r%=%-14.(%l,%c%V%) %P"
    else
        vim.opt_local.statusline = "%<%f%h%m%r%=%-14.(%l,%c%V%) %P"
    end
end

-- Create an augroup to avoid duplicate autocommands
local group = vim.api.nvim_create_augroup("GitBranchStatusline", { clear = true })

-- Create an autocommand that triggers on BufEnter
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "CursorHold", "FocusGained" }, {
    group = group,
    callback = function()
        -- Change the local directory to the directory of the current file
        --vim.cmd("lcd %:p:h")
        -- Update the statusline with the Git branch information
        set_statusline_with_branch()
    end,
})
