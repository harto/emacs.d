;;; General-purpose Elisp functions

(defun trim (s)
  (replace-regexp-in-string "^[[:blank:]\n]+\\|[[:blank:]\n]+$" "" s))

(defun unquote-string (start end)
  "Removes quotation marks from start and end of each line in region."
  (interactive "r")
  (replace-regexp "^[[:space:]]*\"\\|\"[[:space:]]*\\(\\+\\|;\\)[[:space:]]*$"
                  "" nil start end))

(defun project-todo ()
  "Lists outstanding tasks as listed in the sources of the current project."
  (interactive)
  (grep-find (format "find %s -type f -exec grep -EHn '\\b(TODO|FIXME|XXX)\\b' {} \\;"
                     (directory-file-name (ffip-project-root)))))
