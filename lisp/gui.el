;; GUI instance acts as server (should only be one)
(server-start)

;; Set default directory to ~ (this was the behaviour prior to Emacs 27)
(cd "~")

;; Theme hooks, per http://www.greghendershott.com/2017/02/emacs-themes.html

(defvar load-theme-hooks nil)

(defun load-theme-advice (f theme-id &optional no-confirm no-enable &rest args)
  (unless no-enable
    ;; disable all themes for blank slate
    (mapc #'disable-theme custom-enabled-themes))
  (prog1
      (apply f theme-id no-confirm no-enable args)
    (unless no-enable
      (dolist (hook load-theme-hooks)
        (funcall hook theme-id)))))

(advice-add 'load-theme :around #'load-theme-advice)

;; Theme configuration

;; Tweak modeline border, per
;; https://github.com/bbatsov/solarized-emacs#underline-position-setting-for-x
(setq x-underline-at-descent-line t)

(setq solarized-use-variable-pitch nil
      solarized-height-minus-1 1.0
      solarized-height-plus-1 1.0
      solarized-height-plus-2 1.0
      solarized-height-plus-3 1.0
      solarized-height-plus-4 1.0)

(load-theme 'solarized-dark)
(set-frame-font "Monaco-12" t t)

(defun big-screen ()
  (interactive)
  (set-frame-font "Monaco-14" t t))

(defun small-screen ()
  (interactive)
  (set-frame-font "Monaco-12" t t))

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
