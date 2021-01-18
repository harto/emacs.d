;; Find things quickly
;; TODO: are these still needed?
;; TODO: monorepo subproject support?

(defun buffer-mode-glob (buffer)
  "Return globs that finds files matching mode of BUFFER.

For a file \"a.foo\", this normally returns the list (\"*.foo\").
For languages that have a variety of file extensions, this might
produce a list of more than one glob. (e.g. for a buffer using
TypeScript mode, the returned list might be (\"*.ts\" \"*.tsx\")."
  (let* ((mode (with-current-buffer buffer
                 major-mode)))
    (if (or (equal mode 'js2-mode)
            (equal mode 'typescript-mode))
        '("\\*.ts" "\\*.tsx" "\\*.js")
      (list (format "\"*.%s\"" (file-name-extension (buffer-file-name buffer)))))))

(defun grep-project-for-identifier (identifier globs)
  "Grep for references to IDENTIFIER in files matching GLOBS.

This is a simplified alternative to `xref-find-references', which tries to do
various things (like reverse-tag lookups) that don't always work reliably.

The glob is a git-grep pattern relative to the root of the project.  It could be
something like \"*\", \"subproject/\", \"*.js\", etc.

When called interactively, the glob is derived from prefix arg:

 - With no prefix arg, search files with extension matching current buffer in
   the current subproject (see `subproject-root').
 - With prefix \\[universal-argument], search all files in current subproject.
   (For non-monorepos, this is the same as searching the entire project.)
 - With prefix \\[universal-argument] \\[universal-argument], search all files
   in the project."
  (interactive (list (symbol-at-point)
                     (cond ((= (prefix-numeric-value current-prefix-arg) 16) '("*"))
                           ((= (prefix-numeric-value current-prefix-arg) 4) (list (subproject-root)))
                           (t (buffer-mode-glob (current-buffer))))))
  (let ((default-directory (project-root))
        (grep-command (format "git --no-pager grep --color -n -Fw -e \"%s\" -- %s%s"
                              identifier
                              (mapconcat #'identity globs " ")
                              (if grep-project-exclude-paths
                                  (mapconcat (lambda (path)
                                               (format " ':!%s'" path))
                                             grep-project-exclude-paths
                                             "")
                                ""))))
    (message grep-command)
    (grep grep-command)))

(defun isearch-yank-thing-at-point ()
  "Put thing at point into the current isearch string."
  (interactive)
  (let ((sym (symbol-at-point)))
    (if sym
        (setq isearch-regexp t
              isearch-string (concat "\\_<" (regexp-quote (symbol-name sym)) "\\_>")
              isearch-message (mapconcat 'isearch-text-char-description isearch-string "")
              isearch-yank-flag t)
      (ding)))
  (isearch-search-and-update))
