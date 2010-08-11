;; Clojure configuration
;; Adapted from http://github.com/vu3rdd/swank-clojure/blob/master/config.txt

;; clojure-mode

(require 'clojure-mode)
(add-to-list 'auto-mode-alist '("\\.clj$" . clojure-mode))

;; SLIME

(eval-after-load "slime"
  '(progn
     (setq slime-use-autodoc-mode nil)
     (slime-setup '(slime-repl))))

(require 'slime)

;; swank

(eval-after-load "slime"
  '(progn
     (require 'swank-clojure)
     (add-to-list 'slime-lisp-implementations `(clojure ,(swank-clojure-cmd) :init swank-clojure-init) t)
     (add-hook 'slime-indentation-update-hooks 'swank-clojure-update-indentation)
     (add-hook 'slime-repl-mode-hook 'swank-clojure-slime-repl-modify-syntax t)
     (add-hook 'clojure-mode-hook 'swank-clojure-slime-mode-hook t)))

(ad-activate 'slime-read-interactive-args)

;; paredit

;(require 'paredit)
(autoload 'paredit-mode "paredit"
  "Minor mode for pseudo-structurally editing Lisp code." t)
(add-hook 'clojure-mode-hook (lambda () (paredit-mode +1)))


