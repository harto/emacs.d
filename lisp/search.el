;; Find things quickly

;; TODO: this can surely be cleaned up a bit:
;;  - a way to specify desired search tool
;;    (perhaps derive it from installed utilities...?)
;;  - monorepo subproject support

;; =====================================
;; Grep for a string in a directory tree

;; (defun fastest-project-grep-func ()
;;   "Returns a wrapper around the preferred grep-like tool."
;;   (cond ((boundp 'rg-project) #'rg-project)
;;         ((boundp 'git-grep #')))
;;   )

(defun grep-project (search-type)
  "Greps project sources for a given pattern.

By default, `ftf-grepsource' is used to grep sources under version control.

With prefix \\[universal-argument], a case-insensitive git grep is performed.

With prefix \\[universal-argument] \\[universal-argument], a case-insensitive search of all files within the project tree is performed using `ag-project'."
  (interactive "p")
  (cond ((and (= search-type 16) (boundp 'ag-project))
         (command-execute 'ag-project))

        ((= search-type 4)
         (let ((ftf-git-grep-options "-i"))
           (command-execute 'ftf-grepsource)))

        (t
         (command-execute 'ftf-grepsource))))

;; TODO: remove dependency on find-things-fast
;; TODO: find symbol according to current mode (check if this needs fixing)
;; TODO: optionally expand search to all filetypes in project
;; TODO: fallback to various kinds of grep (rg, find|xargs)
(defun grep-project-for-identifier (&optional identifier)
  (interactive (list (symbol-at-point)))
  (let* ((identifier-regexp (format "\\b%s\\b" identifier))
         (git-path (if (= (prefix-numeric-value current-prefix-arg) 4)
                       "*"
                     (format "*.%s" (file-name-extension (buffer-name)))))
         (cmd (format "git --no-pager grep --color -n -e \"%s\" -- %s"
                      identifier-regexp
                      git-path))
         (default-directory (ftf-project-directory)))
    (grep cmd)))

(defvar version-controlled-project-files-command
  "git ls-files"
  "Shell command producing a list of version-controlled project files")
;; (defadvice grep (before kill-grep-before-grep)
;;   (kill-grep))

(defvar non-version-controlled-project-files-command
  (concat "git ls-files -o | "
          "while read path; do "
          "  if [[ -d $path ]]; then"
          "    find ${path%/} -type f;"
          "  else"
          "    echo $path;"
          "  fi;"
          "done | "
          "grep -Ev '[#~]$' | "
          "grep -Ev '\.git'")
  "Shell command producing a list of non-version-controlled project files")

(defun find-project-file (search-type)
  "Finds a named project file with helpful autocompletion.

By default, files under version control are included for autocompletion.

With prefix \\[universal-argument], untracked files are included instead. (Note: this is likely to be quite slow.)"
  (interactive "p")
  (command-execute 'ftf-find-file)
  ;; (cl-letf ((original-ftf-get-git-find-command #'ftf-get-git-find-command)
  ;;           ((symbol-function 'ftf-get-git-find-command) (if (= search-type 4)
  ;;                                                            non-version-controlled-project-files-command
  ;;                                                          version-controlled-project-files-command)))
  ;;   (command-execute 'ftf-find-file))
  )

(eval-after-load 'find-things-fast
  '(setq ftf-filetypes '("*")))
