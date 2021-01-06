(setq custom-file "~/.emacs-custom.el")
(load custom-file nil t)

(add-to-list 'load-path "~/.emacs.d/lisp")

(dolist (lib '("keys"
               "modes"
               "modeline"
               "prefs"
               "search"
               "utils"))
  (load lib nil t))

(if (eq system-type 'darwin)
    (load "osx" nil t))

(if (display-graphic-p)
    (load "gui" nil t)
  (load "console" nil t))

(load "~/remix/remix.el" t t)
