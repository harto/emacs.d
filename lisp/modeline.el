;; Fancy Mode Line
;; Adapted from https://github.com/hlissner/doom-emacs/tree/master/modules/ui/doom-modeline

;; TODO
;; - ensure completions don't slip under modeline
;; - fix right-alignment when flycheck etc. not enabled
;; - unsaved indicator:
;;   - don't show for non-file/"special" buffers
;;   - only show the disk in red, not the whole filename
;; - different read-only indicator?
;; - flycheck-mode: don't change layout while checking
;;   - maybe track last count and show e.g. "--"
;; - abbreviate "Emacs-Lisp" etc.
;; - show number of lines
;; - anzu etc.
;; - git indicators in gutter
;; - improve flycheck gutter indicators
;; - fix colours (git branch, etc.)
;; - fix 1px-wide bar colour
;; - hover text for various modeline segments
;; - byte-compilation?

(defun adjust-mode-line-colours (theme)
  (when (or (eq theme 'solarized-dark) (eq theme 'solarized-light))
    (set-face-attribute 'mode-line nil
                        :underline nil
                        :overline nil
                        :box nil)
    (set-face-attribute 'mode-line-inactive nil
                        :overline nil
                        :underline nil
                        :box nil
                        :background (solarized-color-blend (face-attribute 'default :background)
                                                           (face-attribute 'mode-line :background)
                                                           0.5))))

;; Disable mode-line border whenever we switch themes
(add-hook 'sc/load-theme-hooks #'adjust-mode-line-colours)

(require 'memoize)
(require 'all-the-icons)

;; Configuration

(defvar fml-buffer-file-name-style 'file-name
  "Determines the style used by `fml--buffer-file-name'.

Given ~/src/project/subproject/foo_bar/baz.py
project-relative-with-root => project/subproject/foo_bar/baz.py
project-relative => subproject/foo_bar/baz.py
file-name => baz.py")

;(defvar fml-spacer-width 1)
;; TODO: switch to multiplier of font height?
(defvar fml-vertical-padding 8)

;; Faces

(defface fml-buffer-path
  '((t (:inherit (mode-line-emphasis bold))))
  "Face used for the dirname part of the buffer path.")

(defface fml-buffer-file
  '((t (:inherit (mode-line-buffer-id bold))))
  "Face used for the filename part of the mode-line buffer path.")

(defface fml-buffer-modified
  '((t (:inherit (warning bold) :background nil)))
  "Face used for the 'unsaved' symbol in the mode-line.")

(defface fml-buffer-major-mode
  '((t (:inherit (mode-line-emphasis bold))))
  "Face used for the major-mode segment in the mode-line.")

(defface fml-highlight
  '((t (:inherit mode-line-emphasis)))
  "Face for bright segments of the mode-line.")

;; (defface fml-panel
;;   '((t (:inherit mode-line-highlight)))
;;   "Face for 'X out of Y' segments, such as `+doom-modeline--anzu', `+doom-modeline--evil-substitute' and
;; `iedit'"
;;   :group '+doom-modeline)

(defface fml-info
  `((t (:inherit (success bold))))
  "Face for info-level messages in the modeline. Used by `*vc'.")

(defface fml-warning
  `((t (:inherit (warning bold))))
  "Face for warnings in the modeline. Used by `*flycheck'")

(defface fml-error
  `((t (:inherit (error bold))))
  "Face for errors in the modeline. Used by `*flycheck'")

;; Bar
;; (defface doom-modeline-bar '((t (:inherit highlight)))
;;   "The face used for the left-most bar on the mode-line of an active window."
;;   :group '+doom-modeline)

;; (defface doom-modeline-eldoc-bar '((t (:inherit shadow)))
;;   "The face used for the left-most bar on the mode-line when eldoc-eval is
;; active."
;;   :group '+doom-modeline)

;; (defface doom-modeline-inactive-bar '((t (:inherit warning :inverse-video t)))
;;   "The face used for the left-most bar on the mode-line of an inactive window."
;;   :group '+doom-modeline)

;;
;; Helpers
;;

(defsubst fml--window-active-p ()
  (eq (get-buffer-window (current-buffer))
      (selected-window)))

;;
;; Vertical space
;;

(defun fml--spacer-height ()
  (let* ((font-height (/ (face-attribute 'default :height) 10)))
    (+ font-height (* 2 fml-vertical-padding))))

(defun fml--make-xpm (width height color)
  "Create an XPM bitmap."
  (propertize
   " " 'display
   (let ((data (make-list height (make-list width 1)))
         (color (or color "None")))
     (create-image
      (concat
       (format "/* XPM */\nstatic char * percent[] = {\n\"%i %i 2 1\",\n\". c %s\",\n\"  c %s\","
               (length (car data))
               (length data)
               color
               color)
       (apply #'concat
              (cl-loop with idx = 0
                       with len = (length data)
                       for dl in data
                       do (cl-incf idx)
                       collect
                       (concat "\""
                               (cl-loop for d in dl
                                        if (= d 0) collect (string-to-char " ")
                                        else collect (string-to-char "."))
                               (if (eq idx len) "\"};" "\",\n")))))
      'xpm t :ascent 'center))))

(memoize 'fml--make-xpm nil)

(defun fml--active-vspace ()
  (fml--make-xpm 1 (fml--spacer-height) (face-attribute 'mode-line :background)))

(defun fml--inactive-vspace ()
  (fml--make-xpm 1 (fml--spacer-height) (face-background 'mode-line-inactive)))

(defun fml--buffer-file-name ()
  "Propertized `buffer-file-name' based on `fml-buffer-file-name-style'."
  ;; TODO: find a better colour when file modified
  (propertize
   (pcase fml-buffer-file-name-style
     ('project-relative (fml--buffer-file-name-relative))
     ('project-relative-with-root (fml--buffer-file-name-relative 'include-project))
     ('file-name (fml--buffer-file-name-bare)))
   'help-echo buffer-file-truename))

(defun fml--buffer-file-name-bare ()
  (propertize
   "%b"
   'face
   (let ((face (cond ((buffer-modified-p) 'fml-buffer-modified)
                     ((fml--window-active-p) 'fml-buffer-file))))
     (when face `(:inherit ,face)))))

(defun fml--buffer-file-name-relative (&optional include-project)
  "Propertized `buffer-file-name' showing directories relative to project's root."
  (let ((root (file-truename (project-root))))
    (if (null root)
        (fml--buffer-file-name-bare)
      (let* ((active (fml--window-active-p))
             (modified-faces (if (buffer-modified-p) 'fml-buffer-modified))
             (relative-dirs (file-relative-name (file-name-directory buffer-file-name)
                                                (if include-project (concat root "/..") root)))
             (relative-faces (or modified-faces (if active 'fml-buffer-path)))
             (file-faces (or modified-faces (if active 'fml-buffer-file))))
        (if (equal "./" relative-dirs) (setq relative-dirs ""))
        (concat (propertize relative-dirs 'face (if relative-faces `(:inherit ,relative-faces)))
                (propertize (file-name-nondirectory buffer-file-truename)
                            'face (if file-faces `(:inherit ,file-faces))))))))

;; Modeline segments

(defvar fml--vspace `(:eval (if (fml--window-active-p)
                                (fml--active-vspace)
                              (fml--inactive-vspace))))

(defun fml--buffer-info ()
  (concat (cond ((and buffer-file-name buffer-read-only)
                 (concat (all-the-icons-octicon
                          "lock"
                          :face 'fml-warning
                          :v-adjust -0.05)
                         " "))
                ((and buffer-file-name (buffer-modified-p))
                 (concat (all-the-icons-faicon
                          "floppy-o"
                          :face 'fml-buffer-modified
                          :v-adjust -0.0575)
                         " "))
                ((and buffer-file-name (not (file-exists-p buffer-file-name)))
                 (concat (all-the-icons-octicon
                          "circle-slash"
                          :face 'fml-error
                          :v-adjust -0.05)
                         " "))
                ((buffer-narrowed-p)
                 (concat (all-the-icons-octicon
                          "fold"
                          :face 'fml-warning
                          :v-adjust -0.05)
                         " ")))
          (if buffer-file-name
              (fml--buffer-file-name)
            "%b")))

(defvar fml--position-info
  ;; TODO: highlight just the line number
  `("  "
    (-3 "%p")
    (line-number-mode ((" %l" (column-number-mode ":%c"))))))

(defun fml--buffer-encoding ()
  (concat (pcase (coding-system-eol-type buffer-file-coding-system)
            (0 "LF")
            (1 "CRLF")
            (2 "CR"))
          "  "
          (let ((sys (coding-system-plist buffer-file-coding-system)))
            (cond ((memq (plist-get sys :category) '(coding-category-undecided coding-category-utf-8))
                   "UTF-8")
                  (t (upcase (symbol-name (plist-get sys :name))))))))

(defun fml--vc ()
  "Displays the current branch, colored based on its state."
  (when (and vc-mode buffer-file-name)
    (let* ((backend (vc-backend buffer-file-name))
           (state   (vc-state buffer-file-name backend))
           (active  (fml--window-active-p))
           (face    (if active 'mode-line 'mode-line-inactive))
           (all-the-icons-default-adjust -0.1))
      (concat "   "
              (cond ((memq state '(edited added))
                     (if active (setq face 'fml-info))
                     (all-the-icons-octicon
                      "git-compare"
                      :face face
                      :v-adjust -0.05))

                    ((eq state 'needs-merge)
                     (if active (setq face 'fml-info))
                     (all-the-icons-octicon "git-merge" :face face))

                    ((eq state 'needs-update)
                     (if active (setq face 'fml-warning))
                     (all-the-icons-octicon "arrow-down" :face face))

                    ((memq state '(removed conflict unregistered))
                     (if active (setq face 'fml-error))
                     (all-the-icons-octicon "alert" :face face))

                    (t
                     (if active (setq face 'font-lock-doc-face))
                     (all-the-icons-octicon
                      "git-compare"
                      :face face
                      :v-adjust -0.05)))
              " "
              (propertize (substring vc-mode (+ (if (eq backend 'Hg) 2 3) 2))
                          'face (if active face))))))

(defun fml--major-mode-info ()
  (propertize
   (concat "   "
           (format-mode-line mode-name)
           (when (stringp mode-line-process)
             mode-line-process)
           (and (featurep 'face-remap)
                (/= text-scale-mode-amount 0)
                (format " (%+d)" text-scale-mode-amount)))
   'face (if (fml--window-active-p) 'fml-buffer-major-mode)))

(defun fml--icon (icon &optional text face voffset)
  "Displays an octicon ICON with FACE, followed by TEXT. Uses
`all-the-icons-octicon' to fetch the icon."
  (concat "   "
          (when icon
            (concat
             (all-the-icons-material icon :face face :height 1.1 :v-adjust (or voffset -0.2))
                                        ;(if text +doom-modeline-vspc)
             ))
          (when text
            (propertize text 'face face))))

(defun fml--flycheck ()
  "Displays color-coded flycheck error status in the current buffer with pretty icons."
  (when (boundp 'flycheck-last-status-change)
    (pcase flycheck-last-status-change
      ('finished (if flycheck-current-errors
                     (let-alist (flycheck-count-errors flycheck-current-errors)
                       (fml--icon "warning"
                                  (format " %d" (or .error .warning))
                                  (if .error 'fml-error 'fml-warning)
                                  -0.25))
                   (fml--icon "check" nil 'fml-info)))
      ('running     (fml--icon "access_time" nil 'font-lock-doc-face -0.25))
      ('no-checker  (fml--icon "sim_card_alert" "-" 'font-lock-doc-face))
      ('errored     (fml--icon "sim_card_alert" "Error" 'fml-error))
      ('interrupted (fml--icon "pause" "Interrupted" 'font-lock-doc-face)))))

;; Modeline definitions

;; (defmacro def-modeline (name lhs &optional rhs)
;;   "Defines a modeline format and byte-compiles it. NAME is a symbol to identify
;; it (used by `doom-modeline' for retrieval). LHS and RHS are lists of symbols of
;; modeline segments defined with `def-modeline-segment!'.
;; Example:
;;   (def-modeline! minimal
;;     (bar matches \" \" buffer-info)
;;     (media-info major-mode))
;;   (doom-set-modeline 'minimal t)"
;;   (let ((sym (intern (format "doom-modeline-format--%s" name)))
;;         (lhs-forms (doom--prepare-modeline-segments lhs))
;;         (rhs-forms (doom--prepare-modeline-segments rhs)))
;;     `(progn
;;        (defun ,sym ()
;;          (let ((lhs (list ,@lhs-forms))
;;                (rhs (list ,@rhs-forms)))
;;            (let ((rhs-str (format-mode-line rhs)))
;;              (list lhs
;;                    (propertize
;;                     " " 'display
;;                     `((space :align-to (- (+ right right-fringe right-margin)
;;                                           ,(+ 1 (string-width rhs-str))))))
;;                    rhs-str))))
;;        ,(unless (bound-and-true-p byte-compile-current-file)
;;           `(let (byte-compile-warnings)
;;              (byte-compile #',sym))))))

(defun fml-mode-line (lhs &optional rhs)
  (let ((rhs-str (format-mode-line rhs)))
    (list lhs
          (propertize
           " " 'display
           `((space :align-to (- (+ right right-fringe right-margin)
                                 ,(+ 3 (string-width rhs-str))))))
          rhs-str)))

(defun fml-standard-mode-line ()
  (fml-mode-line `("%e"
                   ,fml--vspace
                   mode-line-front-space
                   (:eval (fml--buffer-info))
                   ,fml--position-info)
                 `((:eval (fml--buffer-encoding))
                   (:eval (fml--vc))
                   (:eval (fml--major-mode-info))
                   (:eval (fml--flycheck)))))

(setq-default mode-line-format `((:eval (fml-standard-mode-line))))
