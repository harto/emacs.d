;;; Find things quickly

;; TODO: monorepo subproject support

(defun grep-project-for-identifier (identifier glob)
  "Greps for references to IDENTIFIER in files matching GLOB.

This is a simplified alternative to `xref-find-references', which tries to do
various things (like reverse-tag lookups) that don't work very well.

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
                     (cond ((= (prefix-numeric-value current-prefix-arg) 16) "*")
                           ((= (prefix-numeric-value current-prefix-arg) 4) (subproject-root))
                           (t (format "\"*.%s\"" (file-name-extension (buffer-file-name)))))))
  (let ((default-directory (project-root)))
    (grep (format "git --no-pager grep --color -n -e \"%s\" -- %s"
                  (format "\\b%s\\b" identifier)
                  glob))))

;; (defadvice grep (before kill-grep-before-grep)
;;   (kill-grep))

;; find-things-fast only searches for extensions used in Chromium source
;; by default. Make it search all filetypes.
(setq-default ftf-filetypes '("*"))
;; Ensure we only grep regular files.
(advice-add 'ftf-get-find-command :around #'ftf-add-files-filter)

(defun ftf-add-files-filter (oldfun &rest args)
  (concat (apply oldfun args) " -type f"))

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
