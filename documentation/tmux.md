## Installing

Assuming a dev-desktop:

```
sudo yum install -y tmux
```

## Common Commands

To **list** current sessions

```
tmux ls            # or alias `tl`
```

To **create** a session with name "xyz"

```
tmux new -s xyz    # or alias `tn`, e.g. `tn xyz`
```

To **attach** to an existing session with name "xyz"

```
tmux a -t xyz      # or alias `ta`, e.g. `ta xyz`
```

To **detach** from a session

```
[Ctrl-b] + d
```

To **create a new window** in the current session

```
[Ctrl-b] + c
```

To **move windows** in the current session

```
[Ctrl-b] + n       # next
[Ctrl-b] + p       # prev
```

To **rename a window** in the current session to "zyx"

```
[Ctrl-b] + :rename-window zyx [Enter]
```

To **split vertically** (note: relies on the tmux.conf below)

```
[Ctrl-b] + |       # `|` is the pipe character
```

To **split horizontally** (note: relies on the tmux.conf below)

```
[Ctrl-b] + _       # `_` is the underscore character
```

## Config

From https://code.amazon.com/packages/MrundleDev/blobs/mainline/--/configuration/dotfiles/.tmux.conf

In `~/.tmux.conf`

```
# .tmux.conf

# split panes using | and _
unbind '"'
unbind %
bind | split-window -h
bind _ split-window -v

# use hkjl for pane traversal
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
# or, use arrow keys
bind -n M-Left  select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up    select-pane -U
bind -n M-Down  select-pane -D

# 256 colors
set -g default-terminal "xterm-256color"

# Default status-bar colors
set -g status-fg black
set -g status-bg green
# Default window title colors
set-window-option -g window-status-fg black
set-window-option -g window-status-bg green
# Highlight active window title
set-window-option -g window-status-current-fg green
set-window-option -g window-status-current-bg black
# Color panes
#set-option -g pane-active-border-fg colour63
#set-option -g pane-border-fg colour245

# Windows start numbering at 1
set -g base-index 1

# New windows have no name
bind-key c new-window -n ''

# No auto-renaming
set-option -g allow-rename off

# No mouse mode
#set -g mouse off

# reload config
bind r source-file ~/.tmux.conf \; display-message "Config reloaded..."

# increase scrollback size to 500k lines
set -g history-limit 500000

#set-window-option -g c0-change-interval 250
#set-window-option -g c0-change-trigger 10

# display messages for longer; milliseconds
set-option -g display-time 3000

# https://github.com/tmux/tmux/issues/353 (krader1961@)
set-option -s escape-time 10
```

## Helpful Aliases

 

In your `~/.bash_profile`

```
setup_tmux()
{
    TMUX=/usr/bin/tmux
    alias tls="$TMUX ls"
    alias tl="tls"
    alias tnew="$TMUX new -s"
    alias tn="tnew"
    alias tkill="$TMUX kill-session -t"
    alias tk="tkill"
    alias tattach="$TMUX attach -dt"
    alias ta="tattach"
}
setup_tmux
```
