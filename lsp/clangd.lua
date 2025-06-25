return {
    cmd = {
      "clangd-19",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=iwyu",
      "--completion-style=detailed",
      "--function-arg-placeholders",
    },
    root_markers = { "compile_commands.json", ".git" },
    filetypes = { "c", "cpp", "objc", "objcpp" },
} 
