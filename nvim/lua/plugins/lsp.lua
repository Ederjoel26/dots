return {
	-- 1. LazyDev: Configures Lua LSP for your Neovim config
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	-- 2. Main LSP Configuration
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Mason: The installer for external tools
			{ "mason-org/mason.nvim", opts = {} },
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Fidget: The bottom-right status spinner
			{ "j-hui/fidget.nvim", opts = {} },

			-- Auto-completion capability
			"saghen/blink.cmp",
		},
		config = function()
			-- This function runs when an LSP attaches to a buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					-- Navigation Keymaps
					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
					map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
					map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
					map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
					map(
						"<leader>ws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[W]orkspace [S]ymbols"
					)
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					-- Highlight word under cursor (if server supports it)
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.server_capabilities.documentHighlightProvider then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})
						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					-- Toggle Inlay Hints (if server supports it)
					if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			-- Diagnostic UI Configuration
			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
				underline = { severity = vim.diagnostic.severity.ERROR },
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "󰅚 ",
						[vim.diagnostic.severity.WARN] = "󰀪 ",
						[vim.diagnostic.severity.INFO] = "󰋽 ",
						[vim.diagnostic.severity.HINT] = "󰌶 ",
					},
				},
				virtual_text = {
					source = "if_many",
					spacing = 2,
					format = function(diagnostic)
						local icons = {
							[vim.diagnostic.severity.ERROR] = "Error",
							[vim.diagnostic.severity.WARN] = "Warning",
							[vim.diagnostic.severity.INFO] = "Info",
							[vim.diagnostic.severity.HINT] = "Hint",
						}
						return string.format("%s: %s", icons[diagnostic.severity], diagnostic.message)
					end,
				},
			})

			-- Merge capabilities with Blink
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			-- LIST OF SERVERS TO INSTALL
			local servers = {
				lua_ls = {
					settings = {
						Lua = {
							completion = { callSnippet = "Replace" },
							-- diagnostics = { disable = { 'missing-fields' } },
						},
					},
				},
				-- TypeScript / JavaScript
				ts_ls = {
					root_dir = require("lspconfig.util").root_pattern("package.json", "tsconfig.json", ".git"),
				},
				cssls = {},
				jsonls = {},
				tailwindcss = {},
				gopls = {},
				pyright = {},
				bashls = {},
				marksman = {},
			}

			-- LIST OF TOOLS TO INSTALL (Formatters, Linters)
			local tools = {
				"stylua", -- Lua formatter
				"prettier", -- JS/HTML/CSS formatter
				"prettierd", -- Faster prettier
				"goimports",
				"black",
				"isort",
			}

			-- Setup Mason to install everything automatically
			require("mason").setup()

			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, tools)

			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})

			-- OPTIONAL: Pre-start TypeScript server for faster initial loading
			vim.api.nvim_create_autocmd("VimEnter", {
				callback = function()
					-- Fixed name: tsserver -> ts_ls
					vim.cmd("LspStart ts_ls")
				end,
			})
		end,
	},
}
