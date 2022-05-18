(defun sc/buffer-string (buffer)
  "Return BUFFER contents as a string."
  (with-current-buffer buffer
    (buffer-substring-no-properties (point-min) (point-max))))

(defun sc/string-replace (substr rep str)
  "Replace occurences of SUBSTR in STR with REP"
  (replace-regexp-in-string substr rep str nil t))

;; Adapted from: https://emacs.stackexchange.com/a/19076
(defun sc/plist-merge (&rest plists)
  "Merge one or more property lists."
  (let ((ret (pop plists)))
    (dolist (plist plists ret)
      (dolist (entry (seq-partition plist 2))
        (plist-put ret (car entry) (cadr entry))))))
