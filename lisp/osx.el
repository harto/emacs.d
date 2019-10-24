;; Mac OS X interop

(defun osx-copy ()
  (shell-command-to-string "pbpaste"))

(defun osx-paste (text &optional push)
  (let ((process-connection-type nil))
    (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
      (process-send-string proc text)
      (process-send-eof proc))))

(setq interprogram-paste-function 'osx-copy)
(setq interprogram-cut-function 'osx-paste)

;; Work around OS X environment nonsense by reading it from shell profile

(defun load-env-from-shell ()
  (dolist (line (split-string (shell-command-to-string "$SHELL -lc env") "\n" t))
    (let* ((parts (split-string line "="))
           (k (nth 0 parts))
           (v (nth 1 parts)))
      (setenv k v))))

(defun reset-exec-path-from-env ()
  (setq exec-path (split-string (getenv "PATH") path-separator)))

(when (display-graphic-p)
  (load-env-from-shell)
  (reset-exec-path-from-env))
