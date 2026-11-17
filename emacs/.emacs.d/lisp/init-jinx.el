;;; init-jinx.el --- Spell checking with Jinx -*- lexical-binding: t; -*-

(defun my/jinx-available-p ()
  "Return non-nil when Jinx's external requirements are present."
  (and (executable-find "enchant-2")
       ;; A C compiler is needed to build jinx-mod, unless it is built.
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
  :bind (("M-$"   . jinx-correct)
         ("C-M-$" . jinx-languages))
  :custom
  (jinx-languages "en_US ar")
  :config
  ;; In Git commit buffers, skip the comment block (file lists, branch names,
  ;; etc.) and only check the message itself.  The default value already
  ;; excludes several of these faces; this adds the missing comment faces.
  (add-to-list 'jinx-exclude-faces
               '(git-commit-mode font-lock-comment-face
                                 font-lock-comment-delimiter-face
                                 git-commit-comment-heading
                                 git-commit-comment-detached))

  ;; Skip code-looking identifiers inside comments, strings, and messages.
  ;; Jinx appends matching entries, so the defaults remain active.
  (add-to-list 'jinx-exclude-regexps
               '(t "\\<[[:alnum:]]+_[[:alnum:]_]+\\>"          ; snake_case
                   "\\<[[:lower:]]+[[:upper:]][[:alnum:]]*\\>"))) ; camelCase

(provide 'init-jinx)
;;; init-jinx.el ends here
