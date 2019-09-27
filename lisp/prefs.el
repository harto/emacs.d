;; General preferences

;; quieter startup
(setq inhibit-startup-screen t)
(setq initial-scratch-message nil)

;; silent bell
(setq ring-bell-function 'ignore)

;; ask for y/n rather than yes/no
(defalias 'yes-or-no-p 'y-or-n-p)

;; less visual noise
(if (boundp 'scroll-bar-mode)
    (scroll-bar-mode -1))
(if (boundp 'tool-bar-mode)
    (tool-bar-mode -1))
(if (boundp 'menu-bar-mode)
    (menu-bar-mode -1))

;; no warnings for rarely-used features
(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'scroll-left 'disabled nil)
(put 'set-goal-column 'disabled nil)

(setq completion-show-help nil)

;; no prompt for following symlinks
(setq vc-follow-symlinks nil)

;; encodings
(set-language-environment 'utf-8)
(set-default-coding-systems 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(set-locale-environment "en_AU.UTF-8")
(setq-default buffer-file-coding-system 'utf-8-unix)

;; whitespace etc
(setq-default indent-tabs-mode nil)
(setq-default require-final-newline t)
(setq-default tab-width 4)
(setq-default ws-trim-level 1)  ; only trim modified lines
(setq-default fill-column 80)

