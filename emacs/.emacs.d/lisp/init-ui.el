;; -*- lexical-binding: t; -*-

(setq text-scale-mode-step 1.1)

(set-face-attribute 'default nil
                    :family "JetBrainsMono Nerd Font" :height 110)
(set-face-attribute 'fixed-pitch nil
                    :family "JetBrainsMono Nerd Font" :height 110)
(set-face-attribute 'fixed-pitch-serif nil
                    :family "Noto Serif" :height 110)
(set-face-attribute 'variable-pitch nil
                    :family "Noto Sans" :height 120)

(defun my/setup-arabic-font (&optional frame)
  "Use `my/arabic-font' for Arabic script on FRAME (default: selected frame)."
  (let ((frame (or frame (selected-frame))))
    (when (display-graphic-p frame)
      (with-selected-frame frame
        (set-fontset-font t 'arabic
                          (font-spec :family "Noto Sans Arabic" :size 14))))))

(if (daemonp)
    (add-hook 'after-make-frame-functions #'my/setup-arabic-font)
  (my/setup-arabic-font))

(use-package doom-themes
  ;; :vc (:url "https://github.com/doomemacs/themes")
  :ensure t
  :config
  (defun my/apply-custom-faces ()
    "Tweak faces the theme (or lsp-bridge) leaves monochrome or hardcoded."
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
       `(flyspell-duplicate ((t (:underline (:style wave)))))

       ;; Hardcoded greys.
       `(lsp-bridge-inlay-hint-face ((t (:inherit shadow))))
       `(lsp-bridge-dart-closing-label-face ((t (:inherit shadow))))

       ;; The references (rg) buffer.
       `(lsp-bridge-ref-font-lock-header-line-text
         ((t (:foreground ,green :weight bold))))
       `(lsp-bridge-ref-font-lock-header-line-edit-mode
         ((t (:foreground ,orange :weight bold))))
       `(lsp-bridge-ref-font-lock-command ((t (:inherit shadow :weight bold))))
       `(lsp-bridge-ref-font-lock-file ((t (:foreground ,blue :weight bold))))
       `(lsp-bridge-ref-font-lock-line-number ((t (:inherit shadow))))
       `(lsp-bridge-ref-font-lock-column-number ((t (:inherit shadow))))
       `(lsp-bridge-ref-font-lock-position-splitter ((t (:inherit shadow))))
       `(lsp-bridge-ref-font-lock-match ((t (:foreground ,yellow :weight bold))))
       `(lsp-bridge-ref-font-lock-diagnostic
         ((t (:foreground ,red :weight bold))))
       `(lsp-bridge-ref-font-lock-mark-changed
         ((t (:foreground ,violet :weight bold))))
       `(lsp-bridge-ref-font-lock-mark-deleted
         ((t (:foreground ,red :weight bold))))
       `(lsp-bridge-ref-font-lock-function-location
         ((t (:foreground ,orange :weight bold))))

       `(acm-frame-border-face ((t (:background ,bar))))
       `(acm-backend-ctags-annotation-face
         ((t (:inherit shadow :slant italic)))))))

  (defun my/load-theme (theme)
    "Disable the current themes, load THEME and re-apply custom faces."
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme theme t)
    (my/apply-custom-faces))

  (defun toggle-theme (&optional mode)
    "Switch theme.  MODE can be `light', `dark', or nil to toggle."
    (interactive)
    (my/load-theme
     (pcase mode
       ('light 'doom-gruvbox-light)
       ('dark  'doom-gruvbox)
       (_ (if (member 'doom-gruvbox custom-enabled-themes)
              'doom-gruvbox-light
            'doom-gruvbox)))))

  (my/load-theme 'doom-gruvbox))

(use-package vi-tilde-fringe
  :init (global-vi-tilde-fringe-mode)
  :diminish vi-tilde-fringe-mode)

(provide 'init-ui)
