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

;; ## JavaScript

(autoload 'js2-mode "js2-mode")
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

(setq js2-bounce-indent-p t)
(setq js2-cleanup-whitespace t)
(setq js2-consistent-level-indent-inner-bracket-p t)
(setq js2-use-ast-for-indentation-p t)

(add-hook 'js2-mode-hook
          (lambda ()
            (load-library "jslint")
            ;; Declare imports on load and save
            (js2-declare-jslint-imports)
            (add-hook 'after-save-hook
                      'js2-declare-jslint-imports
                      nil t)
            (define-key js2-mode-map (kbd "C-c l") 'jslint-buffer-file)
            (define-key js2-mode-map (kbd "C-c o") 'jslint-organise-imports)))

;; CoffeeScript

(autoload 'coffee-mode "coffee-mode")
(add-to-list 'auto-mode-alist '("\\.coffee$" . coffee-mode))

(setq coffee-tab-width 2)
(setq coffee-args-compile '("-c" "--bare"))

(add-hook 'coffee-mode-hook
          (lambda ()
            (add-hook 'after-save-hook #'coffee-compile-file nil t)))

;; ## CSS

(setq css-indent-offset 2)

;; LESS

(autoload 'less-css-mode "less-css-mode")
(add-to-list 'auto-mode-alist '("\\.less$" . less-css-mode))

;; ## PHP

(add-to-list 'auto-mode-alist '("\\.php$" . php-mode))

(defun php-mode-settings ()
  (define-key php-mode-map (kbd "C-M-a") 'php-beginning-of-defun)
  (define-key php-mode-map (kbd "C-M-e") 'php-end-of-defun))

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
  (string-match "\\.cljs$" (buffer-name)))

(add-to-list 'auto-mode-alist '("\\.cljs?$" . clojure-mode))
(add-hook 'clojure-mode-hook
          (lambda ()
            (paredit-mode +1)
            (when (not (cljs-buffer-p))
              (define-key clojure-mode-map (kbd "C-c C-j") 'clojure-jack-in))))

;; ClojureScript doesn't work with SLIME. When we evaluate cljs forms they
;; should be sent to the inferior-lisp REPL instead.
(defadvice slime-mode (around cljs-disable-slime)
  "Activates `slime-mode' iff the current buffer isn't a .cljs file."
  (when (not (cljs-buffer-p))
    ad-do-it))

(setq slime-kill-without-query-p t)

;; Elisp

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (when (not (equal (buffer-name) "*scratch*"))
              (paredit-mode +1))))

