(require 'package)
(add-to-list 'package-archives '("melpa" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-unstable" . "https://melpa.org/packages/") t)
(setq package-user-dir (expand-file-name "~/.emacs.d/elpa"))

;; vendored packages
;; (add-to-list 'load-path "~/.emacs.d/vendor")
;; (let ((default-directory "~/.emacs.d/vendor"))
;;   (normal-top-level-add-subdirs-to-load-path))

;; Disable unwanted chrome before it has the chance to appear
(if (boundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (boundp 'tool-bar-mode) (tool-bar-mode -1))
(if (boundp 'menu-bar-mode) (menu-bar-mode -1))
