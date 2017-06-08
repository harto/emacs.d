;; Workaround https://debbugs.gnu.org/cgi/bugreport.cgi?bug=22596
;; (fixed in Emacs 26.1)
(require 'sql)
;; FIXME: figure out the right hook to do this lazily
(sql-set-product-feature 'postgres
                         :prompt-regexp
                         "^[[:alpha:]_]*=[#>] ")
