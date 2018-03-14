;; Fancy Mode Line
;; Cribbed from https://github.com/hlissner/doom-emacs/tree/master/modules/ui/doom-modeline

;; Possible future improvements
;; - efficiently display number of lines
;; - maximize performance

(require 'memoize)
(require 'all-the-icons)

;; Variables

;; TODO: switch to multiplier of font height?
(defvar fml-vertical-padding 12)

(defvar fml-buffer-file-name-style 'project-relative-with-root
  "Determines the style used by `fml--buffer-file-name'.

Given ~/src/project/subproject/foo_bar/baz.py
project-relative-with-root => project/subproject/foo_bar/baz.py
project-relative => subproject/foo_bar/baz.py
file-name => baz.py")

;; Custom faces
;; (Do these need a real group?)

(defface fml-buffer-path
  '((t (:inherit (mode-line-emphasis bold))))
  "Face used for the dirname part of the buffer path.")

(defface fml-buffer-file
  '((t (:inherit (mode-line-buffer-id bold))))
  "Face used for the filename part of the mode-line buffer path.")

(defface fml-buffer-modified
  '((t (:inherit (error bold) :background nil)))
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


;; Helpers

(defun fml--window-active-p ()
  (eq (get-buffer-window (current-buffer))
      (selected-window)))

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
  (fml--make-xpm 1 (fml--spacer-height) (face-background 'mode-line)))

(defun fml--inactive-vspace ()
  (fml--make-xpm 1 (fml--spacer-height) (face-background 'mode-line-inactive)))

(defun fml--buffer-file-name ()
  "Propertized `buffer-file-name' based on `fml-buffer-file-name-style'."
  ;; TODO: find a better colour when file modified
  ;; TODO: read-only representation (italics?)
  (propertize
   (pcase fml-buffer-file-name-style
     ('project-relative (fml--buffer-file-name-relative))
     ('project-relative-with-root (fml--buffer-file-name-relative 'include-project))
     ('file-name (fml--buffer-file-name-bare)))
   'help-echo buffer-file-truename))

(defun fml--buffer-file-name-bare ()
  (propertize
   (file-name-nondirectory buffer-file-name)
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


;; Segments

(defvar fml--vspace `(:eval (if (fml--window-active-p)
                                (fml--active-vspace)
                              (fml--inactive-vspace))))

(defun fml--buffer-info ()
  (concat (cond (buffer-read-only
                 (concat (all-the-icons-octicon
                          "lock"
                          :face 'doom-modeline-warning
                          :v-adjust -0.05)
                         " "))
                ((buffer-modified-p)
                 (concat (all-the-icons-faicon
                          "floppy-o"
                          :face 'doom-modeline-buffer-modified
                          :v-adjust -0.0575)
                         " "))
                ((and buffer-file-name
                      (not (file-exists-p buffer-file-name)))
                 (concat (all-the-icons-octicon
                          "circle-slash"
                          :face 'doom-modeline-urgent
                          :v-adjust -0.05)
                         " "))
                ((buffer-narrowed-p)
                 (concat (all-the-icons-octicon
                          "fold"
                          :face 'doom-modeline-warning
                          :v-adjust -0.05)
                         " ")))
          (if buffer-file-name
              (fml--buffer-file-name)
            "%b")))

(defvar fml--position-info
  ;; TODO: highlight just the line number
  `((line-number-mode ((11 (" [%l"
                            (column-number-mode ":%c")
                            "]"))))
    (-4 " %p")))

(defun fml--vc ()
  "Displays the current branch, colored based on its state."
  (when (and vc-mode buffer-file-name)
    (let* ((backend (vc-backend buffer-file-name))
           (state   (vc-state buffer-file-name backend))
           (active  (fml--window-active-p))
           (face    (if active 'mode-line 'mode-line-inactive))
           (all-the-icons-default-adjust -0.1))
      (concat "  "
              (cond ((memq state '(edited added))
                     ;(if active (setq face 'doom-modeline-info))
                     (all-the-icons-octicon
                      "git-compare"
                      :face face
                      :v-adjust -0.05))

                    ((eq state 'needs-merge)
                     ;(if active (setq face 'doom-modeline-info))
                     (all-the-icons-octicon "git-merge" :face face))

                    ((eq state 'needs-update)
                     ;(if active (setq face 'doom-modeline-warning))
                     (all-the-icons-octicon "arrow-down" :face face))

                    ((memq state '(removed conflict unregistered))
                     ;(if active (setq face 'doom-modeline-urgent))
                     (all-the-icons-octicon "alert" :face face))

                    (t
                     (if active (setq face 'font-lock-doc-face))
                     (all-the-icons-octicon
                      "git-compare"
                      :face face
                      :v-adjust -0.05)))
              " "
              (propertize (substring vc-mode (+ (if (eq backend 'Hg) 2 3) 2))
                          'face (if active face))
              " "))))

;; (def-modeline-segment! buffer-encoding
;;   "Displays the encoding and eol style of the buffer the same way Atom does."
;;   (concat (pcase (coding-system-eol-type buffer-file-coding-system)
;;             (0 "LF  ")
;;             (1 "CRLF  ")
;;             (2 "CR  "))
;;           (let ((sys (coding-system-plist buffer-file-coding-system)))
;;             (cond ((memq (plist-get sys :category) '(coding-category-undecided coding-category-utf-8))
;;                    "UTF-8")
;;                   (t (upcase (symbol-name (plist-get sys :name))))))
;;           "  "))

;;
;; (def-modeline-segment! major-mode
;;   "The major mode, including process, environment and text-scale info."
;;   (propertize
;;    (concat (format-mode-line mode-name)
;;            (when (stringp mode-line-process)
;;              mode-line-process)
;;            (and (featurep 'face-remap)
;;                 (/= text-scale-mode-amount 0)
;;                 (format " (%+d)" text-scale-mode-amount)))
;;    'face (if (active) 'doom-modeline-buffer-major-mode)))


;; Modlines

(setq mode-line-format `("%e"
                         ,fml--vspace
                         mode-line-front-space
                         ;mode-line-mule-info
                         ;mode-line-client
                         ;mode-line-modified
                          ;mode-line-remote
                         ;mode-line-frame-identification
                         ;"  "
                         (:eval (fml--buffer-info))
                         ,fml--position-info
                         (:eval (fml--vc))
                         "  "
                         mode-line-modes
                         mode-line-misc-info
                         mode-line-end-spaces))

;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (defmacro add-transient-hook! (hook &rest forms)
;;   "Attaches transient forms to a HOOK.
;; HOOK can be a quoted hook or a sharp-quoted function (which will be advised).
;; These forms will be evaluated once when that function/hook is first invoked,
;; then it detaches itself."
;;   (declare (indent 1))
;;   (let ((append (eq (car forms) :after))
;;         (fn (intern (format "doom-transient-hook-%s" (cl-incf doom--transient-counter)))))
;;     `(when ,hook
;;        (fset ',fn
;;              (lambda (&rest _)
;;                ,@forms
;;                (cond ((functionp ,hook) (advice-remove ,hook #',fn))
;;                      ((symbolp ,hook)   (remove-hook ,hook #',fn)))
;;                (unintern ',fn nil)))
;;        (cond ((functionp ,hook)
;;               (advice-add ,hook ,(if append :after :before) #',fn))
;;              ((symbolp ,hook)
;;               (add-hook ,hook #',fn ,append))))))


(defmacro def-modeline-segment! (name &rest forms)
  "Defines a modeline segment and byte compiles it."
  (declare (indent defun) (doc-string 2))
  (let ((sym (intern (format "doom-modeline-segment--%s" name))))
    `(progn
       (defun ,sym () ,@forms)
       ,(unless (bound-and-true-p byte-compile-current-file)
          `(let (byte-compile-warnings)
             (byte-compile #',sym))))))

(defsubst doom--prepare-modeline-segments (segments)
  (cl-loop for seg in segments
           if (stringp seg)
            collect seg
           else
            collect (list (intern (format "doom-modeline-segment--%s" (symbol-name seg))))))

(defmacro def-modeline! (name lhs &optional rhs)
  "Defines a modeline format and byte-compiles it. NAME is a symbol to identify
it (used by `doom-modeline' for retrieval). LHS and RHS are lists of symbols of
modeline segments defined with `def-modeline-segment!'.
Example:
  (def-modeline! minimal
    (bar matches \" \" buffer-info)
    (media-info major-mode))
  (doom-set-modeline 'minimal t)"
  (let ((sym (intern (format "doom-modeline-format--%s" name)))
        (lhs-forms (doom--prepare-modeline-segments lhs))
        (rhs-forms (doom--prepare-modeline-segments rhs)))
    `(progn
       (defun ,sym ()
         (let ((lhs (list ,@lhs-forms))
               (rhs (list ,@rhs-forms)))
           (let ((rhs-str (format-mode-line rhs)))
             (list lhs
                   (propertize
                    " " 'display
                    `((space :align-to (- (+ right right-fringe right-margin)
                                          ,(+ 1 (string-width rhs-str))))))
                   rhs-str))))
       ,(unless (bound-and-true-p byte-compile-current-file)
          `(let (byte-compile-warnings)
             (byte-compile #',sym))))))

(defun doom-modeline (key)
  "Returns a mode-line configuration associated with KEY (a symbol). Throws an
error if it doesn't exist."
  (let ((fn (intern (format "doom-modeline-format--%s" key))))
    (when (functionp fn)
      `(:eval (,fn)))))

(defun doom-set-modeline (key &optional default)
  "Set the modeline format. Does nothing if the modeline KEY doesn't exist. If
DEFAULT is non-nil, set the default mode-line for all buffers."
  (when-let* ((modeline (doom-modeline key)))
    (setf (if default
              (default-value 'mode-line-format)
            (buffer-local-value 'mode-line-format (current-buffer)))
          modeline)))

(def-package! eldoc-eval
  :config
  (defun +doom-modeline-eldoc (text)
    (concat (when (display-graphic-p)
              (+doom-modeline--make-xpm
               (face-background 'doom-modeline-eldoc-bar nil t)
               +doom-modeline-height
               +doom-modeline-bar-width))
            text))

  ;; Show eldoc in the mode-line with `eval-expression'
  (defun +doom-modeline--show-eldoc (input)
    "Display string STR in the mode-line next to minibuffer."
    (with-current-buffer (eldoc-current-buffer)
      (let* ((str              (and (stringp input) input))
             (mode-line-format (or (and str (or (+doom-modeline-eldoc str) str))
                                   mode-line-format))
             mode-line-in-non-selected-windows)
        (force-mode-line-update)
        (sit-for eldoc-show-in-mode-line-delay))))
  (setq eldoc-in-minibuffer-show-fn #'+doom-modeline--show-eldoc)

  (eldoc-in-minibuffer-mode +1))

;; anzu and evil-anzu expose current/total state that can be displayed in the
;; mode-line.
(def-package! evil-anzu
  :requires evil
  :init
  (add-transient-hook! #'evil-ex-start-search (require 'evil-anzu))
  (add-transient-hook! #'evil-ex-start-word-search (require 'evil-anzu))
  :config
  (setq anzu-cons-mode-line-p nil
        anzu-minimum-input-length 1
        anzu-search-threshold 250)
  ;; Avoid anzu conflicts across buffers
  (mapc #'make-variable-buffer-local
        '(anzu--total-matched anzu--current-position anzu--state
          anzu--cached-count anzu--cached-positions anzu--last-command
          anzu--last-isearch-string anzu--overflow-p))
  ;; Ensure anzu state is cleared when searches & iedit are done
  (add-hook 'isearch-mode-end-hook #'anzu--reset-status t)
  (add-hook '+evil-esc-hook #'anzu--reset-status t)
  (add-hook 'iedit-mode-end-hook #'anzu--reset-status))


;; Keep `+doom-modeline-current-window' up-to-date
(defvar +doom-modeline-current-window (frame-selected-window))
(defun +doom-modeline|set-selected-window (&rest _)
  "Sets `+doom-modeline-current-window' appropriately"
  (when-let* ((win (frame-selected-window)))
    (unless (minibuffer-window-active-p win)
      (setq +doom-modeline-current-window win))))

(add-hook 'window-configuration-change-hook #'+doom-modeline|set-selected-window)
(add-hook 'focus-in-hook #'+doom-modeline|set-selected-window)
(advice-add #'handle-switch-frame :after #'+doom-modeline|set-selected-window)
(advice-add #'select-window :after #'+doom-modeline|set-selected-window)

;; fish-style modeline
(def-package! shrink-path
  :commands (shrink-path-prompt shrink-path-file-mixed))


;;
;; Variables
;;

(defvar +doom-modeline-height 29
  "How tall the mode-line should be (only respected in GUI emacs).")

(defvar +doom-modeline-bar-width 3
  "How wide the mode-line bar should be (only respected in GUI emacs).")

(defvar +doom-modeline-vspc
  (propertize " " 'face 'variable-pitch)
  "TODO")

(defvar +doom-modeline-buffer-file-name-style 'truncate-upto-project
  "Determines the style used by `+doom-modeline-buffer-file-name'.

Given ~/Projects/FOSS/emacs/lisp/comint.el
truncate-upto-project => ~/P/F/emacs/lisp/comint.el
truncate-upto-root => ~/P/F/e/lisp/comint.el
truncate-all => ~/P/F/e/l/comint.el
relative-from-project => emacs/lisp/comint.el
relative-to-project => lisp/comint.el
file-name => comint.el")

;; externs
(defvar anzu--state nil)
(defvar evil-mode nil)
(defvar evil-state nil)
(defvar evil-visual-selection nil)
(defvar iedit-mode nil)
(defvar all-the-icons-scale-factor)
(defvar all-the-icons-default-adjust)

;;
;; Modeline helpers
;;


;;
;; Segments
;;

(def-modeline-segment! buffer-default-directory
  "Displays `default-directory'. This is for special buffers like the scratch
buffer where knowing the current project directory is important."
  (let ((face (if (active) 'doom-modeline-buffer-path)))
    (concat (if (display-graphic-p) " ")
            (all-the-icons-octicon
             "file-directory"
             :face face
             :v-adjust -0.05
             :height 1.25)
            (propertize (concat " " (abbreviate-file-name default-directory))
                        'face face))))

;;
(def-modeline-segment! buffer-info
  "Combined information about the current buffer, including the current working
directory, the file name, and its state (modified, read-only or non-existent)."
  (concat (cond (buffer-read-only
                 (concat (all-the-icons-octicon
                          "lock"
                          :face 'doom-modeline-warning
                          :v-adjust -0.05)
                         " "))
                ((buffer-modified-p)
                 (concat (all-the-icons-faicon
                          "floppy-o"
                          :face 'doom-modeline-buffer-modified
                          :v-adjust -0.0575)
                         " "))
                ((and buffer-file-name
                      (not (file-exists-p buffer-file-name)))
                 (concat (all-the-icons-octicon
                          "circle-slash"
                          :face 'doom-modeline-urgent
                          :v-adjust -0.05)
                         " "))
                ((buffer-narrowed-p)
                 (concat (all-the-icons-octicon
                          "fold"
                          :face 'doom-modeline-warning
                          :v-adjust -0.05)
                         " ")))
          (if buffer-file-name
              (+doom-modeline-buffer-file-name)
            "%b")))

;;
(def-modeline-segment! buffer-info-simple
  "Display only the current buffer's name, but with fontification."
  (propertize
   "%b"
   'face (cond ((and buffer-file-name (buffer-modified-p))
                'doom-modeline-buffer-modified)
               ((active) 'doom-modeline-buffer-file))))

;;

;;
(defun mode-line--icon (icon &optional text face voffset)
  "Displays an octicon ICON with FACE, followed by TEXT. Uses
`all-the-icons-octicon' to fetch the icon."
  (concat (if vc-mode " " "  ")
          (when icon
            (concat
             (all-the-icons-material icon :face face :height 1.1 :v-adjust (or voffset -0.2))
             (if text +doom-modeline-vspc)))
          (when text
            (propertize text 'face face))
          (if vc-mode "  " " ")))

(def-modeline-segment! flycheck
  "Displays color-coded flycheck error status in the current buffer with pretty
icons."
  (when (boundp 'flycheck-last-status-change)
    (pcase flycheck-last-status-change
      ('finished (if flycheck-current-errors
                     (let-alist (flycheck-count-errors flycheck-current-errors)
                       (let ((sum (+ (or .error 0) (or .warning 0))))
                         (mode-line--icon "do_not_disturb_alt"
                                        (number-to-string sum)
                                        (if .error 'doom-modeline-urgent 'doom-modeline-warning)
                                        -0.25)))
                   (mode-line--icon "check" nil 'doom-modeline-info)))
      ('running     (mode-line--icon "access_time" nil 'font-lock-doc-face -0.25))
      ('no-checker  (mode-line--icon "sim_card_alert" "-" 'font-lock-doc-face))
      ('errored     (mode-line--icon "sim_card_alert" "Error" 'doom-modeline-urgent))
      ('interrupted (mode-line--icon "pause" "Interrupted" 'font-lock-doc-face)))))
      ;; ('interrupted (mode-line--icon "x" "Interrupted" 'font-lock-doc-face)))))

;;
(defsubst doom-column (pos)
  (save-excursion (goto-char pos)
                  (current-column)))

(def-modeline-segment! selection-info
  "Information about the current selection, such as how many characters and
lines are selected, or the NxM dimensions of a block selection."
  (when (and (active) (or mark-active (eq evil-state 'visual)))
    (let ((reg-beg (region-beginning))
          (reg-end (region-end)))
      (propertize
       (let ((lines (count-lines reg-beg (min (1+ reg-end) (point-max)))))
         (cond ((or (bound-and-true-p rectangle-mark-mode)
                    (eq 'block evil-visual-selection))
                (let ((cols (abs (- (doom-column reg-end)
                                    (doom-column reg-beg)))))
                  (format "%dx%dB" lines cols)))
               ((eq 'line evil-visual-selection)
                (format "%dL" lines))
               ((> lines 1)
                (format "%dC %dL" (- (1+ reg-end) reg-beg) lines))
               (t
                (format "%dC" (- (1+ reg-end) reg-beg)))))
       'face 'doom-modeline-highlight))))


;;
(defun +doom-modeline--macro-recording ()
  "Display current Emacs or evil macro being recorded."
  (when (and (active) (or defining-kbd-macro executing-kbd-macro))
    (let ((sep (propertize " " 'face 'doom-modeline-panel)))
      (concat sep
              (propertize (if (bound-and-true-p evil-this-macro)
                              (char-to-string evil-this-macro)
                            "Macro")
                          'face 'doom-modeline-panel)
              sep
              (all-the-icons-octicon "triangle-right"
                                     :face 'doom-modeline-panel
                                     :v-adjust -0.05)
              sep))))

(defsubst +doom-modeline--anzu ()
  "Show the match index and total number thereof. Requires `anzu', also
`evil-anzu' if using `evil-mode' for compatibility with `evil-search'."
  (when (and anzu--state (not iedit-mode))
    (propertize
     (let ((here anzu--current-position)
           (total anzu--total-matched))
       (cond ((eq anzu--state 'replace-query)
              (format " %d replace " total))
             ((eq anzu--state 'replace)
              (format " %d/%d " here total))
             (anzu--overflow-p
              (format " %s+ " total))
             (t
              (format " %s/%d " here total))))
     'face (if (active) 'doom-modeline-panel))))

(defsubst +doom-modeline--evil-substitute ()
  "Show number of matches for evil-ex substitutions and highlights in real time."
  (when (and evil-mode
             (or (assq 'evil-ex-substitute evil-ex-active-highlights-alist)
                 (assq 'evil-ex-global-match evil-ex-active-highlights-alist)
                 (assq 'evil-ex-buffer-match evil-ex-active-highlights-alist)))
    (propertize
     (let ((range (if evil-ex-range
                      (cons (car evil-ex-range) (cadr evil-ex-range))
                    (cons (line-beginning-position) (line-end-position))))
           (pattern (car-safe (evil-delimited-arguments evil-ex-argument 2))))
       (if pattern
           (format " %s matches " (how-many pattern (car range) (cdr range)))
         " - "))
     'face (if (active) 'doom-modeline-panel))))

(defun doom-themes--overlay-sort (a b)
  (< (overlay-start a) (overlay-start b)))

(defsubst +doom-modeline--iedit ()
  "Show the number of iedit regions matches + what match you're on."
  (when (and iedit-mode iedit-occurrences-overlays)
    (propertize
     (let ((this-oc (or (let ((inhibit-message t))
                          (iedit-find-current-occurrence-overlay))
                        (progn (iedit-prev-occurrence)
                               (iedit-find-current-occurrence-overlay))))
           (length (length iedit-occurrences-overlays)))
       (format " %s/%d "
               (if this-oc
                   (- length
                      (length (memq this-oc (sort (append iedit-occurrences-overlays nil)
                                                  #'doom-themes--overlay-sort)))
                      -1)
                 "-")
               length))
     'face (if (active) 'doom-modeline-panel))))

(def-modeline-segment! matches
  "Displays: 1. the currently recording macro, 2. A current/total for the
current search term (with anzu), 3. The number of substitutions being conducted
with `evil-ex-substitute', and/or 4. The number of active `iedit' regions."
  (let ((meta (concat (+doom-modeline--macro-recording)
                      (+doom-modeline--anzu)
                      (+doom-modeline--evil-substitute)
                      (+doom-modeline--iedit))))
     (or (and (not (equal meta "")) meta)
         (if buffer-file-name " %I "))))

;; TODO Include other information
(def-modeline-segment! media-info
  "Metadata regarding the current file, such as dimensions for images."
  (cond ((eq major-mode 'image-mode)
         (cl-destructuring-bind (width . height)
             (image-size (image-get-display-property) :pixels)
           (format "  %dx%d  " width height)))))

(def-modeline-segment! bar
  "The bar regulates the height of the mode-line in GUI Emacs.
Returns \"\" to not break --no-window-system."
  (if (display-graphic-p)
      (+doom-modeline--make-xpm
       (face-background (if (active)
                            'doom-modeline-bar
                          'doom-modeline-inactive-bar)
                        nil t)
       +doom-modeline-height
       +doom-modeline-bar-width)
    ""))


;;
;; Mode lines
;;

(def-modeline! main
  (bar matches " " buffer-info "  %l:%c %p  " selection-info)
  (buffer-encoding major-mode vcs flycheck))

(def-modeline! minimal
  (bar matches " " buffer-info)
  (media-info major-mode))

(def-modeline! special
  (bar matches " " buffer-info-simple "  %l:%c %p  " selection-info)
  (buffer-encoding major-mode flycheck))

(def-modeline! project
  (bar buffer-default-directory)
  (major-mode))

(def-modeline! media
  (bar " %b  ")
  (media-info major-mode))


;;
;; Hooks
;;

(defun +doom-modeline|init ()
  "Set the default modeline."
  (doom-set-modeline 'main t)

  ;; This scratch buffer is already created and doesn't get a modeline. For the
  ;; love of Emacs, someone give the man a modeline!
  (with-current-buffer "*scratch*"
    (doom-set-modeline 'main)))

(defun +doom-modeline|set-special-modeline ()
  (doom-set-modeline 'special))

(defun +doom-modeline|set-media-modeline ()
p  (doom-set-modeline 'media))

(defun +doom-modeline|set-project-modeline ()
  (doom-set-modeline 'project))


;;
;; Bootstrap
;;

(add-hook 'doom-init-ui-hook #'+doom-modeline|init)
(add-hook 'doom-scratch-buffer-hook #'+doom-modeline|set-special-modeline)
(add-hook '+doom-dashboard-mode-hook #'+doom-modeline|set-project-modeline)

(add-hook 'image-mode-hook   #'+doom-modeline|set-media-modeline)
(add-hook 'org-src-mode-hook #'+doom-modeline|set-special-modeline)
(add-hook 'circe-mode-hook   #'+doom-modeline|set-special-modeline)
