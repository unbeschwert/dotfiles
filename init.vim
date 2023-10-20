call plug#begin(stdpath('data') . '/plugged')
    
    Plug 'jalvesaq/Nvim-R', {'branch': 'stable'}
    Plug 'vim-latex/vim-latex'
    Plug 'JuliaEditorSupport/julia-vim'
    Plug 'whonore/Coqtail'
    Plug 'ziglang/zig.vim'
    Plug 'itchyny/lightline.vim'
    Plug 'kyazdani42/nvim-tree.lua'
    Plug 'neovim/nvim-lspconfig'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'ray-x/lsp_signature.nvim'
    Plug 'ray-x/aurora'
    Plug 'ray-x/guihua.lua', {'do': 'cd lua/fzy && make' }
    Plug 'ray-x/navigator.lua'
    Plug 'hrsh7th/nvim-cmp'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'L3MON4D3/LuaSnip'
    Plug 'saadparwaiz1/cmp_luasnip'
    Plug 'akinsho/toggleterm.nvim'

call plug#end()

colorscheme aurora
let g:aurora_italic = 1
let g:aurora_transparent = 1
let g:aurora_bold = 1
let g:aurora_darker = 1

" settings for mouse 
set mouse=n

" settings for lightline plugin
set laststatus=2
set noshowmode

" Displays line number
set number

" Moving around 
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l

" Resizing windows
noremap <S-up> :resize +5<CR>
noremap <S-down> :resize -5<CR>
noremap <S-left> :vertical:resize -5<CR>
noremap <S-right> :vertical:resize +5<CR>

" syntax for files
syntax on

" Wrap lines
set wrap

" setting 1 tab == 4 spaces
set tabstop=4 shiftwidth=4
set expandtab 
set smarttab

" Enabling file type plugins
filetype indent on
filetype plugin on

" Reads a file when changed 
" outside
set autoread

" Don't redraw when executing
" macros
set lazyredraw

" Search related
set ignorecase smartcase hlsearch

" Set utf-8 as standard encoding
set encoding=utf8

" folding related
set foldmethod=syntax
set nofoldenable

if &term =~ '^screen'
    " tmux will send xterm-style keys when its xterm-keys option is on
    execute 'set <xUp>=\e[1;*A'
    execute 'set <xDown>=\e[1;*B'
    execute 'set <xRight>=\e[1;*C'
    execute 'set <xLeft>=\e[1;*D'
endif

let mapleader=';'

lua << EOF
    require('nvim-tree').setup {
        view = {
            width = 20,
        },
        renderer = {
            icons = {
                show = {
                    file = false,
                    folder = false,
                    folder_arrow = false
                }
            }
        }
    }

    require('toggleterm').setup {
        direction = 'float',
        open_mapping = [[<C-t>]],
        insert_mapping = true,
        close_on_exit = true
    }
     
    local cmp = require('cmp')
    local luasnip = require('luasnip')
    cmp.setup {
        enabled = function()
            local context = require('cmp.config.context')
            if vim.api.nvim_get_mode().mode == 'c' then
                return true
            else
                return not context.in_treesitter_capture("comment") and
                    not context.in_syntax_group("Comment")
            end
        end,
        snippet = {
            expand = function(args) require('luasnip').lsp_expand(args.body) end
        },
        mapping = cmp.mapping.preset.insert({
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
            ['<Tab>'] = cmp.mapping(
                            function(fallback)
                                if cmp.visible() then
                                    cmp.confirm({ select = true })
                                elseif luasnip.expand_or_jumpable() then
                                    luasnip.expand_or_jump()
                                else
                                    fallback()
                                end
                            end, 
                            { 'i', 's' }
                        )
        }),
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' }
        },
        {
            { name = 'buffer' }
        })
    }

    require('lsp_signature').setup({
        debug = true,
        log_path = '~/.cache/nvim/signature.log',
        verbose = true,
        close_timeout = 40,
    })

    require('navigator').setup {
        border = {'╭', '─', '╮', '│', '╯', '─', '╰', '│'},
        keymaps = {
            {
                key = '<Leader>gt',
                func = vim.lsp.buf.type_definition,
                desc = 'type_definition',
            }
        },
        lsp_signature_help = true,
        lsp = {
            servers = {
                'julials',
                'clangd',
                'rust_analyzer',
                'ruff_lsp',
                'hls'
            },
            julials = {
                cmd = {
                    'julia', 
                    '--startup-file=no', 
                    '--history-file=no', '-e', 
                    'using LanguageServer;\
                    using Pkg;\
                    import StaticLint;\
                    import SymbolServer;\
                    env_path = dirname(Pkg.Types.Context().env.project_file);\
                    server = LanguageServer.LanguageServerInstance(stdin, stdout, env_path, "");\
                    server.runlinter = true;\
                    run(server);'
                }, 
                capabilities = require('cmp_nvim_lsp').default_capabilities(
                    vim.lsp.protocol.make_client_capabilities()
                ),
            },
            clangd = {
                cmd = {'clangd-14',
                    '--background-index',
                    '--suggest-missing-includes',
                    '--log=verbose',
                    '--completion-style=detailed',
                    '--clang-tidy',
                    '--header-insertion=iwyu'
                },
                capabilities = require('cmp_nvim_lsp').default_capabilities(
                    vim.lsp.protocol.make_client_capabilities()
                )
            },
            rust_analyzer = {
                capabilities = require('cmp_nvim_lsp').default_capabilities(
                    vim.lsp.protocol.make_client_capabilities()
                )
            },
            ruff_lsp = {
                cmd = {
                    'ruff-lsp'
                },
                filetypes = {
                    'python'
                },
                settings = {
                    logLevel = 'debug'
                },
                capabilities = require('cmp_nvim_lsp').default_capabilities(
                    vim.lsp.protocol.make_client_capabilities()
                )
            },
            hls = {
                settings = {
                    checkParents = 'CheckOnSave',
                    checkProject = true,
                    maxCompletions = 40,
                    formattingProvider = 'ormolu',
                    plugin = {
                        stan = { 
                            globalOn == true,
                        },
                    },
                }
            },
        },
    }
EOF
