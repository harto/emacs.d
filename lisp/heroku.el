;; Adapted from https://github.com/technomancy/heroku.el/blob/master/heroku.el

;; TODO: it would be nice to replace this Heroku pseudo-DB with native Postgres
;; support, but for private spaces that might require opening an SSH tunnel or
;; something.

(defun sc/heroku-auth ()
  (shell-command "heroku auth:whoami || yes | heroku auth:login"))

(defvar sc/heroku-sql-login-params
  `(server database))

(defun sc/heroku-sqli-comint (product options &optional buf-name)
  (sc/heroku-auth)
  (when (string= "" sql-server)
    (error "Must provide Heroku app name as \"server\" param in connection options"))
  (let ((params options))
    (sql-comint product (append options (list "-a" sql-server sql-database)) buf-name)))

(with-eval-after-load 'sql
  ;; Add support for Heroku databases.
  (add-to-list 'sql-product-alist
               (cons 'heroku
                     (sc/plist-merge (copy-sequence (alist-get 'postgres sql-product-alist))
                                     '(:name "Heroku"
                                       :sqli-program "heroku"
                                       :sqli-options ("pg:psql")
                                       :sqli-login sc/heroku-sql-login-params
                                       :sqli-comint-func sc/heroku-sqli-comint
                                       ;; add colons to match prompt like app-name::db-name=>
                                       :prompt-regexp "^[[:alpha:]_:-]*=[#>] "
                                       :prompt-cont-regexp "^[[:alnum:]_:-]*[-(][#>] ")))))
