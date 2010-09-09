;; Top-level emacs configuration
;; Adapted from http://github.com/EnigmaCurry/emacs

;; Keep all libs under ~/.emacs.d
(add-to-list 'load-path "~/.emacs.d")

;; Add top-level dirs in ~/.emacs.d to load path
(progn (cd "~/.emacs.d")
       (normal-top-level-add-subdirs-to-load-path))

;; Add 3rd-party dirs in ~/.emacs.d/vendor to load path
(add-to-list 'load-path "~/.emacs.d/vendor")
(progn (cd "~/.emacs.d/vendor")
       (normal-top-level-add-subdirs-to-load-path))

(load-library "init-elpa")

;; Miscellaneous configuration
(load-library "init-linum")
(load-library "init-misc")

;; Colour theme
(load-library "init-theme")

;; Language-specific mode configurations
(load-library "init-asp")
(load-library "init-clojure")
(load-library "init-html")
(load-library "init-javascript")
(load-library "init-markdown")
(load-library "init-sql")
