;;; Paredit

(autoload 'paredit-mode "paredit")

;;; Clojure / ClojureScript

(defun cljs-buffer-p ()
  "Test if current buffer is a ClojureScript buffer."
  (string-match "\\.cljs$" (buffer-name)))

(require 'clojure-mode)
(add-to-list 'auto-mode-alist '("\\.cljs?$" . clojure-mode))
(add-hook 'clojure-mode-hook
          (lambda ()
            (paredit-mode +1)
            (when (not (cljs-buffer-p))
              (define-key clojure-mode-map (kbd "C-c C-j") 'clojure-jack-in))))

;; ClojureScript doesn't work with SLIME. When we evaluate cljs forms they
;; should be sent to the inferior-lisp REPL instead.
(defadvice slime-mode (around cljs-disable-slime)
  "Activates `slime-mode' iff the current buffer isn't a .cljs file."
  (when (not (cljs-buffer-p))
    ad-do-it))

(setq slime-kill-without-query-p t)

;;; Elisp

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (when (not (equal (buffer-name) "*scratch*"))
              (paredit-mode +1))))
