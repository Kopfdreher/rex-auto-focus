# rex-auto-focus

Give the focused Rex pane 70% of the tab. The other panes share the rest.

## Install

`~/.config/rex/init.lua`:

```lua
package.path = package.path .. ';/path/to/rex-auto-focus/lua/?.lua;/path/to/rex-auto-focus/lua/?/init.lua'
require('auto-focus').setup({ focus = 0.70 })
```

`rex config reload`, then keep a listener running:

```sh
rex do /path/to/rex-auto-focus/plugin/auto-focus.lua --all
```

`rex.on` does not stay registered from `init.lua`. The listener has to be a `rex do` script.

## API

```lua
require('auto-focus').setup({ focus = 0.70, threshold = 0.005 })
require('auto-focus').watch()
require('auto-focus').apply_session(session_id)
require('auto-focus').apply_window(session_id, window)
```

`rex do auto_focus` sizes the active tab once.

MIT
