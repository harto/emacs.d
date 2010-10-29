;; Settings

(setq-default indent-tabs-mode nil)
(setq-default require-final-newline t)

(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'scroll-left 'disabled nil)
(put 'set-goal-column 'disabled nil)

;; Provide C-Tab switching between buffers

(load "~/.emacs.d/vendor/mybuffers.el")
(global-set-key [(control tab)] 'mybuffers-switch)

;; FFIP

(load "~/.emacs.d/vendor/find-file-in-project/find-file-in-project.el")
(global-set-key (kbd "C-x C-M-f") 'find-file-in-project)

;; Line numbering

(require 'linum)
(global-linum-mode 1)

;; Miscellaneous elisp functions

(defun unquote-string (start end)
  "Removes quotation marks from start and end of each line in region."
  (interactive "r")
  (replace-regexp "^[[:space:]]*\"\\|\"[[:space:]]*\\(\\+\\|;\\)[[:space:]]*$"
                  "" nil start end))