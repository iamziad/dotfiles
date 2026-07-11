;; Garbage Collections
(setq gc-cons-threshold 100000000) ;; ~100mb
(setq read-process-output-max 3000000) ;; ~3mb
(setq gc-cons-percentage 0.6)

;; Compile Warnings
(setq comp-async-report-warnings-errors nil) ;; native-comp warning
(setq byte-compile-warnings '(not free-vars unresolved noruntime lexical make-local))

(setq package-enable-at-startup nil)

(setq inhibit-startup-screen t
      auto-save-default t
      make-backup-files nil
      create-lockfiles nil
      version-control t
      backup-by-copying t
      delete-old-versions t
      kept-old-versions 5
      kept-new-versions 5)

(setq default-frame-alist
      '((background-color . "#282828")
        (vertical-scroll-bars . nil)
        (tool-bar-lines . 0)))

(menu-bar-mode   0)
(tool-bar-mode   0)
(scroll-bar-mode 0)
