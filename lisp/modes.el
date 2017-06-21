;;; ====================================
;;; File/mode associations

;; TODO: figure out how to handle autoloads from ad hoc packages
;; (i.e. those not installed via ELPA)
(autoload 'restclient-mode "restclient")

(setq mode-filename-patterns '((js2-mode . ("\\.js$"))

                               (js2-jsx-mode . ("\\.jsx$"))

                               (sass-mode . ("\\.scss$"))

                               (sql-mode . ("\\.pl[sb]$"))

                               (web-mode . ("\\.erb$"
                                            "\\.hbs$"
                                            "\\.html$"
                                            "\\.twig$"))))

(dolist (pair mode-filename-patterns)
  (let ((mode (car pair))
        (patterns (cdr pair)))
    (dolist (pattern patterns)
      (add-to-list 'auto-mode-alist (cons pattern mode)))))

