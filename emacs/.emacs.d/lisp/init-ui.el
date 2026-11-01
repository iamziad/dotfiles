;; -*- lexical-binding: t; -*-

(setq text-scale-mode-step 1.1)

(set-face-attribute 'default nil
                     :family "JetBrains Mono" :height 120 :weight 'normal :width 'normal)
(set-face-attribute 'fixed-pitch nil
                     :family "JetBrains Mono" :height 120 :weight 'normal :width 'normal)
(set-face-attribute 'fixed-pitch-serif nil
                     :family "Noto Serif" :height 110)
(set-face-attribute 'variable-pitch nil
                     :family "Noto Sans" :height 120)

(defun my/setup-arabic-font (&optional frame)
  "Use a matching Arabic font for Arabic script on FRAME (default: selected frame)."
  (let ((frame (or frame (selected-frame))))
    (when (display-graphic-p frame)
      (with-selected-frame frame
        (set-fontset-font t 'arabic
                           (font-spec :family "Noto Sans Arabic"
                                      :size (* 1.3 (/ (face-attribute 'default :height) 10.0))))))))

(add-hook 'after-make-frame-functions #'my/setup-arabic-font)
(when (display-graphic-p)
  (my/setup-arabic-font))

(use-package zenburn-theme)
(use-package monokai-pro-theme)

(use-package doom-themes
  :ensure t
  :custom
  (doom-themes-enable-italic nil)
  (doom-themes-enable-bold nil)
  :config
  (doom-themes-treemacs-config)
  (doom-themes-org-config)
  (defun my/apply-custom-faces ()
    "."
    (let ((bar    (doom-color 'vertical-bar))
          (red    (doom-color 'red))
          (orange (doom-color 'orange))
          (yellow (doom-color 'yellow))
          (green  (doom-color 'green))
          (blue   (doom-color 'blue))
          (violet (doom-color 'violet)))
      (custom-set-faces
       `(font-lock-misc-punctuation-face ((t (:foreground ,orange))))
       `(flyspell-incorrect ((t (:underline (:style wave)))))
       `(flyspell-duplicate ((t (:underline (:style wave)))))))))

(with-eval-after-load 'flycheck
  (custom-set-faces
   '(flycheck-error ((t (:background unspecified))))
   '(flycheck-warning ((t (:background unspecified))))
   '(flycheck-info ((t (:background unspecified))))))

(defun my/server-auto-dark (frame)
  (with-selected-frame frame
    (when (display-graphic-p)
      (auto-dark-mode 1)
      ;; Remove hook so it only runs once
      (remove-hook 'after-make-frame-functions #'my/server-auto-dark))))

(use-package auto-dark
  :diminish auto-dark-mode
  :config
  (setq auto-dark-themes '((doom-gruvbox) (doom-solarized-light)))
  (add-hook 'after-make-frame-functions #'my/server-auto-dark))

(use-package vi-tilde-fringe
  :init (global-vi-tilde-fringe-mode)
  :diminish vi-tilde-fringe-mode)

(provide 'init-ui)
