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

					local client = vim.lsp.get_client_by_id(event.data.client_id)

					-- Auto-display codelens for servers that provide it (e.g. the F#
					-- signature/inferred-type lenses). enable() attaches to the buffer
					-- and re-renders on change, so no manual refresh autocmd is needed.
					if client and client.server_capabilities.codeLensProvider then
						vim.lsp.codelens.enable(true, { bufnr = event.buf })
					end

					-- Safety net: give F# buffers a one-key force-restart so any FSAC
					-- hiccup doesn't need a full nvim restart -- kill the server and
					-- re-attach a fresh one.
					if vim.bo[event.buf].filetype == "fsharp" then
						vim.keymap.set("n", "<leader>lr", function()
							local clients = vim.lsp.get_clients({ name = "fsautocomplete" })
							if #clients == 0 then
								vim.notify("No fsautocomplete client attached", vim.log.levels.WARN)
								return
							end
							for _, c in ipairs(clients) do
								c:stop(true) -- force-kill the (possibly deadlocked) server
							end
							local buf = vim.api.nvim_get_current_buf()
							vim.notify("Restarting fsautocomplete…", vim.log.levels.INFO)
							vim.defer_fn(function()
								if vim.api.nvim_buf_is_valid(buf) then
									vim.api.nvim_exec_autocmds("FileType", { buffer = buf, modeline = false })
								end
							end, 1000)
						end, opts("Restart F# LSP"))
					end
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
			-- ROOT-CAUSE FIX for the F# "hang": nvim-lspconfig defaults FSAC to its
			-- EXPERIMENTAL adaptive server (cmd flag `--adaptive-lsp-server-enabled`).
			-- That server's FSharp.Data.Adaptive path deadlocks -- the main LSP thread
			-- parks on Monitor.Wait at 0% CPU and the editor stalls within ~2 min, and
			-- it also floods $/progress events. Override cmd to drop the flag so FSAC
			-- runs its default/classic server, which loads the same net10 projects
			-- without the deadlock (verified) and emits far fewer progress events.
			--
			-- cmd_env: FSAC ships as a .NET 8 tool; roll it forward onto the installed
			-- .NET 10 runtime so its MSBuild can load the workspace's net10 projects.
			--
			-- handlers: FSAC emits VS Code `command:` hyperlinks in hover docs; rewrite
			-- them to plain label text so they render readably, not as raw HTML.
			local default_hover = vim.lsp.handlers["textDocument/hover"]
			vim.lsp.config("fsautocomplete", {
				cmd = { "fsautocomplete" },
				cmd_env = { DOTNET_ROLL_FORWARD = "LatestMajor" },
				handlers = {
					["textDocument/hover"] = function(err, result, ctx, config)
						local c = result and result.contents
						if type(c) == "table" and type(c.value) == "string" then
							c.value = c.value
								:gsub("<a href=['\"]command:[^'\"]*['\"]>(.-)</a>", "%1")
								:gsub("%[([^%]]*)%]%(command:[^%)]*%)", "%1")
						end
						return default_hover(err, result, ctx, config)
					end,
				},
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
				"lemminx", -- XML language server (validation, completion, formatting)
				"fsautocomplete", -- F# language server (ionide/FsAutoComplete)
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
					"stylua",
					"sql-formatter", -- formatters
					"shellcheck",
					"dotenv-linter", -- linters
					"netcoredbg",
					"codelldb",
					"debugpy", -- debuggers
				},
			})
		end,
	},
}
