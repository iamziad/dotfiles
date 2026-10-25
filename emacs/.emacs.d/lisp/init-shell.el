;; -*- lexical-binding: t; -*-

;; Commint
(setq comint-prompt-read-only t)
(setq shell-command-completion-mode t)

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

(use-package ghostel
  :preface
  (defun my/ghostel-send-C-k-and-kill ()
    "Send `C-k' to ghostel.
Like normal Emacs `C-k': kill to end of line and put it in the kill ring."
    (interactive)
    (kill-ring-save (point) (line-end-position))
    (ghostel-send-key "k" "ctrl"))
  :bind (("C-x m" . ghostel)
         ("C-`" . ghostel-list-buffers)
         :map ghostel-semi-char-mode-map
         ("C-k" . my/ghostel-send-C-k-and-kill)
         ("M-p" . (lambda () (interactive) (ghostel-send-key "p" "ctrl")))
         ("M-n" . (lambda () (interactive) (ghostel-send-key "n" "ctrl"))))
  :config
  (add-to-list 'ghostel-eval-cmds
               '("magit-status-setup-buffer" magit-status-setup-buffer)))

(use-package ghostel-project
  :ensure nil
  :bind (:map project-prefix-map
              ("m" . ghostel-project)
              ("M" . ghostel-project-list-buffers))
  :config
  (add-to-list 'project-switch-commands '(ghostel-project "Ghostel") t)
  (add-to-list 'project-switch-commands
               '(ghostel-project-list-buffers "Ghostel buffers") t))

(use-package ghostel-eshell
  :ensure nil
  :hook (eshell-load . ghostel-eshell-visual-command-mode))

(use-package ghostel-compile
  :ensure nil
  :hook (after-init . ghostel-compile-global-mode))

(provide 'init-shell)
