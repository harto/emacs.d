;; Custom key bindings

;; open-line doesn't indent second line
;; (this isn't perfect either; for some modes it indents the current line)
(global-set-key (kbd "C-o") 'open-line-preserving-indent)

(global-set-key (kbd "M-?") 'grep-project-for-identifier)

;; Backwards window navigation; opposite of `C-x o`.
(global-set-key (kbd "C-x p")
                (lambda ()
                  (interactive)
                  (other-window -1)))

(global-set-key (kbd "C->") 'mc/mark-next-like-this)

;; per http://pragmaticemacs.com/emacs/use-your-digits-and-a-personal-key-map-for-super-shortcuts/
;; make C-0, C-1, ... C-9 available for use
(dotimes (n 10)
  (global-unset-key (kbd (format "C-%d" n))))

(define-prefix-command 'project)
(global-set-key (kbd "C-9") 'project)
(define-key project (kbd "f") 'ftf-find-file)
(define-key project (kbd "g") 'magit-status)
(define-key project (kbd "s") 'ftf-grepsource)

(define-prefix-command 'edit)
(global-set-key (kbd "C-0") 'edit)
(define-key edit (kbd "a") 'align-regexp)
(define-key edit (kbd "s") 'sort-lines)
