local present, lspconfig = pcall(require, "lspconfig")
if not present then
    return
end

local lsp_flags = {
  debounce_text_changes = 150,
}

-- Set up lspconfig.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local servers = { 'lua_ls', 'clangd', 'bashls', 'pyright', 'tsserver', 'html' }

for _, server in ipairs(servers) do
  lspconfig[server].setup {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
  }
end
