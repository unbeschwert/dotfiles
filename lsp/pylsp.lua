return {
    cmd = {"pylsp"}, 
    root_markers = { "pyproject.toml" , ".git"},
    filetypes = { "python" },
    settings = {
        pylsp = {
            plugins = {
                autopep8 = { enabled = false },
                pycodestyle = { enabled = false },
                pyflakes = { enabled = false },
                yapf = { enabled = false }
            }
        }
    }
}
