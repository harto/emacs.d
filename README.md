My Emacs configuration.

## Vanilla Emacsen

Include the following in `~/.emacs` with site-specific settings:

    (load-file "~/.emacs.d/init.el")

## Windows

Include the following in `~/.emacs`:

    (load (expand-file-name "~/.emacs.d/env/win.el"))

## Aquamacs

Include the following in `~/Library/Preferences/Aquamacs Emacs/Preferences.el`:

    (load-file "~/.emacs.d/env/aquamacs.el")
