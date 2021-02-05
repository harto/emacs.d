;; Global key bindings

(global-set-key (kbd "C-c e") 'eval-and-replace-preceding-sexp) ; FIXME: doesn't work :(
(global-set-key [remap open-line] 'open-line-preserving-indent)
;(global-set-key (kbd "M-?") 'grep-project-for-identifier)

;; Backwards window navigation; opposite of `C-x o`.
(global-set-key (kbd "C-x p") (lambda () (interactive) (other-window -1)))
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-x g") 'magit-status)
(global-set-key (kbd "C-x 8 .") (lambda () (interactive) (insert "…")))

;; C-7: flycheck shortcuts
;; (define-prefix-command 'flycheck-shortcuts)
;; (global-set-key (kbd "C-7") 'flycheck-shortcuts)
(global-set-key (kbd "C-7 l") 'flycheck-list-errors)
(global-set-key (kbd "C-7 n") 'flycheck-next-error)
(global-set-key (kbd "C-7 p") 'flycheck-previous-error)
(global-set-key (kbd "C-7 v") 'flycheck-verify-setup)

;; C-8: reserved for mode-specific helpers

;; C-9: project helpers
;; (define-prefix-command 'project)
;; (global-set-key (kbd "C-9") 'project)
(global-set-key (kbd "C-9 r") 'grep-project-for-identifier)

;; C-0: current file/source helpers
;; (define-prefix-command 'edit)
;; (global-set-key (kbd "C-0") 'edit)
(global-set-key (kbd "C-0 a") 'align-regexp)
(global-set-key (kbd "C-0 d") 'diff-current-buffer-with-file)
(global-set-key (kbd "C-0 g") 'magit-file-popup)
(global-set-key (kbd "C-0 r") 'mc/mark-all-symbols-like-this-in-defun)
(global-set-key (kbd "C-0 s") 'sort-lines)
(global-set-key (kbd "C-0 S") 'sort-lines-case-insensitive)

;; Extend isearch-mode to allow yanking thing-at-point
(define-key isearch-mode-map (kbd "M-.") 'isearch-yank-thing-at-point)


