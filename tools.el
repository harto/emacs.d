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

;; Allow hooks to be defined in .dir-locals.el

(defun project-apply-directory-hooks ()
  "Sets directory-local hooks using the value of `directory-hooks', which is a
   list of (hook-name hook-function) pairs."
  (when (boundp 'directory-hooks)
    (dolist (hook-definition directory-hooks)
      (add-hook (car hook-definition)
                (cdr hook-definition)
                nil t))))

(add-hook 'hack-local-variables-hook #'project-apply-directory-hooks)
