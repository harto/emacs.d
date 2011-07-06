;;; Top-level emacs configuration
;;; Adapted from http://github.com/EnigmaCurry/emacs
;;;
;;; All libs are located under ~/.emacs.d. Third-party libs reside in
;;; ~/.emacs.d/vendor.

(add-to-list 'load-path "~/.emacs.d")

;; (progn (cd "~/.emacs.d")
;;        (normal-top-level-add-subdirs-to-load-path))

(add-to-list 'load-path "~/.emacs.d/vendor")
(progn (cd "~/.emacs.d/vendor")
       (normal-top-level-add-subdirs-to-load-path))

;; ELPA initialisation

(load-library "package")
(package-initialize)

;; Language/environment-specific configs

(load-library "web")
(load-library "lisp")

;; Miscellany

(load-library "theme")
(scroll-bar-mode nil)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default require-final-newline t)

(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'scroll-left 'disabled nil)
(put 'set-goal-column 'disabled nil)

;; C-TAB buffer switching
(load-library "mybuffers")
(global-set-key [(control tab)] 'mybuffers-switch)

;; FFIP
(load-library "find-file-in-project")
(global-set-key (kbd "C-x C-M-f") 'find-file-in-project)

;; Line numbering
(global-linum-mode 1)

;; Other file/mode associations
(autoload 'markdown-mode "markdown-mode.el")
(add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.pl[sb]$" . sql-mode))

;; Misc Elisp functions
(load-library "tools")
