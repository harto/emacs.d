;;; General-purpose Elisp functions

;; ### String utils

(defun string-trim (s)
  (replace-regexp-in-string "^[[:blank:]\n]+\\|[[:blank:]\n]+$" "" s))

(defun string-unquote (start end)
  "Removes quotation marks from start and end of each line in region."
  (interactive "r")
  (replace-regexp "^[[:space:]]*\"\\|\"[[:space:]]*\\(\\+\\|;\\)[[:space:]]*$"
                  "" nil start end))

(defun string-join (strings sep)
  (mapconcat #'identity strings sep))

(defun string-drop-prefix (s prefix)
  "Returns S without leading PREFIX."
  (if (string-prefix-p prefix s)
      (substring s (length prefix))
    s))

;; ### Project utilities

(defun project-directory ()
  (let ((root (ffip-project-root)))
    (if root (directory-file-name root))))

(defun project-make ()
  (interactive)
  (let ((root (locate-dominating-file (buffer-file-name) "Makefile")))
    (if root
        (shell-command (format "cd %s && make" root))
      (message "No Makefile found"))))

;; Allow hooks to be defined in .dir-locals.el

(defun project-apply-directory-hooks ()
  "Sets directory-local hooks using the value of `directory-hooks-alist', which
   is a list of (hook-name . hook-function) pairs."
  (when (boundp 'directory-hooks-alist)
    (dolist (hook-definition directory-hooks-alist)
      (add-hook (car hook-definition)
                (cdr hook-definition)
                nil t))))

(add-hook 'hack-local-variables-hook #'project-apply-directory-hooks)

;; ## Misc

(defun open-line-preserving-indent (n)
  "Like `open-line', but correctly indents both current and trailing line.
Passes arg N to `open-line'."
  (interactive "*p")
  (open-line n)
  (indent-for-tab-command)
  (save-excursion
    (next-line n)
    (indent-for-tab-command)))
