return {
	{
		"saghen/blink.cmp",
		event = "InsertEnter", -- Load only when typing
		version = "*", -- Use the latest release

		dependencies = {
			-- You still need the actual snippets (the data),
			-- but you don't need the engine (LuaSnip) anymore.
			"rafamadriz/friendly-snippets",
			"folke/lazydev.nvim",
		},

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = {
				-- 'default' is usually better than 'enter'.
				-- 'enter' can be annoying if you just want to go to a new line.
				-- 'default' uses:
				--   <C-space> to show menu
				--   <C-y> to accept
				--   <C-n>/<C-p> to navigate
				preset = "enter",

				-- If you prefer "Super-Tab" (VSCode style), uncomment this block:
				--[[ 
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        --]]
			},

			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
			},

			-- Visual customization
			completion = {
				documentation = { auto_show = true, auto_show_delay_ms = 500 },
				menu = { border = "rounded" },
			},

			-- Sources: Where the words come from
			sources = {
				default = { "lsp", "path", "snippets", "buffer", "lazydev" },
				providers = {
					lazydev = {
						module = "lazydev.integrations.blink",
						score_offset = 100,
					},
				},
			},

			-- ENABLE NATIVE SNIPPETS (No LuaSnip needed!)
			snippets = { preset = "default" },

			-- Signature help (floating window with function args)
			signature = { enabled = true },
		},
	},
}
