;;; Paredit

(autoload 'paredit-mode "paredit")

;;; Clojure / ClojureScript

(require 'clojure-mode)
(add-to-list 'auto-mode-alist '("\\.cljs?$" . clojure-mode))
(add-hook 'clojure-mode-hook (lambda () (paredit-mode +1)))

;;; Elisp

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (when (not (equal (buffer-name) "*scratch*"))
              (paredit-mode +1))))
