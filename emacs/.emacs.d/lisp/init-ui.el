;;;; -*- lexical-binding: t; -*-

;;;; No buttons only text

(when (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;;;; Fonts

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
  "."
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

;;;; Line numbers and others

(dolist (hook '(prog-mode-hook org-mode-hook markdown-mode-hook fundamental-mode-hook))
  (add-hook hook #'display-line-numbers-mode))
(setq display-line-numbers-type 'relative)

(global-hl-line-mode 1)

;; (when (fboundp 'window-divider-mode)
;;   (window-divider-mode 1))

(setq hl-line-sticky-flag nil
      global-hl-line-sticky-flag nil)

;;;; UI components

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(horizontal-scroll-bars) default-frame-alist)

;;;; Themes

(use-package doom-themes
  :defer t
  :custom
  (doom-themes-enable-italic nil)
  (doom-themes-enable-bold nil)
  :config
  (doom-themes-org-config)
  (load-theme 'doom-gruvbox))

(custom-set-faces
 '(flyspell-incorrect ((t (:underline (:style wave)))))
 '(flyspell-duplicate ((t (:underline (:style wave)))))
 '(flycheck-error ((t (:background unspecified))))
 '(flycheck-warning ((t (:background unspecified))))
 '(flycheck-info ((t (:background unspecified)))))

(use-package auto-dark
  :straight t
  :diminish auto-dark-mode
  :custom
  (auto-dark-themes '((doom-gruvbox) (modus-operandi)))
  :hook
  (after-init . auto-dark-mode))

;;;; Fringes

(fringe-mode '(8 . 0))

(use-package vi-tilde-fringe
  :init (global-vi-tilde-fringe-mode 1)
  :diminish vi-tilde-fringe-mode)

(provide 'init-ui)
;;; init-ui.el ends here
