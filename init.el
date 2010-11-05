;; Top-level emacs configuration
;; Adapted from http://github.com/EnigmaCurry/emacs

;; All libs are located under ~/.emacs.d. Third-party libs reside in
;; ~/.emacs.d/vendor.

(add-to-list 'load-path "~/.emacs.d")

(progn (cd "~/.emacs.d")
       (normal-top-level-add-subdirs-to-load-path))

(add-to-list 'load-path "~/.emacs.d/vendor")
(progn (cd "~/.emacs.d/vendor")
       (normal-top-level-add-subdirs-to-load-path))

(load-library "init-elpa")

(load-library "init-web")
(load-library "init-lisp")
(load-library "init-markdown")
(load-library "init-sql")

;;; Miscellany

(load-library "init-theme")

(setq-default indent-tabs-mode nil)
(setq-default require-final-newline t)

(scroll-bar-mode nil)

(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'scroll-left 'disabled nil)
(put 'set-goal-column 'disabled nil)

;; Provide C-Tab switching between buffers
(load "~/.emacs.d/vendor/mybuffers.el")
(global-set-key [(control tab)] 'mybuffers-switch)

;; FFIP
(load "~/.emacs.d/vendor/find-file-in-project/find-file-in-project.el")
(global-set-key (kbd "C-x C-M-f") 'find-file-in-project)

;; Line numbering
(global-linum-mode 1)

