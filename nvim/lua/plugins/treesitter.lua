return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		opts = {
			ensure_installed = {
				-- Base
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",

				-- Web Development
				"javascript",
				"typescript",
				"tsx",

				-- Backend / Systems (Added)
				"go",
				"gomod", -- Helps with go.mod files
				"python",
			},

			auto_install = true,

			highlight = {
				enable = true,
				additional_vim_regex_highlighting = { "ruby" },
			},

			indent = {
				enable = true,
				disable = { "ruby" },
			},
		},
	},
}
