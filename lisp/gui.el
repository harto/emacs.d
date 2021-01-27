;; GUI instance acts as server (should only be one)
(server-start)

(defun load-env-from-shell ()
  (dolist (line (split-string (shell-command-to-string "$SHELL -lc env") "\n" t))
    (let* ((parts (split-string line "="))
           (k (nth 0 parts))
           (v (nth 1 parts)))
      (setenv k v))))

(defun reset-exec-path-from-env ()
  (setq exec-path (split-string (getenv "PATH") path-separator)))

(defun reset-mac-os-env ()
  "Works around macOS environment problems by loading env (and
subsequently $PATH) via shell profile."
  (load-env-from-shell)
  (reset-exec-path-from-env))

(when (eq system-type 'darwin)
  (reset-mac-os-env)
  ;; Set default directory to ~ (this was the behaviour prior to Emacs 27)
  (cd "~"))

;; Theme hooks, per http://www.greghendershott.com/2017/02/emacs-themes.html

(defvar load-theme-hooks nil)

(defun load-theme-advice (f theme-id &optional no-confirm no-enable &rest args)
  (unless no-enable
    ;; disable all themes for blank slate
    (mapc #'disable-theme custom-enabled-themes))
  (prog1
      (apply f theme-id no-confirm no-enable args)
    (unless no-enable
      (dolist (hook load-theme-hooks)
        (funcall hook theme-id)))))

(advice-add 'load-theme :around #'load-theme-advice)

;; Theme configuration

;; Tweak modeline border, per
;; https://github.com/bbatsov/solarized-emacs#underline-position-setting-for-x
(setq x-underline-at-descent-line t)

(setq solarized-use-variable-pitch nil
      solarized-height-minus-1 1.0
      solarized-height-plus-1 1.0
      solarized-height-plus-2 1.0
      solarized-height-plus-3 1.0
      solarized-height-plus-4 1.0)

(defun big-screen ()
  (interactive)
  (set-frame-font "Monaco-14" t t))

(defun small-screen ()
  (interactive)
  (set-frame-font "Monaco-12" t t))

(defun hi-vis ()
  (interactive)
  (big-screen)
  (load-theme 'solarized-light))

(defun lo-vis ()
  (interactive)
  (small-screen)
  (load-theme 'solarized-dark))

;; line-number-mode is disabled when changing themes for some reason
(add-hook 'load-theme-hooks (lambda (theme) (line-number-mode +1)))

(lo-vis)
