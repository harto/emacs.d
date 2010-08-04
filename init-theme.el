;; Favourite colour theme

(when (require 'color-theme nil t)
  (color-theme-initialize)
  (load-library "color-theme-twilight")
  (color-theme-twilight))