;;; ====================================
;;; File/mode associations

;; TODO: figure out how to handle autoloads from ad hoc packages
;; (i.e. those not installed via ELPA)
(autoload 'restclient-mode "restclient")

(setq mode-filename-patterns '((clojure-mode . ("\\.clj$"
                                                "\\.cljx$"))

                               (clojurescript-mode . ("\\.cljs$"))

                               (js2-mode . ("\\.js$"
                                            "\\.jsx$"))

                               (less-css-mode . ("\\.less$"))

                               (markdown-mode . ("\\.markdown$"
                                                 "\\.md$"))

                               (ruby-mode . ("\\.builder$"
                                             "\\.rake$"
                                            "\\bCapfile$"
                                             "\\bGemfile$"
                                             "\\bRakefile$"))

                               (sass-mode . ("\\.scss$"))

                               (sql-mode . ("\\.pl[sb]$"))

                               (web-mode . ("\\.erb$"
                                            "\\.hbs$"
                                            "\\.html$"
                                            "\\.twig$"))

                               (yaml-mode . ("\\.yaml$"))))

(dolist (pair mode-filename-patterns)
  (let ((mode (car pair))
        (patterns (cdr pair)))
    (dolist (pattern patterns)
      (add-to-list 'auto-mode-alist (cons pattern mode)))))

