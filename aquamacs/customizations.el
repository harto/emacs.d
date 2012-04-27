(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(aquamacs-additional-fontsets nil t)
 '(aquamacs-customization-version-id 210 t)
 '(aquamacs-tool-bar-user-customization nil t)
 '(default-frame-alist (quote ((right-fringe . 1)
                               (left-fringe . 1)
                               (internal-border-width . 0)
                               (vertical-scroll-bars . right)
                               (cursor-type . box)
                               (fringe)
                               (modeline . t)
                               (color-theme-name . color-theme-twilight)
                               (tool-bar-lines . 0)
                               (menu-bar-lines . 1)
                               (background-color . "#141414")
                               (background-mode . dark)
                               (border-color . "black")
                               (cursor-color . "#A7A7A7")
                               (foreground-color . "#F8F8F8")
                               (mouse-color . "sienna1"))))
 '(global-hl-line-mode t)
 '(global-linum-mode t)
 '(ns-tool-bar-display-mode (quote both) t)
 '(ns-tool-bar-size-mode (quote regular) t)
 '(safe-local-variable-values (quote ((less-css-target-directory . "../../src/xxx/static/styles")
                                      (directory-hooks-alist (after-save-hook . project-make))
                                      (ffip-patterns "*.html" "*.less" "*.coffee")
                                      (compile-less lambda nil (call-process "cake" nil nil nil "css") (minibuffer-message "Finished CSS compilation"))
                                      (compile-less lambda nil (call-process "cake" nil nil nil "css"))
                                      (compile-less lambda nil (call-process "cake css"))
                                      (ffip-patterns "*.clj" "*.js" "*.less" "*.css" "*.html")
                                      (ffip-patterns "*.clj" "*.js" "*.css" "*.html")
                                      (ffip-patterns "*.clj")
                                      (ffip-patterns "*.clj" "*.js" "*.html")
                                      (ffip-patterns quote ("*.clj" "*.js" "*.html"))
                                      (inferior-lisp-program "lein trampoline cljsbuild repl-listen")
                                      (inferior-lisp-program "lein cljs-repl"))))
 '(visual-line-mode nil t))

(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil
                :stipple nil
                :background "#141414"
                :foreground "#CACACA"
                :inverse-video nil
                :box nil
                :strike-through nil
                :overline nil
                :underline nil
                :slant normal
                :weight normal
                :height 120
                :width normal
                :foundry "apple"
                :family "Consolas"))))
 '(aquamacs-variable-width ((((type ns)) (:inherit variable-pitch))))
 '(echo-area ((t nil)))
 '(fixed-pitch ((t nil)))
 '(mode-line ((t (:inherit variable-pitch
                  :background "grey75"
                  :foreground "black"))))
 '(mode-line-flags ((t nil)))
 '(tabbar-default ((t (:inherit variable-pitch))))
 '(text-mode-default ((((type ns)) (:inherit autoface-default))))
 '(variable-pitch ((t (:height 1.0
                       :family "Helvetica")))))
