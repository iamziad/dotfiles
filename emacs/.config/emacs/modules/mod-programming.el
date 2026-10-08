;;; mod-programming.el --- programming configuration -*- lexical-binding: t; -*-

;;; --------------------------------------------------------------------------
;;; Languages
;;; --------------------------------------------------------------------------

(use-package nix-mode
  :ensure t
  :mode "\\.nix\\'"
  :hook (nix-mode . (lambda ()
                      (add-hook 'before-save-hook #'nix-mode-format nil t))))

(use-package fish-mode
  :straight t
  :mode (("\\.fish\\'" . fish-mode))
  :hook (fish-mode . (lambda ()
                       (add-hook 'before-save-hook 'fish_indent-before-save))))

;;; --------------------------------------------------------------------------
;;; General
;;; --------------------------------------------------------------------------

;; Basic Indentation & Formatting
(setq-default indent-tabs-mode nil
              tab-width 4
              standard-indent 4
              c-basic-offset 4
              compilation-scroll-output t)

(setq js-indent-level 2
      typescript-ts-mode-indent-offset 2
      json-ts-mode-indent-offset 2
      css-indent-offset 2
      java-ts-mode-indent-offset 4
      c-ts-mode-indent-offset 4
      c-ts-mode-indent-style 'k&r
      c-default-style '((java-mode . "java") (awk-mode . "awk") (other . "k&r")))

;; Dev tools
(setq gdb-many-windows t
      gdb-show-main t)

;; Makefiles MUST use real tabs
(add-hook 'makefile-mode-hook (lambda () (setq indent-tabs-mode t)))

(add-hook 'prog-mode-hook
          (lambda ()
            (setq bidi-paragraph-direction 'left-to-right
                  bidi-display-reordering nil)))

;; Fix compile escape codes
(add-hook 'compilation-filter-hook
          (lambda () (ansi-color-apply-on-region (point-min) (point-max))))

(defun my/enable-bidi ()
  (setq bidi-paragraph-direction nil
        bidi-display-reordering t))

(add-hook 'web-mode-hook #'my/enable-bidi)
(add-hook 'html-ts-mode-hook #'my/enable-bidi)
(add-hook 'html-mode-hook #'my/enable-bidi)
(add-hook 'mhtml-mode-hook #'my/enable-bidi)

;; Misc
(global-subword-mode +1)

(use-package flycheck
  :ensure t
  :hook (prog-mode . flycheck-mode)
  :config
  (setq flycheck-display-errors-delay 0.2)
  (with-eval-after-load 'flycheck
    (add-hook 'eldoc-documentation-functions #'flycheck-eldoc nil t))
  :bind
  (("C-c C-e n" . flycheck-next-error)
   ("C-c C-e p" . flycheck-previous-error)
   ("C-c C-e l" . flycheck-list-errors)
   ))

(use-package flycheck-inline
  :ensure t
  :hook
  (flycheck-mode . flycheck-inline-mode))

(use-package apheleia
  :ensure t
  :diminish apheleia-mode
  :config
  (apheleia-global-mode +1))

(use-package hl-todo
  :init (global-hl-todo-mode 1))

;; (use-package rainbow-delimiters
;;   :hook (prog-mode . rainbow-delimiters-mode))

(use-package auto-rename-tag
  :diminish auto-rename-tag-mode
  :ensure t
  :hook ((web-mode
          html-mode
          html-ts-mode
          mhtml-mode
          rjsx-mode
          js-ts-mode
          tsx-ts-mode) . auto-rename-tag-mode))

(use-package ligature
  :config
  ;; Enable the "www" ligature in every possible major mode
  (ligature-set-ligatures 't '("www"))
  ;; Enable traditional ligature support in eww-mode, if the
  ;; `variable-pitch' face supports it
  (ligature-set-ligatures 'eww-mode '("ff" "fi" "ffi"))
  ;; Enable all Cascadia Code ligatures in programming modes
  (ligature-set-ligatures 'prog-mode '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
                                       ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
                                       "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
                                       "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                                       "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
                                       "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
                                       "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
                                       "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
                                       ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
                                       "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
                                       "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
                                       "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
                                       "\\\\" "://"))
  ;; Enables ligature checks globally in all buffers. You can also do it
  ;; per mode with `ligature-mode'.
  (global-ligature-mode t))

;;; --------------------------------------------------------------------------
;;; GDB Multiple Windows
;;; --------------------------------------------------------------------------

(with-eval-after-load 'gdb-mi
  (defun my-gdb-setup-windows ()
    (set-window-dedicated-p (selected-window) nil)
    (switch-to-buffer gud-comint-buffer)
    (delete-other-windows)
    (let ((win-src (selected-window))
          (win-right (split-window-horizontally (round (* 0.55 (window-width))))))
      (select-window win-src)
      (let ((win-console (split-window-vertically (round (* 0.65 (window-body-height))))))
        (set-window-buffer win-src
                           (if gud-last-last-frame
                               (gud-find-file (car gud-last-last-frame))
                             (if gdb-main-file (gud-find-file gdb-main-file)
                               (list-buffers-noselect))))
        (setq gdb-source-window win-src)
        (set-window-buffer win-console gud-comint-buffer))

      (select-window win-right)
      (gdb-set-window-buffer (gdb-get-buffer-create 'gdb-locals-buffer))
      (let ((w (split-window-vertically (round (* 0.25 (window-body-height))))))
        (select-window w)
        (gdb-set-window-buffer (gdb-get-buffer-create 'gdb-breakpoints-buffer))
        (let ((w (split-window-vertically (round (* 0.33 (window-body-height))))))
          (select-window w)
          (gdb-set-window-buffer (gdb-get-buffer-create 'gdb-registers-buffer))
          (let ((w (split-window-vertically (round (* 0.5 (window-body-height))))))
            (select-window w)
            (gdb-set-window-buffer (gdb-get-buffer-create 'gdb-threads-buffer)))))
      (select-window win-src)))

  (advice-add 'gdb-setup-windows :override #'my-gdb-setup-windows)
  (setq gdb-many-windows t))

(provide 'mod-programming)
;;; mod-programming.el ends here
