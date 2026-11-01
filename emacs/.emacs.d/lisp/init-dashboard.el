;; -*- lexical-binding: t; -*-

(use-package dashboard
  :ensure t
  :config
  (setq dashboard-projects-backend 'projectile)
  (setq dashboard-startup-banner 'logo) ; or 'official, or a path to an image
  (setq dashboard-center-content t)
  (add-hook 'server-after-make-frame-hook 'dashboard-open)

  ;; Configure dashboard items
  (setq dashboard-items '(
    (recents   . 5)   ; Show 5 recent files
    (bookmarks . 5)   ; Show 5 bookmarks
    (projects  . 5)   ; Show projects
    (agenda    . 5)))   ; Show org agenda (requires org-agenda setup)

  (dashboard-setup-startup-hook))

(provide 'init-dashboard)
