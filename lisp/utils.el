;; =====================================
;;  Strings

(defun string-trim (s)
  (replace-regexp-in-string "^[[:blank:]\n]+\\|[[:blank:]\n]+$" "" s))

(defun string-unquote (start end)
  "Removes quotation marks from start and end of each line in region."
  (interactive "r")
  (replace-regexp "^[[:space:]]*\"\\|\"[[:space:]]*\\(\\+\\|;\\)[[:space:]]*$"
                  "" nil start end))

(defun string-join (strings sep)
  "Join a list of strings with a given separator."
  (mapconcat #'identity strings sep))

(defun string-drop-prefix (prefix s)
  "Returns S without leading PREFIX."
  (if (string-prefix-p prefix s)
      (substring s (length prefix))))

;; =====================================
;; Project-related helpers

(defun project-directory ()
  (require 'find-things-fast)
  (let ((root (ftf-project-directory)))
    (if root (directory-file-name root))))

;;=====================================
;; Misc

(defun open-line-preserving-indent (n)
  "Like `open-line', but makes a better attempt at indenting the new line.
Passes arg N to `open-line'."
  (interactive "*p")
  (open-line n)
  (unless (zerop (current-indentation))
    ;; TODO: make it work with `n' open lines
    (save-excursion
      (next-line)
      (beginning-of-line)
      (delete-horizontal-space)
      (indent-for-tab-command))))
