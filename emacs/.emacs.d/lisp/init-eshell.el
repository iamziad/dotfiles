;;; init-eshell.el --- Eshell configuration -*- lexical-binding: t; -*-

(require 'eshell)

(defun my/eshell-prompt ()
  "Eshell prompt: directory, Git branch (with * when dirty), then a lambda."
  (let ((branch (car (ignore-errors
                       (process-lines "git" "branch" "--show-current"))))
        (dirty (ignore-errors
                 (process-lines "git" "status" "--porcelain"))))
    (propertize
     (concat (propertize (abbreviate-file-name (eshell/pwd))
                         'face 'eshell-ls-directory)
             (when branch
               (propertize (format " (%s%s)" branch (if dirty "*" ""))
                           'face 'font-lock-string-face))
             (propertize "\nλ " 'face 'font-lock-function-name-face))
     'read-only t 'rear-nonsticky t)))

(defun my/eshell-other-window ()
  "Open Eshell in another window."
  (interactive)
  (let ((buffer (save-window-excursion (eshell))))
    (pop-to-buffer buffer)))

(setq eshell-prompt-function #'my/eshell-prompt
      eshell-banner-message ""
      eshell-prompt-regexp "^λ "
      eshell-highlight-prompt t
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

(keymap-global-set "C-c e e" #'eshell)
(keymap-global-set "C-c e o" #'my/eshell-other-window)

(provide 'init-eshell)
;;; init-eshell.el ends here
