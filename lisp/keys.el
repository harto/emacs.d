;;; ====================================
;;; Custom key bindings

;; open-line doesn't indent second line
;; (this isn't perfect either; for some modes it indents the current line)
(global-set-key (kbd "C-o") #'open-line-preserving-indent)

;; Backwards window navigation; opposite of `C-x o`.
(global-set-key (kbd "C-x p")
                (lambda ()
                  (interactive)
                  (other-window -1)))

(global-set-key (kbd "C-c g") 'magit-status)

(global-set-key (kbd "C-c M-s") 'sort-lines)

;; Multiple cursors
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

;; Finding things
(global-set-key (kbd "C-c f") 'find-project-file)
(global-set-key (kbd "C-c s") 'grep-project)
