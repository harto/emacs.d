(require 'package)
(add-to-list 'package-archives '("melpa" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-unstable" . "https://melpa.org/packages/") t)
(setq package-user-dir (expand-file-name "~/.emacs.d/elpa"))

(setq custom-file "~/.emacs-custom.el")
(load custom-file nil t)

(add-to-list 'load-path "~/.emacs.d/lisp")

(load "keys")
(load "modes")
(load "modeline")
(load "prefs")
(load "search")
(load "utils")

(load (if (display-graphic-p) "gui" "console"))

(load "~/remix/remix.el" t)

(message "")

;; (from https://blog.d46.us/advanced-emacs-startup/)
;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))
