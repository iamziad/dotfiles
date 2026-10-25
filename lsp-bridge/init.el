;;; init.el --- Ziad's Emacs configuration -*- lexical-binding: t; -*-

;;;; Bootstrap

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

(use-package diminish :demand t)

(require 'cl-lib)
(require 'seq)
(require 'xdg)

(use-package no-littering
  :demand t
  :config
  (with-eval-after-load 'recentf
    (add-to-list 'recentf-exclude no-littering-var-directory)
    (add-to-list 'recentf-exclude no-littering-etc-directory)))

(use-package gcmh
  :diminish gcmh-mode
  :config
  (gcmh-mode 1))

;;;; Modules

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'mason)
(require 'lsp)
(require 'dape)
(require 'ai)

(require 'c)
(require 'java)
(require 'javascript)
(require 'web)
(require 'sql)

;;;; Core behavior

(setq user-full-name    "Ziad Ahmed"
      user-mail-address "dev.ziadahmed@gmail.com")

(setopt ring-bell-function #'ignore
        use-short-answers t
        inhibit-startup-screen t
        use-dialog-box nil
        confirm-kill-emacs 'yes-or-no-p
        help-window-select t
        warning-minimum-level :error
        custom-file (expand-file-name "custom.el" "~/.cache/emacs/")
        make-backup-files nil
        create-lockfiles nil
        require-final-newline t
        ;; Clipboard
        select-enable-clipboard t
        select-enable-primary t
        select-active-regions nil
        save-interprogram-paste-before-kill t
        kill-do-not-save-duplicates t
        ;; Windows and scrolling
        window-combination-resize t
        switch-to-buffer-obey-display-actions t
        scroll-conservatively 101
        auto-window-vscroll nil
        scroll-margin 10
        scroll-error-top-bottom t
        ;; Editing
        tab-always-indent 'complete
        comment-empty-lines t
        ;; Mode line
        line-number-mode t
        column-number-mode t
        x-underline-at-descent-line nil
        ;; Parens
        show-paren-delay 0
        show-paren-mode t
        show-paren-style 'parenthesis
        show-paren-context-when-offscreen 'overlay
        ;; Misc
        list-matching-lines-default-context-lines 2
        shell-command-prompt-show-cwd t)

(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 80
              display-fill-column-indicator-column 100
              duplicate-line-final-position 1
              default-input-method "arabic")

(setq display-line-numbers-type 'relative)
(setq auto-revert-use-notify t)

(dolist (hook '(prog-mode-hook org-mode-hook markdown-mode-hook))
  (add-hook hook #'display-line-numbers-mode))

(blink-cursor-mode -1)
(size-indication-mode -1)
(delete-selection-mode +1)
(electric-indent-mode +1)
(electric-pair-mode +1)
(global-hl-line-mode +1)
(global-so-long-mode +1)
(auto-save-visited-mode +1)
(recentf-mode +1)
(savehist-mode +1)
(repeat-mode +1)
(winner-mode +1)
;; (global-display-fill-column-indicator-mode +1)

(use-package autorevert
  :straight nil
  :diminish auto-revert-mode
  :init (global-auto-revert-mode +1))

(use-package which-key
  :straight nil
  :diminish which-key-mode
  :init (which-key-mode +1))

(use-package eldoc
  :straight nil
  :diminish eldoc-mode
  :custom (eldoc-echo-area-use-multiline-p 'truncate-sym-name-if-fit))

;;;; UI

(setq text-scale-mode-step 1.1)

(set-face-attribute 'default nil
                    :family "JetBrainsMono Nerd Font" :height 110)
(set-face-attribute 'fixed-pitch nil
                    :family "JetBrainsMono Nerd Font" :height 110)
(set-face-attribute 'fixed-pitch-serif nil
                    :family "Noto Serif" :height 110)
(set-face-attribute 'variable-pitch nil
                    :family "Noto Sans" :height 120)

(defun my/setup-arabic-font (&optional frame)
  "Use `my/arabic-font' for Arabic script on FRAME (default: selected frame)."
  (let ((frame (or frame (selected-frame))))
    (when (display-graphic-p frame)
      (with-selected-frame frame
        (set-fontset-font t 'arabic
                          (font-spec :family "Noto Sans Arabic" :size 14))))))

(if (daemonp)
    (add-hook 'after-make-frame-functions #'my/setup-arabic-font)
  (my/setup-arabic-font))

;; RTL
(defun my/org-bidi-setup ()
  "Configure bidirectional text for Org buffers."
  (setq-local bidi-paragraph-direction nil)

  ;; Determine direction separately for each line.
  (setq-local bidi-paragraph-start-re "^"
              bidi-paragraph-separate-re "^"))

(add-hook 'org-mode-hook #'my/org-bidi-setup)

(use-package doom-themes
  :config
  (defun my/apply-custom-faces ()
    "Tweak faces the theme (or lsp-bridge) leaves monochrome or hardcoded."
    (let ((bar    (doom-color 'vertical-bar))
          (red    (doom-color 'red))
          (orange (doom-color 'orange))
          (yellow (doom-color 'yellow))
          (green  (doom-color 'green))
          (blue   (doom-color 'blue))
          (violet (doom-color 'violet)))
      (custom-set-faces
       `(font-lock-misc-punctuation-face ((t (:foreground ,orange))))
       `(flyspell-incorrect ((t (:underline (:style wave)))))
       `(flyspell-duplicate ((t (:underline (:style wave)))))

       ;; Hardcoded greys.
       `(lsp-bridge-inlay-hint-face ((t (:inherit shadow))))
       `(lsp-bridge-dart-closing-label-face ((t (:inherit shadow))))

       ;; The references (rg) buffer.
       `(lsp-bridge-ref-font-lock-header-line-text
         ((t (:foreground ,green :weight bold))))
       `(lsp-bridge-ref-font-lock-header-line-edit-mode
         ((t (:foreground ,orange :weight bold))))
       `(lsp-bridge-ref-font-lock-command ((t (:inherit shadow :weight bold))))
       `(lsp-bridge-ref-font-lock-file ((t (:foreground ,blue :weight bold))))
       `(lsp-bridge-ref-font-lock-line-number ((t (:inherit shadow))))
       `(lsp-bridge-ref-font-lock-column-number ((t (:inherit shadow))))
       `(lsp-bridge-ref-font-lock-position-splitter ((t (:inherit shadow))))
       `(lsp-bridge-ref-font-lock-match ((t (:foreground ,yellow :weight bold))))
       `(lsp-bridge-ref-font-lock-diagnostic
         ((t (:foreground ,red :weight bold))))
       `(lsp-bridge-ref-font-lock-mark-changed
         ((t (:foreground ,violet :weight bold))))
       `(lsp-bridge-ref-font-lock-mark-deleted
         ((t (:foreground ,red :weight bold))))
       `(lsp-bridge-ref-font-lock-function-location
         ((t (:foreground ,orange :weight bold))))

       `(acm-frame-border-face ((t (:background ,bar))))
       `(acm-backend-ctags-annotation-face
         ((t (:inherit shadow :slant italic)))))))

  (defun my/load-theme (theme)
    "Disable the current themes, load THEME and re-apply custom faces."
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme theme t)
    (my/apply-custom-faces))

  (defun toggle-theme (&optional mode)
    "Switch theme.  MODE can be `light', `dark', or nil to toggle."
    (interactive)
    (my/load-theme
     (pcase mode
       ('light 'doom-gruvbox-light)
       ('dark  'doom-gruvbox)
       (_ (if (member 'doom-gruvbox custom-enabled-themes)
              'doom-gruvbox-light
            'doom-gruvbox)))))

  (my/load-theme 'doom-gruvbox))

(use-package vi-tilde-fringe
  :init (global-vi-tilde-fringe-mode)
  :diminish vi-tilde-fringe-mode)

;;;; Editing and Keybinding

(bind-keys*
 ("C-/"     . undo-only)
 ("C-?"     . undo-redo)
 ("C-}"     . forward-paragraph)
 ("C-{"     . backward-paragraph)
 ("C-,"     . duplicate-dwim)
 ("C-c e"   . eshell)
 ("C-c c"   . compile)
 ("C-c C"   . recompile)
 ("C-c f"   . find-file-at-point)
 ("C-c C-f" . find-file-other-window)
 ("C-x C-k" . kill-buffer-and-window)
 ("C-<tab>" . mode-line-other-buffer))

(defun my/kill-other-windows-and-buffers ()
  "Kill the buffers shown in other windows, then delete those windows.
The current buffer is never killed, even if it is also shown elsewhere."
  (interactive)
  (let* ((current (selected-window))
         (buffers (seq-uniq
                   (mapcar #'window-buffer
                           (remq current (window-list nil 'no-minibuf))))))
    (dolist (buf (remq (current-buffer) buffers))
      (when (buffer-live-p buf)
        (kill-buffer buf)))
    (delete-other-windows)))

(keymap-global-set "C-c w 1" #'my/kill-other-windows-and-buffers)

(use-package crux
  :bind
  (("C-j"                              . crux-top-join-line)
   ("M-<return>"                       . crux-smart-open-line)
   ("M-<backspace>"                    . crux-kill-whole-line)
   ;; ("C-k"                              . crux-kill-whole-line)
   ("C-c K"                            . crux-kill-other-buffers)
   ("C-c U"                            . crux-reopen-as-root)
   ("C-c C-x r"                        . crux-rename-file-and-buffer)
   ("C-c C-x d"                        . crux-delete-file-and-buffer)
   ("<remap> <move-beginning-of-line>" . crux-move-beginning-of-line)))

(use-package smart-hungry-delete
  :bind (([remap backward-delete-char-untabify] . smart-hungry-delete-backward-char)
         ([remap delete-backward-char]          . smart-hungry-delete-backward-char)
         ([remap delete-char]                   . smart-hungry-delete-forward-char))
  :init (smart-hungry-delete-add-default-hooks))

(use-package whitespace-cleanup-mode
  :custom
  (whitespace-cleanup-mode-preserve-point t)
  (whitespace-cleanup-mode-only-if-initially-clean nil)
  :diminish whitespace-cleanup-mode
  :config (global-whitespace-cleanup-mode +1))

(use-package expand-region
  :bind ("C-=" . er/expand-region))

(use-package multiple-cursors
  :bind (("C->"     . mc/mark-next-like-this)
         ("C-<"     . mc/mark-previous-like-this)
         ("C-M-<"   . mc/skip-to-previous-like-this)
         ("C-M->"   . mc/skip-to-next-like-this)
         ("C-c m d" . mc/mark-all-dwim)
         ("C-c m a" . mc/mark-all-like-this)
         ("C-c m n" . electric-newline-and-maybe-indent)
         ("C-c m e" . mc/edit-lines))
  :config
  (require 'mc-hide-unmatched-lines-mode)
  (setq mc/always-run-for-all t))

;;;; Completion and snippets

(use-package flyspell
  :straight nil
  :hook ((text-mode . flyspell-mode)
         (prog-mode . flyspell-prog-mode))
  :diminish flyspell-mode)

(use-package vertico
  :init (vertico-mode))

(use-package marginalia
  :config (marginalia-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides
   '((file (styles partial-completion))
     (project-file (styles partial-completion))))
  (completion-pcm-leading-wildcard t))

(use-package dabbrev
  :straight nil
  :config
  (add-to-list 'dabbrev-ignored-buffer-regexps "\\` ")
  (dolist (mode '(authinfo-mode doc-view-mode pdf-view-mode tags-table-mode))
    (add-to-list 'dabbrev-ignored-buffer-modes mode)))

(global-set-key [remap dabbrev-expand] #'hippie-expand)
(add-hook 'after-change-major-mode-hook
          (lambda () (local-set-key (kbd "M-TAB") #'dabbrev-expand)))

(use-package fancy-dabbrev
  :diminish fancy-dabbrev-mode
  :config (global-fancy-dabbrev-mode 1))

(use-package yasnippet
  :config
  (setq yas-snippet-dirs '("~/.config/emacs/snippets"))
  (yas-global-mode 1))

;;;; Navigation

(use-package isearch
  :straight nil
  :custom
  (lazy-count-prefix-format "(%s/%s) ")
  (isearch-lazy-count t)
  (isearch-allow-motion t)
  (isearch-allow-scroll t)
  (isearch-repeat-on-direction-change t)
  (isearch-wrap-pause 'no-ding))

;; imenu
(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (add-to-list 'imenu-generic-expression
                         '("Sections" "^;;;\\{1,4\\} \\(.+?\\)[ -]*$" 1))))

(use-package syntax-subword
  :custom (syntax-subword-skip-spaces t)
  :diminish syntax-subword-mode
  :config
  (global-syntax-subword-mode -1)
  (global-set-key (kbd "M-F") #'syntax-subword-forward)
  (global-set-key (kbd "M-B") #'syntax-subword-backward)
  (global-set-key (kbd "M-D") #'syntax-subword-kill)
  (global-set-key (kbd "<M-S-backspace>") #'syntax-subword-backward-kill))

(use-package iy-go-to-char
  :bind* (("C-'" . iy-go-to-char)
          ("C-;" . iy-go-to-char-backward)))

(use-package symbol-overlay
  :bind (("M-n" . symbol-overlay-jump-next)
         ("M-p" . symbol-overlay-jump-prev))
  :hook (prog-mode . symbol-overlay-mode)
  :diminish symbol-overlay-mode)

(use-package hideshow
  :straight nil
  :hook (prog-mode . hs-minor-mode)
  :diminish hs-minor-mode
  :config
  (defun toggle-fold ()
    "Toggle folding of the block at the end of the current line."
    (interactive)
    (save-excursion
      (end-of-line)
      (hs-toggle-hiding)))
  (keymap-global-set "C-c t f" #'toggle-fold))

(use-package windmove
  :straight nil
  :config
  ;; `:repeat t' already registers the commands as repeatable.
  (defvar-keymap my/windmove-repeat-map
    :repeat t
    "h" #'windmove-left
    "l" #'windmove-right
    "k" #'windmove-up
    "j" #'windmove-down)
  (keymap-global-set "C-c w h" #'windmove-left)
  (keymap-global-set "C-c w l" #'windmove-right)
  (keymap-global-set "C-c w k" #'windmove-up)
  (keymap-global-set "C-c w j" #'windmove-down))

;; Tabs
(setq tab-bar-show 1)

(dolist (i (number-sequence 1 9))
  (keymap-global-set (format "M-%d" i)
                     (lambda () (interactive) (tab-bar-select-tab i))))
(keymap-global-set "C-x t k" #'tab-close)
(keymap-global-set "C-x t o" #'tab-close-other)

;;;; Projects and version control

(use-package projectile
  :init
  (setq projectile-project-search-path '("~/Projects/"))
  (projectile-mode 1)
  :config
  (define-key projectile-mode-map (kbd "C-x p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-x C-b") 'projectile-ibuffer))

(use-package magit
  :custom
  (magit-diff-refine-hunk t)
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  (magit-save-repository-buffers 'dontask))

(use-package diff-hl
  :bind (("M-{" . diff-hl-previous-hunk)
         ("M-}" . diff-hl-next-hunk))
  :custom (diff-hl-update-async t)
  :init (global-diff-hl-mode)
  :config (diff-hl-flydiff-mode 1))

;;;; Environment and external tooling

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x pgtk))
  :custom
  (exec-path-from-shell-arguments '("-l"))
  (exec-path-from-shell-variables '("PATH" "MANPATH" "JAVA_HOME"))
  :config (exec-path-from-shell-initialize))

(use-package envrc
  :if (executable-find "direnv")
  :hook (after-init . envrc-global-mode))

;;;; Tree-sitter

(use-package treesit-auto
  :demand t
  :custom
  (treesit-auto-install t)
  (treesit-auto-langs '(bash css javascript json tsx typescript yaml))
  :config
  (treesit-auto-install-all)
  (treesit-auto-add-to-auto-mode-alist treesit-auto-langs)
  (global-treesit-auto-mode))

;;; Formatting

(use-package apheleia
  :diminish "Aphe"
  :config (apheleia-global-mode 1))

;;;; Emacs Lisp

(use-package rainbow-delimiters
  :hook (emacs-lisp-mode . rainbow-delimiters-mode))

;;;; Markdown and Org

(use-package markdown-mode)

;;; Org
(setq org-directory "~/Documents/org"
      org-agenda-files (list "~/Documents/org")
      org-hide-leading-stars t
      org-ellipsis " ▾"
      org-hide-emphasis-markers t
      org-pretty-entities t
      org-log-done 'note
      ;; Source blocks (literate programming)
      org-confirm-babel-evaluate nil
      org-src-window-setup 'current-window
      org-src-tab-acts-natively t
      org-src-fontify-natively t
      org-src-preserve-indentation t
      python-shell-completion-native-enable nil
      ;; Images and LaTeX
      org-preview-latex-default-process 'dvisvgm
      org-startup-with-latex-preview t
      org-image-actual-width nil
      org-image-max-width 450)

(add-hook 'org-mode-hook
          (lambda ()
            (visual-line-mode 1)
            (electric-pair-local-mode -1)
            (org-indent-mode 1)))

(with-eval-after-load 'org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t) (C . t) (shell . t) (java . t) (js . t) (sql . t)))
  (keymap-unset org-mode-map "C-c C-k")
  (require 'org-tempo))

(add-to-list 'display-buffer-alist
             '("\\*Org Select\\*\\|CAPTURE"
               (display-buffer-below-selected)
               (window-height . 0.6)))

(setq org-capture-templates
      '(("a" "Anki Card" entry
         (file+headline "/tmp/anki.org" "Anki flashcards for today")
         "* \n:PROPERTIES:\n:ANKI_DECK:\n:ANKI_NOTE_TYPE: Basic\n:END:\n\n** Front\n\n** Back\n")
        ("d" "Deadline Task" entry
         (file+headline "~/Documents/org/tasks.org" "Deadlines")
         "* TODO %?\n DEADLINE: %^{Deadline}t\n %a\n")
        ("i" "Idea" entry
         (file "~/Documents/org/ideas.org")
         "* TODO %?\n %a %U\n\n")
        ("s" "Scheduled Task" entry
         (file+headline "~/Documents/org/tasks.org" "Schedules")
         "* TODO %?\n SCHEDULED: %^{Date}t\n %a\n")
        ("t" "Todo Inbox" entry
         (file "~/Documents/org/inbox.org")
         "* TODO %?\n %a %U\n\n")
        ("w" "Watch/Read Later" entry
         (file+headline "~/Documents/org/later.org" "Watch/Read Later")
         "* TODO %^{Title}\n [[%x][Link]]\n :PROPERTIES:\n :TYPE: %^{Type|Video|Article|Tutorial|Lecture/Conference}\n :END:\n\n %?\n %U\n")))

(use-package org-download
  :custom
  (org-download-heading-lvl nil)
  (org-download-image-dir "./images"))

(use-package verb
  :config
  (setq verb-json-use-mode 'json-ts-mode)
  (with-eval-after-load 'org
    (define-key org-mode-map (kbd "C-c C-r") verb-command-map))
  (define-key verb-response-body-mode-map (kbd "q")
              (lambda () (interactive) (quit-window t))))

;;;; Shell and compilation

;; Commint
(setq comint-prompt-read-only t)
(setq shell-command-completion-mode t)

(defun my/compilation-select-window (&rest _)
  "Select the *compilation* window if it is visible."
  (when-let* ((w (get-buffer-window "*compilation*")))
    (select-window w)))

(use-package compile
  :straight nil
  :custom
  (compilation-always-kill t)
  (compilation-ask-about-save nil)
  (compilation-auto-jump-to-first-error nil)
  (compilation-max-output-line-length nil)
  (compilation-scroll-output 'first-error)
  :hook (compilation-filter . ansi-color-compilation-filter)
  :config
  (define-key compilation-mode-map (kbd "C-o") nil)
  (setenv "NO_COLOR" "1")
  (advice-add 'compilation-start :after #'my/compilation-select-window))

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
         :map ghostel-semi-char-mode-map
         ("C-k" . my/ghostel-send-C-k-and-kill)
         ("M-p" . (lambda () (interactive) (ghostel-send-key "p" "ctrl")))
         ("M-n" . (lambda () (interactive) (ghostel-send-key "n" "ctrl"))))
  :config
  (add-to-list 'ghostel-eval-cmds
               '("magit-status-setup-buffer" magit-status-setup-buffer)))

(use-package ghostel-project
  :straight nil
  :bind (:map project-prefix-map
              ("m" . ghostel-project)
              ("M" . ghostel-project-list-buffers))
  :config
  (add-to-list 'project-switch-commands '(ghostel-project "Ghostel") t)
  (add-to-list 'project-switch-commands
               '(ghostel-project-list-buffers "Ghostel buffers") t))

(use-package ghostel-eshell
  :straight nil
  :hook (eshell-load . ghostel-eshell-visual-command-mode))

(use-package ghostel-compile
  :straight nil
  :hook (after-init . ghostel-compile-global-mode))

;;;; Dired

(use-package dired
  :straight nil
  :custom
  (dired-listing-switches "-alh --group-directories-first")
  (dired-dwim-target t)
  (delete-by-moving-to-trash t)
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-auto-revert-buffer t)
  (dired-mouse-drag-files t)
  (image-dired-thumb-size 250)
  (image-dired-thumbnail-storage 'standard)
  :config
  (require 'dired-x)
  (setq dired-omit-files (concat dired-omit-files "\\|^\\..+$"))
  (put 'dired-jump 'repeat-map nil))

(use-package async
  :after dired
  :config (dired-async-mode 1))

(use-package dired-subtree
  :after dired
  :custom (dired-subtree-use-backgrounds nil)
  :bind (:map dired-mode-map
              ("TAB" . dired-subtree-toggle)))

(use-package dired-git-info
  :after dired
  :custom (dgi-auto-hide-details-p nil)
  :bind (:map dired-mode-map
              (")" . dired-git-info-mode)))

;;;; Misc

(use-package elfeed
  :config
  (setq elfeed-feeds
        '(("https://archlinux.org/feeds/news/" unix)
          ("https://protesilaos.com/codelog.xml" emacs prot))))

(use-package daemons)

(use-package hydra)

;;; Zen mode

(use-package olivetti
  :straight t
  :hook ((eww-mode . olivetti-mode)
         (olivetti-mode . mod-olivetti--toggle))
  :bind ("C-c v o" . olivetti-mode)
  :custom (olivetti-body-width 90))

(defvar-local mod-olivetti--state nil
  "Display settings saved when `olivetti-mode' was turned on.")

(defun mod-olivetti--apply-fringes (&rest _)
  "Hide the fringes in every window showing the current buffer."
  (when olivetti-mode
    (dolist (win (get-buffer-window-list (current-buffer) nil t))
      (set-window-fringes win 0 0 nil t))))

(defun mod-olivetti--toggle ()
  "Strip distractions when `olivetti-mode' is on and restore them when off."
  (if olivetti-mode
      (progn
        (setq mod-olivetti--state
              (list (bound-and-true-p display-line-numbers-mode)
                    (bound-and-true-p display-fill-column-indicator-mode)
                    cursor-type))
        (display-line-numbers-mode -1)
        (display-fill-column-indicator-mode -1)
        (setq-local cursor-type 'bar)
        (mod-olivetti--apply-fringes)
        (add-hook 'window-configuration-change-hook
                  #'mod-olivetti--apply-fringes nil t))
    (when mod-olivetti--state
      (cl-destructuring-bind (ln fci ct) mod-olivetti--state
        (when ln (display-line-numbers-mode 1))
        (when fci (display-fill-column-indicator-mode 1))
        (setq-local cursor-type ct)))
    (remove-hook 'window-configuration-change-hook
                 #'mod-olivetti--apply-fringes t)
    (dolist (win (get-buffer-window-list (current-buffer) nil t))
      (set-window-fringes win nil nil nil nil))))

;;;; Mode-line cleanup for built-in modes

(diminish 'abbrev-mode)
(diminish 'visual-line-mode)
(with-eval-after-load 'org-indent
  (diminish 'org-indent-mode))

;;; init.el ends here
