return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{
				"mason-org/mason.nvim",
				opts = {
					registries = {
						"github:mason-org/mason-registry",
						"github:Crashdummyy/mason-registry",
					},
				},
			},
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"saghen/blink.cmp",
			{ "folke/lazydev.nvim", ft = "lua", opts = {} },
		},
		config = function()
			vim.diagnostic.config({
				virtual_text = true,
				severity_sort = true,
				float = { border = "rounded", source = true },
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "E",
						[vim.diagnostic.severity.WARN] = "W",
						[vim.diagnostic.severity.INFO] = "I",
						[vim.diagnostic.severity.HINT] = "H",
					},
				},
			})

			-- Shared keymaps for every LSP server (incl. rustaceanvim, roslyn, haskell-tools)
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("srj31_lsp_attach", { clear = true }),
				callback = function(event)
					local function opts(desc)
						return { buffer = event.buf, desc = desc, silent = true, noremap = true }
					end
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("Goto Definition"))
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts("Goto References"))
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts("Goto Implementation"))
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("Hover"))
					vim.keymap.set("n", "<leader>ds", vim.diagnostic.open_float, opts("Line Diagnostics"))
					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts("Code Action"))
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts("Rename"))
					vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, opts("Run CodeLens"))
					vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts("Signature Help"))
					vim.keymap.set("n", "]d", function()
						vim.diagnostic.jump({ count = 1, float = true })
					end, opts("Next Diagnostic"))
					vim.keymap.set("n", "[d", function()
						vim.diagnostic.jump({ count = -1, float = true })
					end, opts("Prev Diagnostic"))
					vim.keymap.set("n", "<leader>aa", vim.diagnostic.setqflist, opts("All Diagnostics -> qflist"))
					vim.keymap.set("n", "<leader>ae", function()
						vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.ERROR })
					end, opts("All Errors -> qflist"))
					vim.keymap.set("n", "<leader>aw", function()
						vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.WARN })
					end, opts("All Warnings -> qflist"))
				end,
			})

			-- Global capabilities (blink) for all servers
			vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

			-- Per-server overrides
			vim.lsp.config("lua_ls", {
				settings = { Lua = { completion = { callSnippet = "Replace" } } },
			})
			vim.lsp.config("clangd", {
				on_attach = function(client)
					client.server_capabilities.signatureHelpProvider = false
				end,
			})

			local lsp_servers = {
				"lua_ls",
				"ocamllsp",
				"ts_ls",
				"pyright",
				"ruff",
				"sqls",
				"marksman",
				"bashls",
				"clangd",
			}
			require("mason-lspconfig").setup({
				ensure_installed = lsp_servers,
				-- Allowlist: only auto-enable these (NOT every installed mason server),
				-- so rustaceanvim/haskell-tools/roslyn.nvim remain the sole owners of
				-- rust_analyzer/hls/roslyn, and dropped servers can't be resurrected.
				automatic_enable = lsp_servers,
			})

			require("mason-tool-installer").setup({
				ensure_installed = {
					"roslyn", -- C# server (used by roslyn.nvim)
					"haskell-language-server", -- hls (used by haskell-tools.nvim)
					"prettier",
					"shfmt",
					"ocamlformat",
					"fourmolu",
					"stylua", -- formatters
					"shellcheck", -- linter
					"netcoredbg",
					"codelldb",
					"debugpy", -- debuggers
				},
			})
		end,
	},
}
