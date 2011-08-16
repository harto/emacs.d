;;; General-purpose Elisp functions

(defun trim (s)
  (replace-regexp-in-string "^[[:blank:]\n]+\\|[[:blank:]\n]+$" "" s))

(defun unquote-string (start end)
  "Removes quotation marks from start and end of each line in region."
  (interactive "r")
  (replace-regexp "^[[:space:]]*\"\\|\"[[:space:]]*\\(\\+\\|;\\)[[:space:]]*$"
                  "" nil start end))

;; Project utilities

(defun project-directory ()
  (directory-file-name (ffip-project-root)))

(setq project-todo-pattern "\\b(TODO|FIXME|XXX)\\b")

(defun project-todo ()
  "Lists outstanding tasks as listed in the sources of the current project."
  (interactive)
  (grep-find (format "find %s -type f ! -path '*/.git/*' -exec grep -EHn '%s' {} \\;"
                     (project-directory)
                     project-todo-pattern)))

(defun project-make ()
  (interactive)
  (let ((dir (project-directory)))
    (if dir
        (shell-command (format "cd %s && make" dir))
      (message "No parent project found"))))

(global-set-key (kbd "C-c t") 'project-todo)
(global-set-key (kbd "C-c m") 'project-make)
