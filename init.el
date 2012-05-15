;;; Top-level emacs configuration
;;; Adapted from http://github.com/EnigmaCurry/emacs
;;;
;;; Third-party libs live in ~/.emacs.d/vendor
;;; ELPA packages live in ~/.emacs.d/vendor/elpa

(add-to-list 'load-path "~/.emacs.d")
(add-to-list 'load-path "~/.emacs.d/vendor")
(let ((current-directory default-directory))
  (cd "~/.emacs.d/vendor")
  (normal-top-level-add-subdirs-to-load-path)
  (cd current-directory))

;; ELPA initialisation
(require 'package)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(setq package-user-dir (expand-file-name (convert-standard-filename "~/.emacs.d/vendor/elpa")))
(package-initialize)

;; Language/environment-specific configs
(load-library "tools")
(load-library "programming")

;; Appearance
(require 'color-theme)
(require 'color-theme-solarized)
(color-theme-solarized-dark)
(menu-bar-mode -1)
(if (boundp 'scroll-bar-mode)
    (scroll-bar-mode nil))

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default require-final-newline t)

(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'scroll-left 'disabled nil)
(put 'set-goal-column 'disabled nil)

(setq org-startup-indented t)

;; C-TAB buffer switching
(load-library "mybuffers")
(global-set-key [(control tab)] 'mybuffers-switch)

;; Console mouse support
(when (not (display-graphic-p))
  (require 'mouse)
  (xterm-mouse-mode t)
  ;(defun track-mouse (e))
  (global-set-key [mouse-4]
                  '(lambda ()
                     (interactive)
                     (scroll-down 1)))
  (global-set-key [mouse-5]
                  '(lambda ()
                     (interactive)
                     (scroll-up 1))))

;; Find things quickly
(ido-mode)
(require 'find-file-in-project)
(global-set-key (kbd "C-x C-M-f") 'find-file-in-project)

;; Line numbering
(line-number-mode 1)
(column-number-mode 1)

;; Other file/mode associations
(autoload 'markdown-mode "markdown-mode.el")
(add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))
