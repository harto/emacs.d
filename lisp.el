;;; Paredit

(autoload 'paredit-mode "paredit")

;;; Clojure / ClojureScript

(require 'clojure-mode)
(add-to-list 'auto-mode-alist '("\\.cljs?$" . clojure-mode))
(add-hook 'clojure-mode-hook (lambda () (paredit-mode +1)))

;; ClojureScript doesn't work with SLIME. When we evaluate cljs forms they
;; should be sent to the inferior-lisp REPL instead.
(defadvice slime-mode (around cljs-disable-slime)
  "Activates `slime-mode' iff the current buffer isn't a .cljs file."
  (when (not (string-match "\\.cljs$" (buffer-name)))
    ad-do-it))

;;; Elisp

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (when (not (equal (buffer-name) "*scratch*"))
              (paredit-mode +1))))
