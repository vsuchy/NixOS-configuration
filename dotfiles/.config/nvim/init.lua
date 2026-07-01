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

--- mini.deps: Plugin manager ---

local packages_path = fn.stdpath("data") .. "/site/"
local mini_path = packages_path .. "pack/deps/start/mini.nvim"

if not vim.uv.fs_stat(mini_path) then
  cmd("echo 'Installing mini.nvim' | redraw")

  local clone_cmd = { "git", "clone", "--filter=blob:none", "--branch", "stable", "https://github.com/nvim-mini/mini.nvim", mini_path }

  fn.system(clone_cmd)
  cmd("packadd mini.nvim | helptags ALL")
  cmd("echo 'Installed mini.nvim' | redraw")
end

require("mini.deps").setup({
  path = {
    package = packages_path
  }
})

local add = MiniDeps.add
local later = MiniDeps.later
local now = MiniDeps.now

--- mini.nvim: Library of independent modules ---

later(function()
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
end)

--- dracula.nvim: Dracula colorscheme ---

now(function()
  add({
    source = "Mofiqul/dracula.nvim",
    checkout = "ae752c1"
  })

  require("dracula").setup({
    italic_comment = true
  })

  cmd("colorscheme dracula")
end)

--- LSP Setup ---

now(function()
  --- LSP configuration ---

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

  --- mason.nvim: Easily install and manage LSP servers, ... ---

  add({
    source = "mason-org/mason.nvim",
    checkout = "v2.2.1"
  })

  require("mason").setup({
    log_level = vim.log.levels.OFF,

    ui = {
      check_outdated_packages_on_open = false
    }
  })

  --- Install LSP packages ---

  local registry = require("mason-registry")
  registry.refresh()

  local function ensure_installed(package)
    if not registry.is_installed(package) then
      local p = registry.get_package(package)
      p:install()
    end
  end

  ensure_installed("bash-language-server")
  ensure_installed("shellcheck")
  ensure_installed("json-lsp")
  ensure_installed("lua-language-server")
  ensure_installed("rubocop")
end)

--- nvim-treesitter: Treesitter configurations and abstraction layer ---

later(function()
  add({
    source = "nvim-treesitter/nvim-treesitter",
    checkout = "4916d65",
    hooks = { post_checkout = function() cmd("TSUpdate") end }
  })

  api.nvim_create_autocmd("FileType", {
    callback = function()
      pcall(vim.treesitter.start)
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  })
end)

--- blink.cmp: Completion plugin ---

later(function()
  add({
    source = "saghen/blink.cmp",
    checkout = "v1.10.2",
    depends = {
      {
        source = "rafamadriz/friendly-snippets",
        checkout = "6cd7280"
      }
    }
  })

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
end)

--- lualine.nvim: Statusline plugin ---

later(function()
  add({
    source = "nvim-lualine/lualine.nvim",
    checkout = "a905eee"
  })

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
end)

--- gitsigns.nvim: Git integration for buffers ---

later(function()
  add({
    source = "lewis6991/gitsigns.nvim",
    checkout = "v2.1.0"
  })

  require("gitsigns").setup({})
end)

--- grug-far.nvim: Find and replace ---

later(function()
  add({
    source = "MagicDuck/grug-far.nvim",
    checkout = "1.6.67"
  })

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
end)

--- render-markdown.nvim: Improve viewing markdown files ---

later(function()
  add({
    source = "MeanderingProgrammer/render-markdown.nvim",
    checkout = "v8.12.0"
  })

  require("render-markdown").setup({
    completions = {
      lsp = {
        enabled = true
      }
    }
  })
end)
