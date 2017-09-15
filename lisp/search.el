;; Find things quickly

;; TODO: monorepo subproject support

;; TODO: find symbol according to current mode (check if this needs fixing)
;; TODO: optionally expand search to all filetypes in project
;; TODO: fallback to various kinds of grep (rg, find|xargs)
(defun grep-project-for-identifier (&optional identifier)
  "An alternative to `xref-find-references' that unconditionally uses git-grep."
  (interactive (list (if (= (prefix-numeric-value current-prefix-arg) 4)
                         (prompt-for-identifier (symbol-at-point))
                       (symbol-at-point))))
  (let* ((identifier-regexp (format "\\b%s\\b" identifier))
         (git-path (if (= (prefix-numeric-value current-prefix-arg) 4)
                       "*"
                     (format "*.%s" (file-name-extension (buffer-file-name)))))
         (cmd (format "git --no-pager grep --color -n -e \"%s\" -- %s"
                      identifier-regexp
                      git-path))
         (default-directory (project-directory)))
    (grep cmd)))

(defun prompt-for-identifier (default-identifier)
  (read-input "Grep project for identifier: " default-identifier))

;; (defadvice grep (before kill-grep-before-grep)
;;   (kill-grep))

(eval-after-load 'find-things-fast
  '(setq-default ftf-filetypes '("*")))
