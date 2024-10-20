(defvar sc/org-export-uri nil
  "Org data is automatically exported in JSON format to this (S3) URI.")

(defvar sc/org-sync-s3-access-key-id nil
  "AWS access key for writing exported org data to S3.")

(defvar sc/org-sync-s3-secret-access-key nil
  "AWS secret access key for writing exported org data to S3.")

(defun sc/maybe-export-org-data (&optional org-path)
  "Exports org data to S3 in JSON format if `sc/org-export-uri' is set.

AWS credentials should be provided as variables
`sc/org-sync-s3-access-key-id' and
`sc/org-sync-s3-secret-access-key'."
  (when sc/org-export-uri
    (let* ((org-path (or org-path buffer-file-name))
           (json-tmp-path (make-temp-file (format "%s.json." (file-name-sans-extension org-path)))))
      (with-temp-file json-tmp-path
        (insert (sc/org-todo-json org-path)))
      (with-environment-variables (("AWS_ACCESS_KEY_ID" sc/org-sync-s3-access-key-id)
                                   ("AWS_SECRET_ACCESS_KEY" sc/org-sync-s3-secret-access-key))
        (start-process "org-sync" "*org-sync*" "aws" "s3" "mv" json-tmp-path sc/org-export-uri))
      (delete-file json-tmp-path))))

(defun sc/org-todo-json (org-path)
  (json-encode `((todos . ,(sc/org-todo-data org-path))
                 (dumped . ,(format-time-string "%Y-%m-%d %H:%M")))))

(defun sc/org-todo-data (org-path)
  (org-element-map
   (with-current-buffer (find-file-noselect org-path)
     (save-restriction
       (widen)
       (org-element-parse-buffer)))
   '(headline)
   (lambda (el)
     (let ((todo-state (org-element-property :todo-keyword el)))
       (when (member todo-state '("STARTED" "TODO"))
         `((state . ,(substring-no-properties todo-state))
           (headline . ,(substring-no-properties (org-element-property :raw-value el)))
           (tags . ,(mapcar #'substring-no-properties (org-element-property :tags el)))
           (scheduled . ,(sc/org-timestamp->string (org-element-property :scheduled el)))
           (deadline . ,(sc/org-timestamp->string (org-element-property :deadline el)))
           (created . ,(sc/org-timestamp->string (org-element-map el '(timestamp)
                                                                  (lambda (ts)
                                                                    (when (eq 'inactive (org-element-property :type ts))
                                                                      ts))
                                                                  nil t)))))))))

(defun sc/org-timestamp->string (ts)
  (if ts
      (format "%04d-%02d-%02d"
              (org-element-property :year-start ts)
              (org-element-property :month-start ts)
              (org-element-property :day-start ts))
    nil))
