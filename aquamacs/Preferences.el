;; This is the Aquamacs Preferences file.
;; Add Emacs-Lisp code here that should be executed whenever
;; you start Aquamacs Emacs. If errors occur, Aquamacs will stop
;; evaluating this file and print errors in the *Messags* buffer.
;; Use this file in place of ~/.emacs (which is loaded as well.)

;; Keep customisations in .emacs.d instead of ~/Library/Preferences
(setq custom-file "~/.emacs.d/aquamacs/customizations.el")
(load custom-file)

(load-file "~/.emacs.d/init.el")

(tabbar-mode nil)

