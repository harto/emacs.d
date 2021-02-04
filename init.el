(require 'package)
(add-to-list 'package-archives '("melpa" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-unstable" . "https://melpa.org/packages/") t)
(setq package-user-dir (expand-file-name "~/.emacs.d/elpa"))

;; https://github.com/jwiegley/use-package
(eval-when-compile
  (require 'use-package))

(setq custom-file "~/.emacs-custom.el")
(load custom-file nil t)

;; Put temp and config files in a consistent place.
(use-package no-littering
  :ensure t
  :config
  ;; Opt to store Emacs backup and auto-save files in a centralised
  ;; (out-of-the-way) location. By default Emacs stores an auto-save files
  ;; (etc.) in the same directory as the original file, which can interfere with
  ;; tools that watch directories for changes (auto-recompilation processes,
  ;; Dropbox, etc.)
  (setq auto-save-file-name-transforms
        `((".*" ,(let ((dir (no-littering-expand-var-file-name "auto-save/")))
                   (make-directory dir t)
                   dir) t)))
  (setq backup-directory-alist
        `((".*" . ,(let ((dir (no-littering-expand-var-file-name "backup/")))
                     (make-directory dir t)
                     dir)))))

(add-to-list 'load-path "~/.emacs.d/lisp")

(load "keys")
(load "modes")
(load "modeline")
(load "prefs")
(load "search")
(load "utils")

(load (if (display-graphic-p) "gui" "console"))

(load "~/remix/remix.el" t)

(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Ready in %.2f seconds (%d garbage collections)"
                     (float-time (time-subtract after-init-time before-init-time))
                     gcs-done)))

;; (from https://blog.d46.us/advanced-emacs-startup/)
;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))
