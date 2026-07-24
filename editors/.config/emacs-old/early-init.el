(setq package-enable-at-startup nil)

(setq inhibit-startup-screen t
      package-enable-at-startup nil
      auto-save-default t
      make-backup-files nil
      create-lockfiles nil
      version-control t
      backup-by-copying t
      delete-old-versions t
      kept-old-versions 5
      kept-new-versions 5)

(setq default-frame-alist
      '((vertical-scroll-bars . nil)
        (tool-bar-lines . 0)))

(menu-bar-mode   0)
(tool-bar-mode   0)
(scroll-bar-mode 0)

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(require 'gruvbox-theme nil t)
