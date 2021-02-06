;; (defun project-root ()
;;   "Return the root of the project containing the current buffer's file."
;;   (let ((root (ftf-project-directory)))
;;     (when (and buffer-file-name root)
;;       (directory-file-name root))))

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

;; (defun slurp-file (path)
;;   (with-temp-buffer
;;     (insert-file-contents path)
;;     (buffer-string)))
