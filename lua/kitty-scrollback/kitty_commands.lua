---@mod kitty-scrollback.kitty_commands
local ksb_hl = require('kitty-scrollback.highlights')

local M = {}

local p
local opts ---@diagnostic disable-line: unused-local

M.setup = function(private, options)
  p = private
  opts = options ---@diagnostic disable-line: unused-local
end

M.send_paste_buffer_text_to_kitty_and_quit = function(bracketed_paste_mode)
  -- convert table to string separted by carriage returns
  local cmd_str = table.concat(
    vim.tbl_filter(function(l) return #l > 0 end, vim.api.nvim_buf_get_lines(p.paste_bufid, 0, -1, false)
    ), '\r')
  -- wrap in bracketed paste mode
  cmd_str = '\\x1b[200~' .. cmd_str .. '\r\\x1b[201~' -- see https://cirw.in/blog/bracketed-paste
  -- if not bracked paste mode trigger add a carriage return to execute command
  if not bracketed_paste_mode then
    cmd_str = cmd_str .. '\r'
  end
  vim.system({
    'kitty',
    '@',
    'send-text',
    '--match=id:' .. p.kitty_data.window_id,
    cmd_str,
  }, {
    text = true,
  }):wait()

  vim.cmd.quitall({ bang = true })
end

M.close_kitty_loading_window = function()
  if p.kitty_loading_winid then
    vim.system({
      'kitty',
      '@',
      'close-window',
      '--match=id:' .. p.kitty_loading_winid,
    }, {
      text = true
    }):wait()
  end
  p.kitty_loading_winid = nil
end

M.signal_winchanged_to_kitty_child_process = function()
  vim.system({
    'kitty',
    '@',
    'signal-child',
    'SIGWINCH'
  })
end

M.open_kitty_loading_window = function()
  if p.kitty_loading_winid then
    M.close_kitty_loading_window()
  end
  local kitty_cmd = vim.list_extend({ 'kitty',
      '@',
      'launch',
      '--type',
      'overlay',
      '--title',
      'kitty-scrollback.nvim :: loading...',
      '--env',
      'KITTY_SCROLLBACK_NVIM_STYLE_SIMPLE=' .. tostring(opts.status_window.style_simple),
      '--env',
      'KITTY_SCROLLBACK_NVIM_STATUS_WINDOW_ENABLED=' .. tostring(opts.status_window.enabled),
      '--env',
      'KITTY_SCROLLBACK_NVIM_SHOW_TIMER=' .. tostring(opts.status_window.show_timer),
    },
    vim.list_extend(
      ksb_hl.get_highlights_as_env(),
      { p.kitty_data.ksb_dir .. '/python/loading.py', }
    )
  )
  p.kitty_loading_winid = tonumber(vim.system(kitty_cmd, { text = true }):wait().stdout)
end

return M
