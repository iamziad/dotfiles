(setq package-enable-at-startup nil)

(setq package-enable-at-startup nil)

(defvar my-cache-dir (expand-file-name "cache/" user-emacs-directory))

(dolist (dir (list my-cache-dir
                   (concat my-cache-dir "auto-save-list/")
                   (concat my-cache-dir "backups/")
                   (concat my-cache-dir "transient/")
                   (concat my-cache-dir "eshell/")
                   (concat my-cache-dir "org/")))
    (unless (file-exists-p dir)
        (make-directory dir t)))

(setq auto-save-default t
      make-backup-files nil
      create-lockfiles nil
      version-control t
      backup-by-copying t
      delete-old-versions t
      kept-old-versions 5
      kept-new-versions 5
      auto-save-list-file-prefix (concat my-cache-dir "auto-save-list/saves-")
      backup-directory-alist `(("." . ,(concat my-cache-dir "backups/"))))


(setq gc-cons-percentage 0.6)
(setq idle-update-delay 1.0)

(setq-default cursor-in-non-selected-windows nil)
(setq highlight-nonselected-windows nil)
(setq fast-but-imprecise-scrolling t)
(setq inhibit-compacting-font-caches t)

(menu-bar-mode 0)
(tool-bar-mode   0)
(menu-bar-mode   0)
(scroll-bar-mode 0)
(column-number-mode)
