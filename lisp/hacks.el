;; Workaround https://debbugs.gnu.org/cgi/bugreport.cgi?bug=22596
;; (fixed in Emacs 26.1)
(eval-after-load 'sql
  '(sql-set-product-feature 'postgres
                            :prompt-regexp
                            "^[[:alpha:]_-]*=[#>] "))
