;;; Console-specific prefs
;;; (not normally used; possibly broken)

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
