# .emacs.d

 1. Install to ~/.emacs.d
 2. ???
 3. Profit


## Overview

 - Core configuration is in `early-init.el` and `init.el`.
 - 3rd-party packages are in `elpa` and version controlled, including `.elc` files (since these are portable).
 - Persistent package data is in `etc`, and transient/temporary data is in `var` (per the no-littering package).
 - Elisp miscellany is in `lisp` (nothing much there anymore; most of it has been replaced by 3rd-party packages).
 - Emacs-friendly wrappers for system commands are in `helpers`.
