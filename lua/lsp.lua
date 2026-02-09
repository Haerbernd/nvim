vim.lsp.config('luals', {
        cmd = {'lua-language-server'},
        filetypes = {'lua'},
        root_markers = {'.luarc.json', '.luarc.jsonc'},
})

vim.lsp.enable('luals')

vim.lsp.config('clangd', {
        cmd = { 'clangd', '--background-index', '--clang-tidy', '--log=verbose' },
        filetypes = {"cpp", "h", "hpp"},
        init_options = {
                fallbackFlags = {'-std=c++20'},
        },
})

vim.lsp.enable('clangd')


vim.lsp.config('marksman', { -- entirely optional the default config is fine
        cmd = {"marksman", "server"},
        filetypes = {"markdown", "markdown.mdx"},
        root_markers = {".marksman.toml", ".git"}
})
vim.lsp.enable('marksman')
