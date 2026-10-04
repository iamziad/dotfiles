;;; mod-consult.el -*- lexical-binding: t; -*-

(use-package consult
  :bind (("C-x b"   . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x p b" . consult-project-buffer)
         ("C-x r b" . consult-bookmark)
         ("M-y"     . consult-yank-pop)
         ("M-g g"   . consult-goto-line)
         ("M-g i"   . consult-imenu)
         ("M-g f"   . consult-flymake)
         ("M-s r"   . consult-ripgrep)
         ("M-s g"   . consult-git-grep)
         ("M-s l"   . consult-line))
  :init
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref))

(use-package consult-lsp)

(provide 'mod-consult)
