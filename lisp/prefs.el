;; =====================================
;; General preferences

;; silent startup
(setq inhibit-startup-screen t)
(setq initial-scratch-message nil)

;; silent bell
(setq ring-bell-function 'ignore)

;; ask for y/n rather than yes/no
(defalias 'yes-or-no-p 'y-or-n-p)

(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'scroll-left 'disabled nil)
(put 'set-goal-column 'disabled nil)

(setq org-startup-indented t)

;; no prompt for following symlinks
(setq vc-follow-symlinks nil)

;; =====================================
;; ido-mode

(ido-mode +1)
(ido-everywhere +1)

;; layout results vertically
(setq ido-decorations (list "\n-> " ""
                            "\n   "
                            "\n   ..."
                            "[" "]"
                            " [No match]"
                            " [Matched]"
                            " [Not readable]"
                            " [Too big]"
                            " [Confirm]"))

;; effectively disable auto-merge
(setq ido-auto-merge-delay-time 999)

;; better fuzzy matching
(require 'flx-ido)
(flx-ido-mode +1)

;; =====================================
;; Encodings

(set-language-environment 'utf-8)
(set-default-coding-systems 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(set-locale-environment "en_AU.UTF-8")
(setq-default buffer-file-coding-system 'utf-8-unix)

;; =====================================
;; Miscellany

;; Snippet expansion
(yas-global-mode +1)
;; TODO: figure out a way to set require-final-newline -> nil for snippets
;; (is there a yas-mode?)

(if (boundp 'scroll-bar-mode)
    (scroll-bar-mode -1))
(if (boundp 'tool-bar-mode)
    (tool-bar-mode -1))
(if (boundp 'menu-bar-mode)
    (menu-bar-mode -1))

(show-paren-mode +1)
(line-number-mode +1)
(column-number-mode +1)

(setq-default fill-column 80)

;; =====================================
;; Whitespace

(setq-default indent-tabs-mode nil)
(setq-default require-final-newline t)
(setq-default tab-width 4)

(global-ws-trim-mode t)
(set-default 'ws-trim-level 1)  ; only trim modified lines
