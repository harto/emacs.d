;; 99designs configuration
;; Note: this file isn't loaded by default.
;; This file depends on https://github.com/99designs/99-elisp

(defun 99-init-key-bindings ()
  (define-key php-mode-map (kbd "C-c t") '99-vm-run-test-file))

(99-update-directory-class '99-contests-project
                           '((nil . ((tab-width . 2)
                                     (c-basic-offset . 2)))))


;; ## PHP

;; TODO: insert newline before and after opening '{'

;; php-mode automatically adds a bunch of overly general assocations to
;; auto-mode alist -- this overrides it
(setq php-file-patterns nil)
(add-to-list 'auto-mode-alist '("/[^./]+\\.php$" . php-mode))

;; use html-mode for PHP templates
(add-to-list 'auto-mode-alist '("\\.tpl\\.php$" . html-mode))

(defadvice c-electric-slash (before php-close-phpdoc-comment)
  (when (and (equal major-mode 'php-mode)
             (eolp)
             (looking-back "^[[:space:]]+\\*[[:space:]]+"))
    (delete-horizontal-space t)))

(defun php-mode-settings ()
  (set (make-local-variable 'comment-start) "//")
  (set (make-local-variable 'comment-end) "")
  (set (make-local-variable 'comment-style) 'indent)
  (c-set-style "99designs")
  (require 'php-reference)
  (setq php-reference-cmd-opts '("--ascii"))
  (fci-mode)
  (99-init-key-bindings)
  (define-key php-mode-map (kbd "C-M-a") 'php-beginning-of-defun)
  (define-key php-mode-map (kbd "C-M-e") 'php-end-of-defun)
  (define-key php-mode-map (kbd "C-c d") 'php-reference))

(add-hook 'php-mode-hook #'php-mode-settings)


;; ## JavaScript

(add-hook 'js2-mode-hook #'99-use-project-jshint-config)
