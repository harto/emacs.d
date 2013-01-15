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
(setq package-user-dir (expand-file-name "~/.emacs.d/vendor/elpa"))
(package-initialize)

;; Language/environment-specific configs
(load-library "tools")
(load-library "programming")

;; Appearance
(require 'color-theme)
(require 'color-theme-solarized)
(color-theme-solarized-dark)
(if (boundp 'scroll-bar-mode)
    (scroll-bar-mode -1))
(if (boundp 'tool-bar-mode)
    (tool-bar-mode -1))

(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default require-final-newline t)

(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'scroll-left 'disabled nil)

(setq org-startup-indented t)

;; Console-specific stuff
(unless (display-graphic-p)
  ;; Basic mouse support
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
                     (scroll-up 1)))
  ;; Hide vertical buffer separator
  (set-face-background 'vertical-border "#000")
  (set-face-foreground 'vertical-border "#000")
  ;; Hide menu bar
  (menu-bar-mode -1))

;; Backwards window navigation
(global-set-key (kbd "C-x p")
                (lambda ()
                  (interactive)
                  (other-window -1)))

;; Find things quickly
(global-set-key (kbd "C-c f") 'ftf-find-file)
(global-set-key (kbd "C-c s") 'rgrep)

(ido-mode)
;; Layout ido results vertically, rather than horizontally
(setq ido-decorations (list "\n-> " ""
                            "\n   "
                            "\n   ..."
                            "[" "]"
                            " [No match]"
                            " [Matched]"
                            " [Not readable]"
                            " [Too big]"
                            " [Confirm]"))
;; Effectively disable auto-merge
(setq ido-auto-merge-delay-time 999)

;; Line numbering
(line-number-mode 1)
(column-number-mode 1)

;; Other file/mode associations
(autoload 'markdown-mode "markdown-mode.el")
(add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))

;; Git
(require 'magit)
(global-set-key (kbd "C-c g") 'magit-status)
;; For command-line commit messages
(add-to-list 'auto-mode-alist '("\\bCOMMIT_EDITMSG$" . diff-mode))
