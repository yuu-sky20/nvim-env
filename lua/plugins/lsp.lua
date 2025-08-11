return {
  -- カスタムスニペットを使えるようにする
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local ls = require("luasnip")
     
      require("luasnip.loaders.from_lua").lazy_load({
        paths = "~/.config/nvim/lua/snippets",
      })
     
      require("luasnip.loaders.from_vscode").lazy_load() -- friendly-snippets を併用したい場合
      vim.keymap.set('n', '<leader>@', require("luasnip.loaders").edit_snippet_files, { desc = "Edit snippets" })
    end
  },

  -- Mason本体（各言語のLSPインストールを管理する）
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },

  -- Mason と lspconfig の橋渡し
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason-lspconfig").setup({
        -- Masonで自動インストールしたいLSPサーバーのリスト
        ensure_installed = {
          "lua_ls", -- Lua
          "ts_ls", -- TypeScript
          "bashls", -- Bash
          "clangd", -- C
          "cmake", -- C MAKE
          "cssls", -- CSS
          "dockerls", -- Dockerfile
          "docker_compose_language_service", -- docker-compose.yml
          "gopls", -- GoLang
          "html", -- HTML
          "jsonls", -- JSON
          "marksman", 
          "pylsp", -- Python
          "rust_analyzer", -- Rust
          "intelephense", -- PHP
          -- 必要に応じて他のLSPを追加
        },
        
        -- Masonでインストールされた全てのLSPサーバーを自動設定
        automatic_installation = true,
      })
    end
  },

  -- LSP本体
 {
    'neovim/nvim-lspconfig',
    dependencies = { 
      'saghen/blink.cmp',
      'mason-org/mason-lspconfig.nvim',
    },
    config = function()
      local lspconfig = require('lspconfig')
      local blink = require('blink.cmp')
      
      -- blink.cmpのcapabilitiesを取得
      local capabilities = blink.get_lsp_capabilities()

      require("mason-lspconfig").setup {
        function(server_name)
          require('lspconfig')[server_name].setup {}
        end
      }
    end
  },

  {
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },

    build = "cargo build --release",
    opts = {
      -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
      -- 'super-tab' for mappings similar to vscode (tab to accept)
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- All presets have the following mappings:
      -- C-space: Open menu or open docs if already open
      -- C-n/C-p or Up/Down: Select next/previous item
      -- C-e: Hide menu
      -- C-k: Toggle signature help (if signature.enabled = true)
      --
      -- See :h blink-cmp-config-keymap for defining your own keymap
      keymap = { preset = 'super-tab' },

      appearance = {
        nerd_font_variant = 'mono'
      },

      -- (Default) Only show the documentation popup when manually triggered
      completion = { documentation = { auto_show = true } },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },

      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" }
  },

  -- Haskell
  {
    'mrcjkb/haskell-tools.nvim',
    version = '^5', -- Recommended
    lazy = false,
    config = function()
      local ht = require('haskell-tools')
      local bufnr = vim.api.nvim_get_current_buf()
      local opts = { noremap = true, silent = true, buffer = bufnr, }

      vim.keymap.set('n', '<space>ll', vim.lsp.codelens.run, opts)
      vim.keymap.set('n', '<space>la', ht.hoogle.hoogle_signature, opts)
      vim.keymap.set('n', '<space>le', ht.lsp.buf_eval_all, opts)
      vim.keymap.set('n', '<leader>lr', ht.repl.toggle, opts)
      vim.keymap.set('n', '<leader>lb', function()
        ht.repl.toggle(vim.api.nvim_buf_get_name(0))
      end, opts)
      vim.keymap.set('n', '<leader>lq', ht.repl.quit, opts)
    end
  },

  -- Metals (Scala LSP)
  {
    "scalameta/nvim-metals",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    ft = { "scala", "sbt", "java" },
    opts = function()
      local metals_config = require("metals").bare_config()
      metals_config.on_attach = function(client, bufnr)
        -- your on_attach function
      end

      return metals_config
    end,
    config = function(self, metals_config)
      local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = self.ft,
        callback = function()
          require("metals").initialize_or_attach(metals_config)
        end,
        group = nvim_metals_group,
      })
    end
  }
}
