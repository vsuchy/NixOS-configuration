---------------
--- General ---
---------------

--- Local aliases ---

local api = vim.api
local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local map = vim.keymap.set
local opt = vim.opt

--- Files / History ---

opt.history = 0       -- A history of ":" commands, and a history of previous search patterns.
opt.shada = ""        -- The shada file is not read and written.
opt.swapfile = false  -- Don't use a swapfile.

--- Text formatting ---

opt.expandtab = true    -- Use the appropriate number of spaces to insert a <Tab>.
opt.shiftwidth = 2      -- Number of spaces to use for each step of (auto)indent.
opt.smartindent = true  -- Do smart autoindenting when starting a new line.
opt.softtabstop = 2     -- Number of spaces that a <Tab> counts for while performing editing operations.
opt.tabstop = 2         -- Number of spaces that a <Tab> in the file counts for.

--- UI ---

opt.cursorline = true     -- Highlight the text line of the cursor.
opt.number = true         -- Print the line number in front of each line.
opt.showmatch = true      -- When a bracket is inserted, briefly jump to the matching one.
opt.showmode = false      -- Don't put a message on the last line.
opt.signcolumn = "yes:1"  -- Always draw the signcolumn with fixed space.
opt.wrap = false          -- Lines will not wrap.

--- Search ---

opt.ignorecase = true  -- Ignore case in search patterns.
opt.smartcase = true   -- Override "ignorecase" option if the search pattern contains upper case characters.

--- Clipboard ---

opt.clipboard = "unnamedplus"  -- Use the system's clipboard.

--- LSP ---

vim.diagnostic.config({
  update_in_insert = true,
  virtual_text = true
})

--------------------
--- Key bindings ---
--------------------

g.mapleader = " "

map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next Buffer", silent = true })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous Buffer", silent = true })

---------------------
--- Auto commands ---
---------------------

local group = api.nvim_create_augroup("UserConfigAutoCmds", { clear = true })

--- Normalize whitespace ---

api.nvim_create_autocmd("BufWritePre", {
  group = group,
  callback = function()
    if not vim.bo.binary and vim.bo.filetype ~= "diff" then
      cmd("retab")

      local view = fn.winsaveview()
      cmd([[keeppatterns %s/\s\+$//e]])
      fn.winrestview(view)
    end
  end
})

---------------
--- Plugins ---
---------------

--- mini.nvim: Library of independent modules ---

require("mini.move").setup({
  mappings = {
    up = "<S-Up>",
    down = "<S-Down>",
    left = "<S-Left>",
    right = "<S-Right>",

    line_up = "<S-Up>",
    line_down = "<S-Down>",
    line_left = "<S-Left>",
    line_right = "<S-Right>"
  }
})

require("mini.pick").setup({
  window = {
    config = function()
      local ui = api.nvim_list_uis()[1]
      local width = math.floor(ui.width * 0.75)
      local height = math.floor(ui.height * 0.75)

      return {
        relative = "editor",
        anchor = "NW",
        width = width,
        height = height,
        col = math.floor((ui.width - width) / 2),
        row = math.floor((ui.height - height) / 2)
      }
    end
  }
})

require("mini.extra").setup({})
require("mini.pairs").setup({})
require("mini.splitjoin").setup({})
require("mini.surround").setup({})

--- dracula.nvim: Dracula colorscheme ---

require("dracula").setup({
  italic_comment = true
})

cmd("colorscheme dracula")

--- blink.cmp: Completion plugin ---

require("blink.cmp").setup({
  fuzzy = {
    frecency = {
      enabled = false
    }
  },
  keymap = {
    preset = "enter"
  }
})

--- gitsigns.nvim: Git integration for buffers ---

require("gitsigns").setup({})

--- grug-far.nvim: Find and replace ---

require("grug-far").setup({
  windowCreationCommand = "split",

  engines = {
    ripgrep = {
      placeholders = {
        enabled = false
      }
    }
  },
  helpLine = {
    enabled = false
  }
})

--- lualine.nvim: Statusline plugin ---

require("lualine").setup({
  options = {
    icons_enabled = false,
    theme = "dracula-nvim"
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "filename" },
    lualine_c = { "branch", "diff", "diagnostics" },
    lualine_x = {},
    lualine_y = { "encoding", "fileformat", "filetype" },
    lualine_z = { "location" }
  },
  inactive_sections = {
    lualine_a = { "filename" },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {
    lualine_z = { "buffers" }
  }
})

--- render-markdown.nvim: Improve viewing markdown files ---

require("render-markdown").setup({
  completions = {
    lsp = {
      enabled = true
    }
  }
})

--- nvim-treesitter: Treesitter configurations and abstraction layer ---

api.nvim_create_autocmd("FileType", {
  callback = function()
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
})

--- LSP Setup ---

local lsp = vim.lsp

lsp.log.set_level(vim.log.levels.OFF)

lsp.config("*", { root_markers = { ".git" } })

lsp.config("bashls", {
  cmd = { "bash-language-server", "start" },
  filetypes = { "bash", "sh" }
})

lsp.config("jsonls", {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" }
})

lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json" }
})

lsp.config("rubocop", {
  cmd = { "rubocop", "--lsp" },
  filetypes = { "ruby" },
  root_markers = { "Gemfile" }
})

lsp.enable({ "bashls", "jsonls", "lua_ls", "rubocop" })
