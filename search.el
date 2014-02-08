;; Find things quickly
(load-library "find-things-fast")

(defun grep-project (search-type)
  "Greps project sources for a given pattern.

By default, `ftf-grepsource' is used to grep sources under version control.

With prefix \\[universal-argument], a case-insensitive git grep is performed.

With prefix \\[universal-argument]-\\[universal-argument], a case-insensitive
search of all files within the project tree is performed."
  (interactive "p")
  (cond ((= search-type 16) (command-execute 'rgrep))
        ((= search-type 4) (let ((ftf-git-grep-options "-i"))
                             (command-execute 'ftf-grepsource)))
        (t (command-execute 'ftf-grepsource))))

(defvar version-controlled-project-files-command
  "git ls-files"
  "Shell command producing a list of version-controlled project files")

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

With prefix \\[universal-argument], untracked files are included instead. (Note:
this is likely to be quite slow.)"
  (interactive "p")
  (flet ((ftf-get-git-find-command () (if (= search-type 4)
                                          non-version-controlled-project-files-command
                                        version-controlled-project-files-command)))
    (command-execute 'ftf-find-file)))

(global-set-key (kbd "C-c f") 'find-project-file)
(global-set-key (kbd "C-c s") 'grep-project)
