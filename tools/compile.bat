@echo off
set WD=%~dp0
emacs --batch --load "%WD%compile.el" --eval '(compile-all "%*")'
