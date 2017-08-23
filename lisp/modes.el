;;; ====================================
;;; File/mode associations

;; TODO: figure out how to handle autoloads from ad hoc packages
;; (i.e. those not installed via ELPA)
(autoload 'ftf-find-file "find-things-fast")
(autoload 'ftf-grepsource "find-things-fast")
(autoload 'restclient-mode "restclient")

(dolist (pair '((js2-mode . ("\\.js$"))

                (js2-jsx-mode . ("\\.jsx$"))

                (sass-mode . ("\\.scss$"))

                (sql-mode . ("\\.pl[sb]$"))

                (web-mode . ("\\.erb$"
                             "\\.hbs$"
                             "\\.html$"
                             "\\.twig$"))))
  (let ((mode (car pair))
        (patterns (cdr pair)))
    (dolist (pattern patterns)
      (add-to-list 'auto-mode-alist (cons pattern mode)))))

