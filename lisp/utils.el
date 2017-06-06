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
  "Join a list of strings with a given separator."
  (mapconcat #'identity strings sep))

(defun string-drop-prefix (prefix s)
  "Returns S without leading PREFIX."
  (if (string-prefix-p prefix s)
      (substring s (length prefix))))

;; (defun string-decamel (s &optional sep)
;;   (replace-regexp-in-string "\\([A-Z]\\)" (concat "\\1" sep) s))

;; ### Project utilities

(defun project-directory ()
  (require 'find-things-fast)
  (let ((root (ftf-project-directory)))
    (if root (directory-file-name root))))

(defun project-relative (path)
  "Returns PATH relative to project root."
  (interactive (list (buffer-file-name)))
  (string-drop-prefix (file-truename (file-name-as-directory (project-directory)))
                      (file-truename path)))

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

(defun save-buffer-and-run-last-emamux-command ()
  (interactive)
  (save-buffer)
  (emamux:run-last-command))