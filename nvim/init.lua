-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/site/pack/lazy/start/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        lazypath
    })
end
vim.opt.rtp:prepend(lazypath)


-- Set space as the leader key
vim.g.mapleader = " "

-- Basic Settings
vim.opt.number = true
vim.opt.mouse = ""
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.clipboard = "unnamedplus"

-- Use spaces, not literal tabs
vim.opt.expandtab = true

-- 1 indentation level = 4 spaces
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

-- Better colors in modern terminals
vim.o.termguicolors = true

require("lazy").setup({
    -- Colorscheme
    { 
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("tokyonight").setup({
                style = "moon",
                styles = {
                    sidebars = "dark",
                    floats = "dark"
                },
                on_highlights = function(hl, c)
                    hl.LineNr = { fg = c.comment }
                    hl.CursorLineNr = { fg = c.orange, bold = true}
                end,
            })

            vim.cmd([[colorscheme tokyonight]])
        end,
    },

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local telescope = require("telescope")
            local builtin = require("telescope.builtin")

            telescope.setup({
                defaults = {
                    prompt_prefix = "❯ ",
                    selection_caret = "➤ ",
                    path_display = { "smart" }
                }
            })

            vim.keymap.set("n", "<leader>ff", builtin.find_files, {desc = "Find files" })
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, {desc = "Live grep" })
            vim.keymap.set("n", "<leader>fb", builtin.buffers, {desc = "Buffers" })
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, {desc = "Help" })

        end,
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        opts = {
            ensure_installed = {
                "lua", "python", "c", "cpp", "bash", "json", "markdown"
            },
            highlight = { enable = true },
            indent = { enable = true},
        }
    },

    -- Iron.NVIM
    {
        "Vigemus/iron.nvim",
        config = function()
            local iron = require("iron.core")
            local view = require("iron.view")
            
            iron.setup({
                config = {
                    repl_definition = {
                        python = {
                            -- --no autoindent helps when sending indented blocks
                            command = {"ipython", "--no-autoindent" },
                        },
                },
                repl_open_cmd = view.split.vertical.rightbelow(90),
            },
            keymaps = {
                send_line = "<leader>sl",
                visual_send = "<leader>ss",
                send_motion = "<leader>sc",
                cr = "<leader>s<cr>",
                interrupt = "<leader>si",
                exit = "<leader>sq",
                clear = "<leader>sx",
            },
            ignore_blank_lines = true,
            })
        
            -- REPL Control
            vim.keymap.set("n", "<leader>rs", "<cmd>IronRepl<cr>", { desc = "Start IPython REPL" })
            vim.keymap.set("n", "<leader>rf", "<cmd>IronFocus<cr>", { desc = "Focus REPL" })
            vim.keymap.set("n", "<leader>rh", "<cmd>IronHide<cr>", { desc = "Hide REPL" })
            vim.keymap.set("n", "<leader>rr", "<cmd>IronRestart<cr>", { desc = "Restart REPL" })
        end,
    },
    
    -- Lint
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local lint = require("lint")

            -- Use Ruff for Python
            lint.linters_by_ft = {
                python = { "ruff" },
            }

            -- When to go linting
            local group = vim.api.nvim_create_augroup("Linting", { clear = true })
            vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
                group = group,
                callback = function()
                    -- try_lint() wont' throw if no linter is configured
                    lint.try_lint()
                end,
            })

            -- Keymap to run lint manually
            vim.keymap.set("n", "<leader>l", function()
                lint.try_lint()
            end, {desc = "Lint current file" })
        end,
    },
    
    -- LSP: mason + lspconfig
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        config = true,
    },
    
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = { "pyright", "ruff" },
        },
    },
    
    {
        "neovim/nvim-lspconfig",
        dependencies = { "williamboman/mason-lspconfig.nvim" },
        config = function()
            local lspconfig = require("lspconfig")

            -- Pyright: types + intelligence
            lspconfig.pyright.setup({})

            -- Ruff: lint + code actions (+optional formatting)
            lspconfig.ruff.setup({})

            -- Useful LSP Keymaps
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
            vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "References" })
            vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })

            -- Diagnostics
            vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Line diagnostics" })
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
        end,
    }
})

-- Keymaps 
vim.keymap.set("n", "<leader>w", ":w<CR>")
