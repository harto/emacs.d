;; Mode configurations

;; =====================================
;; Python

(setq python-shell-setup-codes '("import pydoc; pydoc.pager = pydoc.plainpager; print('disabled pydoc pager')"))

;; =====================================
;; JavaScript

(setq-default js2-basic-offset 2)
(setq-default js2-bounce-indent-p t)
(setq-default js2-cleanup-whitespace t)

(add-hook 'js2-mode-hook #'configure-js2-mode)

(defun configure-js2-mode ()
  ;; sane word navigation
  (subword-mode +1)
  ;; balance parens etc.
  ;; fixme: disabled until I figure out correct behaviour for
  ;; `electric-pair-open-newline-between-pairs'.
  (setq electric-pair-open-newline-between-pairs nil)
  (electric-pair-local-mode +1)
  ;; override jump to definition in js2-mode
  (define-key js2-mode-map (kbd "M-.") 'js2-jump))

(defun js2-jump ()
  "Look for thing at point in current file, falling back to project-wide search."
  (interactive)
  (condition-case ex
      ;; TODO: figure out how to skip imports
      (command-execute 'js2-jump-to-definition)
    ('error
     (command-execute 'xref-find-definitions))))

;; =====================================
;; TypeScript

(add-hook 'typescript-mode-hook #'configure-typescript-mode)
(add-hook 'typescript-mode-hook 'lsp)

(defun configure-typescript-mode ()
  (electric-pair-local-mode +1)
  (subword-mode +1)
  (local-set-key (kbd "C-8 r") 'lsp-rename))

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
;; Lisp

(add-hook 'lisp-mode-hook #'paredit-mode)

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
(with-eval-after-load 'sql
  (sql-set-product-feature 'postgres
                           :prompt-regexp
                           "^[[:alpha:]_-]*=[#>] "))

;; =====================================
;; Org

(setq org-startup-indented t)

(with-eval-after-load 'org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (ruby . t)
     (shell . t)
     (sql . t)))
  ;; Markdown export
  (require 'ox-md))


;; =====================================
;; Non-default file/mode associations

(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.jsx$" . js2-jsx-mode))
(add-to-list 'auto-mode-alist '("\\.tsx$" . typescript-mode))
(add-to-list 'auto-mode-alist '("\\.scss$" . sass-mode))
(add-to-list 'auto-mode-alist '("\\.pl[bs]$" . sql-mode))
(add-to-list 'auto-mode-alist '("\\.\\(erb\\|hbs\\|html\\|twig\\)$" . web-mode))

;; =====================================
;; Global modes

(show-paren-mode +1)
(yas-global-mode +1)
