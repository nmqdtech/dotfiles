local present, conf = pcall(require, "nvim-treesitter.configs")
if not present then
    return
end

conf.setup {
    ensure_installed = { "c", "lua", "bash" },
    highlight = { enable = true },
}
