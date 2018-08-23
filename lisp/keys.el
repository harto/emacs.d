;; Custom key bindings

(global-set-key (kbd "C-c e") 'eval-and-replace-preceding-sexp)

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

;; C-7: flycheck shortcuts
(define-prefix-command 'flycheck-shortcuts)
(global-set-key (kbd "C-7") 'flycheck-shortcuts)
(define-key flycheck-shortcuts (kbd "l") 'flycheck-list-errors)
(define-key flycheck-shortcuts (kbd "n") 'flycheck-next-error)
(define-key flycheck-shortcuts (kbd "p") 'flycheck-previous-error)
(define-key flycheck-shortcuts (kbd "v") 'flycheck-verify-setup)

;; C-8: custom extensions for major mode

;; C-9: project helpers
(define-prefix-command 'project)
(global-set-key (kbd "C-9") 'project)
(define-key project (kbd "f") 'ftf-find-file)
(define-key project (kbd "g") 'magit-status)
(define-key project (kbd "s") 'ftf-grepsource)

;; C-0: current file/source helpers
(define-prefix-command 'edit)
(global-set-key (kbd "C-0") 'edit)
(define-key edit (kbd "a") 'align-regexp)
(define-key edit (kbd "d") 'diff-current-buffer-with-file)
(define-key edit (kbd "g") 'magit-file-popup)
(define-key edit (kbd "r") 'mc/mark-all-symbols-like-this-in-defun)
(define-key edit (kbd "s") 'sort-lines)
(define-key edit (kbd "S") 'sort-lines-case-insensitive)

(defun diff-current-buffer-with-file ()
  (interactive)
  (diff-buffer-with-file (current-buffer)))

(defun sort-lines-case-insensitive ()
  (interactive)
  (let ((sort-fold-case t))
    ;; TODO: handle prefix arg
    (command-execute 'sort-lines)))

;; Extend isearch-mode to allow yanking thing-at-point
(define-key isearch-mode-map (kbd "M-.") 'isearch-yank-thing-at-point)

;; Override default M-. in js2-mode
(defun js2-jump ()
  "Look for thing at point in current file, falling back to project-wide search."
  (interactive)
  (condition-case ex
      ;; TODO: figure out how to skip imports
      (command-execute 'js2-jump-to-definition)
    ('error
     (command-execute 'xref-find-definitions))))

(add-hook 'js2-mode
          (lambda ()
            (define-key js2-mode-map (kbd "M-.") 'js2-jump)))
