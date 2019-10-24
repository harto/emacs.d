;; Mode configurations

;; =====================================
;; JavaScript

(setq-default js2-basic-offset 2)
(setq-default js2-bounce-indent-p t)
(setq-default js2-cleanup-whitespace t)

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
            (electric-pair-local-mode +1)))

;; =====================================
;; Flow mode

(define-derived-mode flow-mode typescript-mode "Flow"
  "JavaScript with Flow type-checking")

(add-hook 'flow-mode-hook #'configure-flow-mode)

(defun configure-flow-mode ()
  (electric-pair-local-mode +1)
  (subword-mode +1))

;; =====================================
;; Ruby

(add-hook 'ruby-mode-hook
          (lambda ()
            (subword-mode +1)))

(setq-default ruby-insert-encoding-magic-comment nil)

;; =====================================
;; Clojure / ClojureScript

(add-hook 'clojure-mode-hook #'paredit-mode)
(add-hook 'paredit-mode-hook
          (lambda ()
            ;; prevent paredit M-? shadowing default binding
            (define-key paredit-mode-map (kbd "M-?") nil)))

;; =====================================
;; Elisp

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (unless (equal (buffer-name) "*scratch*")
              (paredit-mode +1))
            ;; Don't care about documentation
            (setq-local flycheck-disabled-checkers '(emacs-lisp-checkdoc))))

;; =====================================
;; Shell

(setq-default sh-basic-offset 2)

;; =====================================
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

;; =====================================
;; Java

(add-hook 'java-mode-hook
          (lambda ()
            (setq-local c-basic-offset 2)))

;; =====================================
;; SQL

(add-hook 'sql-interactive-mode-hook
          (lambda ()
            (toggle-truncate-lines t)))

;; Handle dashes in database names
(eval-after-load 'sql
  '(sql-set-product-feature 'postgres
                            :prompt-regexp
                            "^[[:alpha:]_-]*=[#>] "))

;; =====================================
;; Org

(setq org-startup-indented t)

;; =====================================
;; ido

;; layout results vertically
(setq ido-decorations (list "\n-> " ""
                            "\n   "
                            "\n   ..."
                            "[" "]"
                            " [No match]"
                            " [Matched]"
                            " [Not readable]"
                            " [Too big]"
                            " [Confirm]"))

;; effectively disable auto-merge
(setq ido-auto-merge-delay-time 999)

;; =====================================
;; File/mode associations

;; TODO: figure out how to handle autoloads from ad hoc packages
;; (i.e. those not installed via ELPA)
;; (autoload 'ftf-find-file "find-things-fast")
;; (autoload 'ftf-grepsource "find-things-fast")
;; (autoload 'ftf-project-directory "find-things-fast")
;; (autoload 'restclient-mode "restclient")

(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.jsx$" . js2-jsx-mode))
(add-to-list 'auto-mode-alist '("\\.scss$" . sass-mode))
(add-to-list 'auto-mode-alist '("\\.pl[bs]$" . sql-mode))
(add-to-list 'auto-mode-alist '("\\.\\(erb\\|hbs\\|html\\|twig\\)$" . web-mode))

;; =====================================
;; Global modes

(show-paren-mode +1)
(line-number-mode +1)
(column-number-mode +1)
(global-flycheck-mode +1)
(yas-global-mode +1)
(global-ws-trim-mode t)
(ido-mode +1)
(ido-everywhere +1)
;; (require 'flx-ido)
(flx-ido-mode +1)
