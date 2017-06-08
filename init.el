;; personal extensions
(add-to-list 'load-path "~/.emacs.d/lisp")

;; ad hoc 3rd-party extensions
(add-to-list 'load-path "~/.emacs.d/vendor")
(let ((default-directory "~/.emacs.d/vendor"))
  (normal-top-level-add-subdirs-to-load-path))

;; ELPA packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(setq package-user-dir (expand-file-name "~/.emacs.d/vendor/elpa"))
(package-initialize)

;; customizations
(setq custom-file "~/.emacs-custom.el")
(load custom-file nil t)

(dolist (lib '("hacks"
               "keys"
               "modes"
               "prefs"
               "programming"
               "search"
               "utils"))
  (load lib nil t))

(if (eq system-type 'darwin)
    (load "osx" nil t))

(if (display-graphic-p)
    (load "gui" nil t)
  (load "console" nil t))

(load "~/spot/spot.el" t t)
