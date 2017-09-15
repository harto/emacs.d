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

(defun cleanup-buffers ()
  "Kill as many buffers as possible."
  (interactive)
  (dolist (buf (buffer-list))
    (if (auto-killable-buffer? buf)
      (kill-buffer buf))))

(defun auto-killable-buffer? (buffer-or-name)
  (let* ((buf (get-buffer buffer-or-name))
         (buf-name (buffer-name buf))
         (buf-mode (with-current-buffer buf major-mode))
         (buf-process (get-buffer-process buf)))
    (or (and (string-match "^\\*.+" buf-name)
             (not (equal "*scratch*" buf-name))
             ;; per `process-kill-buffer-query-function'
             (or (not buf-process)
                 (not (memq (process-status buf-process) '(run stop open listen)))
                 (not (process-query-on-exit-flag buf-process))))
        (eq buf-mode 'dired-mode)
        (not (equal "TAGS" buf-name))
        (not (buffer-modified-p buf)))))
