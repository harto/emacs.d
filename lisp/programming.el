;; Support for various programming languages

;; JavaScript

(setq js2-basic-offset 2)
(setq js2-bounce-indent-p t)
(setq js2-cleanup-whitespace t)

(add-hook 'js2-mode-hook
          (lambda ()
            ;; inline linting
            ;(require 'flymake-jshint)
            ;(flymake-mode)
            ;; sane word navigation
            (subword-mode +1)
            ;; balance parens etc.
            ;; fixme: disabled until I figure out correct behaviour for
            ;; `electric-pair-open-newline-between-pairs'.
            (setq electric-pair-open-newline-between-pairs nil)
            (electric-pair-local-mode +1)
            ))

;; LESS

(setq less-css-lessc-options '("--no-color"))

;; Ruby

(add-hook 'ruby-mode-hook
          (lambda ()
            (subword-mode +1)))

(setq-default ruby-insert-encoding-magic-comment nil)

;; Clojure / ClojureScript

(add-hook 'clojure-mode-hook #'paredit-mode)
(add-hook 'paredit-mode-hook
          (lambda ()
            ;; prevent paredit M-? shadowing default binding
            (define-key paredit-mode-map (kbd "M-?") nil)))

;; Elisp

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (unless (equal (buffer-name) "*scratch*")
              (paredit-mode +1))))

;; Shell

(setq sh-basic-offset 2)

;; Git

(defun git-commit-set-line-limits ()
  "Set line length limits when writing commit & pull request messages.
This function is referenced by `git-commit-setup-hook'."
  (if (equal (buffer-name) "PULLREQ_EDITMSG")
      (progn
        (setq-local git-commit-summary-max-length 100)
        ;; `most-positive-fixnum' rather than NIL so
        ;; fill-paragraph & fill-region work
        (setq-local fill-column most-positive-fixnum))
    (setq-local fill-column 72)))
