;;; init-consult.el -*- lexical-binding: t; -*-

(defun my/search-project ()
  "Search the current project for the symbol at point."
  (interactive)
  (let ((project (project-current t)))
    (unless project
      (user-error "No project found"))
    (consult-ripgrep (project-root project)
                     (thing-at-point 'symbol t))))

(defvar-keymap my/search-map
  :doc "Search commands (C-c s)."
  "s" #'consult-line
  "r" #'my/search-project
  "g" #'consult-grep
  "o" #'consult-outline
  "i" #'consult-imenu
  "m" #'consult-mark)

(keymap-global-set "C-c s" my/search-map)

(use-package consult
  :ensure t
  :demand t
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
  :config
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref))

(provide 'init-consult)
