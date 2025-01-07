local opt = vim.opt

-- General indentation settings
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.number = true
opt.relativenumber = true

-- Example of filetype-specific indentation via an autocmd
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    {
      {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
          require("nvim-tree").setup()      -- Basic setup
          vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>")
        end
      },
      {
        "nvim-treesitter/nvim-treesitter", 
        build = ":TSUpdate",
        config = function()
          local configs = require("nvim-treesitter.configs")

          configs.setup({ 
            ensure_installed = { "rust", "html", "javascript", "typescript" , "lua"},
            highlight = { enable = true },
            indent = { enable = true },
          })
        end,
      },
      {
        "neovim/nvim-lspconfig",
        config = function()
          require("lspconfig").rust_analyzer.setup({})
        end,
      },
      {
        'hrsh7th/nvim-cmp',
        config = function()
          local cmp = require'cmp'

          cmp.setup({
            sources = {
              { name = 'nvim_lsp' },
              { name = 'buffer' },
              { name = 'path' },
            },
            mapping = {
              ['<C-Space>'] = cmp.mapping.complete(),
              ['<CR>'] = cmp.mapping.confirm({ select = true }),
              ['<Tab>'] = cmp.mapping.select_next_item(),
              ['<S-Tab>'] = cmp.mapping.select_prev_item(),
            },
          })
        end
      },
      'hrsh7th/cmp-nvim-lsp',   -- LSP support
      'hrsh7th/cmp-buffer',     -- Buffer completions
      'hrsh7th/cmp-path',
    }
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
