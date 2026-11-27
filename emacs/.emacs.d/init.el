;; -*- lexical-binding: t; -*-

;;; Packages

(require 'package)

(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/"))
      package-archive-priorities
      '(("gnu" . 10) ("nongnu" . 5) ("melpa" . 0)))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package no-littering
  :demand t
  :config
  (setq custom-file
        (no-littering-expand-etc-file-name "custom.el"))
  (load custom-file t t))

;;; Core

(use-package emacs
  :ensure nil
  :demand t
  :init
  (defun my/keyboard-quit-dwim ()
    "Better C-g."
    (interactive)
    (cond
     ((region-active-p) (keyboard-quit))
     ((derived-mode-p 'completion-list-mode) (delete-completion-window))
     ((> (minibuffer-depth) 0) (abort-recursive-edit))
     (t (keyboard-quit))))

  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  :bind
  (("C-g"   . my/keyboard-quit-dwim)
   ("C-c r" . point-to-register)
   ("C-c j" . jump-to-register)
   ("C-c e" . eshell)
   ("M-F"   . forward-to-word)
   ("M-B"   . backward-to-word))
  :bind*
  (("C-,"     . duplicate-dwim)
   ("C-c C-f" . find-file-other-window)
   ("C-c k"   . kill-buffer-and-window)
   ("C-<tab>" . mode-line-other-buffer))
  :custom
  (mode-line-collapse-minor-modes
   '(not flymake-mode eglot--managed-mode defining-kbd-macro))

  (create-lockfiles nil)
  (make-backup-files t)
  (shift-select-mode nil)
  (delete-by-moving-to-trash t)
  (require-final-newline t)
  (use-short-answers t)
  (use-dialog-box nil)
  (x-gtk-use-system-tooltips nil)
  (initial-major-mode 'fundamental-mode)
  (inhibit-startup-message t)
  (initial-scratch-message nil)
  (custom-safe-themes t)
  (ring-bell-function #'ignore)
  (scroll-margin 5)
  (scroll-conservatively 101)
  (save-interprogram-paste-before-kill t)
  (enable-recursive-minibuffers t)
  (switch-to-buffer-obey-display-actions t)
  :config
  (setq-default indent-tabs-mode nil
                tab-width 4
                sentence-end-double-space nil
                cursor-in-non-selected-windows nil
                default-input-method "arabic"
                duplicate-line-final-position 1
                duplicate-region-final-position 1)

  (column-number-mode 1)
  (delete-selection-mode 1)
  (electric-pair-mode 1)
  (show-paren-mode 1)
  (global-so-long-mode 1)
  (save-place-mode 1)
  (savehist-mode 1)
  (recentf-mode 1)
  (winner-mode 1)
  (repeat-mode 1))

(use-package autorevert
  :ensure nil
  :hook (emacs-startup-hook . global-auto-revert-mode)
  :custom
  (auto-revert-remote-files nil)
  (auto-revert-verbose t)
  (auto-revert-avoid-polling t)
  (global-auto-revert-non-file-buffers t))

(use-package which-key
  :ensure nil
  :hook (after-init-hook . which-key-mode)
  :config
  (setq which-key-separator " "
        which-key-prefix-prefix "… "
        which-key-max-display-columns 3
        which-key-idle-delay 0.5
        which-key-idle-secondary-delay 0.25
        which-key-add-column-padding 1
        which-key-max-description-length 40)
  (which-key-add-key-based-replacements
    "C-c" "mode-and-user"
    "C-x p" "projects"
    "C-x v" "version-control"
    "C-x t" "tab-bar"
    "M-s" "search-map"))

(setq auto-mode-alist
      (append '(("\\.env\\'"          . conf-mode)
                ("\\.gitignore\\'"    . conf-mode)
                ("\\.clang-format\\'" . conf-mode)
                ("\\.vimrc\\'"        . conf-mode)
                ("\\.project\\'"      . nxml-mode)
                ("\\.classpath\\'"    . nxml-mode))
              auto-mode-alist))


;;; Appearance

(use-package display-line-numbers
  :ensure nil
  :hook ((prog-mode conf-mode) . display-line-numbers-mode)
  :custom
  (display-line-numbers-width 3)
  (display-line-numbers-type 'relative))

(use-package vi-tilde-fringe
  :ensure t
  :init (global-vi-tilde-fringe-mode 1))

(advice-add 'load-theme :before
            (lambda (&rest _) (mapc #'disable-theme custom-enabled-themes)))

(defun my/apply-theme (dark)
  (let ((theme (if dark 'doom-gruvbox 'modus-operandi)))
    (unless (custom-theme-enabled-p theme)
      (load-theme theme t))))

(defun my/portal-dark-p (value)
  (eql 1 (car (last (flatten-tree value)))))

(when (require 'dbus nil t)
  (add-hook
   'emacs-startup-hook
   (lambda ()
     (when (getenv "DBUS_SESSION_BUS_ADDRESS")
       (condition-case err
           (progn
             (dbus-register-signal
              :session "org.freedesktop.portal.Desktop"
              "/org/freedesktop/portal/desktop"
              "org.freedesktop.portal.Settings" "SettingChanged"
              (lambda (ns key value)
                (when (and (equal ns "org.freedesktop.appearance")
                           (equal key "color-scheme"))
                  (my/apply-theme (my/portal-dark-p value)))))
             (my/apply-theme
              (my/portal-dark-p
               (dbus-call-method
                :session "org.freedesktop.portal.Desktop"
                "/org/freedesktop/portal/desktop"
                "org.freedesktop.portal.Settings" "Read"
                "org.freedesktop.appearance" "color-scheme"))))
         (error (message "System theme sync unavailable: %s"
                         (error-message-string err))))))))

(defun my/switch-theme ()
  (interactive)
  (let ((themes (mapcar #'symbol-name (custom-available-themes))))
    (while t
      (let ((theme (intern (completing-read "Theme (C-g to quit): " themes nil t))))
        (mapc #'disable-theme custom-enabled-themes)
        (load-theme theme t)))))

(use-package olivetti
  :hook (eww-mode . olivetti-mode)
  :bind ("C-c v o" . olivetti-mode)
  :custom (olivetti-body-width 100)
  :config
  (add-hook 'olivetti-mode-on-hook
            (lambda () (display-line-numbers-mode -1)))
  (add-hook 'olivetti-mode-off-hook
            (lambda ()
              (when (derived-mode-p 'prog-mode 'conf-mode)
                (display-line-numbers-mode 1)))))


;;; Completion

(use-package icomplete
  :bind (:map icomplete-minibuffer-map
              ("SPC" . self-insert-command)
              ("TAB" . icomplete-force-complete)
              ("C-n" . icomplete-forward-completions)
              ("C-p" . icomplete-backward-completions)
              ("C-v" . icomplete-vertical-toggle)
              ("RET" . icomplete-force-complete-and-exit)
              ("C-j" . exit-minibuffer))
  :hook
  (after-init . icomplete-mode)
  :config
  (setq icomplete-delay-completions-threshold 0)
  (setq icomplete-compute-delay 0)
  (setq icomplete-show-matches-on-no-input t)
  (setq icomplete-hide-common-prefix nil)
  (setq icomplete-prospects-height 1)
  (setq icomplete-separator " | ")
  (setq icomplete-with-completion-tables t)
  (setq icomplete-in-buffer nil)
  (setq icomplete-max-delay-chars 0)
  (setq icomplete-scroll t)
  (setq icomplete-vertical-in-buffer-adjust-list t)
  (setq icomplete-vertical-render-prefix-indicator t)
  (set-face-attribute 'icomplete-first-match nil
                      :background 'nil
                      :foreground "#fabd2f"
                      :weight 'bold
                      :inherit nil))

(use-package minibuffer
  :ensure nil
  :demand t
  :custom
  (completions-detailed t)
  (completions-format 'one-column)
  (completions-max-height 10)
  (completion-ignore-case t)
  (completion-show-help nil)
  (completion-auto-help nil)
  (completion-auto-select t)
  (enable-recursive-minibuffers t)
  (minibuffer-visible-completions t)
  (completion-eager-update t)
  :bind
  (:map completion-in-region-mode-map
        ("C-i" . minibuffer-choose-completion)
        ("C-n" . minibuffer-next-completion)
        ("C-p" . minibuffer-previous-completion)))

(use-package orderless
  :ensure t
  :demand t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides
   '((file (styles partial-completion orderless)))))

(use-package yasnippet
  :ensure t
  :custom (yas-snippet-dirs (list (expand-file-name "snippets/" user-emacs-directory)))
  :config (yas-global-mode 1))

(use-package company
  :hook ((prog-mode text-mode) . company-mode)
  :bind (:map company-mode-map
              ("M-<tab>"   . company-complete-selection)
              ("<tab>"   . company-indent-or-complete-common)
              :map company-active-map
              ("<tab>"   . company-complete-selection))
  :init
  (setq tab-always-indent 'complete)
  :config
  (setq company-idle-delay nil
        company-minimum-prefix-length 1
        company-tooltip-align-annotations t
        completion-ignore-case t
        company-transformers '(company-sort-prefer-same-case-prefix
                               company-sort-by-occurrence)
        company-frontends '(company-pseudo-tooltip-frontend
                            company-preview-if-just-one-frontend)
        company-backends '((company-capf :with company-yasnippet)
                           (company-files :with company-yasnippet)
                           (company-dabbrev-code company-keywords :with company-yasnippet)
                           (company-dabbrev :with company-yasnippet)))
  (define-advice company-show-doc-buffer (:around (&rest args) prot)
    (let ((help-window-select nil)
          (display-buffer-alist nil)
          (display-buffer-overriding-action
           '((display-buffer-reuse-mode-window display-buffer-below-selected)
             (window-height . 0.4)
             (post-command-select-window . nil))))
      (apply args))))


;;; Editing

(defun my/move-beginning-of-line ()
  "Go to indentation; if already there, go to the real beginning of line."
  (interactive)
  (let ((orig (point)))
    (back-to-indentation)
    (when (= orig (point))
      (move-beginning-of-line 1))))
(keymap-global-set "C-a" #'my/move-beginning-of-line)

(defun my/goto-line ()
  "Like `goto-line' but always with absolute line numbers."
  (interactive)
  (let ((display-line-numbers 'absolute))
    (call-interactively #'goto-line)))
(keymap-global-set "M-g M-g" #'my/goto-line)

(use-package expand-region
  :ensure t
  :bind ("C-=" . er/expand-region))

(use-package multiple-cursors
  :ensure t
  :bind (("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c m a" . mc/mark-all-like-this)
         ("C-c m d" . mc/mark-all-dwim))
  :config (setq mc/always-run-for-all t))

(use-package smart-hungry-delete
  :ensure t
  :bind (([remap backward-delete-char-untabify] . smart-hungry-delete-backward-char)
         ([remap delete-backward-char]          . smart-hungry-delete-backward-char)
         ([remap delete-char]                   . smart-hungry-delete-forward-char))
  :init (smart-hungry-delete-add-default-hooks))

(use-package whitespace
  :ensure nil
  :hook (prog-mode . whitespace-mode)
  :custom
  (whitespace-style
   (quote
    (face tabs trailing space-before-tab newline indentation empty space-after-tab tab-mark)))
  :config
  (add-hook 'before-save-hook #'delete-trailing-whitespace))

(use-package jinx
  :ensure t
  :hook (emacs-startup . global-jinx-mode)
  :bind
  ("M-$" . jinx-correct)
  :custom
  (jinx-languages "en_US ar"))


;;; Windows

(use-package window
  :ensure nil
  :custom
  (display-buffer-alist
   '(
     ((or . ((derived-mode . occur-mode)
             (derived-mode . grep-mode)
             (derived-mode . Buffer-menu-mode)
             (derived-mode . log-view-mode)
             (derived-mode . xref--xref-buffer-mode)))
      (display-buffer-reuse-mode-window display-buffer-below-selected)
      (window-height . 0.45)
      (body-function . select-window))

     ("\\*\\(Backtrace\\|Warnings\\|Compile-Log\\|Messages\\|Bookmark List\\|Occur\\|eldoc\\)\\*"
      (display-buffer-in-side-window)
      (window-height . 0.30)
      (side . bottom)
      (slot . 0))

     ("\\*\\(Ibuffer\\)\\*"
      (display-buffer-in-side-window)
      (window-width . 100)
      (side . right)
      (slot . 1)))))

(use-package windmove
  :ensure nil
  :config
  (windmove-default-keybindings)
  (with-eval-after-load 'org
    (add-hook 'org-shiftup-final-hook #'windmove-up)
    (add-hook 'org-shiftdown-final-hook #'windmove-down)
    (add-hook 'org-shiftleft-final-hook #'windmove-left)
    (add-hook 'org-shiftright-final-hook #'windmove-right))
  (defvar-keymap my/window-map
    :repeat t
    "h" #'windmove-left
    "j" #'windmove-down
    "k" #'windmove-up
    "l" #'windmove-right
    "r" #'window-layout-rotate-clockwise
    "R" #'window-layout-rotate-anticlockwise
    "0" #'delete-window
    "1" #'delete-other-windows)
  (keymap-global-set "C-c w" my/window-map))


;;; Files

(use-package dired
  :ensure nil
  :hook (dired-mode . dired-hide-details-mode)
  :custom
  (dired-listing-switches "-ahlv --group-directories-first")
  (dired-dwim-target t)
  (dired-kill-when-opening-new-dired-buffer t))

(use-package dired-subtree
  :after dired
  :custom (dired-subtree-use-backgrounds nil)
  :bind (:map dired-mode-map ("TAB" . dired-subtree-toggle)))

(use-package trashed
  :ensure t)

(defun my/sudo-edit ()
  (interactive)
  (if buffer-file-name
      (find-alternate-file (concat "/sudo::" buffer-file-name))
    (user-error "Buffer is not visiting a file")))


;;; Search

(use-package isearch
  :ensure nil
  :hook
  (isearch-mode . deactivate-mark)
  :config
  (setq isearch-lazy-count t)
  (setq lazy-count-prefix-format "(%s/%s) ")
  (setq lazy-count-suffix-format nil)
  (setq isearch-allow-motion t)
  (setq isearch-allow-scroll t)
  (setq isearch-repeat-on-direction-change t)
  (setq isearch-wrap-pause 'no-ding))

(use-package xref
  :ensure nil
  :config
  (setq xref-search-program (if (executable-find "rg") 'ripgrep 'grep)))


;;; Project & Build

(use-package project
  :ensure nil
  :custom
  (project-vc-extra-root-markers '(".project" "Makefile" "package.json"))
  (project-compilation-buffer-name-function
   (lambda (_) (format "*compilation: %s*" (project-name (project-current)))))
  (project-switch-commands
   '((project-find-file "Find file" ?f)
     (magit-project-status "Magit" ?v)
     (project-dired "Dired" ?d)
     (project-compile "Compile" ?c)
     (project-eshell "Eshell" ?e)
     (project-kill-buffers "Kill buffers" ?k))))

(use-package compile
  :ensure nil
  :custom
  (compilation-scroll-output 'first-error)
  (compilation-ask-about-save nil)
  (compilation-always-kill t)
  :config
  (add-hook 'compilation-filter-hook #'ansi-color-compilation-filter))


;;; Version Control

(use-package diff
  :ensure nil
  :config
  (setq diff-font-lock-syntax nil))

(use-package ediff
  :ensure nil
  :config
  (setq ediff-split-window-function 'split-window-horizontally)
  (setq ediff-window-setup-function 'ediff-setup-windows-plain))

(use-package vc
  :ensure nil
  :defer t
  :custom
  (vc-follow-symlinks t)
  (vc-git-print-log-follow t))

(defun my/magit-status ()
  "Open `magit-status' and jump to current file if visiting one in a Git repo."
  (interactive)
  (let* ((root (and buffer-file-name
                    (locate-dominating-file buffer-file-name ".git")))
         (buffer-file-path (and root (file-relative-name buffer-file-name root))))
    (if (not buffer-file-path)
        (call-interactively #'magit-status)
      (let ((section-ident `((file . ,buffer-file-path) (unstaged) (status))))
        (call-interactively #'magit-status)
        (delete-other-windows)
        (goto-char (point-min))
        (cl-loop until (when (equal section-ident (magit-section-ident (magit-current-section)))
                         (magit-section-show (magit-current-section))
                         (recenter)
                         t)
                 do (condition-case nil
                        (magit-section-forward)
                      (error (cl-return (magit-status-goto-initial-section-1)))))))))

(defun my/magit-save-buffer-show-status ()
  "Save buffer and show its changes in `magit-status'."
  (interactive)
  (save-buffer)
  (my/magit-status))

(use-package magit
  :ensure t
  :defer t
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  (magit-save-repository-buffers 'dontask)
  :bind (("C-x g" . my/magit-save-buffer-show-status)
         ("C-c g" . magit-status))
  :config
  (keymap-set magit-mode-map "." #'magit-diff-toggle-refine-hunk))


;;; Terminal

(use-package ghostel
  :ensure t
  :hook ((after-init . ghostel-status-indicator-mode)
         (after-init . ghostel-compile-global-mode)
         (after-init . ghostel-comint-global-mode)
         (after-init . ghostel-shell-command-global-mode)
         (eshell-load . ghostel-eshell-visual-command-mode))
  :bind ("C-x m" . ghostel)
  :config
  (require 'ghostel-eshell)
  (require 'ghostel-compile)
  (require 'ghostel-comint)
  (add-to-list 'ghostel-eval-cmds
               '("magit-status-setup-buffer" magit-status-setup-buffer)))

(use-package ghostel-project
  :ensure nil
  :bind (:map project-prefix-map
              ("m" . ghostel-project)
              ("M" . ghostel-project-list-buffers))
  :config
  (add-to-list 'project-switch-commands '(ghostel-project "Ghostel") t)
  (add-to-list 'project-switch-commands '(ghostel-project-list-buffers "Ghostel buffers") t)
  (add-to-list 'project-kill-buffer-conditions '(derived-mode . ghostel-mode)))


;;; Org

(use-package org
  :ensure nil
  :hook ((org-mode . visual-line-mode)
         (org-mode . org-indent-mode))
  :custom
  (org-directory "~/Documents/org/")
  (org-agenda-files '("~/Documents/org/"))
  (org-default-notes-file "~/Documents/org/inbox.org")
  (org-startup-folded 'content)
  (org-hide-emphasis-markers t)
  (org-return-follows-link t)
  (org-log-done 'time)
  (org-todo-keywords
   '((sequence "TODO(t)" "WAIT(w!)" "|" "CANCEL(c!)" "DONE(d!)")))
  (org-capture-templates
   '(("a" "Anki Card" entry
      (file+headline "/tmp/anki.org" "Anki flashcards for today")
      "* \n:PROPERTIES:\n:ANKI_DECK:\n:ANKI_NOTE_TYPE: Basic\n:END:\n\n** Front\n\n** Back\n")
     ("t" "Task" entry (file+headline "inbox.org" "Tasks")
      "* TODO %?\n  %U\n")
     ("n" "Note" entry (file+headline "inbox.org" "Notes")
      "* %?\n  %U\n")))
  :config
  (make-directory org-directory t)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (C . t)
     (shell . t)
     (java . t)
     (js . t)
     (sql . t)
     (sqlite . t)))
  (require 'org-tempo))

(defvar-keymap my/org-map
  :doc "Org map (C-c o)."
  "a" #'org-agenda
  "c" #'org-capture
  "t" #'org-babel-tangle)

(keymap-global-set "C-c o" my/org-map)

(use-package anki-editor
  :ensure t
  :after org)

(use-package verb
  :ensure t
  :after org
  :custom (verb-json-use-mode 'json-ts-mode)
  :config
  (keymap-set org-mode-map "C-c C-r" verb-command-map)
  (keymap-set verb-response-body-mode-map "q"
              (lambda () (interactive) (quit-window t))))


;;; Development

(add-hook 'prog-mode-hook
          (lambda ()
            (font-lock-add-keywords
             nil '(("\\<\\(TODO\\|FIXME\\|HACK\\|XXX\\)\\>" 1 'warning prepend)))))

(add-hook 'prog-mode-hook #'subword-mode)
(add-hook 'prog-mode-hook #'hs-minor-mode)

(use-package eldoc
  :ensure nil
  :custom
  (eldoc-help-at-pt t)
  (eldoc-echo-area-use-multiline-p nil)
  (eldoc-echo-area-prefer-doc-buffer t)
  (eldoc-documentation-strategy 'eldoc-documentation-compose)
  :init (global-eldoc-mode 1))

(defun my/flymake-toggle-eol ()
  "Toggle Flymake diagnostics at end of line."
  (interactive)
  (setq-local flymake-show-diagnostics-at-end-of-line
              (not flymake-show-diagnostics-at-end-of-line))
  (flymake-mode -1)
  (flymake-mode 1)
  (message "Flymake EOL diagnostics %s"
           (if flymake-show-diagnostics-at-end-of-line "enabled" "disabled")))

(use-package flymake
  :ensure nil
  :hook ((prog-mode . flymake-mode)
         (prog-mode . repeat-mode))
  :bind (:map flymake-mode-map
              ("C-c 1 n" . flymake-goto-next-error)
              ("C-c 1 p" . flymake-goto-prev-error)
              ("C-c 1 l" . flymake-show-buffer-diagnostics)
              ("C-c 1 L" . flymake-show-project-diagnostics)
              ("C-c 1 e" . my/flymake-toggle-eol))
  :custom
  (flymake-show-diagnostics-at-end-of-line nil)
  :config
  (defvar-keymap my/flymake-repeat-map
    :repeat t
    "n" #'flymake-goto-next-error
    "p" #'flymake-goto-prev-error
    "e" #'my/flymake-toggle-eol
    "l" #'flymake-show-buffer-diagnostics
    "L" #'flymake-show-project-diagnostics))

(use-package eglot
  :ensure nil
  :hook ((c-mode c-ts-mode
                 java-mode java-ts-mode
                 js-ts-mode typescript-ts-mode tsx-ts-mode
                 mhtml-mode html-ts-mode web-mode
                 css-mode css-ts-mode json-ts-mode)
         . eglot-ensure)
  :bind (:map eglot-mode-map
              ("C-c l r" . eglot-rename)
              ("C-c l a" . eglot-code-actions)
              ("C-c l f" . eglot-format)
              ("C-c l d" . eldoc)
              ("C-c l h" . eglot-inlay-hints-mode))
  :custom
  (eglot-autoshutdown t)
  (eglot-sync-connect nil)
  (eglot-events-buffer-config '(:size 0 :format full))
  (eglot-extend-to-xref t)
  :config
  (setq read-process-output-max (* 1024 1024))
  (add-to-list 'eglot-stay-out-of 'company)

  (dolist (face '(eglot-highlight-symbol-face
                  eglot-semantic-declaration
                  eglot-semantic-modifier
                  eglot-semantic-namespace
                  eglot-semantic-static
                  eglot-semantic-readonly))
    (set-face-attribute face nil
                        :inherit 'unspecified
                        :foreground 'unspecified
                        :background 'unspecified)))

(use-package eldoc-box
  :commands (eldoc-box-help-at-point)
  :custom
  (eldoc-box-max-pixel-width 600)
  (eldoc-box-max-pixel-height 400)
  :bind
  ("C-c l b" . eldoc-box-help-at-point))

(use-package breadcrumb
  :vc (:url "https://github.com/joaotavora/breadcrumb.git" :rev :newest)
  :hook ((java-mode java-ts-mode) . breadcrumb-local-mode)
  :config
  (setq-default frame-title-format
                '(:eval (when (fboundp 'bc--header-line)
                          (bc--header-line)))))

(use-package dape
  :ensure t
  :init (setq dape-key-prefix "\C-cd")
  :custom
  (dape-buffer-window-arrangement 'right)
  (window-sides-vertical t))

(use-package apheleia
  :config
  (setf (alist-get 'google-java-format apheleia-formatters)
        '("google-java-format" "--aosp" "-"))
  (apheleia-global-mode +1))

(use-package markdown-mode
  :mode ("\\.md\\'" . gfm-mode)
  :hook (markdown-mode . outline-minor-mode)
  :custom-face (markdown-code-face ((t (:inherit default)))))

;;; Emacs Lisp

(defun my/elisp-imenu-setup ()
  "Config navigation"
  (add-to-list 'imenu-generic-expression
               '("Sections" "^;;;+\\s-*\\(.+\\)$" 1))
  (add-to-list 'imenu-generic-expression
               '("Packages" "^\\s-*(use-package\\s-+\\(\\(?:\\sw\\|\\s_\\)+\\)" 1)))

(add-hook 'emacs-lisp-mode-hook #'my/elisp-imenu-setup)

;;; CC

(defun my/mark-function-body ()
  "Mark the body of the function at point."
  (interactive)
  (beginning-of-defun)
  (if (not (search-forward "{" nil t))
      (user-error "No function body found")
    (let ((start (point)))
      (backward-char)
      (forward-sexp)
      (backward-char)
      (push-mark start nil t)
      (setq deactivate-mark nil))))

(use-package cc-mode
  :ensure nil
  :custom
  (c-default-style '((java-mode . "java")
                     (awk-mode . "awk")
                     (other . "k&r")))
  :bind (:map c-mode-base-map ("C-c m b" . my/mark-function-body)))

(add-hook 'makefile-mode-hook (lambda () (setq-local indent-tabs-mode t)))


;;; Java

(use-package java-kit
  :vc (:url "https://github.com/LuciusChen/java-kit" :rev :newest)
  :hook ((java-mode java-ts-mode) .
         (lambda ()
           (java-kit-mode 1)
           (local-set-key (kbd "C-c t t") #'java-kit-test)
           (local-set-key (kbd "C-c t u") #'java-kit-run-test)
           (local-set-key (kbd "C-c t d") #'java-kit-debug-test)))
  :config
  (setopt java-kit-jdtls-jvm-arguments '("-Xmx4G" "-XX:+UseStringDeduplication"))
  (let ((jar (expand-file-name
              "var/dape/adapters/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-0.53.2.jar"
              user-emacs-directory)))
    (when (file-exists-p jar)
      (setopt java-kit-jdtls-bundles (list jar)))))

(use-package jarchive
  :ensure t
  :hook (after-init . jarchive-setup))


;;; Web

(let ((node-bin (expand-file-name "~/.local/share/fnm/aliases/default/bin")))
  (when (file-directory-p node-bin)
    (setenv "PATH" (concat node-bin path-separator (getenv "PATH")))
    (add-to-list 'exec-path node-bin)))

(setq-default js-indent-level 2
              typescript-ts-mode-indent-offset 2
              css-indent-offset 2)

(add-to-list 'auto-mode-alist '("\\.jsx?\\'\\|\\.[mc]js\\'" . js-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'"  . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.json\\'" . json-ts-mode))

(use-package web-mode
  :mode "\\.html?\\'"
  :custom
  (web-mode-markup-indent-offset 2)
  (web-mode-css-indent-offset 2)
  (web-mode-code-indent-offset 2))

(use-package emmet-mode
  :hook ((html-ts-mode sgml-mode css-ts-mode css-mode
                       js-jsx-mode js-ts-mode tsx-ts-mode web-mode)
         . emmet-mode)
  :bind (:map emmet-mode-keymap ("C-." . emmet-expand-line))
  :custom (emmet-move-cursor-between-quotes t)
  :config
  (add-to-list 'emmet-css-major-modes 'css-ts-mode)
  (dolist (mode '(js-ts-mode tsx-ts-mode))
    (add-to-list 'emmet-jsx-major-modes mode)))

(use-package sgml-mode
  :ensure nil
  :hook ((sgml-mode web-mode js-ts-mode tsx-ts-mode) . sgml-electric-tag-pair-mode))

(use-package rainbow-mode
  :hook ((css-mode css-ts-mode scss-mode web-mode html-ts-mode) . rainbow-mode))

;; tsls + eslint + tailwindcss
(use-package eglot-typescript-preset
  :after eglot
  :custom
  (eglot-typescript-preset-lsp-server 'rass)
  (eglot-typescript-preset-rass-tools
   '(typescript-language-server eslint tailwindcss-language-server))
  (eglot-typescript-preset-css-lsp-server 'rass))

;; html + tailwindcss
(with-eval-after-load 'eglot
  (put 'web-mode 'eglot-language-id "html")
  (put 'mhtml-mode 'eglot-language-id "html")
  (add-to-list 'eglot-server-programs
               '((mhtml-mode html-mode web-mode html-ts-mode sgml-mode)
                 "rass" "--" "vscode-html-language-server" "--stdio"
                 "--" "tailwindcss-language-server" "--stdio")))

(use-package know-your-http-well
  :ensure t)


;;; AI

(use-package agent-shell
  :ensure t)
