;;; mod-flymake.el

(use-package flymake
  :straight nil
  :hook (prog-mode . flymake-mode)
  :bind
  (("M-n"     . flymake-goto-next-error)
   ("M-p"     . flymake-goto-prev-error)
   ("C-c ! l" . flymake-show-buffer-diagnostics)
   ("C-c ! p" . flymake-show-project-diagnostics)))

(provide 'mod-flymake)

;;; mod-flymake.el ends here
