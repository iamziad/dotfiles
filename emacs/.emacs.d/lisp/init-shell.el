;; -*- lexical-binding: t; -*-

(use-package fish-mode
  :ensure t
  :mode (("\\.fish\\'" . fish-mode))
  :hook (fish-mode . (lambda ()
                       (add-hook 'before-save-hook 'fish_indent-before-save))))

;; Commint
(setq comint-prompt-read-only t)
(setq shell-command-completion-mode t)

;; Eshell
(defun my/eshell-prompt ()
  "Eshell prompt: directory, git branch (with * when dirty), then a lambda."
  (let ((branch (car (ignore-errors (process-lines "git" "branch" "--show-current"))))
        (dirty  (ignore-errors (process-lines "git" "status" "--porcelain"))))
    (propertize
     (concat (propertize (abbreviate-file-name (eshell/pwd)) 'face 'eshell-ls-directory)
             (when branch
               (propertize (format " (%s%s)" branch (if dirty "*" ""))
                           'face 'font-lock-string-face))
             (propertize "\nλ " 'face 'font-lock-function-name-face))
     'read-only t 'rear-nonsticky t)))

(setq eshell-prompt-function #'my/eshell-prompt
      eshell-banner-message ""
      eshell-prompt-regexp "^λ "
      eshell-highlight-prompt nil
      eshell-history-size 10000
      eshell-hist-ignoredups t
      eshell-scroll-to-bottom-on-input 'this
      eshell-destroy-buffer-when-process-dies t
      eshell-command-aliases-list
      '(("ll"    "ls -lh $*")
        ("la"    "ls -lah $*")
        ("e"     "find-file $1")
        ("d"     "dired $1")
        ("clear" "clear 1")
        ("gs"    "git status -sb")
        ("ga"    "git add $*")
        ("gc"    "git commit -m $*")
        ("gca"   "git commit --amend")
        ("gp"    "git push")
        ("gpl"   "git pull")
        ("gco"   "git checkout $*")
        ("gb"    "git branch $*")
        ("gd"    "git --no-pager diff $*")
        ("gl"    "git --no-pager log --oneline --graph --decorate -15")
        ("gm"    "magit-status")))

(provide 'init-shell)
