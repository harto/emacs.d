;; Clojure-mode configuration

(require 'clojure-mode)
(add-to-list 'auto-mode-alist '("\\.clj$" . clojure-mode))

;; TODO: check if paredit-mode is available?
(require 'paredit)
(add-hook 'clojure-mode-hook (lambda () (paredit-mode 1)))

(require 'slime)
(require 'swank-clojure)

;; FIXME: this simple one works for Win32
;; (require 'slime)
;; (add-hook 'clojure-mode-hook
;;           (lambda ()
;;             (paredit-mode 1)))
