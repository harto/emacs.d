;;; service.el --- manage groups of services (processes) within Emacs

;;; Commentary:

;; Provides a way to configure and manage processes from within Emacs. Services
;; are defined using `define-service' and optionally arranged into groups with
;; `define-service-group'. Services and groups can then be managed with
;; `service-start', `service-stop', etc.
;;
;; A list view is provided by `list-services'. Services can be managed from
;; here, and also from their individual buffers.
;;
;; Additional features:
;; - Services may be arranged into groups, which can be managed together.
;; - Services may declare dependencies, which are started as needed.
;; - Functions for stopping, starting, and rebuilding services, and for
;;   constructing arbitrary commands that run in the context of a service.
;;
;; Similar packages:
;; - https://github.com/davidmiller/dizzee
;; - https://github.com/zweifisch/foreman-mode

;; TODO:
;; - flesh out service list mode
;; - optionally interactively edit config prior to start

(require 'comint)

(defvar service-configs-alist nil
  "Maps each service to its configuration alist.
This is normally populated via `define-service'.")

(defvar service-groups-alist nil
  "Maps each service group to the names of its members.
This is normally populated via `define-service-group'.")

(defun define-service (service &rest configs)
  "Registers SERVICE with given CONFIGS.

SERVICE should be a symbol. CONFIGS should be key-value pairs,
with the following keys supported:
  :cd          Directory in which the service should be run.
  :build       Command to (re)build the service (default: \"make\")
  :depends-on  Optional service name, or list of service names, to
               start along with this service
  :start       Command to start the service (e.g. \"bundle exec foo\")
  :stop        Optional command to stop the service (e.g.
               \"docker-compose down ...\"). By default, services
               are terminated via SIGTERM.
  :direnv      If non-nil, commands are prefixed with \"direnv exec ...\"
  :env         Optional alist of environment variables

Example usage:

  (define-service \\='foo
    :cd \"~/src/foo\"
    :start \"bin/start-foo\")

Once registered, services may be managed via `service-start', etc.
"
  (or (symbolp service)
      (error "Service identifier %S should be a symbol" service))
  ;; Delete any existing occurrence
  (setq service-configs-alist (assoc-delete-all service service-configs-alist))
  (let ((config-alist (mapcar
                       (lambda (kv) (cons (car kv) (cadr kv)))
                       (seq-partition configs 2))))
    (push (cons service config-alist) service-configs-alist)))

(defun define-service-group (group members)
  "Defines GROUP as a service group with MEMBERS.

Once defined, groups may be managed like services using
`service-start', etc."
  (setq service-groups-alist (assoc-delete-all group service-groups-alist))
  (push (cons group members) service-groups-alist))

(defun service--config (service)
  (or (alist-get service service-configs-alist)
      (error "Service not registered: %s" service)))

(defun service-directory (service)
  "Gets home directory of SERVICE."
  (if-let ((dir (alist-get :cd (service--config service))))
      (expand-file-name dir)
    default-directory))

(defun service-build-command (service &optional command)
  "Construct a command for execution in the context of SERVICE.

If COMMAND is not specified, the `:start' configuration option is used."
  (let* ((config (service--config service))
         (command (or command (alist-get :start config)))
         (parts (list command)))
    ;; TODO
    ;; (when-let ((env (alist-get :env config)))
    ;;   (push (format "env %s" (string-join (cl-loop for (k v)
    ;;                                                on env
    ;;                                                by 'cddr
    ;;                                                collect (format "%s=%s" k v))
    ;;                                       " "))
    ;;         parts))
    (when (alist-get :direnv config)
      (push "direnv exec ." parts))
    (string-join parts " ")))

(defun service--get-buffer (service)
  "Returns the buffer associated with SERVICE, if any."
  (get-buffer (format "*%s*" service)))

;; TODO: handle predicate & default?
(defun service--completing-read (prompt opts &optional pred default)
  "Prompts user for a selection from OPTS with PROMPT."
  ;; TODO: could this be simplified?
  (let* ((valid-opts (seq-filter (or pred #'identity) opts))
         (default (if (member default valid-opts) default)))
    (intern (completing-read (if default
                                 (format "%s (%s): " prompt default)
                               (format "%s: " prompt))
                             (mapcar #'symbol-name valid-opts)
                             nil
                             t
                             nil
                             'remix-services
                             (symbol-name default)))))

(defun service--read-service (verb &optional pred default)
  "Prompts user for a service to act upon with VERB."
  (service--completing-read (format "%s service" verb) (mapcar #'car service-configs-alist) pred default))

(defun service--read-group (verb)
  "Prompts user for a service group to act upon with VERB."
  (service--completing-read (format "%s service group" verb) (mapcar #'car service-groups-alist)))

;;;###autoload
(defun service-build (service)
  "Builds SERVICE via `compile' using the configured `:build' command.

If not configured, the build command defaults to \"make\"."
  (interactive (list (service--read-service "Build")))
  (let ((default-directory (service-directory service)))
    (compile (service-build-command service (or (alist-get :build (service--config service))
                                                "make")))))

(defvar-local service-current nil
  "The service running in the current buffer.")

(defun service--init (service)
  ;; TODO: check if already running?
  (message "Starting service: %s" service)
  (let ((config (service--config service)))
    (dolist (dep (alist-get :depends-on config))
      (service--init dep))
    (let* ((default-directory (service-directory service))
           (service-buffer (make-comint (symbol-name service) "/bin/sh" nil "-c" (service-build-command service))))
      (with-current-buffer service-buffer
        (setq service-current service)
        (service-process-mode +1)))))

(defun service--default-dwim ()
  "Guesses which service would make a reasonable default value.

When in a service buffer, returns `service-current'.
When in Service List mode, returns the service at point."
  (or service-current (tabulated-list-get-id)))

;; start service contexts:
;; - ad hoc / interactively (M-x service-start)
;; - from service buffer
;; - from service list

;;;###autoload
(defun service-start (&optional service)
  "Prompts for a service to start."
  ;; TODO: When called with prefix argument, override various options
  (interactive)
  (let ((service (or service (service--read-service "Start" nil (service--default-dwim)))))
    (service--init service)
    (pop-to-buffer (service--get-buffer service))))

;;;###autoload
(defun service-start-group (group)
  (interactive (list (service--read-group "Start")))
  (message "Starting service group: %s" group)
  (dolist (member (alist-get group service-groups-alist))
    (service--init member)))

(defun service-stop (&optional service)
  "Stops a service.

When called interatively, prompts for SERVICE."
  ;; TODO: filter to running services?
  (interactive (list (service--read-service "Stop" nil (service--default-dwim))))
  (setq service (or service service-current (error "No service specified")))
  (let ((service-buffer (or (service--get-buffer service)
                            (error "Service not running: %s" service))))
    (pop-to-buffer service-buffer)
    (comint-interrupt-subjob)
    (with-timeout (5 (progn
                       (message "Forcibly killing %s process" service)
                       (comint-kill-subjob)))
      (while (process-live-p (get-buffer-process service-buffer))
        (sleep-for 0.05)))))

(defun service-restart (&optional service)
  "Restarts a service.

When called interactively, prompts for SERVICE.
SERVICE defaults to `service-current'."
  ;; TODO: filter to running services?
  (interactive (list (service--read-service "Restart" nil service-current)))
  (setq service (or service service-current (error "No service specified")))
  (message "Restarting %s" service)
  (service-stop service)
  ;; TODO: wait for service to be dead
  (service-start service))

;; (dolist (f '(service-build
;;              service-start
;;              service-restart
;;              service-stop))
;;   (eval `(defun ,(concat f "-current")
;;            (interactive)
;;            (,f service-current))))

(defun service-build-current ()
  (interactive)
  (service-build service-current))

(defun service-start-current ()
  (interactive)
  (service-start service-current))

(defun service-restart-current ()
  (interactive)
  (service-restart service-current))

(defun service-stop-current ()
  (interactive)
  (service-stop service-current))


;; Service output mode

(defvar service-process-mode-map
  (define-keymap
    ;; :parent comint-mode-map ; ?
    "C-c s b" 'service-build-current
    "C-c s s" 'service-start-current
    "C-c s r" 'service-restart-current
    "C-c s k" 'service-stop-current))

(define-minor-mode service-process-mode
  "Minor mode for interacting with a service."
  ;; :keymap service-process-mode-map
  )


;; Service list mode

;; (Adapted from process-menu-mode)

(defvar service-menu-mode-map
  (define-keymap
    "s" 'service-start
    "k" 'service-stop
    "r" 'service-restart))

(define-derived-mode service-menu-mode tabulated-list-mode "Service Menu"
  "Major mode for listing services."
  (setq tabulated-list-format [("Service" 20 t)
                               ("Status" 8 t)
                               ("Buffer" 25 t)
                               ("Command" 0 t)])
  (setq tabulated-list-sort-key (cons "Service" nil))
  (add-hook 'tabulated-list-revert-hook 'service-menu--refresh nil t))

(defun service-menu--service-buffer-link (service)
  (let ((buf (service--get-buffer service)))
    (if (buffer-live-p buf)
        `(,(buffer-name buf)
          face link
          help-echo ,(format-message
                      "Visit buffer `%s'"
                      (buffer-name buf))
          follow-link t
          service-buffer ,buf
          action service-menu--visit-buffer
          )
      "--")))

(defun service-menu--visit-buffer (button)
  (display-buffer (button-get button 'service-buffer)))

(defun service-menu--refresh ()
  "Regenerate the list of services for the Service List buffer."
  (setq tabulated-list-entries
        (mapcar (lambda (service)
                  (list service
                        (let* ((buffer (service--get-buffer service))
                               (process (get-buffer-process buffer)))
                          (vector (symbol-name service)
                                  (if buffer
                                      (if (process-live-p process)
                                          "running"
                                        ;; TODO: distinguish between stopped & crashed
                                        ;; TODO: colorize
                                        "stopped")
                                    "--")
                                  (service-menu--service-buffer-link service)
                                  (if process
                                      ;; TODO: drop "sh -c" prefix
                                      (string-join (process-command process) " ")
                                    "")))))
                (mapcar #'car service-configs-alist)))
  (tabulated-list-init-header))

(defun list-services ()
  "List all services in the \"*Service list*\" buffer."
  (interactive)
  (let ((buffer (get-buffer-create "*Service List*")))
    (with-current-buffer buffer
      (service-menu-mode)
      (service-menu--refresh)
      (tabulated-list-print))
    (display-buffer buffer)))


(provide 'service)
