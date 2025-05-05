vim.opt.syntax = "on"

function Pretty_folding()
  local begin = vim.fn.getline(vim.v.foldstart)
  local bottom = vim.fn.getline(vim.v.foldend):gsub("^%s*(.-)%s*$", "%1")
  local lines = vim.v.foldend - vim.v.foldstart
  return begin .. "... " .. lines .. " lines ..." .. bottom
end

vim.opt.encoding = "utf-8" -- Use default encoding UTF-8 for all files
vim.opt.expandtab = true -- Transforms tab \t to spaces
vim.opt.shiftwidth = 2 -- Size of use >> and <<, ctrl-t and ctrl-d (i) to 2
vim.opt.softtabstop = 2 -- Amount of tabs added (i)
vim.opt.tabstop = 2 -- Size of tab
vim.opt.shiftround = true -- When press tab, set the spaces when press tab to round of shiftwidth multiplier

vim.opt.smartindent = true -- Automatic indent for some file types
vim.opt.foldmethod = "expr" -- use treesitter or maybe "indent"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevelstart = 99 -- Begin with 2 levels of nested folds
vim.opt.foldenable = false -- Don't fold the content when open a file
vim.opt.foldtext = "v:lua.Pretty_folding()"
vim.opt.hlsearch = true -- Highlight the matchs of a search
vim.opt.ignorecase = true -- Ignore case when search
vim.opt.incsearch = true -- Move screen to matched search
vim.opt.showmatch = true -- Show the match bracket {} () []

vim.opt.list = true -- Show control chars
vim.opt.listchars = "tab: >,trail:·" -- Change tab and trails chars
vim.opt.number = true -- Show the numbers of lines
-- vim.opt.cursorline=true                -- Add a bar in current line of cursor
-- vim.opt.cursorcolumn=true              -- Set cursor column

vim.opt.wildmenu = true -- Activate the interactive autocomplete in statusline
vim.opt.wildmode = "longest:full" -- Complete with best match and show options in statusline
vim.opt.laststatus = 2 -- Always show the status line in windows

vim.g.netrw_sizestyle = "H" -- Humanable size of files
vim.g.netrw_list_hide = "^..+" -- Hide the hidden files

vim.opt.completeopt = "menu,menuone,noselect"

vim.g.mapleader = ";" -- leader key

-- Remaps
vim.api.nvim_set_keymap('n', '<space>', ':nohlsearch<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-y>', '3<C-Y>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-e>', '3<C-E>', { noremap = true })
vim.api.nvim_set_keymap('v', '<C-y>', '3<C-Y>', { noremap = true })
vim.api.nvim_set_keymap('v', '<C-e>', '3<C-E>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-w>e', ':Explore<CR>', { noremap = true })

require('packer').startup(function()
  -- Packer manage itself
  use 'wbthomason/packer.nvim'

  -- LSP
  use {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    'neovim/nvim-lspconfig',
  }

  -- Completion
  use {
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-buffer',
    'saadparwaiz1/cmp_luasnip',
  }

  -- Syntax
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }

  -- Snipets
  use {
    'L3MON4D3/LuaSnip'
  }

  -- File navigation
  use {
    'nvim-telescope/telescope.nvim',
    requires = { { 'nvim-lua/plenary.nvim' } }
  }

  -- File explorer
  -- use {
  --   'nvim-tree/nvim-tree.lua',
  --   requires = {
  --     'nvim-tree/nvim-web-devicons', -- optional, for file icons
  --   },
  -- }

  -- colorscheme
  use {
    'sainnhe/sonokai',
  }
end)

vim.cmd("colorscheme sonokai")

-- clipboard
-- vim.g.clipboard = {
--   name = 'wsl',
--   copy = { ["+"] = { "clip.exe" }, ["*"] = { "clip.exe" } },
-- }

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local cmp = require('cmp')
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "path" },
    { name = 'luasnip' },
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
})

-- syntax
local treesitter = require('nvim-treesitter.configs')
treesitter.setup {
  -- A list of parser names, or "all"
  ensure_installed = { "lua", "hcl", "typescript", "javascript", "tsx", "python" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    additional_vim_regex_highlighting = false,
  },
}

require("mason").setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

require("mason-lspconfig").setup {
    ensure_installed = { "efm", "lua_ls", 'ts_ls', 'cssls', 'html', 'terraformls', 'pyright', 'bashls', "yamlls" },
}


local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '<leader>z', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', '<leader>x', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- keymaps when lsp starts

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(_, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', '<leader>gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', '<leader>K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<leader><C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<leader>f', vim.lsp.buf.formatting, bufopts)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

local lspconfig = require('lspconfig')
lspconfig['lua_ls'].setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' }
      }
    }
  }
}
-- generic lsp setup
for _, lang in pairs({ 'ts_ls', 'cssls', 'html', 'terraformls', 'pyright', 'bashls' }) do
  lspconfig[lang].setup({
    on_attach = on_attach,
    capabilities = capabilities,
  });
end

lspconfig['yamlls'].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      yaml = {
        schemas = {
          ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/refs/heads/master/v1.31.1-standalone-strict/all.json"] = "*/*.k8s.yaml",
          ["https://raw.githubusercontent.com/ansible/ansible-lint/refs/heads/main/src/ansiblelint/schemas/playbook.json"] = "*/*.playbook.yaml",
        }
      }
    }
}

lspconfig['efm'].setup({
  init_options = { documentFormatting = true },
  settings = {
    languages = {
      terraform = {
        { formatCommand = "terraform fmt" }
      },
      python = {
        { formatCommand = "black --quiet -", formatStdin = true },
        { formatCommand = "isort --quiet -", formatStdin = true },
        {
          lintCommand = "pylint --output-format text --score no --msg-template {path}:{line}:{column}:{C}:{msg} ${INPUT}",
          lintStdin = false,
          lintFormats = { "%f:%l:%c:%t:%m" },
          lintOffsetColumns = 1,
          lintIgnoreExitCode = true,
          lintCategoryMap = {
            I = "H",
            R = "I",
            C = "I",
            W = "W",
            E = "E",
            F = "E",
          }
        }
      }
    },
    filetypes = { "terraform", "python" }
  }
})

-- Telescope

vim.api.nvim_set_keymap('n', '<C-f>', ':Telescope find_files<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-b>', ':Telescope buffers<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-g>', ':Telescope live_grep<CR>', { noremap = true })

-- Snipets
luasnip.add_snippets('all', {
  luasnip.snippet("ternary", {
    luasnip.insert_node(1, "cond"), luasnip.text_node(" ? "), luasnip.insert_node(2, "then"), luasnip.text_node(" : "),
    luasnip.insert_node(3, "else") }
  )
})

luasnip.add_snippets('javascript', {
  luasnip.snippet('func', {
    luasnip.text_node("const "),
    luasnip.insert_node(1, "fn"),
    luasnip.text_node(" = ("),
    luasnip.insert_node(2, "param"),
    luasnip.text_node(") => {"),
    luasnip.insert_node(3),
    luasnip.text_node({ " };", " " }),
  }),
})
luasnip.add_snippets('typescriptreact', {
  luasnip.snippet('cfn', {
    luasnip.text_node("const "),
    luasnip.insert_node(1, "Component"),
    luasnip.text_node({ " = ({}) => {", "", "  return (", "" }),
    luasnip.insert_node(0),
    luasnip.text_node({ "", "  );", "};", "", "export default ", }),
    luasnip.function_node(function(args)
      return args[1][1]
    end, { 1 }, {}),
    luasnip.text_node(";")
  }),
  luasnip.snippet('fn', {
    luasnip.text_node("const "),
    luasnip.insert_node(1, "fn"),
    luasnip.text_node(" = ("),
    luasnip.insert_node(2, "param"),
    luasnip.text_node(") => {"),
    luasnip.insert_node(3),
    luasnip.text_node({ "};", " " }),
  }),
  luasnip.snippet('jsx', {
    luasnip.text_node("<"),
    luasnip.insert_node(1, "component"),
    luasnip.text_node(" "),
    luasnip.insert_node(2, "props"),
    luasnip.text_node({ ">", "" }),
    luasnip.insert_node(0),
    luasnip.text_node({ "", "</" }),
    luasnip.function_node(function(args)
      return args[1][1]
    end, { 1 }, {}),
    luasnip.text_node(">")
  }),
  luasnip.snippet('html', {
    luasnip.text_node("<"),
    luasnip.insert_node(1, "tag"),
    luasnip.insert_node(2, " prop"),
    luasnip.text_node(">"),
    luasnip.insert_node(0),
    luasnip.text_node("</"),
    luasnip.function_node(function(args)
      return args[1][1]
    end, { 1 }, {}),
    luasnip.text_node(">")
  })
})
