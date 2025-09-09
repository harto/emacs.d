;; (From https://blog.d46.us/advanced-emacs-startup/)
;; Make startup faster by reducing the frequency of garbage
;; collection. (The default is 800 kilobytes.) Measured in bytes.
(setq gc-cons-threshold (* 100 1000 1000))

;; Disable unwanted chrome before it has the chance to appear.
(if (boundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (boundp 'tool-bar-mode) (tool-bar-mode -1))
;; TODO: I think we could ignore this in GUI mode
(if (boundp 'menu-bar-mode) (menu-bar-mode -1))

;; Configure fonts before the first window becomes visible.
;; https://fonts.google.com/specimen/Roboto+Mono
(defvar sc/font-height-regular 130)
(defvar sc/font-height-bigger 150)
(set-face-attribute 'default nil
                    :family "Roboto Mono"
                    :height sc/font-height-regular)

;; Code that should run before `package-initialize' is meant to go in this file
;; (according to the help documentation for that function)
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-unstable" . "https://melpa.org/packages/") t)
