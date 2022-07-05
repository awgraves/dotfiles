# Kitty Terminal

To get kitty to start on macos with a default session setup (tabs, windows, etc) a file must be placed and sourced correctly.

Create a session file following [these instructions](https://sw.kovidgoyal.net/kitty/overview/#startup-sessions) 

Then create a file called `macos-launch-services-cmdline` with the contents `--session <ABSOLUTE_PATH_TO_HOME_DIR>/.config/kitty/<YOUR_SESSION_FILE_NAME>`

Place both the `macos-launch-services-cmdline` and your session file together in the ~/.config/kitty dir.

See [this link](https://sw.kovidgoyal.net/kitty/faq/#how-do-i-specify-command-line-options-for-kitty-on-macos) for details.
