call plug#begin()

    Plug 'nvim-treesitter/nvim-treesitter', {'branch': 'main'}
    Plug 'nvim-tree/nvim-tree.lua'
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'nvim-tree/nvim-web-devicons'
    Plug 'rebelot/kanagawa.nvim'
    Plug 'https://git.sr.ht/~p00f/clangd_extensions.nvim'
    Plug 'mrcjkb/rustaceanvim'

call plug#end()

colorscheme kanagawa

let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1

set termguicolors

" settings for mouse 
set number

" Moving around 
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l

" Resizing windows
noremap <S-up> :resize +5<CR>
noremap <S-down> :resize -5<CR>
noremap <S-left> :vertical:resize -5<CR>
noremap <S-right> :vertical:resize +5<CR>

" Wrap lines
set wrap

" setting 1 tab == 4 spaces
set tabstop=4 shiftwidth=4 expandtab smarttab

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

set completeopt+=menuone,noselect

lua << EOF

    require('nvim-tree').setup()
    require('lualine').setup()
    
    vim.lsp.enable({
        'ruff',
        'pylsp',
        'clangd'
    })
    
    -- vim.lsp.set_log_level('debug')

    vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(ev)
            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            if client and client:supports_method('textDocument/completion') then
                local chars = {}
                for i = 32, 126 do
                    table.insert(chars, string.char(i))
                end
                client.server_capabilities.completionProvider.triggerCharacters = chars
                vim.lsp.completion.enable(
                    true, client.id, ev.buf, { autotrigger = true }
                )
            end
        end,
    })

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup(
            'lsp_attach_disable_ruff_hover', 
            { clear = true }
        ),
        callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client and client.name == 'ruff' then
              client.server_capabilities.hoverProvider = false
            end
        end,
        desc = 'LSP: Disable hover capability from Ruff',
        })

    vim.diagnostic.config({
        virtual_text = {
            current_line = true
        },
    })
    
EOF
