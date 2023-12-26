local prefix = 'ksb_builtin_'

return {
  configs = {
    [prefix .. 'get_text_all'] = function()
      return {
        kitty_get_text = {
          extent = 'all',
          ansi = true,
        },
      }
    end,
    [prefix .. 'last_cmd_output'] = function()
      vim.o.termguicolors = true
      vim.o.wrap = true
      vim.o.listchars = 'tab:»·,nbsp:+,trail:·,extends:→,precedes:←,eol:¬'
      vim.o.columns = 1000
      vim.keymap.set('n', 'j', 'gj', { silent = true })
      vim.keymap.set('n', 'k', 'gk', { silent = true })
      vim.keymap.set('v', 'j', 'gj', { silent = true })
      vim.keymap.set('v', 'k', 'gk', { silent = true })
      return {
        kitty_get_text = {
          extent = 'last_cmd_output',
          ansi = true,
        },
        restore_options = true,
      }
    end,
    [prefix .. 'last_visited_cmd_output'] = function()
      return {
        kitty_get_text = {
          extent = 'last_visited_cmd_output',
          ansi = true,
        },
      }
    end,
    [prefix .. 'checkhealth'] = function()
      return {
        checkhealth = true,
      }
    end,
  },
}
