(setq package-enable-at-startup nil)

(defvar my-cache-dir (expand-file-name "cache/" user-emacs-directory))
(unless (file-exists-p my-cache-dir)
    (make-directory my-cache-dir t))

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

(setq savehist-file (concat my-cache-dir "history")
      recentf-save-file (concat my-cache-dir "recentf")
      bookmark-default-file (concat my-cache-dir "bookmarks")
      save-place-file (concat my-cache-dir "places")
      project-list-file (concat my-cache-dir "projects"))

(setq eshell-directory-name (concat my-cache-dir "eshell/")
      tramp-persistency-file-name (concat my-cache-dir "tramp"))

(setq transient-history-file (concat my-cache-dir "transient/history.el")
      transient-levels-file  (concat my-cache-dir "transient/levels.el")
      transient-values-file  (concat my-cache-dir "transient/values.el")
      url-cache-directory (concat my-cache-dir "url/cache")
      url-cookie-file     (concat my-cache-dir "url/cookies")
      request-storage-directory (concat my-cache-dir "request/"))

(with-eval-after-load 'org
    (setq org-persist-directory (concat my-cache-dir "org/persist/")))

(when (boundp 'native-comp-eln-load-path)
    (startup-redirect-eln-cache (concat my-cache-dir "eln-cache/")))
