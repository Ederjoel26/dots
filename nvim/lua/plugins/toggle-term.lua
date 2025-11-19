return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		opts = {
			open_mapping = [[<C-t>]],
			direction = "float",
			shade_terminals = false,

			shell = vim.fn.has("win32") == 1 and "pwsh" or vim.o.shell,

			float_opts = {
				width = 100,
				height = 30,
				winblend = 0,
				zindex = 80,
				border = {
					{ " ", "FloatBorder" },
					{ " ", "FloatBorder" },
					{ " ", "FloatBorder" },
					{ " ", "FloatBorder" },
					{ " ", "FloatBorder" },
					{ " ", "FloatBorder" },
					{ " ", "FloatBorder" },
					{ " ", "FloatBorder" },
				},
			},

			highlights = {
				Normal = { guibg = "#1a1a1a" },
				FloatBorder = { guifg = "#555555", guibg = "#1a1a1a" },
				NormalFloat = { guibg = "#1a1a1a" },
			},
		},
	},
}
