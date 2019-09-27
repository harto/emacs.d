;; ad hoc 3rd-party extensions
;; (add-to-list 'load-path "~/.emacs.d/vendor")
;; (let ((default-directory "~/.emacs.d/vendor"))
;;   (normal-top-level-add-subdirs-to-load-path))

;; managed packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-unstable" . "https://melpa.org/packages/") t)
(setq package-user-dir (expand-file-name "~/.emacs.d/elpa"))
(package-initialize)

;; customizations
(setq custom-file "~/.emacs-custom.el")
(load custom-file nil t)

;; personal extensions
(add-to-list 'load-path "~/.emacs.d/lisp")

(dolist (lib '("hacks"
               "keys"
               "modes"
               "modeline"
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

(load "~/remix/remix.el" t t)
