(defun compile-all (paths)
  (loop for path in (split-string paths)
        do (byte-compile-file path)))
