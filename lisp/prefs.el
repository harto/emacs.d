;;; ====================================
;;; General preferences

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

(setq org-startup-indented t)

;;; ====================================
;;; ido-mode

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

;;; ====================================
;;; Miscellany

;; Snippet expansion

(yas-global-mode +1)

;;; ====================================
;;; Whitespace

(setq-default indent-tabs-mode nil
              tab-width 4
              require-final-newline t)

(global-ws-trim-mode t)
(set-default 'ws-trim-level 1)  ; only trim modified lines
