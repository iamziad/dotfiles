;;; mod-apheleia.el

(use-package apheleia
  :ensure t
  :config
  (apheleia-global-mode +1))

;; (use-package apheleia
;;   :ensure t
;;   :config
;;   (apheleia-global-mode +1)
;;   (setf (alist-get 'typescript-ts-mode apheleia-mode-alist) 'prettier)
;;   (setf (alist-get 'tsx-ts-mode apheleia-mode-alist)        'prettier)
;;   (setf (alist-get 'html-ts-mode apheleia-mode-alist)       'prettier)
;;   (setf (alist-get 'css-ts-mode apheleia-mode-alist)        'prettier)
;;   (setf (alist-get 'json-ts-mode apheleia-mode-alist)       'prettier)
;;   (setf (alist-get 'bash-ts-mode apheleia-mode-alist)       'shfmt)
;;   (setf (alist-get 'c-ts-mode apheleia-mode-alist)          'clang-format)
;;   (setf (alist-get 'c++-ts-mode apheleia-mode-alist)        'clang-format))

(provide 'mod-apheleia)

;;; mod-apheleia.el ends here
