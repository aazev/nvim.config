local ts_languages = {
    "vimdoc",
    "javascript",
    "typescript",
    "c",
    "lua",
    "rust",
    "jsdoc",
    "bash",
    "go",
    "templ",
}

local function should_disable_treesitter(buf, lang)
    if lang == "html" then
        return true
    end

    local max_filesize = 100 * 1024 -- 100 KB
    local filename = vim.api.nvim_buf_get_name(buf)

    if filename == "" then
        return false
    end

    local ok, stats = pcall(vim.uv.fs_stat, filename)

    if ok and stats and stats.size > max_filesize then
        vim.notify(
            "File larger than 100KB; treesitter disabled for performance",
            vim.log.levels.WARN,
            { title = "Treesitter" }
        )

        return true
    end

    return false
end

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },

        config = function()
            -- New main-branch API.
            require("nvim-treesitter").setup({
                install_dir = vim.fn.stdpath("data") .. "/site",
            })

            -- Custom parser registration must happen through TSUpdate autocmd on main.
            vim.api.nvim_create_autocmd("User", {
                pattern = "TSUpdate",
                callback = function()
                    require("nvim-treesitter.parsers").templ = {
                        install_info = {
                            url = "https://github.com/vrischmann/tree-sitter-templ.git",
                            files = { "src/parser.c", "src/scanner.c" },
                            branch = "master",
                        },
                    }
                end,
            })

            vim.treesitter.language.register("templ", "templ")

            -- Replacement for old ensure_installed.
            require("nvim-treesitter").install(ts_languages)

            -- Replacement for old highlight.enable / indent.enable.
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    local buf = args.buf
                    local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)

                    if not lang then
                        return
                    end

                    if should_disable_treesitter(buf, lang) then
                        return
                    end

                    local ok = pcall(vim.treesitter.start, buf, lang)

                    if not ok then
                        return
                    end

                    -- Replacement for old indent.enable = true.
                    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

                    -- Similar intent to your old additional_vim_regex_highlighting = { "markdown" }.
                    if lang == "markdown" then
                        vim.bo[buf].syntax = "ON"
                    end
                end,
            })
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter-context",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("treesitter-context").setup({
                enable = true,
                multiwindow = false,
                max_lines = 20,
                min_window_height = 0,
                line_numbers = true,
                multiline_threshold = 20,
                trim_scope = "outer",
                mode = "cursor",
                separator = nil,
                zindex = 20,
                on_attach = nil,
            })
        end,
    },
}
