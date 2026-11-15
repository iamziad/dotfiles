;;; init-jinx.el --- Spell checking with jinx -*- lexical-binding: t; -*-

;; sudo pacman -S enchant hunspell hunspell-en_us

(defun my/jinx-available-p ()
  "Return non-nil when jinx's external requirements are present."
  (and (executable-find "enchant-2")
       ;; A C compiler is needed to build jinx-mod, unless it is
       ;; already built.
       (or (executable-find "gcc")
           (executable-find "cc")
           (locate-library "jinx-mod"))))

(unless (my/jinx-available-p)
  (message "jinx disabled: install enchant and gcc (or a prebuilt jinx-mod)"))

(use-package jinx
  :ensure t
  :if (my/jinx-available-p)
  :diminish jinx-mode
  :hook (emacs-startup . global-jinx-mode)
  :bind (("M-$" . jinx-correct)
         ("C-M-$" . jinx-languages))
  :custom
  ;; English only
  (jinx-languages "en_US")
  :config
  ;; In programming modes: check only comments, docstrings and strings
  (add-to-list 'jinx-include-faces
               '(prog-mode font-lock-comment-face
                           font-lock-comment-delimiter-face
                           font-lock-doc-face
                           font-lock-string-face))

  ;; In git commit buffers (magit): skip the "# ..." comment block
  ;; (file lists, branch names, etc.) and only check the message itself
  (add-to-list 'jinx-exclude-faces
               '(git-commit-mode font-lock-comment-face
                                 font-lock-comment-delimiter-face
                                 git-commit-comment-heading
                                 git-commit-comment-file
                                 git-commit-comment-branch-local
                                 git-commit-comment-branch-remote
                                 git-commit-comment-detached
                                 git-commit-comment-action))

  ;; Skip code-looking identifiers inside comments/strings/commit messages
  (add-to-list 'jinx-exclude-regexps
               '(t "\\<[[:alnum:]]+_[[:alnum:]_]+\\>"         ; snake_case
                   "\\<[[:lower:]]+[[:upper:]][[:alnum:]]*\\>"))) ; camelCase

(provide 'init-jinx)
;;; init-jinx.el ends here
