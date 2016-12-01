;; Support for various programming languages

;; ## Web stuff
(setq web-mode-extensions '("html" "twig" "erb" "hbs"))
(setq web-mode-pattern (format "\\.\\(%s\\)$" (mapconcat #'regexp-quote web-mode-extensions "\\|")))
(add-to-list 'auto-mode-alist `(,web-mode-pattern . web-mode))

;; ## JavaScript

(autoload 'js2-mode "js2-mode")
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.jsx$" . js2-mode))

(setq js2-bounce-indent-p t)
(setq js2-cleanup-whitespace t)
(setq js2-consistent-level-indent-inner-bracket-p t)
(setq js2-use-ast-for-indentation-p t)

(add-hook 'js2-mode-hook
          (lambda ()
            ;; inline linting
            ;(require 'flymake-jshint)
            ;(flymake-mode)
            ;; sane word navigation
            (subword-mode +1)
            ;; balance parens etc.
            (local-electric-pair-mode)))

;; LESS

(add-to-list 'auto-mode-alist '("\\.less$" . less-css-mode))
(setq less-css-lessc-options '("--no-color"))

;; SCSS

(add-to-list 'auto-mode-alist '("\\.scss$" . sass-mode))

;; ## Ruby

(dolist (pattern '("\\bRakefile$"
                   "\\.rake$"
                   "\\bGemfile$"
                   "\\bCapfile$"
                   "\\.builder$"))
  (add-to-list 'auto-mode-alist `(,pattern . ruby-mode)))

(add-hook 'ruby-mode-hook
          (lambda ()
            (subword-mode +1)))

;; ## SQL

(add-to-list 'auto-mode-alist '("\\.pl[sb]$" . sql-mode))

;; ## Lisp

(autoload 'paredit-mode "paredit")

;; Clojure / ClojureScript

(defun cljs-buffer-p ()
  "Test if current buffer is a ClojureScript buffer."
  (equal 'clojurescript-mode major-mode))

(add-to-list 'auto-mode-alist '("\\.clj$" . clojure-mode))
(add-to-list 'auto-mode-alist '("\\.cljx$" . clojure-mode))
(add-to-list 'auto-mode-alist '("\\.cljs$" . clojurescript-mode))

(add-hook 'clojure-mode-hook #'paredit-mode)

;; Elisp

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (unless (equal (buffer-name) "*scratch*")
              (paredit-mode +1))))

;; ## Shell

(setq sh-basic-offset 2)
