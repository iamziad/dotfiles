;;; mod-flymake.el

(use-package flymake
  :straight nil
  :hook (prog-mode . flymake-mode)
  :bind
  (("M-n"     . flymake-goto-next-error)
   ("M-p"     . flymake-goto-prev-error)
   ("C-c ! l" . flymake-show-buffer-diagnostics)
   ("C-c ! p" . flymake-show-project-diagnostics)))

;; (use-package flymake-eslint
;;   :ensure t
;;   :hook ((js-ts-mode         . flymake-eslint-enable)
;;          (typescript-ts-mode . flymake-eslint-enable)
;;          (tsx-ts-mode        . flymake-eslint-enable)
;;          (web-mode           . flymake-eslint-enable)
;;          (js-mode            . flymake-eslint-enable)
;;          (js2-mode           . flymake-eslint-enable)
;;          (rjsx-mode          . flymake-eslint-enable)))

(provide 'mod-flymake)

;;; mod-flymake.el ends here
