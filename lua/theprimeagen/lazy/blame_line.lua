return {
    "braxtons12/blame_line.nvim",
    cond = function()
        -- Execute the Git command quietly. Returns 0 on success.
        return os.execute("git rev-parse --is-inside-work-tree > /dev/null 2>&1") == 0
    end,
    config = function()
        require("blame_line").setup({
            show_in_visual = true,
            show_in_insert = true,
            prefix = " ",
            template = "<author> • <author-time> • <summary>",
            date = {
                relative = true,
                format = "%d/%m/%Y",
            },
            hl_group = "BlameLineNvim",
            delay = 0
        })
    end,
}
