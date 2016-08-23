;;; Top-level emacs configuration
;;; Adapted from http://github.com/EnigmaCurry/emacs
;;;
;;; Third-party libs live in ~/.emacs.d/vendor
;;; ELPA packages live in ~/.emacs.d/vendor/elpa

(add-to-list 'load-path "~/.emacs.d/lisp")
(add-to-list 'load-path "~/.emacs.d/vendor")
(let ((current-directory default-directory))
  (cd "~/.emacs.d/vendor")
  (normal-top-level-add-subdirs-to-load-path)
  (cd current-directory))

;; ELPA initialisation
(require 'package)
(add-to-list 'package-archives '("marmalade" . "https://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(setq package-user-dir (expand-file-name "~/.emacs.d/vendor/elpa"))
(package-initialize)

;; Store customizations in a consistent location
(setq custom-file "~/.emacs-custom.el")
(load custom-file)

;; Language/environment-specific configs
(load-library "tools")
(load-library "programming")
(load-library "search")
(if (eq system-type 'darwin)
    (load-library "osx"))

;; Appearance
(require 'color-theme)
(require 'color-theme-solarized)
;; NB: This looks weird unless terminal
;; is also configured to use Solarized.
(color-theme-solarized-dark)
(if (boundp 'scroll-bar-mode)
    (scroll-bar-mode -1))
(if (boundp 'tool-bar-mode)
    (tool-bar-mode -1))

(defun hivis ()
  (interactive)
  (color-theme-solarized-light)
  (set-default-font "Monaco-14"))

;; Line limit indicator
(setq-default fill-column 80)
(when (display-graphic-p)
  (require 'fill-column-indicator)
  (setq fci-rule-color "#073642")
  ;; Enable everywhere
  (define-globalized-minor-mode global-fci-mode
    fci-mode turn-on-fci-mode)
  ;(global-fci-mode)
  )

;; Highlight matching parens/brackets/etc
(show-paren-mode +1)

(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)

;; Shuttupify the bell
(setq ring-bell-function 'ignore)

;; Always ask for y/n keypress instead of "yes"/"no"
(defalias 'yes-or-no-p 'y-or-n-p)

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
  (defun track-mouse (e))
  (setq mouse-sel-mode t)
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

;; Sane indentation with C-o
(global-set-key (kbd "C-o") #'open-line-preserving-indent)

(ido-mode +1)
(ido-everywhere +1)
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
;; better fuzzy matching
(require 'flx-ido)
(flx-ido-mode +1)

;; Line numbering
(line-number-mode 1)
(column-number-mode 1)

;; Other file/mode associations
(autoload 'markdown-mode "markdown-mode")
(add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown$" . markdown-mode))
(autoload 'yaml-mode "yaml-mode")
(add-to-list 'auto-mode-alist '("\\.yaml$" . yaml-mode))

(autoload 'restclient-mode "restclient")

;; Git
(global-set-key (kbd "C-c g") 'magit-status)

;; Tmux
;; (global-set-key (kbd "C-c C-t r") 'emamux:run-command)
;; (global-set-key (kbd "C-c C-t l") 'emamux:run-last-command)
;; (global-set-key (kbd "<f5>") #'save-buffer-and-run-last-emamux-command)

;; Multiple cursors
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

;; Flymake config
;; Show flymake messages in minibuffer
;; (eval-after-load "flymake"
;;   '(require 'flymake-cursor))

;; Snippet expansion
(yas-global-mode +1)

;; Whitespace cleanup
(global-ws-trim-mode t)
;; Only trim modified lines
(set-default 'ws-trim-level 1)

;; GUI instance acts as server (should only be one)
(when (display-graphic-p)
  (server-start))

;; Work things
(if (file-exists-p "~/spot/spot.el")
    (load-library "~/spot/spot"))
