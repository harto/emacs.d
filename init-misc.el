;; Settings

(setq-default indent-tabs-mode nil)

(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'scroll-left 'disabled nil)
(put 'set-goal-column 'disabled nil)


(load "~/.emacs.d/vendor/mybuffers.el")
(global-set-key [(control tab)] 'mybuffers-switch)

(load "~/.emacs.d/vendor/find-file-in-project/find-file-in-project.el")
(global-set-key (kbd "C-x C-M-f") 'find-file-in-project)

;; Miscellaneous elisp functions

(defun unquote-string (start end)
  "Removes quotation marks from start and end of each line in region."
  (interactive "r")
  (replace-regexp "^[[:space:]]*\"\\|\"[[:space:]]*\\(\\+\\|;\\)[[:space:]]*$"
                  "" nil start end))