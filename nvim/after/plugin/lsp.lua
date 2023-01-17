local lsp = require('lsp-zero')

lsp.preset('recommended')

lsp.ensure_installed {
	'eslint',
	'sumneko_lua',
	'rust_analyzer',
}

local set = function(keys, func, desc)
	if desc then
		desc = 'LSP: ' .. desc
	end

	vim.keymap.set('n', keys, func, { desc = desc })
end

set('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
set('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

set('<leader>gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
set('<leader>gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
set('<leader>gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
set('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
set('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

-- Setup mason so it can manage external tooling
require('mason').setup()

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup_handlers {
	function(server_name)
		require('lspconfig')[server_name].setup {
			on_attach = on_attach,
		}
	end,
}

-- Completion settings
local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
	['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
	['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
	['<C-Space>'] = cmp.mapping.complete(),
	['<C-l>'] = cmp.mapping.confirm({ select = true }),
})

lsp.setup_nvim_cmp({
	mapping = cmp_mappings
})

lsp.setup()
