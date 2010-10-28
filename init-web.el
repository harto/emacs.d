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

(setq js2-bounce-indent-p t)
(setq js2-cleanup-whitespace t)

;; CSS

(setq css-indent-offset 2)

;; LESS

(add-to-list 'auto-mode-alist '("\\.less$" . css-mode))

;; ASP (!)

(autoload 'asp-mode "asp-mode.el")
(add-to-list 'auto-mode-alist '("\\.asp$" . asp-mode))

