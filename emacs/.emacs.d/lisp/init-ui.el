;;; init-ui.el --- Appearance, fonts, themes, and tabs -*- lexical-binding: t; -*-

(require 'display-line-numbers)
(require 'fringe)

(declare-function doom-themes-org-config "doom-themes" ())
(declare-function global-vi-tilde-fringe-mode "vi-tilde-fringe"
                  (&optional arg))
(declare-function vim-tab-bar-mode "vim-tab-bar" (&optional arg))

;;; Frame decorations ---------------------------------------------------------

(when (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; These also cover frames created by the daemon.
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(horizontal-scroll-bars) default-frame-alist)

;; Side windows (used by dape and others) stack vertically.
(setq window-sides-vertical t)

;;; Fonts ---------------------------------------------------------------------

(setq text-scale-mode-step 1.1
      global-text-scale-adjust-resizes-frames nil)

(set-face-attribute 'default nil
                    :family "JetBrains Mono" :height 110 :weight 'normal)
(set-face-attribute 'fixed-pitch nil
                    :family "JetBrains Mono" :height 110 :weight 'normal)
(set-face-attribute 'fixed-pitch-serif nil
                    :family "Noto Serif" :height 110)
(set-face-attribute 'variable-pitch nil
                    :family "Noto Sans" :height 120)

(defun my/setup-arabic-font (&optional frame)
  "Set the Arabic fontset for FRAME."
  (let ((frame (or frame (selected-frame))))
    (when (display-graphic-p frame)
      (with-selected-frame frame
        (set-fontset-font t 'arabic
                          (font-spec :family "Noto Sans Arabic"
                                     :size (* 1 (/ (face-attribute 'default :height)
                                                   10.0))))))))

(add-hook 'after-make-frame-functions #'my/setup-arabic-font)
(when (display-graphic-p)
  (my/setup-arabic-font))

;;; Line numbers and highlighting ---------------------------------------------

(setq display-line-numbers-type 'relative)
(dolist (hook '(prog-mode-hook org-mode-hook markdown-mode-hook fundamental-mode-hook))
  (add-hook hook #'display-line-numbers-mode))

(setq hl-line-sticky-flag nil
      global-hl-line-sticky-flag nil)
(global-hl-line-mode 1)

;;; Fringes -------------------------------------------------------------------

(fringe-mode '(8 . 0))

(use-package vi-tilde-fringe
  :ensure t
  :init (global-vi-tilde-fringe-mode 1)
  :diminish vi-tilde-fringe-mode)

;;; Tabs ----------------------------------------------------------------------

(setq tab-bar-show 1)

(dotimes (index 9)
  (let ((tab-number (1+ index)))
    (keymap-global-set (format "M-%d" tab-number)
                       (lambda ()
                         (interactive)
                         (tab-bar-select-tab tab-number)))))
(keymap-global-set "C-x t o" #'tab-close-other)

(use-package vim-tab-bar
  :ensure t
  :demand t
  :config
  (vim-tab-bar-mode 1))

;;; Themes --------------------------------------------------------------------

(defun my/disable-all-themes (&rest _)
  "Disable every enabled theme so themes do not stack on each other."
  (mapc #'disable-theme custom-enabled-themes))
(advice-add 'load-theme :before #'my/disable-all-themes)

(defun my/apply-custom-faces (&rest _)
  "Re-apply personal face tweaks after a theme is enabled."
  (custom-set-faces
   '(flyspell-incorrect ((t (:underline (:style wave)))))
   '(flyspell-duplicate ((t (:underline (:style wave)))))))

(add-hook 'enable-theme-functions #'my/apply-custom-faces)

(use-package doom-themes
  :ensure t
  :custom
  (doom-themes-enable-italic nil)
  (doom-themes-enable-bold nil)
  :config
  (doom-themes-org-config)
  (load-theme 'doom-gruvbox t))

(defvar my/theme-light 'modus-operandi
  "Theme used when the desktop is in light mode.")
(defvar my/theme-dark 'doom-gruvbox
  "Theme used when the desktop is in dark mode.")

(defun my/apply-theme (dark)
  "Apply the light or dark theme according to DARK."
  (let ((theme (if dark my/theme-dark my/theme-light)))
    (unless (custom-theme-enabled-p theme)
      (mapc #'disable-theme custom-enabled-themes)
      (load-theme theme t))))

(defun my/portal-dark-p (value)
  "Return non-nil when the portal VALUE indicates dark mode."
  (equal 1 (car (flatten-tree value))))

(defun my/sync-theme-with-system ()
  "Synchronize the Emacs theme with the desktop color scheme."
  (when (and (featurep 'dbus)
             (getenv "DBUS_SESSION_BUS_ADDRESS"))
    (condition-case err
        (let ((value
               (dbus-call-method :session
                                 "org.freedesktop.portal.Desktop"
                                 "/org/freedesktop/portal/desktop"
                                 "org.freedesktop.portal.Settings"
                                 "Read"
                                 "org.freedesktop.appearance"
                                 "color-scheme")))
          (my/apply-theme (my/portal-dark-p value)))
      (error
       (message "Could not sync system theme: %s"
                (error-message-string err))))))

(defun my/on-setting-changed (namespace key value)
  "Handle desktop appearance changes for NAMESPACE, KEY, and VALUE."
  (when (and (equal namespace "org.freedesktop.appearance")
             (equal key "color-scheme"))
    (my/apply-theme (my/portal-dark-p value))))

(defun my/setup-theme-sync ()
  "Register for desktop color-scheme changes and apply the current one."
  (when (and (featurep 'dbus)
             (getenv "DBUS_SESSION_BUS_ADDRESS"))
    (condition-case err
        (progn
          (dbus-register-signal :session
                                "org.freedesktop.portal.Desktop"
                                "/org/freedesktop/portal/desktop"
                                "org.freedesktop.portal.Settings"
                                "SettingChanged"
                                #'my/on-setting-changed)
          (my/sync-theme-with-system))
      (error
       (message "System theme synchronization unavailable: %s"
                (error-message-string err))))))

;; `require' must not abort startup on Emacs builds without D-Bus.
(require 'dbus nil t)
(add-hook 'emacs-startup-hook #'my/setup-theme-sync)

(provide 'init-ui)
;;; init-ui.el ends here
