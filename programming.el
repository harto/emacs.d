;; Support for various programming languages

;; ## Web stuff
(setq web-mode-extensions '("html" "twig" "erb"))
(setq web-mode-pattern (format "\\.\\(%s\\)$" (mapconcat #'regexp-quote web-mode-extensions "\\|")))
(add-to-list 'auto-mode-alist `(,web-mode-pattern . web-mode))

;; ## JavaScript

(autoload 'js2-mode "js2-mode")
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

(setq js2-bounce-indent-p t)
(setq js2-cleanup-whitespace t)
(setq js2-consistent-level-indent-inner-bracket-p t)
(setq js2-use-ast-for-indentation-p t)

;; /*global ...*/ organisation
;;
;; Use `jslint-organise-imports' to remove unused imports and arrange imports
;; nicely. Use `js2-declare-jslint-imports' to add imports to
;; `js2-additional-externs', avoiding `js2-mode' warnings.

(defvar jslint-imports-pattern "/\\*global \\([^*]+\\)\\*/"
  "Regular expression matching /*global ...*/ declarations.")

(defvar jslint-global-max-column 80
  "Column at which to wrap /*global ...*/ declarations.")

(defun jslint-import-declarations ()
  "Returns a list of import declarations within the /*global ...*/ block of the
   current buffer."
  (save-excursion
    (goto-char (point-min))
    (if (re-search-forward jslint-imports-pattern nil t)
        (let ((body (match-string-no-properties 1)))
          (delete-dups (mapcar #'string-trim (split-string body ",")))))))

(defun jslint-symbol (import-declaration)
  "Returns the name of the symbol in an import declaration. Imports may be of
   the form `<symbol>:true`, indicating that variable reassignment is allowed."
  (car (split-string import-declaration ":")))

(defun jslint-unreferenced-symbol-p (symbol)
  "Returns true if a symbol is unreferenced beyond the JSLint /*global ...*/
   declaration."
  (save-excursion
    (goto-char (point-min))
    (re-search-forward jslint-imports-pattern)
    (not (re-search-forward (format "\\b%s\\b" symbol) nil t))))

(defun jslint-organise-imports ()
  "Makes existing /*global ...*/ block look nice."
  (interactive)
  (let ((imports (jslint-import-declarations)))
    (when imports
      ;; Remove unused imports
      (setq imports (remove-if (lambda (import-declaration)
                                 (jslint-unreferenced-symbol-p
                                  (jslint-symbol import-declaration)))
                               imports))
      ;; TODO: would be nice to have uppercased stuff appear first
      (setq imports (sort imports 'string<))
      (save-excursion
        ;; Replace existing import list
        (goto-char (point-min))
        (re-search-forward jslint-imports-pattern)
        (replace-match "/*global ")
        (dolist (import imports)
          (when (>= (+ (current-column) (length import) 1)
                    jslint-global-max-column)
            (delete-char -1)              ;delete trailing " "
            (insert "\n  "))
          (insert import ", "))
        (delete-char -2)                  ;delete trailing ", "
        (insert " */")))))

(defun js2-declare-jslint-imports ()
  "Use JSLint /*global ... */ declarations to define `js2-additional-externs'."
  (setq js2-additional-externs
        (delete-dups (append (mapcar #'jslint-symbol
                                     (jslint-import-declarations))
                             js2-additional-externs))))

(add-hook 'js2-mode-hook
          (lambda ()
            ;; Update js2-additional-externs on load and save
            (js2-declare-jslint-imports)
            (add-hook 'after-save-hook
                      'js2-declare-jslint-imports
                      nil t)
            (define-key js2-mode-map (kbd "C-c o") 'jslint-organise-imports)
            ;; inline linting
            (require 'flymake-jshint)
            (flymake-mode)))

;; ## CSS

(setq css-indent-offset 2)

;; LESS

(add-to-list 'auto-mode-alist '("\\.less$" . less-css-mode))
(setq less-css-lessc-options '("--no-color"))

;; SCSS

(add-to-list 'auto-mode-alist '("\\.scss$" . sass-mode))

;; ## Ruby

(dolist (pattern '("\\bRakefile$"
                   "\\.rake$"
                   "\\bGemfile$"
                   "\\bCapfile$"))
  (add-to-list 'auto-mode-alist `(,pattern . ruby-mode)))

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
(add-hook 'clojure-mode-hook
          (lambda ()
            (paredit-mode +1)
            (unless (cljs-buffer-p)
              (define-key clojure-mode-map (kbd "C-c C-j") 'nrepl-jack-in))))

;; ClojureScript doesn't work with SLIME. When we evaluate cljs forms they
;; should be sent to the inferior-lisp REPL instead.
;; FIXME: is this relevant anymore?
(defadvice slime-mode (around cljs-disable-slime)
  "Activates `slime-mode' iff the current buffer isn't a .cljs file."
  (unless (cljs-buffer-p)
    ad-do-it))

;; nrepl customisations
(add-hook 'nrepl-interaction-mode-hook 'nrepl-turn-on-eldoc-mode)
(add-hook 'nrepl-mode-hook 'paredit-mode)

;; Elisp

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (unless (equal (buffer-name) "*scratch*")
              (paredit-mode +1))))

;; ## Shell

(setq sh-basic-offset 2)
