;; Windows configuration

(load (expand-file-name "~/.emacs.d/init.el"))

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(inhibit-startup-screen t)
 '(tool-bar-mode nil)
 '(transient-mark-mode t))

(custom-set-faces
 '(default ((t (:height 100 :family "Consolas"))))
 '(fixed-pitch ((t nil))))

(setq w32-use-w32-font-dialog nil)
(menu-bar-mode -1)

;; (add-to-list 'default-frame-alist
;;              '(cursor-color . "#999999"))
