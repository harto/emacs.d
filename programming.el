;; Support for various programming languages

;; ## HTML

(setq html-helper-new-buffer-template
      '("<!DOCTYPE html>
<html>
<head>
  <title>" p "</title>
  <link rel=\"stylesheet\" href=\"" p "\">
  <script src=\"\"></script>
</head>

<body>
  " p "
</body>
</html>"))

;; Jinja2 templates

(add-to-list 'auto-mode-alist '("\\.jinja2$" . html-mode))

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

;; flymake JSLint integration

(defvar flymake-jslint-cmd "~/.emacs.d/bin/flymake-jslint"
  "JSLint command used by flymake.")
(defvar flymake-jslint-cmd-opts '("--vars=true"
                                  "--maxerr=100"
                                  "--regexp=true")
  "Options passed to `flymake-jslint-cmd'.")
(defvar flymake-jslint-err-patterns '(("^\\([0-9]+\\):\\([0-9]+\\):\\(.+\\)$" nil 1 2 3))
  "Regexps matching `flymake-jslint-cmd' error messages.")

(defun flymake-jslint-init ()
  "Returns the linting command used by flymake."
  (let ((tempfile (file-relative-name (flymake-init-create-temp-buffer-copy
                                       'flymake-create-temp-inplace)
                                      (file-name-directory buffer-file-name))))
    (list flymake-jslint-cmd (append flymake-jslint-cmd-opts (list tempfile)))))

(defun flymake-jslint-load ()
  (require 'flymake)
  (require 'flymake-cursor)
  (set (make-local-variable 'flymake-err-line-patterns)
       flymake-jslint-err-patterns)
  (set (make-local-variable 'flymake-allowed-file-name-masks)
       '(("\\.js$" flymake-jslint-init)))
  (set (make-local-variable 'flymake-cursor-error-display-delay) 0.5)
  (custom-set-faces '(flymake-errline ((((class color)) (:underline "yellow")))))
  (flymake-mode 1)
  (flymake-cursor-mode 1))

(add-hook 'js2-mode-hook
          (lambda ()
            ;; Update js2-additional-externs on load and save
            (js2-declare-jslint-imports)
            (add-hook 'after-save-hook
                      'js2-declare-jslint-imports
                      nil t)
            (define-key js2-mode-map (kbd "C-c o") 'jslint-organise-imports)
            ;; inline linting
            (flymake-jslint-load)))

;; ## CSS

(setq css-indent-offset 2)

;; LESS

(add-to-list 'auto-mode-alist '("\\.less$" . less-css-mode))
(setq less-css-lessc-options '("--no-color"))

;; ## PHP

(add-to-list 'auto-mode-alist '("\\.php$" . php-mode))

(defadvice c-electric-slash (before php-close-phpdoc-comment)
  (when (and (equal major-mode 'php-mode)
             (eolp)
             (looking-back "^[[:space:]]+\\*[[:space:]]+"))
    (delete-horizontal-space t)))

(defun php-mode-settings ()
  (define-key php-mode-map (kbd "C-M-a") 'php-beginning-of-defun)
  (define-key php-mode-map (kbd "C-M-e") 'php-end-of-defun)
  (set (make-local-variable 'comment-start) "//")
  (set (make-local-variable 'comment-end) "")
  (set (make-local-variable 'comment-style) 'indent))

(add-hook 'php-mode-hook #'php-mode-settings)

;; ## Ruby

(add-to-list 'auto-mode-alist '("\\(\\bRakefile\\|\\.rake\\)$" . ruby-mode))

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
(defadvice slime-mode (around cljs-disable-slime)
  "Activates `slime-mode' iff the current buffer isn't a .cljs file."
  (unless (cljs-buffer-p)
    ad-do-it))

(setq slime-kill-without-query-p t)

;; Elisp

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (unless (equal (buffer-name) "*scratch*")
              (paredit-mode +1))))

