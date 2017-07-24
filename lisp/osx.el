;; Mac OS X interop

(defun osx-copy ()
  (shell-command-to-string "pbpaste"))

(defun osx-paste (text &optional push)
  (let ((process-connection-type nil))
    (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
      (process-send-string proc text)
      (process-send-eof proc))))

;; Note: copy-paste under tmux needs some additional configuration.
;; See https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard

(setq interprogram-paste-function 'osx-copy)
(setq interprogram-cut-function 'osx-paste)

(defun set-exec-path-from-shell-path ()
  (let ((path (shell-command-to-string "$SHELL -lc 'echo -n $PATH'")))
    (setenv "PATH" path)
    (setq exec-path (split-string path path-separator))))

(when (display-graphic-p)
  (set-exec-path-from-shell-path))
