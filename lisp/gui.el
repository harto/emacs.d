;; GUI instance acts as server (should only be one)
(server-start)

;; Themes, fonts, etc.

(setq solarized-use-variable-pitch nil)
(setq solarized-height-minus-1 1.0)
(setq solarized-height-plus-1 1.0)
(setq solarized-height-plus-2 1.0)
(setq solarized-height-plus-3 1.0)
(setq solarized-height-plus-4 1.0)

;; Tweak modeline border, per
;; https://github.com/bbatsov/solarized-emacs#underline-position-setting-for-x
(setq x-underline-at-descent-line t)

(load-theme 'solarized-dark)

(defun big-screen ()
  (interactive)
  (set-frame-font "Monaco-14" t t))

(defun small-screen ()
  (interactive)
  (set-default-font "Monaco-12" t t))

(defun hi-vis ()
  (interactive)
  (big-screen)
  (load-theme 'solarized-light))

(defun lo-vis ()
  (interactive)
  (small-screen)
  (load-theme 'solarized-dark))

;; (require 'fill-column-indicator)
;; (setq fci-rule-color "#073642")
;; (define-globalized-minor-mode global-fci-mode
;;  fci-mode turn-on-fci-mode)
;; (global-fci-mode)
