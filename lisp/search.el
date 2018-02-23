;; Find things quickly

;; TODO: monorepo subproject support

(defun grep-project-for-identifier (&optional identifier)
  "An alternative to `xref-find-references' that unconditionally uses git-grep."
  (interactive (list ;; (if (= (prefix-numeric-value current-prefix-arg) 4)
                     ;;     (prompt-for-identifier (if (symbol-at-point)
                     ;;                                (symbol-name (symbol-at-point))
                     ;;                              nil))
                     ;;   (symbol-at-point))
                     (symbol-at-point)))
  (let* ((identifier-regexp (format "\\b%s\\b" identifier))
         (git-path (if (= (prefix-numeric-value current-prefix-arg) 4)
                       "*"  ; FIXME: is this useful?
                     (format "\"*.%s\"" (file-name-extension (buffer-file-name)))))
         (cmd (format "git --no-pager grep --color -n -e \"%s\" -- %s"
                      identifier-regexp
                      git-path))
         (default-directory (project-directory)))
    (grep cmd)))

(defun prompt-for-identifier (default-identifier)
  ;(message "default-identifier: %s (%s)" default-identifier (type-of default-identifier))
  (read-string (format "Grep project for identifier%s: " (if default-identifier
                                                             (format " (%s)" default-identifier) ""))
               nil nil default-identifier))

;; (defadvice grep (before kill-grep-before-grep)
;;   (kill-grep))

(eval-after-load 'find-things-fast
  '(progn
     (setq-default ftf-filetypes '("*"))
     (advice-add 'ftf-get-find-command :around #'ftf-add-files-filter)))

(defun ftf-add-files-filter (oldfun &rest args)
  (concat (apply oldfun args) " -type f"))
