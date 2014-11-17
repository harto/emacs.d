;; 99designs configuration

(load-library "99")

(defun 99-init-key-bindings ()
  (define-key php-mode-map (kbd "C-c t") '99-vm-run-test-file)
  (define-key php-mode-map (kbd "C-M-a") 'php-beginning-of-defun)
  (define-key php-mode-map (kbd "C-M-e") 'php-end-of-defun)
  (define-key php-mode-map (kbd "C-c d") 'php-reference))


;; ## Misc web

;; TODO: let this be configured by .editorconfig
(add-hook 'web-mode-hook (lambda () (setq web-mode-markup-indent-offset 4)))


;; ## PHP

;; TODO: insert newline before and after opening '{'

;; php-mode automatically adds a bunch of overly general associations to
;; auto-mode alist -- this overrides it
(setq php-file-patterns nil)
(add-to-list 'auto-mode-alist '("/[^./]+\\.php$" . php-mode))

;; use web-mode for PHP templates
(add-to-list 'auto-mode-alist '("\\.tpl\\.php$" . web-mode))

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
  (setq php-reference-cmd-opts '("--cache=~/.php-reference/cache"
                                 "--ascii"))
  (99-use-project-phpcs-config)
  (99-init-key-bindings)
  (subword-mode))

(add-hook 'php-mode-hook #'php-mode-settings)


;; ## JavaScript

(add-hook 'js2-mode-hook #'99-use-project-jshint-config)
