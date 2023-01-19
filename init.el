;; Note: configuration also exists in early-init.el

;; # Initialization

;; use-package provides a nice way to lazy-load and configure packages.
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

;; Configuration set via the Customize system is appended to init.el by
;; default. I don't want a bunch of autogenerated cruft there, so I store it in
;; a separate file (which I treat as throwaway). In general I try to specify all
;; relevant config in code, rather than setting values through the Customize UI.
(setq custom-file (no-littering-expand-var-file-name "custom.el"))
(load custom-file t)


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
(dolist (sym '(downcase-region
               erase-buffer
               narrow-to-region
               scroll-left              ; still need this?
               set-goal-column
               upcase-region))
  (put sym 'disabled nil))
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

(use-package server
  :if (display-graphic-p)
  :init
  (add-hook 'after-init-hook 'server-start t))

;; TODO: replace with exec-path-from-shell package? (Note: that package doesn't
;; automatically load all env vars - is that a problem?)
(defun sc/load-env-from-shell ()
  (dolist (line (split-string (shell-command-to-string "$SHELL -ic env") "\n" t))
    (let* ((parts (split-string line "="))
           (k (nth 0 parts))
           (v (nth 1 parts)))
      (setenv k v))))

(defun sc/reset-exec-path-from-env ()
  (setq exec-path (split-string (getenv "PATH") path-separator)))

(defun sc/reset-mac-os-env ()
  "Works around macOS environment problems by loading env (in
particular, $PATH) via shell profile."
  (sc/load-env-from-shell)
  (sc/reset-exec-path-from-env))

(when (eq window-system 'ns)
  (sc/reset-mac-os-env)
  ;; Set default directory to ~ (this was the behaviour prior to Emacs 27)
  (cd "~"))

(defun sc/jump-to-emacs-config ()
  (interactive)
  (find-file-other-window "~/.emacs.d/init.el"))

;; s-, jumps to Customize by default, but I don't want to use that.
(global-set-key (kbd "s-,") 'sc/jump-to-emacs-config)

;; I sometimes press s-t to open a new tab when I think I have my browser
;; focused. If I have Emacs focused instead, a system font panel pops up and I
;; have to use the mouse to close it. Instead of that, I just unbind s-t.
(global-set-key (kbd "s-t") nil)

(use-package dired
  :defer t

  :custom
  ;; Suppress "ls does not support --dired" warning
  (dired-use-ls-dired nil)

  :config
  ;; from https://jblevins.org/log/dired-open
  (defun sc/dired-open-file-in-default-application ()
    "Opens file at point using the macOS `open` command."
    (interactive)
    (start-process "default-app" nil "open" (dired-get-file-for-visit)))

  :bind (:map dired-mode-map
              ("C-u C-o" . sc/dired-open-file-in-default-application)))


;; # Modeline

(line-number-mode +1)
(column-number-mode +1)

;; Things to fix:
;; - more space between groups (and additional space at end of line)
;; - show flycheck errors and warnings separately
;;
;; Note: `all-the-icons-install-fonts' must be run the first time this config is
;; loaded onto a new machine.
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
  (solarized-use-more-italic nil)
  (solarized-distinct-doc-face t)

  ;; Opt out of variable-width fonts in a bunch of places. We selectively
  ;; enable something like this in Org mode, but don't want it everywhere.
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

(defun sc/adjust-solarized-mode-line-appearance (theme)
  (when (or (eq theme 'solarized-dark) (eq theme 'solarized-light))
    ;; Solarized adds top & bottom borders to the modeline, but those look bad
    ;; with our custom modeline.
    (set-face-attribute 'mode-line nil :underline nil :overline nil :box nil)
    (set-face-attribute 'mode-line-inactive nil :underline nil :overline nil :box nil
                        ;; Tweak background color for deemphasised modelines
                        :background (solarized-color-blend (face-attribute 'default :background)
                                                           (face-attribute 'mode-line :background)
                                                           0.5))))

(add-hook 'sc/load-theme-hooks 'sc/adjust-solarized-mode-line-appearance)

(defun sc/big-screen ()
  (interactive)
  (set-face-attribute 'default nil :height sc/font-height-bigger)
  (doom-modeline-refresh-font-width-cache))

(defun sc/small-screen ()
  (interactive)
  (set-face-attribute 'default nil :height sc/font-height-regular)
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
(global-set-key (kbd "C-1 m") 'toggle-frame-maximized)
(global-set-key (kbd "C-1 f") 'toggle-frame-fullscreen)

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
(global-set-key (kbd "C-0 b") 'browse-url-at-point)
(global-set-key (kbd "C-0 d") 'sc/diff-current-buffer-with-file)
(global-set-key (kbd "C-0 s") 'sort-lines)
(global-set-key (kbd "C-0 s") 'sc/sort-lines-case-insensitive)

(define-key isearch-mode-map (kbd "M-.") 'sc/isearch-yank-symbol-at-point)

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
  (ido-everywhere +1))

;; flx-ido (https://github.com/lewang/flx) replaces the ido sorting algorithm
;; for better fuzzy-matching.
(use-package flx-ido
  :after ido
  :config
  (flx-ido-mode))

;; find-things-fast helps with locating files in git repos (and other kinds of
;; "projects").
(use-package find-things-fast
  :bind (("C-9 f" . ftf-find-file)
         ("C-9 4 f" . sc/ftf-find-file-other-window)
         ("C-9 s" . ftf-grepsource))

  :custom
  ;; find-things-fast only searches for extensions used in chromium source by
  ;; default - make it search for all file types.
  (ftf-filetypes '("*"))

  :config
  (defun sc/ftf-find-file-other-window ()
    (interactive)
    (cl-letf (((symbol-function 'find-file) #'find-file-other-window))
      (command-execute 'ftf-find-file)))

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

(use-package grep
  :defer t
  :custom
  ;; Don't prompt to save buffers when grepping for things.
  (grep-save-buffers nil))

;; Backwards window navigation (opposite of `C-x o`).
(global-set-key (kbd "C-x p") (lambda () (interactive) (other-window -1)))

(use-package xref
  :defer t
  :custom
  ;; Default to using thing at point instead of prompting for identifier.
  (xref-prompt-for-identifier '(not xref-find-definitions
                                    xref-find-definitions-other-window
                                    xref-find-definitions-other-frame
                                    xref-find-references)))

;; For projects where we can't use LSP (or something equivalent), fall back to a
;; simpler regex-based xref backend.
(use-package dumb-jump
  :defer t
  ;; :config
  ;; ;; dumb-jump only implements jumping to definitions (via e.g. `C-.`). Here we
  ;; ;; provide a simple way to list references to a symbol so that `C-?` also does
  ;; ;; something useful.
  ;; (cl-defmethod xref-backend-references ((_backend (eql dump-jump)) identifier)
  ;;   ;; TODO: maybe reuse bits of https://github.com/harto/emacs.d/blob/1b1a9b11d1a2ed92badcbc83eb6546b029314157/lisp/search.el
  ;;   )
  )


;; # Git

(use-package magit
  :bind (("C-x g" . magit-status)
         ;; TODO: jump to rev at point in browser
         ;; :map magit-revision-mode-map
         :map magit-status-mode-map
         ("C-c p" . sc/hub-pull-request))

  :custom
  ;; Automatically save repo files when doing various magit operations
  (magit-save-repository-buffers 'dontask)

  :config
  (defun sc/hub-pull-request ()
    "Creates a GitHub pull request via the `hub` CLI."
    ;; TODO:
    ;; - provide options (e.g. draft, base branch)
    ;; - close *Async shell command* buffer after success
    (interactive)
    (async-shell-command "hub pull-request --browse"))

  (defun sc/browse-gh-rev (rev remote)
    (interactive (list magit-buffer-revision (magit-primary-remote))) ; FIXME: figure out the right things to put here
    (let* ((remote-url (magit-get "remote" remote "url"))
           (rev-url (if (string-match "^.+@github.com:\\(.+\\)/\\(.+\\)\.git$" remote-url)
                        (format "https://github.com/%s/%s/commit/%s" (match-string 1 remote-url) (match-string 2 remote-url) rev)
                      (error "Unparseable remote URL: %s" remote-url))))
      (message remote-url)
      (browse-url rev-url))))

;; git-commit (a dependency of magit) is used when editing commit messages and
;; PR descriptions. I configure this because I want to unset the max line length
;; for PR descriptions. (There might be an easier way to do this.)
(use-package git-commit
  :defer t

  :custom
  (git-commit-summary-max-length 50)

  :config
  (add-hook 'git-commit-setup-hook 'sc/set-git-commit-line-limits)

  (defun sc/set-git-commit-line-limits ()
    "Set line length limits when writing commit & pull request messages."
    (if (equal (buffer-name) "PULLREQ_EDITMSG")
        (progn
          (setq-local git-commit-summary-max-length 100)
          ;; `most-positive-fixnum' rather than nil, so
          ;; that fill-paragraph & fill-region work
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
  (compilation-message-face 'default)

  :config
  ;; TODO: maybe replace with something like
  ;; https://superuser.com/questions/416567/combine-compilation-mode-and-ansi-term-mode-in-emacs
  (defun sc/maybe-reset-compilation-buffer ()
    (save-excursion
      (when (search-backward "c" nil t)
        (let ((inhibit-read-only t))
          (delete-region (point-min) (+ 2 (point))))
        (setq-local compilation-num-errors-found 0
                    compilation-num-warnings-found 0
                    compilation-num-infos-found 0))))

  (add-hook 'compilation-filter-hook 'sc/maybe-reset-compilation-buffer))

(use-package lsp-mode
  :hook (typescript-mode . lsp)

  :custom
  ;; Hard-code npm location - without this, tsserver looks for it in the same
  ;; directory as node, e.g. $HOMEBREW_PREFIX/Cellar/node@14/14.18.3/bin. See:
  ;; https://github.com/microsoft/TypeScript/issues/23924
  (lsp-clients-typescript-javascript-server-args '("--npmLocation $HOMEBREW_PREFIX/bin/npm"))

  :config
  (with-eval-after-load 'lsp-clients
    ;; TODO: investigate automatically adding node_modules/.bin to PATH
    ;; e.g. https://github.com/codesuki/add-node-modules-path
    (lsp-dependency
     'typescript
     `(:system "/Users/stuart/src/remix/client/node_modules/.bin/tsserver"))))

;; Autocompletion framework. (This seems to be automatically required by
;; lsp-mode, but we list it here as documentation.)
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
  (add-hook 'lisp-interaction-mode-hook (lambda () (paredit-mode -1)))

  (defun sc/visit-scratch-buffer-other-window ()
    (interactive)
    (switch-to-buffer-other-window "*scratch*"))

  :bind (:map emacs-lisp-mode-map
         ("C-c C-z" . sc/visit-scratch-buffer-other-window)))

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
                                            "; ")))
  :config
  (add-hook 'xref-backend-functions 'dumb-jump-xref-activate))

;; Invoke pytest directly from Python files
(use-package pytest
  :defer t)

;; Switch between Python virtual environments.
;; TODO: start using this
;; (use-package pyvenv :defer t)

(use-package ruby-mode
  :defer t
  :custom
  (ruby-insert-encoding-magic-comment nil)
  :config
  (add-hook 'xref-backend-functions 'dumb-jump-xref-activate))

(use-package inf-ruby
  :defer t
  ;; :custom
  ;; (inf-ruby-default-implementation "pry")
  :config
  (add-to-list 'inf-ruby-implementations '("rails" . "rails console"))
  ;; ;; TODO: figure out if we should switch to some non-OS-default Ruby
  ;; (chruby-use-corresponding)
  )

;; Switch between Ruby versions.
(use-package chruby
  :defer t)

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
  ;; Recognise dashes and numbers as valid parts of DB names
  (sql-set-product-feature 'postgres :prompt-regexp "^[[:alpha:][:digit:]_-]*=[#>] "))

(use-package typescript-mode
  :mode "\\.tsx\\'"
  :bind (:map typescript-mode-map
         ("C-8 r" . lsp-rename)))

(use-package ts-comint
  :defer t
  :custom
  (ts-comint-program-command "npx")
  ;; If ts-node is invoked in the context of a tsconfig.json that specifies
  ;; isolatedModules: true, then statements entered at the REPL cannot be
  ;; compiled. (The reason seems to be that ts-node writes each statement to a
  ;; file and compiles it, but tsc will reject the module as invalid unless it
  ;; imports or exports something.) Therefore we unconditionally override that
  ;; setting.
  (ts-comint-program-arguments '("ts-node" "-O" "{\"isolatedModules\": false}")))

(use-package web-mode
  :mode "\\.\\(erb\\|hbs\\|html\\|twig\\)\\'"

  :custom
  (web-mode-markup-indent-offset 2))


;; # Org

;; TODO: consider some visual changes:
;; - variable-pitch font
;; - totally hide heading bullets
;; - no indentation
;; - margins above headings

(use-package org
  :defer t

  :bind
  (("C-c a" . 'org-agenda)
   ("C-c n" . 'org-capture))

  :custom
  (org-startup-indented t)
  (org-hide-emphasis-markers t)
  (org-ellipsis "…")
  (org-confirm-babel-evaluate nil)
  ;; once we've scheduled something, omit it from TODO lists (and show it only
  ;; in the agenda)
  ;; TODO: maybe we'd still like to see stuff scheduled this week... ?
  (org-agenda-todo-ignore-scheduled 'future)

  (org-agenda-files '("~/org/todo.org"
                      "~/org/dates.org"
                      ))
  (org-refile-targets '(("~/org/todo.org" . (:level . 1))
                        ("~/org/ideas.org" . (:level . 1))))
  (org-archive-location "~/org/archive.org::* Archive")
  ;; (advice-add 'org-refile :after 'org-save-all-org-buffers)

  ;; TODO: can we :kill-buffer by default?
  (org-capture-templates
   (let ((todo-target '(file+headline "~/org/todo.org" "Tasks")))
     `(("t" "To-do (misc)"         entry ,todo-target "* TODO %?\n%u"             :kill-buffer t)
       ("w" "To-do (work)"         entry ,todo-target "* TODO %? :@work:\n%u"     :kill-buffer t)
       ("h" "To-do (home)"         entry ,todo-target "* TODO %? :@home:\n%u"     :kill-buffer t)
       ("c" "To-do (computer)"     entry ,todo-target "* TODO %? :@computer:\n%u" :kill-buffer t)
       ("p" "To-do (phone)"        entry ,todo-target "* TODO %? :@phone:\n%u"    :kill-buffer t)
       ("e" "Errand"               entry ,todo-target "* TODO %? :@errand:\n%u"   :kill-buffer t)
       ("l" "To discuss with Lucy" entry ,todo-target "* TODO %? :@lucy:\n%u"     :kill-buffer t)
       ("s" "Shopping"             entry ,todo-target "* TODO %? :@shopping:\n%u" :kill-buffer t)

       ("n" "Note" entry (file+headline "~/org/inbox.org" "Inbox") "* %?" :kill-buffer t))))

   ;; https://orgmode.org/manual/Agenda-Views.html#Agenda-Views
   (org-agenda-custom-commands
    ;; TODO:
    ;; - sort by date
    ;; - low-effort task view
    ;; - combined agenda + tasks for work view
    '(("c" "Computer tasks" tags-todo "@computer")
      ("h" "Home tasks"
       ((tags-todo "@home" ((org-agenda-overriding-header "Next actions")
                            (org-agenda-skip-function '(org-agenda-skip-entry-if 'scheduled))))
        (tags-todo "@home" ((org-agenda-overriding-header "Scheduled")
                            (org-agenda-skip-function '(org-agenda-skip-entry-if 'notscheduled))))))
      ("w" "Work tasks"
       ((tags-todo "@work+TODO=\"TODO\"" ((org-agenda-overriding-header "Next actions")
                                          (org-agenda-skip-function '(org-agenda-skip-entry-if 'scheduled))))
        (tags-todo "@work+TODO=\"TODO\"" ((org-agenda-overriding-header "Scheduled")
                                          (org-agenda-skip-function '(org-agenda-skip-entry-if 'notscheduled))))))
      ;; TODO: consolidate copypasta
      ("d" "Work agenda (today)"
       ((agenda "" ((org-agenda-span 'day)))
        (tags-todo "TODO=\"STARTED\""
                   ((org-agenda-overriding-header "Currently doing")))
        (tags-todo "@work+TODO=\"TODO\""
                   ((org-agenda-overriding-header "Unscheduled")
                    (org-agenda-skip-function '(org-agenda-skip-entry-if 'scheduled))))))
      ("k" "Work agenda (week)"
       ((agenda "")
        (tags-todo "TODO=\"STARTED\""
                   ((org-agenda-overriding-header "Currently doing")))
        (tags-todo "@work+TODO=\"TODO\""
                   ((org-agenda-overriding-header "Unscheduled")
                    (org-agenda-skip-function '(org-agenda-skip-entry-if 'scheduled))))))
      ("l" "Lucy" tags-todo "@lucy")
      ("p" "Phone" tags-todo "@phone")
      ("e" "Errand" tags-todo "@errand")
      ("r" "Weekly review"
       ;; TODO: should scheduled/unscheduled include tasks w/ deadlines?
       ((tags-todo "TODO=\"TODO\"|TODO=\"STARTED\""
                   ((org-agenda-overriding-header "Unscheduled")
                    (org-agenda-skip-function '(org-agenda-skip-entry-if 'scheduled))))
        (tags-todo "TODO=\"TODO\""
                   ((org-agenda-overriding-header "Scheduled")
                    (org-agenda-skip-function '(org-agenda-skip-entry-if 'notscheduled))))
        (todo "WAIT" ((org-agenda-overriding-header "Waiting")))
        (todo "DONE" ((org-agenda-overriding-header "Done")))))
      ("i" "Ideas")))

   :config
   ;; Show headlines in bigger (variable-width) fonts
   ;; https://fonts.google.com/specimen/Work+Sans
   (let* ((heading `(:font "Work Sans")))
     (custom-theme-set-faces 'user
                             `(org-document-title ((t (,@heading :height 1.4 :weight semibold))))
                             `(org-level-1 ((t (,@heading :height 1.3 :weight semibold))))
                             `(org-level-2 ((t (,@heading :height 1.2 :weight semibold))))
                             `(org-level-3 ((t (,@heading :height 1.1 :weight semibold))))
                             `(org-level-4 ((t (,@heading :height 1.0 :weight semibold))))
                             `(org-level-5 ((t (,@heading))))
                             `(org-level-6 ((t (,@heading))))
                             `(org-level-7 ((t (,@heading))))
                             `(org-level-8 ((t (,@heading))))))

   ;; Darken source block background for emphasis
   (require 'color)
   (set-face-attribute 'org-block nil
                       :background (color-darken-name
                                    (face-attribute 'default :background) 2)
                       :extend t)

   ;; Permit evaluation of various languages in src blocks
   (org-babel-do-load-languages
    'org-babel-load-languages
    '((dot . t)
      (emacs-lisp . t)
      (python . t)
      (ruby . t)
      (shell . t)
      (sql . t)))

   ;; Markdown export
   (require 'ox-md)

   ;; Soft-wrap long lines
   (add-hook 'org-mode-hook 'visual-line-mode)
   ;; (add-hook 'org-mode-hook (lambda () (setq fill-column 100)))
   ;; (add-hook 'org-mode-hook 'visual-fill-column-mode)

   ;; Replace dashes with bullets in lists (per
   ;; http://www.howardism.org/Technical/Emacs/orgmode-wordprocessor.html)
   (font-lock-add-keywords 'org-mode
                           '(("^ *\\([-]\\) "
                              (0 (prog1 () (compose-region (match-beginning 1)
                                                           (match-end 1)
                                                           "•" ; or "·"
                                                           ))))))

   ;; We use a variable-width font for headings (see :custom-face section
   ;; above). This mostly looks nice, but results in a minor visual annoyance
   ;; where headings don't align precisely with their subsequent body text,
   ;; because the headline bullet (and following space) are rendered in a
   ;; variable-width font. To ensure everything lines up nicely, we render the
   ;; bullet and space in the default (fixed-width) body font.
   (font-lock-add-keywords 'org-mode '(("^\\**\\(\\* \\)" 1 (let* ((level (- (match-end 0) (match-beginning 0) 1)))
                                                              (list :inherit (intern (format "org-level-%s" level))
                                                                    :family (face-attribute 'default :family)
                                                                    :height (face-attribute 'default :height)))))))

;; Show unicode bullets instead of asterisks for headings
(use-package org-bullets
  :hook (org-mode . org-bullets-mode)
  :custom
  ;; Use the same bullet at all levels
  (org-bullets-bullet-list '("•")))

(defun sc/weekly-review ()
  (interactive)
  (switch-to-buffer (format "review-%s" (format-time-string "%Y-%m-%d")))
  (org-mode)
  (insert-file-contents "~/org/weekly-review.org"))


;; # Miscellanous helper functions and utilities

(add-to-list 'load-path "~/.emacs.d/lisp")
;; TODO: should we lazy-load these?
(load "utils")
(load "heroku")
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
