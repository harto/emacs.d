;;; ====================================
;;; File/mode associations

;; TODO: figure out how to handle autoloads from ad hoc packages
;; (i.e. those not installed via ELPA)
(autoload 'ftf-find-file "find-things-fast")
(autoload 'ftf-grepsource "find-things-fast")
(autoload 'ftf-project-directory "find-things-fast")
(autoload 'restclient-mode "restclient")

(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.jsx$" . js2-jsx-mode))
(add-to-list 'auto-mode-alist '("\\.scss$" . sass-mode))
(add-to-list 'auto-mode-alist '("\\.pl[bs]$" . sql-mode))
(add-to-list 'auto-mode-alist '("\\.\\(erb\\|hbs\\|html\\|twig\\)$" . web-mode))

