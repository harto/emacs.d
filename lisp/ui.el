;;; Appearance

(if (boundp 'scroll-bar-mode)
    (scroll-bar-mode -1))
(if (boundp 'tool-bar-mode)
    (tool-bar-mode -1))
(if (boundp 'menu-bar-mode)
    (menu-bar-mode -1))

(setq solarized-use-variable-pitch nil)
(setq solarized-height-minus-1 1.0)
(setq solarized-height-plus-1 1.0)
(setq solarized-height-plus-2 1.0)
(setq solarized-height-plus-3 1.0)
(setq solarized-height-plus-4 1.0)
;(setq solarized-use-more-italic t)

(load-theme 'solarized-dark)
;(load-theme 'zenburn)

(defun hivis ()
  (interactive)
  (load-theme 'solarized-light)
  (set-default-font "Monaco-14"))

(defun lovis ()
  (interactive)
  (load-theme 'solarized-dark)
  (set-default-font "Monaco-12"))

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
