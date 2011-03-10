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

(autoload 'js2-mode "js2-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
(setq js2-bounce-indent-p t)
(setq js2-cleanup-whitespace t)
(setq js2-consistent-level-indent-inner-bracket-p t)
(setq js2-use-ast-for-indentation-p t)

;; CSS

(setq css-indent-offset 2)

;; LESS quasi-mode

(add-to-list 'auto-mode-alist '("\\.less$" . css-mode))
(setq-default compile-less nil)
(add-hook 'after-save-hook
          (lambda ()
            (when (and (string-match "\\.less$" buffer-file-name)
                       compile-less)
              (funcall compile-less))))

;; ASP (!)

(autoload 'asp-mode "asp-mode.el")
(add-to-list 'auto-mode-alist '("\\.asp$" . asp-mode))

