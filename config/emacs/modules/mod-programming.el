;;; mod-programming.el --- programming configuration -*- lexical-binding: t; -*-

;; Basic Indentation & Formatting
(setq-default indent-tabs-mode nil
              tab-width 4
              standard-indent 4
              c-basic-offset 4
              compilation-scroll-output t)

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

(use-package hl-todo
  :init (global-hl-todo-mode 1))

(use-package auto-rename-tag
  :ensure t
  :hook ((web-mode
          html-mode
          html-ts-mode
          mhtml-mode
          rjsx-mode
          js-ts-mode
          tsx-ts-mode) . auto-rename-tag-mode))

;;; --------------------------------------------------------------------------
;;; Language Specific Indentation Settings
;;; --------------------------------------------------------------------------

;; C / C++
(setq c-default-style "k&r"
      c-ts-mode-indent-offset 4
      c-ts-mode-indent-style 'k&r)

(add-hook 'c-ts-base-mode-hook (lambda ()
                                 (local-set-key (kbd "RET")
                                                #'reindent-then-newline-and-indent)))

;; Java
(setq java-ts-mode-indent-offset 4)

;; JavaScript / TypeScript

(setq js-indent-level 2
      typescript-ts-mode-indent-offset 2)

(with-eval-after-load 'js-mode 'typescript-ts-mode 'tsx-ts-mode 'web-mode
                      (define-key js-mode-map (kbd "M-.") 'lsp-ui-peek-find-definitions))


;; HTML / CSS
(setq sgml-basic-offset 2
      css-indent-offset 2
      css-ts-mode-indent-offset 2)

;;; --------------------------------------------------------------------------
;;; Extra Language Modes
;;; --------------------------------------------------------------------------

(use-package nix-mode
  :ensure t
  :mode "\\.nix\\'"
  :hook (nix-mode . (lambda ()
                      (add-hook 'before-save-hook #'nix-mode-format nil t))))

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
