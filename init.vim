call plug#begin()

    Plug 'nvim-treesitter/nvim-treesitter', {'branch': 'main'}
    Plug 'nvim-tree/nvim-tree.lua'
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'nvim-tree/nvim-web-devicons'
    Plug 'rebelot/kanagawa.nvim'
    Plug 'https://git.sr.ht/~p00f/clangd_extensions.nvim'
    Plug 'mrcjkb/rustaceanvim'
    Plug 'hrsh7th/nvim-cmp-kit'
    Plug 'hrsh7th/nvim-ix'

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

    vim.o.winborder = 'rounded'
    
    require('nvim-tree').setup()
    require('lualine').setup()
    
    vim.lsp.enable({
        'ruff',
        'pylsp',
        'clangd'
    })
    
    -- vim.lsp.set_log_level('debug')
    
    local ix = require('ix')
    vim.lsp.config('*', {
        capabilities = ix.get_capabilities()
    })
    ix.setup({
        expand_snippet = function(snippet_body)
            vim.snippet.expand(snippet_body)
        end
    })
    do
        vim.keymap.set({ 'i', 'c' }, '<C-d>', ix.action.scroll(0 + 3))
        vim.keymap.set({ 'i', 'c' }, '<C-u>', ix.action.scroll(0 - 3))

        vim.keymap.set({ 'i', 'c' }, '<C-Space>', ix.action.completion.complete())
        vim.keymap.set({ 'i', 'c' }, '<C-n>', ix.action.completion.select_next())
        vim.keymap.set({ 'i', 'c' }, '<C-p>', ix.action.completion.select_prev())
        vim.keymap.set({ 'i', 'c' }, '<C-e>', ix.action.completion.close())
        ix.charmap.set('c', '<CR>', ix.action.completion.commit_cmdline())
        ix.charmap.set('i', '<CR>', ix.action.completion.commit({ select_first = true }))
        vim.keymap.set('i', '<C-y>', ix.action.completion.commit({ select_first = true, replace = true, no_snippet = true }))

        vim.keymap.set({ 'i', 's' }, '<C-o>', ix.action.signature_help.trigger_or_close())
        vim.keymap.set({ 'i', 's' }, '<C-j>', ix.action.signature_help.select_next())
    end

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
        virtual_lines = {
            current_line = true,
        },
        virtual_text = false,
    })
    
EOF
