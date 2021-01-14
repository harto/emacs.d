(require 'package)
(add-to-list 'package-archives '("melpa" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-unstable" . "https://melpa.org/packages/") t)
(setq package-user-dir (expand-file-name "~/.emacs.d/elpa"))

(setq custom-file "~/.emacs-custom.el")
(load custom-file nil t)

(add-to-list 'load-path "~/.emacs.d/lisp")

(dolist (lib '("keys"
               "modes"
               "modeline"
               "prefs"
               "search"
               "utils"))
  (load lib nil t))

(if (eq system-type 'darwin)
    (load "osx" nil t))

(if (display-graphic-p)
    (load "gui" nil t)
  (load "console" nil t))

(load "~/remix/remix.el" t t)
