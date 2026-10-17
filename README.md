# tmux-conf [![license: MIT](https://img.shields.io/github/license/b0o/tmux-conf?style=flat&color=green)](https://mit-license.org)

tmux configuration, based on [Maddison's tmux configuration](https://github.com/b0o/tmux-conf).
Runs on Linux (Garuda / Arch) with [kitty](https://github.com/garuda-dotfiles/terminal-conf); the
`windows-psmux` branch is the Windows port for [psmux](https://github.com/marlocarlo/psmux).

## Requirements

- tmux >= 3.2 (tested with 3.8)
- bash, `ps` (for `navi.tmux`)
- `xsel` (tmux-thumbs copy to clipboard)
- kitty with the [terminal-conf](https://github.com/garuda-dotfiles/terminal-conf) config, which sends the
  special key combos listed below

```bash
sudo pacman -S --needed tmux xsel
```

## Install

```bash
git clone https://github.com/garuda-dotfiles/tmux-conf ~/dotfiles-conf/tmux-conf
ln -s ~/dotfiles-conf/tmux-conf ~/.config/tmux
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
tmux
```

Then press `C-Space` `I` to install the plugins. tmux-thumbs asks to compile or download its binary;
choose download when `cargo` is not installed.

## Files

| File | Purpose |
| --- | --- |
| `tmux.conf` | Main configuration |
| `navi.tmux` | Background job that marks panes running (n)vim/ssh, so `M-h/j/k/l` is passed through to them |
| `layouts/*.window.sh` | [tmuxifier](https://github.com/jimeh/tmuxifier) window layouts |
| `plugins/` | Plugins installed by tpm (git-ignored) |

## Keys

The prefix is `C-Space`.

| Keys | Action |
| --- | --- |
| `prefix` `R` | Reload `~/.config/tmux/tmux.conf` |
| `prefix` `I` | Install plugins (tpm) |
| `prefix` `V` / `S` | Split horizontally / vertically in the current directory |
| `prefix` `C-v` / `C-s` | Split with 20% size |
| `prefix` `1`..`9` | Select window N, create it when missing |
| `prefix` `h/j/k/l` | Select pane |
| `prefix` `a` | Last window |
| `prefix` `x` / `p` | Cut / paste pane |
| `prefix` `X` / `P` | Cut / paste window |
| `prefix` `r` | Rename window |
| `prefix` `Q` / `C-w` | Kill pane / window (with confirmation) |
| `prefix` `` ` `` | Copy mode (vi keys) |
| `prefix` `Tab` | tmux-thumbs hints |
| `M-h/j/k/l` | Select pane (passed through to (n)vim and ssh) |
| `M-!`..`M-(` | Join the pane into window 1..9, or break it out to that window |

### Special combos (sent by kitty)

tmux cannot tell these keys apart on its own, so kitty sends one character for each and `tmux.conf`
binds the character ("Terminal special combos").

| Keys | Character | Action |
| --- | --- | --- |
| `C-M-[` / `C-M-]` | `Ö` U+00D6 / `¡` U+00A1 | Resize pane left / right |
| `C-M-S-[` / `C-M-S-]` | `¢` U+00A2 / `£` U+00A3 | Resize pane up / down |
| `C-M-S-h/j/k/l` | `¤ ¥ ¦ §` U+00A4..U+00A7 | Swap pane with its neighbour |
| `C-S-h/j/k/l` | `Ð Ñ Ò Ó` U+00D0..U+00D3 | Move pane into the neighbouring column / row |
| `C-M-'` / `C-M-;` | `¨` U+00A8 / `©` U+00A9 | Next / previous window |
| `C-M-S-'` / `C-M-S-;` | `°` U+00B0 / `±` U+00B1 | Move window right / left |
| `C-M-Return` | `²` U+00B2 | New window in the current directory |
| `C-M-1`..`C-M-9` | `Á`..`É` U+00C1..U+00C9 | Select window N, create it when missing |

`C-M-[` uses U+00D6 because kitty strips U+00A0 (no-break space) as whitespace in `send_text`.

## Plugins

- [tpm](https://github.com/tmux-plugins/tpm)
- [tmux-autoreload](https://github.com/b0o/tmux-autoreload)
- [tmux-prefix-highlight](https://github.com/tmux-plugins/tmux-prefix-highlight)
- [tmux-thumbs](https://github.com/fcsonline/tmux-thumbs)

## Notes

- Bindings use format conditions (`if-shell -F`) instead of shell tests, so they work with any
  `default-shell`.
- The tmuxifier popups (`prefix` `N`/`n`/`M`/`m`) need zsh, comark and tmuxifier, which are not part
  of this setup.

## License

&copy; 2021 Maddison Hellstrom

Released under the MIT License.
