;; Support for various programming languages

;; JavaScript

(setq js2-bounce-indent-p t)
(setq js2-cleanup-whitespace t)
;; TODO: find out what these did and update them
;; (setq js2-consistent-level-indent-inner-bracket-p t)
;; (setq js2-use-ast-for-indentation-p t)

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

;; Clojure / ClojureScript

(add-hook 'clojure-mode-hook #'paredit-mode)

;; Elisp

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (unless (equal (buffer-name) "*scratch*")
              (paredit-mode +1))))

;; Shell

(setq sh-basic-offset 2)

;; Git

(defun git-commit-maybe-unset-line-limits ()
  "Unset line length limitations when writing pull request messages.
This function could be referenced by `git-commit-setup-hook'."
  (when (string-match (buffer-name) "PULLREQ_EDITMSG")
    (setq-local git-commit-summary-max-length 100)
    (setq-local fill-column nil)))
