;; =====================================
;; Project-related helpers

(defun subproject-root ()
  "Return the root of the current subproject within a monorepo.
For non-monorepos, this is the same as `project-root'."
  ;; FIXME
  (project-root))

(defun project-root ()
  "Return the root of the project containing the current buffer's file."
  (let ((root (ftf-project-directory)))
    (when (and buffer-file-name root)
      (directory-file-name root))))

;; =====================================
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

(defun cleanup-buffers ()
  "Kill as many buffers as possible."
  (interactive)
  (dolist (buf (buffer-list))
    (if (auto-killable-buffer-p buf)
      (kill-buffer buf))))

(defun auto-killable-buffer-p (buffer-or-name)
  (let* ((buf (get-buffer buffer-or-name))
         (buf-name (buffer-name buf))
         (buf-mode (with-current-buffer buf major-mode))
         (buf-process (get-buffer-process buf)))
    (and (or (and (string-match "^\\*.+" buf-name)
                  (not (equal "*scratch*" buf-name))
                  ;; per `process-kill-buffer-query-function'
                  (or (not buf-process)
                      (not (memq (process-status buf-process) '(run stop open listen)))
                      (not (process-query-on-exit-flag buf-process))))
             (eq buf-mode 'dired-mode)
             (not (buffer-modified-p buf)))
         (not (equal "TAGS" buf-name)))))

(defun slurp-file (path)
  (with-temp-buffer
    (insert-file-contents path)
    (buffer-string)))

;; http://emacsredux.com/blog/2013/06/21/eval-and-replace/
(defun eval-and-replace-preceding-sexp ()
  "Replace the preceding sexp with its value."
  (interactive)
  (backward-kill-sexp)
  ;; FIXME: doesn't work
  (let ((sexpr (current-kill 0)))
    (message "%s" sexpr)
    (condition-case nil
        (prin1 (eval (read sexpr))
               (current-buffer))
      (error (message "Invalid expression: %s" sexpr)
             (insert (current-kill 0))))))

(defun diff-current-buffer-with-file ()
  (interactive)
  (diff-buffer-with-file (current-buffer)))

(defun sort-lines-case-insensitive ()
  (interactive)
  (let ((sort-fold-case t))
    ;; TODO: handle prefix arg
    (command-execute 'sort-lines)))

