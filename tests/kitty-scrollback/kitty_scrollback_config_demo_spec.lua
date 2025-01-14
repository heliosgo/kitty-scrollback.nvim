local assert = require('luassert.assert')
local h = require('tests.helpers')
local describe = describe ---@diagnostic disable-line: undefined-global
local it = it ---@diagnostic disable-line: undefined-global
local after_each = after_each ---@diagnostic disable-line: undefined-global
local before_each = before_each ---@diagnostic disable-line: undefined-global

h.setup_backport()

local ksb_dir = vim.fn.fnamemodify(
  vim.fn.fnamemodify(vim.api.nvim_get_runtime_file('lua/kitty-scrollback', false)[1], ':h:h'),
  ':p'
)
h.debug({
  ksb_dir = ksb_dir,
  kitty_conf = ksb_dir .. 'tests/kitty.conf',
})

local tmpsock = h.tempsocket(ksb_dir .. 'tmp/')
local kitty_instance

local shell = h.debug(h.is_github_action and '/bin/bash' or (vim.o.shell .. ' --noprofile --norc'))

local kitty_cmd = h.debug({
  'kitty',
  '--listen-on=unix:' .. tmpsock,
  '--config',
  ksb_dir .. 'tests/kitty.conf',
  '--override',
  'shell=' .. shell,
  '--override',
  'enabled_layouts=fat:bias=90',
  '--override',
  'initial_window_width=161c',
  '--override',
  'initial_window_height=30c',
  '--override',
  'font_size=18.0',
  '--override',
  'background_opacity=1.0',
  '--session',
  '-', -- read session from stdin
})

describe('kitty-scrollback.nvim', function()
  before_each(function()
    vim.fn.mkdir(ksb_dir .. 'tests/workdir', 'p')
    kitty_instance = vim.system(kitty_cmd, {
      stdin = 'cd ' .. ksb_dir,
    })
    local ready = false
    vim.fn.wait(5000, function()
      ready = (h.debug(h.kitty_remote_ls():wait()).code == 0)
      return ready
    end, 500)

    assert.is_true(ready, 'kitty is not ready for remote connections, exiting')
    h.pause_seconds()

    local ksb_work_dir = os.getenv('KITTY_SCROLLBACK_NVIM_DIR') or 'tmp/kitty-scrollback.nvim'
    local is_directory = vim.fn.isdirectory(ksb_work_dir) > 0
    if is_directory then
      vim.system({ 'rm', '-rf', ksb_work_dir }):wait()
    end
    vim
      .system({
        'git',
        'clone',
        'https://github.com/mikesmithgh/kitty-scrollback.nvim',
        ksb_work_dir,
      })
      :wait()

    h.feed_kitty({
      h.send_as_string([[source ]] .. ksb_dir .. [[tests/bashrc]]),
      h.send_as_string([[cd ]] .. ksb_work_dir),
      h.with_pause_seconds_before(h.send_without_newline(h.clear())),
    })
  end)

  after_each(function()
    kitty_instance:kill(2)
    kitty_instance = nil
  end)

  it('should demo', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.send_without_newline([[
banner
ksb_tree
loldino
lolbanner
]]),
        h.with_pause_seconds_before([[
colortest


]]),
        h.open_kitty_scrollback_nvim(),
        h.send_without_newline([[a]]),
        h.send_without_newline([[
# builtin > kitty_scrollback_nvim
default configuration for the keymap `kitty_mod+h`

Browse scrollback buffer in kitty-scrollback.nvim 
]]),
        h.send_without_newline(h.esc()),
        h.send_without_newline([[gg0]]),
      }),
      {
        stdout = h.with_status_win(
          [[
         _____          ..-~             ~-..-~
        |     |   \~~~\.'                    `./~~~/                                                                                                             
       ---------   \__/                        \__/                                                                                                              
      .'  O    \     /               /       \  "                                                                                                                
     (_____,    `._.'               |         }  \/~~~/                                                                                                          
      `----.          /       }     |        /    \__/                                                                                                           
            `-.      |       /      |       /      `. ,~~|                                                                                                       
                ~-.__|      /_ - ~ ^|      /- _      `..-'                                                                                                       
                     |     /        |     /     ~-.     `-. _  _  _                                                                                              
                     |_____|        |_____|         ~ - . _ _ _ _ _>                                                                                             
$ lolbanner
        _     _ _____ _______ _______ __   __     _______ _______  ______  _____                ______  _______ _______ _     _   __   _ _    _ _____ _______    
        |____/    |      |       |      \_/   ___ |______ |       |_____/ |     | |      |      |_____] |_____| |       |____/    | \  |  \  /    |   |  |  |    
        |    \_ __|__    |       |       |        ______| |_____  |    \_ |_____| |_____ |_____ |_____] |     | |_____  |    \_ . |  \_|   \/   __|__ |  |  |    
                                                                                                                                                                 
$🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
N▏# builtin > kitty_scrollback_nvim                                                                                                                             ▕
\▏# default configuration for the keymap `kitty_mod+h`                                                                                                          ▕
\▏#                                                                                                                                                             ▕
\▏# Browse scrollback buffer in kitty-scrollback.nvim                                                                                                           ▕
\▏#                                                                                                                                                             ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
T▏                                                                                                                                                              ▕
$🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
$▏                                                                                                                                                              ▕
$▏         \y Yank               <C-CR> Execute               <S-CR> Paste                :w Paste               g? Toggle Mappings                             ▕
$🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
]],
          168
        ),
        cursor_y = 17,
        cursor_x = 3,
      },
      'kitty-scrollback.nvim did not have expected results for builtin > kitty_scrollback_nvim'
    )
  end)
end)
