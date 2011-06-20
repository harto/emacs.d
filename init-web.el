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

(defun jslint ()
  (interactive)
  (let ((fname (buffer-file-name)))
    (when fname
      (shell-command (format "jslint %s" fname)))))

(defun js2-declare-jslinted-externs ()
  "Use JSLint /*global ... */ declarations to define js2-additional-externs"
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward "/\\*global \\([^*]+\\)\\*/" nil t)
      (setq js2-additional-externs
            (append (split-string (match-string-no-properties 1) "[ \n\t]*,[ \n\t]*")
                    js2-additional-externs)))))

(add-hook 'js2-mode-hook 'js2-declare-jslinted-externs)

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

