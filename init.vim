
" init.vim

" Specify the location of the Plug.vim script
call plug#begin('~/.config/nvim/plugged')

Plug 'rebelot/kanagawa.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

" For vsnip users.
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.x' }

Plug 'stevearc/dressing.nvim'
Plug 'sindrets/diffview.nvim'

Plug 'lukas-reineke/indent-blankline.nvim'

Plug 'lewis6991/gitsigns.nvim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'tpope/vim-fugitive'
Plug 'dense-analysis/ale'
Plug 'SmiteshP/nvim-navic'
Plug 'ray-x/lsp_signature.nvim'
Plug 'ThePrimeagen/harpoon'


" End of Plug configuration
call plug#end()

colorscheme kanagawa
set number

let g:indent_blankline_char_highlight = 'LineNr'
let g:indent_blankline_char = '▏'
let g:indent_blankline_space_char_highlight = 'LineNr'
let g:ale_linters = {
      \ 'python': ['pylint', 'flake8', 'mypy'],
      \ }
let g:diffview_external_difftool = 'git diff'





" Set transparency
"highlight IndentBlanklineChar ctermbg=NONE guibg=NONE ctermfg=Grey guifg=Grey gui=NONE 
"highlight IndentBlanklineSpaceChar ctermbg=NONE guibg=NONE ctermfg=Grey guifg=Grey gui=NONE 
highlight IndentBlanklineChar guifg=#CC5500
highlight IndentBlanklineSpaceChar guifg=#CC5500
"let g:indent_blankline_use_treesitter = v:true " if you have treesitter installed

augroup myDiffviewConfig
  autocmd!
  autocmd FileType git diffview
augroup END

autocmd BufNewFile,BufRead *.py set keywordprg=pydoc3.8



lua << EOF
  require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the five listed parsers should always be installed)
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  -- List of parsers to ignore installing (or "all")
  ignore_install = { "javascript" },

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    disable = { "c", "rust" },
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
    disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      ['<Tab>'] = cmp.mapping.select_next_item(),
      ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
      { name = 'treesitter'},	
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  
-- set termguicolors to enable highlight groups
  vim.opt.termguicolors = true

-- empty setup using defaults 
  
  -- Set up lspconfig.
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  require('lspconfig').pyright.setup {
  capabilities = capabilities
 }

  local navic = require("nvim-navic")

  require("lspconfig").clangd.setup {
    on_attach = function(client, bufnr)
        navic.attach(client, bufnr)
    end
  }

  require('lspconfig').rust_analyzer.setup{}

  local cfg = {}  -- add your config here
  require "lsp_signature".setup(cfg)
  
  vim.cmd("source ~/.config/nvim/my_keybinds.lua") 

  require('lspconfig').cssls.setup{
    cmd = {'css-languageserver', '--stdio'},
    capabilities = capabilities,
  }


  local tf_capabilities = vim.lsp.protocol.make_client_capabilities()
  tf_capabilities.textDocument.completion.completionItem.snippetSupport = true
  require('lspconfig').terraformls.setup{
	cmd = {'terraform-ls', 'serve'},
    filetypes = {'terraform', 'hcl', 'tf', 'tfvars'},
  	capabilities = tf_capabilities,
    root_dir = function(fname)
        return vim.fn.getcwd()
    end,
  }

EOF


set laststatus=2
let g:airline_extensions = ['hunks', 'branch', 'tabline']
let g:airline_powerline_fonts=1
let g:airline_theme='wombat'
hi Normal guibg=NONE ctermbg=NONE
hi NonText guibg=NONE ctermbg=NONE
hi SignColumn guibg=NONE ctermbg=NONE
hi VertSplit guibg=NONE ctermbg=NONE
hi StatusLine guibg=NONE ctermbg=NONE
hi StatusLineNC guibg=NONE ctermbg=NONE
hi StatusLineTerm guibg=NONE ctermbg=NONE
hi StatusLineTermNC guibg=NONE ctermbg=NONE
