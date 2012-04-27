;;; Top-level emacs configuration
;;; Adapted from http://github.com/EnigmaCurry/emacs
;;;
;;; Third-party libs live in ~/.emacs.d/vendor
;;; ELPA packages live in ~/.emacs.d/vendor/elpa

(add-to-list 'load-path "~/.emacs.d")
(add-to-list 'load-path "~/.emacs.d/vendor")
(cd "~/.emacs.d/vendor")
(normal-top-level-add-subdirs-to-load-path)

;; ELPA initialisation
(require 'package)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(setq package-user-dir (expand-file-name (convert-standard-filename "~/.emacs.d/vendor/elpa")))
(package-initialize)

;; Language/environment-specific configs
(load-library "tools")
(load-library "web")
(load-library "lisp")

;; Appearance
(require 'color-theme)
(require 'color-theme-solarized)
(color-theme-solarized-dark)
(scroll-bar-mode nil)

(setq-default line-spacing 1)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default require-final-newline t)

(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'scroll-left 'disabled nil)
(put 'set-goal-column 'disabled nil)

;; ido
(when (boundp 'ido-mode)
  (ido-mode))

(setq org-startup-indented t)

;; C-TAB buffer switching
(load-library "mybuffers")
(global-set-key [(control tab)] 'mybuffers-switch)

;; FFIP
(require 'find-file-in-project)
(global-set-key (kbd "C-x C-M-f") 'find-file-in-project)

;; Line numbering
(when (boundp 'global-linum-mode)
  (global-linum-mode 1))

;; Other file/mode associations
(autoload 'markdown-mode "markdown-mode.el")
(add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.pl[sb]$" . sql-mode))

(cd "~")
