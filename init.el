;; Note: configuration also exists in early-init.el

;; use-package provides a nice way to lazy-load and configure packages. I try to
;; use it for most installed packages (even those that don't need any
;; configuration), mostly as a way to remember what I've installed.
(eval-when-compile
  (require 'use-package))

;; (setq use-package-compute-statistics t)

;; Put temp and config files in a consistent place. This package should be
;; configured early (before packages start putting their files everywhere).
(use-package no-littering
  :custom
  ;; Put Emacs backup and auto-save files in a centralised (out-of-the-way)
  ;; location. By default Emacs stores auto-save files (etc.) alongside the
  ;; original files, which interferes with tools that watch directories for
  ;; changes (auto-recompilation processes, Dropbox, etc.)
  (auto-save-file-name-transforms
   `((".*" ,(let ((dir (no-littering-expand-var-file-name "auto-save/")))
              (make-directory dir t)
              dir) t)))
  (backup-directory-alist
   `((".*" . ,(let ((dir (no-littering-expand-var-file-name "backup/")))
                (make-directory dir t)
                dir)))))


;; # General preferences

;; Quieter startup
(setq inhibit-startup-screen t)
(setq initial-scratch-message nil)
(setq inhibit-startup-echo-area-message "stuart")

;; Silence bell (perhaps only relevant in terminal?)
(setq ring-bell-function 'ignore)

;; Prompt for y/n rather than yes/no
(defalias 'yes-or-no-p 'y-or-n-p)

;; Disable warnings for rarely-used features
(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'scroll-left 'disabled nil)        ; still need this?
(put 'set-goal-column 'disabled nil)
;; Hide usage instructions in *Completion* buffer
(setq completion-show-help nil)
;; Disable prompt when following symlinks to version-controlled files
(setq vc-follow-symlinks nil)

;; UTF-8 everywhere by default
(set-language-environment 'utf-8)
(set-default-coding-systems 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(set-locale-environment "en_AU.UTF-8")
(setq-default buffer-file-coding-system 'utf-8-unix)

;; Whitespace
(setq-default indent-tabs-mode nil)
(setq-default require-final-newline t)
(setq-default tab-width 4)
(setq-default fill-column 80)

;; Trim extraneous whitespace (from modified lines only) on save
(use-package ws-trim
  :config
  (setq-default ws-trim-level 1)
  (global-ws-trim-mode t))

;; Highlight matching parentheses
(show-paren-mode +1)

;; Minor mode to visually indicate where the fill column is.
;; TODO: decide if I want to keep this or not
(use-package fill-column-indicator
  :defer t
  :custom
  (fci-rule-color "#073642"))

;; Avoid warnings about dumb terminals in subprocesses
;; TODO: should this go with other OS / environment stuff?
(setenv "PAGER" "cat")

;; Make C-0, C-1, ... C-9 available for use as prefix bindings, per
;; http://pragmaticemacs.com/emacs/use-your-digits-and-a-personal-key-map-for-super-shortcuts/
;;
;; I use these prefixes to group commands as follows:
;; - C-1: theme/font switching
;; - C-7: flycheck (error checking)
;; - C-8: custom extensions to the current major mode
;; - C-9: project navigation
;; - C-0: text editing
(dotimes (n 10)
  (global-unset-key (kbd (format "C-%d" n))))


;; # Console setup
;;
;; (Commented-out because I haven't used this in years, and it likely doesn't
;; work anymore.)

;; (unless (display-graphic-p)
;;   ;; Rudimentary mouse support
;;   (require 'mouse)
;;   (xterm-mouse-mode t)
;;   (defun track-mouse (e))
;;   (setq mouse-sel-mode t)
;;   (global-set-key [mouse-4] '(lambda () (interactive) (scroll-down 1)))
;;   (global-set-key [mouse-5] '(lambda () (interactive) (scroll-up 1)))
;;   ;; Hide vertical buffer separator
;;   (set-face-background 'vertical-border "#000")
;;   (set-face-foreground 'vertical-border "#000"))


;; # Desktop/GUI setup

;; TODO: delay slightly?
(use-package server
  :if (display-graphic-p)
  :init
  (add-hook 'after-init-hook 'server-start t))

;; TODO: replace with exec-path-from-shell package
(defun sc/load-env-from-shell ()
  (dolist (line (split-string (shell-command-to-string "$SHELL -lc env") "\n" t))
    (let* ((parts (split-string line "="))
           (k (nth 0 parts))
           (v (nth 1 parts)))
      (setenv k v))))

(defun sc/reset-exec-path-from-env ()
  (setq exec-path (split-string (getenv "PATH") path-separator)))

(defun sc/reset-mac-os-env ()
  "Works around macOS environment problems by loading env (and
subsequently $PATH) via shell profile."
  (sc/load-env-from-shell)
  (sc/reset-exec-path-from-env))

(when (and (display-graphic-p) (eq system-type 'darwin))
  (sc/reset-mac-os-env)
  ;; Set default directory to ~ (this was the behaviour prior to Emacs 27)
  (cd "~"))


;; # Modeline

(line-number-mode +1)
(column-number-mode +1)

;; TODO: investigate replacing this with a 3rd-party thing
;(load "modeline")

;; Things to fix:
;; - more space between groups (and additional space at end of line)
;; - show flycheck errors and warnings separately
(use-package doom-modeline
  :custom
  (doom-modeline-height 28)
  (doom-modeline-bar-width 2)
  ;; The major mode is shown on the right-hand side, so I don't also need to see
  ;; an icon.
  (doom-modeline-major-mode-icon nil)

  :custom-face
  ;; By default the filename is shown like an error (bright red) when the buffer
  ;; is unsaved. It's a bit distracting, so we render it like a warning instead.
  (doom-modeline-buffer-modified ((t (:inherit (warning bold) :background nil))))
  ;; By default the little vertical bar on the left-hand side of the modeline is
  ;; highlighted for non-active windows. This seems backwards, so we reverse it.
  (doom-modeline-bar ((t (:background ,(face-foreground 'mode-line-inactive)))))
  (doom-modeline-bar-inactive ((t (:inherit highlight))))

  :init
  (doom-modeline-mode))


;; # Theme configuration

;; TODO: should we do any of this stuff in early-init.el (i.e. before the frame
;; is visible)?

;; Simple hook system for themes, per
;; http://www.greghendershott.com/2017/02/emacs-themes.html

(defvar sc/load-theme-hooks nil
  "Hook run after loading a theme.")

(defun sc/call-load-theme-with-hooks (f theme-id &optional no-confirm no-enable &rest args)
  (unless no-enable
    ;; Disable all themes before the new theme is enabled.
    ;; TODO: should this be separate advice?
    (mapc #'disable-theme custom-enabled-themes))
  ;; TODO: should this be :after advice?
  (prog1 (apply f theme-id no-confirm no-enable args)
    (unless no-enable
      (dolist (hook sc/load-theme-hooks)
        (funcall hook theme-id)))))

(advice-add 'load-theme :around 'sc/call-load-theme-with-hooks)

(use-package solarized
  :custom
  (solarized-use-variable-pitch nil)
  (solarized-height-minus-1 1.0)
  (solarized-height-plus-1 1.0)
  (solarized-height-plus-2 1.0)
  (solarized-height-plus-3 1.0)
  (solarized-height-plus-4 1.0)
  ;; Tweak modeline border, per
  ;; https://github.com/bbatsov/solarized-emacs#underline-position-setting-for-x
  (x-underline-at-descent-line t))

;; line-number-mode is disabled when changing themes for some reason, so make
;; sure to reenable it when we do that.
(add-hook 'sc/load-theme-hooks (lambda (_theme) (line-number-mode)))

;; Solarized adds top & bottom borders the modeline, but we use a custom
;; modeline and the borders look bad there.
(defun sc/disable-mode-line-borders (theme)
  (when (or (eq theme 'solarized-dark) (eq theme 'solarized-light))
    (set-face-attribute 'mode-line nil :underline nil :overline nil :box nil)
    (set-face-attribute 'mode-line-inactive nil :underline nil :overline nil :box nil
                        :background (solarized-color-blend (face-attribute 'default :background)
                                                           (face-attribute 'mode-line :background)
                                                           0.5))))

(add-hook 'sc/load-theme-hooks 'sc/disable-mode-line-borders)

(defun sc/big-screen ()
  (interactive)
  (set-frame-font "Monaco-14" t t)
  (doom-modeline-refresh-font-width-cache))

(defun sc/small-screen ()
  (interactive)
  (set-frame-font "Monaco-12" t t)
  (doom-modeline-refresh-font-width-cache))

(defun sc/hi-vis ()
  (interactive)
  (sc/big-screen)
  (load-theme 'solarized-light))

(defun sc/lo-vis ()
  (interactive)
  (sc/small-screen)
  (load-theme 'solarized-dark))

(defun sc/invert-theme ()
  (interactive)
  (cond ((member 'solarized-dark custom-enabled-themes) (load-theme 'solarized-light))
        ((member 'solarized-light custom-enabled-themes) (load-theme 'solarized-dark))))

(global-set-key (kbd "C-1 b") 'sc/big-screen)
(global-set-key (kbd "C-1 s") 'sc/small-screen)
(global-set-key (kbd "C-1 h") 'sc/hi-vis)
(global-set-key (kbd "C-1 l") 'sc/lo-vis)
(global-set-key (kbd "C-1 i") 'sc/invert-theme)

(when (display-graphic-p)
  (load-theme 'solarized-dark))


;; # Editing improvements

;; Treat components of CamelCasedWords as individual words when moving the
;; cursor forwards & backwards by word. i.e. with point like "|FooBar", pressing
;; `M-f` moves to "Foo|Bar", not "FooBar|".
(use-package subword
  :hook ((js2-mode python-mode ruby-mode typescript-mode) . subword-mode))

;; Automatically insert closing parentheses, brackets, etc. in certain
;; (non-Lisp) modes. (In Lisp code we use paredit instead.)
(use-package elec-pair
  :hook ((js2-mode typescript-mode) . electric-pair-local-mode))

;; Disable a built-in minor mode that triggers automatic reindentation when
;; newlines are inserted. (TODO: figure out if we actually need to do this)
(use-package electric
  :defer t
  :custom
  (electric-indent-mode nil))

;; Multiple cursors
(use-package multiple-cursors
  :custom
  (mc/always-run-for-all t)

  :bind (("C->" . mc/mark-next-like-this)
         ("C-<" . mc/unmark-next-like-this)
         ;; TODO: think of a more obvious binding
         ("C-0 m" . mc/mark-all-symbols-like-this-in-defun)))

;; Custom editing functions

(defun sc/open-line-preserving-indent (n)
  "Like `open-line', but makes a better attempt at indenting the new line.
Passes arg N to `open-line'."
  (interactive "*p")
  (open-line n)
  (unless (zerop (current-indentation))
    ;; TODO: make it work with `n' open lines
    (save-excursion
      (forward-line)
      (beginning-of-line)
      (delete-horizontal-space)
      (indent-for-tab-command))))

(defun sc/diff-current-buffer-with-file ()
  (interactive)
  (diff-buffer-with-file (current-buffer)))

(defun sc/sort-lines-case-insensitive ()
  (interactive)
  (let ((sort-fold-case t))
    ;; TODO: handle prefix arg
    (command-execute 'sort-lines)))

(defun sc/isearch-yank-symbol-at-point ()
  "Put entire symbol at point into the current isearch string."
  (interactive)
  (let ((sym (symbol-at-point)))
    (if sym
        (setq isearch-regexp t
              isearch-string (concat "\\_<" (regexp-quote (symbol-name sym)) "\\_>")
              isearch-message (mapconcat 'isearch-text-char-description isearch-string "")
              isearch-yank-flag t)
      (ding)))
  (isearch-search-and-update))

;; http://emacsredux.com/blog/2013/06/21/eval-and-replace/
;; (defun sc/eval-and-replace-preceding-sexp ()
;;   "replace the preceding sexp with its value."
;;   (interactive)
;;   (backward-kill-sexp)
;;   ;; fixme: doesn't work
;;   (let ((sexpr (current-kill 0)))
;;     (message "%s" sexpr)
;;     (condition-case nil
;;         (prin1 (eval (read sexpr))
;;                (current-buffer))
;;       (error (message "invalid expression: %s" sexpr)
;;              (insert (current-kill 0))))))
;;
;; (global-set-key (kbd "C-c e") 'sc/eval-and-replace-preceding-sexp)

(global-set-key (kbd "C-0 a") 'align-regexp)
(global-set-key (kbd "C-0 d") 'sc/diff-current-buffer-with-file)
(global-set-key (kbd "C-0 s") 'sort-lines)
(global-set-key (kbd "C-0 s") 'sc/sort-lines-case-insensitive)

(define-key isearch-mode-map (kbd "M-.") 'sc/isearch-yank-symbol-at-point)

;; TODO: can we defer this at startup?
;; TODO: do I even use this anymore?
;; (use-package yasnippet
;;   :config
;;   (yas-global-mode +1))


;; # File/buffer navigation improvements

;; ido-mode improves the experience of finding files and switching buffers.
(use-package ido
  :custom
  ;; Layout results vertically
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
  ;; delaying it for a really long time.
  (ido-auto-merge-delay-time 999)

  :config
  (ido-mode +1)
  (ido-everywhere +1)
  ;; flx-ido (https://github.com/lewang/flx) replaces the ido sorting algorithm
  ;; for better fuzzy-matching.
  (flx-ido-mode +1))

;; find-things-fast helps with locating files in git repos (and other kinds of
;; "projects").
(use-package find-things-fast
  :bind (("C-9 f" . ftf-find-file)
         ("C-9 s" . ftf-grepsource))

  :custom
  ;; find-things-fast only searches for extensions used in chromium source by
  ;; default.
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
    (let* ((exclusions (mapcar (lambda (path)
                                 (format ":!%s" path))
                               sc/ftf-grepsource-exclusions))
           (ftf-filetypes (append ftf-filetypes exclusions)))
      (message "%s" ftf-filetypes)
      (apply func args)))

  (advice-add 'ftf-grepsource :around 'sc/add-ftf-grepsource-exclusions))

;; Backwards window navigation (opposite of `C-x o`).
(global-set-key (kbd "C-x p") (lambda () (interactive) (other-window -1)))


;; # Git

(use-package magit
  :bind (("C-x g" . magit-status)
         ;; TODO: i don't think i use this
         ("C-0 g" . magit-file-popup)))

;; git-commit (a dependency of magit) is used when editing commit messages and
;; PR descriptions. I configure this because I want to unset the max line length
;; for PR descriptions. (There might be an easier way to do this.)
(use-package git-commit
  :defer t

  :custom
  (git-commit-summary-max-length 50)
  (git-commit-setup-hook '(git-commit-propertize-diff
                           git-commit-save-message
                           git-commit-setup-changelog-support
                           git-commit-turn-on-auto-fill
                           with-editor-usage-message
                           sc/set-git-commit-line-limits))

  :config
  (defun sc/set-git-commit-line-limits ()
    "Set line length limits when writing commit & pull request messages."
    (if (equal (buffer-name) "PULLREQ_EDITMSG")
        (progn
          (setq-local git-commit-summary-max-length 100)
          ;; `most-positive-fixnum' rather than nil so
          ;; fill-paragraph & fill-region work
          (setq-local fill-column most-positive-fixnum))
      (setq-local fill-column 72))))


;; # Programming

;; Error highlighting and linting framework.
;; TODO: investigate flymake
(use-package flycheck
  :hook (prog-mode . flycheck-mode)

  :custom
  (flycheck-disabled-checkers '(emacs-lisp-checkdoc))
  (flycheck-navigation-minimum-level 'error)

  :config
  ;; TODO: instead of this, rebind default Flycheck prefix (`C-c !`) to
  ;; something more usable
  (defun sc/configure-flycheck ()
    (local-set-key (kbd "C-7 l") 'flycheck-list-errors)
    (local-set-key (kbd "C-7 n") 'flycheck-next-error)
    (local-set-key (kbd "C-7 p") 'flycheck-previous-error)
    (local-set-key (kbd "C-7 v") 'flycheck-verify-setup))
  (add-hook 'prog-mode-hook 'sc/configure-flycheck))

(use-package compile
  :defer t
  :custom
  ;; TODO: determine if this is needed
  (compilation-message-face 'default))

(use-package lsp-mode
  :hook (typescript-mode . lsp))

;; Autocompletion framework
(use-package company :defer t)

;; Paredit is for rapidly navigating and modifying lisp S-expressions.
(use-package paredit
  :hook ((clojure-mode emacs-lisp-mode lisp-mode) . paredit-mode)
  :bind (:map paredit-mode-map
         ("M-?" . nil)  ; don't shadow xref-find-references
         ("C-M-<backspace>" . backward-kill-sexp)))

;; Specific language configurations

(use-package clojure-mode
  :defer t

  :custom
  (clojure-defun-indents '(async div render table thead tbody tr ns query ul li
                           reg-cofx reg-event-db reg-event-fx reg-sub reg-fx))

  ;; :config
  ;; (add-hook 'clojure-mode-hook (lambda () (setq-local fill-column 100)))
  )

(use-package elisp-mode
  :defer t
  :config
  ;; (add-hook 'emacs-lisp-mode-hook (lambda () (setq-local fill-column 100)))
  ;; Sometimes I type non-Lisp stuff into the *scratch* buffer and I don't want
  ;; strict parenthesis matching.
  (add-hook 'lisp-interaction-mode-hook (lambda () (paredit-mode -1))))

(use-package js2-mode
  :mode ("\\.jsx?\\'")

  :custom
  (js2-basic-offset 2)
  (js2-bounce-indent-p t)
  (js2-strict-inconsistent-return-warning nil)

  :config
  (add-hook 'js2-mode-hook
            (lambda ()
              ;; TODO: document why I need this
              (setq electric-pair-open-newline-between-pairs nil)))

  (defun sc/js2-jump ()
    "Look for thing at point in current file, falling back to
project-wide search."
    (interactive)
    (condition-case ex
        ;; TODO: skip imports
        (command-execute 'js2-jump-to-definition)
      ('error
       (command-execute 'xref-find-definitions))))

  :bind (:map js2-mode-map
         ("M-." . sc/js2-jump)))

(use-package python
  :defer t
  :custom
  ;; Disable pydoc pager so that `help(…)` doesn't complain about not having a
  ;; fully-functional terminal. Note: the final print() is required, because
  ;; `python-shell-setup-code' seems to block until some kind of output is sent.
  (python-shell-setup-codes `(,(string-join '("import pydoc"
                                              "pydoc.pager = pydoc.plainpager"
                                              "print('pydoc pager disabled')")
                                            "; "))))

;; Invoke pytest directly from Python files
(use-package pytest :defer t)

;; Switch between Python virtual environments.
;; TODO: start using this
;; (use-package pyvenv :defer t)

(use-package ruby-mode
  :defer t
  :custom
  (ruby-insert-encoding-magic-comment nil))

(use-package sass-mode
  :mode "\\.scss\\'")

(use-package sh-script
  :defer t
  :custom
  (sh-basic-offset 2))

(use-package sql
  :mode "\\.pl[bs]\\'"
  :config
  ;; Query results look bad when wrapped, so extend them off-screen instead
  (add-hook 'sql-interactive-mode-hook 'toggle-truncate-lines t)
  ;; Handle dashed database names in psql prompt
  (sql-set-product-feature 'postgres :prompt-regexp "^[[:alpha:]_-]*=[#>] "))

(use-package typescript-mode
  :mode "\\.tsx\\'"
  :bind (:map typescript-mode-map
         ("C-8 r" . lsp-rename)))

(use-package ts-comint
  :defer t
  :custom
  ;; TODO: document these
  (ts-comint-program-arguments '("-O" "{\"isolatedModules\": false}"))
  (ts-comint-program-command "ts-node")
)

(use-package web-mode
  :mode "\\.\\(erb\\|hbs\\|html\\|twig\\)\\'"

  :custom
  (web-mode-markup-indent-offset 2))


;; # Org

(use-package org
  :defer t

  :custom
  (org-startup-indented t)
  (org-ellipsis " …")

  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (ruby . t)
     (shell . t)
     (sql . t)))

  ;; Markdown export
  (require 'ox-md)

  ;; Soft-wrap long lines
  (add-hook 'org-mode-hook 'visual-line-mode)
  (add-hook 'org-mode-hook (lambda () (setq fill-column 100)))
  (add-hook 'org-mode-hook 'visual-fill-column-mode))


;; # Miscellanous helper functions and utilities

(add-to-list 'load-path "~/.emacs.d/lisp")
;; TODO: can we lazy-load (or delete) this?
(load "utils")
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
