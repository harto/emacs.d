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
;;; UI

;; Chrome

(if (boundp 'scroll-bar-mode)
    (scroll-bar-mode -1))
(if (boundp 'tool-bar-mode)
    (tool-bar-mode -1))

;; Colour scheme

(setq solarized-use-variable-pitch nil)
(setq solarized-height-minus-1 1.0)
(setq solarized-height-plus-1 1.0)
(setq solarized-height-plus-2 1.0)
(setq solarized-height-plus-3 1.0)
(setq solarized-height-plus-4 1.0)

(load-theme 'solarized-dark)

(defun hi-vis ()
  (interactive)
  (load-theme 'solarized-light)
  (set-default-font "Monaco-14"))

(defun lo-vis ()
  (interactive)
  (load-theme 'solarized-dark)
  (set-default-font "Monaco-12"))

;;; ====================================
;;; Highlighting

;; Line limit indicator

(setq-default fill-column 80)
(when (display-graphic-p)
  (require 'fill-column-indicator)
  (setq fci-rule-color "#073642") ; FIXME: extract from theme?
  (define-globalized-minor-mode global-fci-mode
    fci-mode turn-on-fci-mode)
  ;(global-fci-mode)
  )

(show-paren-mode +1)

(line-number-mode 1)
(column-number-mode 1)

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
