return {
  "williamboman/mason.nvim",
  opts = {
    ensure_installed = {
      "prettier",
      "stylua",
      "shellcheck",
      "shfmt",
      "flake8",
      "nginx-config-formatter",
      "ts-standard",
    },
  },
}
