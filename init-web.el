;;; Support for various web-related languages

;; HTML

(setq html-helper-new-buffer-template
      '("<!DOCTYPE html>
<html>
<head>
  <title>" p "</title>
  <link rel=\"stylesheet\" type=\"text/css\" href=\"/css/" p "\" />
</head>

<body>
  " p "
</body>
</html>"))

;; JavaScript

(autoload 'js2-mode "js2-mode")
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
(setq js2-bounce-indent-p t)
(setq js2-cleanup-whitespace t)
(setq js2-consistent-level-indent-inner-bracket-p t)
(setq js2-use-ast-for-indentation-p t)

(defun js2-jslint ()
  (interactive)
  (let ((fname (buffer-file-name)))
    (when fname
      (shell-command (format "jslint %s" fname)))))

(defvar js2-jslint-imports
  "/\\*global \\([^*]+\\)\\*/")

(defun trim (s)
  (replace-regexp-in-string "^[[:blank:]\n]+\\|[[:blank:]\n]+$" "" s))

(defun js2-find-jslint-imports ()
  "Returns a list of JSLint imports as declared in a /*global ... */ block."
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward js2-jslint-imports nil t)
      (mapcar #'trim (split-string (match-string-no-properties 1) ",")))))

(defun js2-declare-jslint-imports ()
  "Use JSLint /*global ... */ declarations to define js2-additional-externs"
  (setq js2-additional-externs (append (js2-find-jslint-imports) js2-additional-externs)))

(defun js2-organise-jslint-imports ()
  "Make /*global ...*/ declarations look nice."
  (interactive)
  (when-let (imports (js2-find-jslint-imports))
    (sort imports 'string<)
    (save-excursion
      (goto-char (point-min))
      (re-search-forward js2-jslint-imports)
      (replace-match "/*global ")
      (dolist (import imports)
        (when (>= (+ (current-column) (length import) 1) 80)
          (delete-char -1)              ;delete trailing " "
          (insert "\n  "))
        (insert import ", "))
      (delete-char -2)                  ;delete trailing ", "
      (insert " */"))))

(add-hook 'js2-mode-hook
          (lambda ()
            ;; Declare imports on load and save
            (js2-declare-jslint-imports)
            (add-hook 'after-save-hook
                      'js2-declare-jslint-imports
                      nil t)
            ;; FIXME: key mappings
            (define-key js2-mode-map (kbd "C-c l") 'js2-jslint)
            (define-key js2-mode-map (kbd "C-c o") 'js2-organise-jslint-imports)))

;; CoffeeScript

(autoload 'coffee-mode "coffee-mode")
(add-to-list 'auto-mode-alist '("\\.coffee$" . coffee-mode))

(setq coffee-tab-width 2)
(setq coffee-args-compile '("-c" "--bare"))

(add-hook 'coffee-mode-hook
          (lambda ()
            (add-hook 'after-save-hook #'coffee-compile-file nil t)))

;; CSS

(setq css-indent-offset 2)

;; LESS CSS

(autoload 'less-css-mode "less-css-mode")
(add-to-list 'auto-mode-alist '("\\.less$" . less-css-mode))

(setq-default less-css-target-directory nil)

(defun less-css-target-filename (source-file &optional target-directory)
  "Calculates the target (CSS) filename for a given source (LESS) path. If the
   given target-directory is nil, the directory of the source file is used."  
  (expand-file-name
   (replace-regexp-in-string "\.less$" ".css" (file-name-nondirectory source-file))
   (file-name-as-directory (or target-directory (file-name-directory source-file)))))

(defun less-css-compile (source-file target-file)
  "Compiles a LESS file to the target CSS file."
  (when (file-exists-p target-file)
    (delete-file target-file))
  (with-temp-buffer
    (call-process "lessc" nil (current-buffer) nil (file-truename source-file))
    (write-file (file-truename target-file)))
  (minibuffer-message "Compiled %s" target-file))

(add-hook 'less-css-mode-hook
          (lambda ()
            (add-hook 'after-save-hook
                      (lambda ()
                        "Compiles current LESS file into a CSS file."
                        (less-css-compile buffer-file-name
                                          (less-css-target-filename
                                           buffer-file-name
                                           less-css-target-directory)))
                      nil t)))

;; ASP (!)

(autoload 'asp-mode "asp-mode.el")
(add-to-list 'auto-mode-alist '("\\.asp$" . asp-mode))

