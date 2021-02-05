;; Note: configuration also exists in early-init.el

;; use-package (https://github.com/jwiegley/use-package) provides a nice way to
;; lazy-load and configure packages.
(eval-when-compile
  (require 'use-package))

;; Configuration set via the Customize system is automatically put in this file
;; by default. I don't want a bunch of autogenerated cruft added here, so I
;; store it in a separate file. Also, the use-package macro has a way to specify
;; Custom variables inline, so I prefer to do that where possible.
(setq custom-file "~/.emacs-custom.el")
(load custom-file nil t)

;; Put temp and config files in a consistent place. This package should be
;; configured early, before other packages start putting their files everywhere.
(use-package no-littering
  :config
  ;; Put Emacs backup and auto-save files in a centralised (out-of-the-way)
  ;; location. By default Emacs stores auto-save files (etc.) alongside the
  ;; original files, which interferes with tools that watch directories for
  ;; changes (auto-recompilation processes, Dropbox, etc.)
  (setq auto-save-file-name-transforms
        `((".*" ,(let ((dir (no-littering-expand-var-file-name "auto-save/")))
                   (make-directory dir t)
                   dir) t)))
  (setq backup-directory-alist
        `((".*" . ,(let ((dir (no-littering-expand-var-file-name "backup/")))
                     (make-directory dir t)
                     dir)))))

;; # General preferences

;; quieter startup
(setq inhibit-startup-screen t)
(setq initial-scratch-message nil)

;; silence bell (perhaps only relevant in terminal?)
(setq ring-bell-function 'ignore)

;; prompt for y/n rather than yes/no
(defalias 'yes-or-no-p 'y-or-n-p)

;; no warnings for rarely-used features
(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'scroll-left 'disabled nil)        ; still need this?
(put 'set-goal-column 'disabled nil)
;; hide usage instructions in *Completion* buffer
(setq completion-show-help nil)
;; no prompt for following symlinks
(setq vc-follow-symlinks nil)

;; encodings: UTF-8 everywhere by default
(set-language-environment 'utf-8)
(set-default-coding-systems 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(set-locale-environment "en_AU.UTF-8")
(setq-default buffer-file-coding-system 'utf-8-unix)

;; whitespace
(setq-default indent-tabs-mode nil)
(setq-default require-final-newline t)
(setq-default tab-width 4)
(setq-default fill-column 80)
;; trim extraneous whitespace (from modified lines only) on save
(use-package ws-trim
  :config
  (setq-default ws-trim-level 1))
(global-ws-trim-mode t)

(line-number-mode +1)
(column-number-mode +1)

;; Avoid warnings about dumb terminals in subprocesses
(setenv "PAGER" "cat")

;; Make C-0, C-1, ... C-9 available for use as prefix bindings, per
;; http://pragmaticemacs.com/emacs/use-your-digits-and-a-personal-key-map-for-super-shortcuts/
(dotimes (n 10)
  (global-unset-key (kbd (format "C-%d" n))))

;; # Navigation improvements

;; ido improves the experience of finding files and switching buffers
(use-package ido
  :custom
  ;; layout results vertically
  (ido-decorations (list "\n-> " ""     ; "brackets" around prospect list
                         "\n   "        ; separator between prospects
                         "\n   ..."     ; end of truncated list of prospects
                         "[" "]"        ; brackets around common match string
                         " [No match]"
                         " [Matched]"
                         " [Not readable]"
                         " [Too big]"
                         " [Confirm]"))
  ;; I prefer not to use ido's auto-merge behaviour, so I "disable" it by
  ;; setting it to an extremly high value
  (ido-auto-merge-delay-time 999)

  :config
  (ido-everywhere +1)
  ;; flx-ido (https://github.com/lewang/flx) replaces the ido sorting algorithm
  ;; for better fuzzy-matching.
  (flx-ido-mode +1))

(ido-mode +1)

;; find-things-fast helps with locating files in git repos (and other kinds of
;; "projects")
(use-package find-things-fast
  :custom
  ;; find-things-fast only searches for extensions used in Chromium source by default.
  (ftf-filetypes '("*"))

  :config
  ;; When searching and grepping in a non-git context, i.e. using `find`, make
  ;; sure to only include regular files (not directories, symlinks, etc.)
  (advice-add 'ftf-get-find-command
              :filter-return
              (lambda (find-command)
                (concat find-command " -type f")))

  ;; Provide a way to exclude files from searches. find-things-fast already
  ;; excludes git-ignored files, but we might also want to exclude certain
  ;; versioned files (fixtures, package lockfiles, etc.).
  (defvar sc/ftf-grepsource-exclusions ()
    "List of paths to exclude from `ftf-grepsource'.")

  (defun sc/add-ftf-grepsource-exclusions (func &rest args)
    "Temporarily incorporates `sc/ftf-grepsource-exclusions' into `ftf-filetypes'."
    (let* ((exclusions (mapcar (lambda (path) (format ":!%s" path)) sc/ftf-grepsource-exclusions))
           (ftf-filetypes (append ftf-filetypes exclusions)))
      (message "%s" ftf-filetypes)
      (apply func args)))

  (advice-add 'ftf-grepsource :around #'sc/add-ftf-grepsource-exclusions)

  :bind (("C-9 f" . ftf-find-file)
         ("C-9 s" . ftf-grepsource)))

;; # Programming

;; Error highlighting and linting framework.
;; TODO: investigate flymake
(use-package flycheck
  :bind (("C-7 l" . flycheck-list-errors)
         ("C-7 n" . flycheck-next-error)
         ("C-7 p" . flycheck-previous-error)
         ("C-7 v" . flycheck-verify-setup)))
;; TODO: maybe enable only in programming modes? (how?)
(global-flycheck-mode +1)

;; # Personal helper functions and utilities

(add-to-list 'load-path "~/.emacs.d/lisp")
(load "keys")
(load "modes")
(load "modeline")
(load "search")
(load "utils")
(load (if (display-graphic-p) "gui" "console"))
;; My library of work helper functions lives outside this repo, so I don't
;; accidentally reveal anything sensitive.
(load "~/remix/remix.el" t)

;; # Finalise configuration

;; (from https://blog.d46.us/advanced-emacs-startup/)

;; Log startup time metrics
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Ready in %.2f seconds (%d garbage collections)"
                     (float-time (time-subtract after-init-time before-init-time))
                     gcs-done)))

;; Increase garbage collection threshold from 800KB -> 2MB. This is meant to
;; result in fewer pauses for garbage collection.
(setq gc-cons-threshold (* 2 1000 1000))
