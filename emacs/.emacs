;;; ============================================================
;;; PACKAGE MANAGEMENT
;;; ============================================================

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;;; ============================================================
;;; CORE SETTINGS
;;; ============================================================

(setq inhibit-startup-screen t)
(setq custom-file "~/.emacs.custom.el")
(load custom-file 'noerror 'nomessage)

(recentf-mode 1)
(electric-pair-mode 1)
(global-visual-line-mode 1)
(savehist-mode)
(delete-selection-mode)
(column-number-mode)
(setq Man-notify-method 'pushy)

(setq duplicate-line-final-position 1)
(setq isearch-allow-scroll 1)

(setq initial-buffer-choice
      (lambda ()
        (when (zerop (length command-line-args-left))
          (recentf-open-files))))

;; Open files in read-only mode by default
(add-hook 'find-file-hook #'read-only-mode)

(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)

(setq switch-to-buffer-obey-display-actions t)

;;; ============================================================
;;; BACKUP & AUTO-SAVE
;;; ============================================================

(setq make-backup-files t)
(setq backup-directory-alist '((".*" . "~/.emacs.d/backup-files/")))
(setq auto-save-default nil)

;;; ============================================================
;;; INDENTATION
;;; ============================================================

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default standard-indent 4)

(defun my/set-universal-indentation ()
  "Force 4-space indentation for both classic and tree-sitter modes."
  (setq indent-tabs-mode nil)
  (setq tab-width 4)

  (setq c-basic-offset 4)
  (setq c-ts-mode-indent-offset 4)
  (setq java-ts-mode-indent-offset 4)
  (setq python-indent-offset 4)
  (setq go-ts-mode-indent-offset 4)
  (setq js-indent-level 4)
  (setq typescript-ts-mode-indent-offset 4)
  (setq css-indent-offset 4)
  (setq web-mode-markup-indent-offset 4)
  (setq json-ts-mode-indent-offset 4)
  (setq yaml-ts-mode-indent-offset 4)
  (setq rust-ts-mode-indent-offset 4))

(add-hook 'prog-mode-hook #'my/set-universal-indentation)

(add-hook 'text-mode-hook (lambda () (setq indent-tabs-mode nil)))

;;; ============================================================
;;; WHITESPACE
;;; ============================================================

(global-whitespace-mode 1)
(setq whitespace-style '(face trailing tabs tab-mark))

(dolist (hook '(dired-mode-hook
                magit-mode-hook
                magit-status-mode-hook
                magit-log-mode-hook))
  (add-hook hook (lambda ()
                   (whitespace-mode 0))))

;;; ============================================================
;;; UI CHROME
;;; ============================================================

(tool-bar-mode   0)
(menu-bar-mode   0)
(scroll-bar-mode 0)

;;; ============================================================
;;; FONT
;;; ============================================================

(defun my/set-font ()
  (set-face-attribute 'default nil
                      :font   "JetBrainsMono Nerd Font Mono"
                      :height 110))

(if (daemonp)
    (add-hook 'after-make-frame-functions
              (lambda (frame)
                (with-selected-frame frame
                  (my/set-font))))
  (my/set-font))

;;; ============================================================
;;; ARABIC / BIDI SUPPORT
;;; ============================================================

(defun my/set-font (&optional frame)
  (with-selected-frame (or frame (selected-frame))
    (set-face-attribute 'default nil
                        :font   "JetBrainsMono Nerd Font Mono"
                        :height 110)

    (let ((arabic-font (font-spec :family "Noto Sans Arabic" :size 14)))
      (set-fontset-font "fontset-default" 'arabic arabic-font frame)
      (set-fontset-font "fontset-default" '(#x0600 . #x06FF) arabic-font frame)
      (set-fontset-font "fontset-default" '(#xFB50 . #xFDFF) arabic-font frame)
      (set-fontset-font "fontset-default" '(#xFE70 . #xFEFF) arabic-font frame))))

(if (daemonp)
    (add-hook 'after-make-frame-functions #'my/set-font)
  (my/set-font))

;;; ---- org-mode specific ----------------------------------------

(defun my/org-bidi-setup ()
  "Sensible bidi defaults for org-mode with mixed Arabic/English."
  ;; Let Emacs detect paragraph direction automatically
  (setq-local bidi-paragraph-direction nil)
  ;; Disable visual-line truncation quirks that break RTL display
  (setq-local word-wrap t)
  ;; Input method shortcut — toggle with s-\ (already bound globally)
  )

(add-hook 'org-mode-hook #'my/org-bidi-setup)

;;; ============================================================
;;; LINE NUMBERS
;;; ============================================================

(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode t)

(dolist (hook '(term-mode-hook
                shell-mode-hook
                eshell-mode-hook
                vterm-mode-hook))
  (add-hook hook (lambda ()
                   (display-line-numbers-mode 0)
                   (display-fill-column-indicator-mode 0))))

;;; ============================================================
;;; COLUMN INDICATOR
;;; ============================================================

(setq-default fill-column 80)
(setq display-fill-column-indicator-character ?│)
(global-display-fill-column-indicator-mode 1)
(set-face-attribute 'fill-column-indicator nil
                    :foreground "#444444"
                    :weight 'bold)

;;; ============================================================
;;; MODE LINE
;;; ============================================================

(setq-default mode-line-format
      '("%e"
        mode-line-front-space
        mode-line-mule-info
        mode-line-client
        mode-line-modified
        mode-line-remote
        mode-line-frame-identification
        mode-line-buffer-identification
        "   "
        mode-line-position
        (vc-mode vc-mode)
        "  "
        mode-line-modes
        (:eval (if buffer-read-only (propertize " [hjkl]" 'face 'shadow) ""))
        mode-line-misc-info
        mode-line-end-spaces))

;;; ============================================================
;;; SCROLLING
;;; ============================================================

(setq scroll-conservatively 101
      scroll-margin          5
      scroll-step            1)

(pixel-scroll-precision-mode 1)
(setq pixel-scroll-precision-use-momentum     nil
      pixel-scroll-precision-interpolate-mice nil
      mouse-wheel-scroll-amount               '(3 ((shift) . 1) ((control) . 5))
      mouse-wheel-progressive-speed           nil
      mouse-wheel-follow-mouse                t)

;; (pixel-scroll-precision-mode 1)

;;; ============================================================
;;; NAVIGATION — prefixed hjkl (always on)
;;; ============================================================

(define-minor-mode my-nav-mode
  "Global navigation keybindings that override major modes."
  :global t
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "C-h") 'backward-char)
            (define-key map (kbd "C-j") 'next-line)
            (define-key map (kbd "C-k") 'previous-line)
            (define-key map (kbd "C-l") 'forward-char)
            (define-key map (kbd "C-f") 'forward-word)
            (define-key map (kbd "C-b") 'backward-word)
            (define-key map (kbd "C-p")
              (lambda () (interactive) (previous-line 8) (recenter)))
            (define-key map (kbd "C-n")
              (lambda () (interactive) (next-line 8) (recenter)))
            ;; drag-stuff
            (define-key map (kbd "C-S-h") 'drag-stuff-left)
            (define-key map (kbd "C-S-j") 'drag-stuff-down)
            (define-key map (kbd "C-S-k") 'drag-stuff-up)
            (define-key map (kbd "C-S-l") 'drag-stuff-right)
            map))

(my-nav-mode 1)

;;; ============================================================
;;; NAVIGATION — bare hjkl (read-only buffers only)
;;; ============================================================

(defun my/gg-beginning-of-buffer ()
  "Go to beginning of buffer on second g (vi-style gg)."
  (interactive)
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "g")
      (lambda () (interactive) (beginning-of-buffer)))
    (set-transient-map map nil (lambda () (message nil)))))

(define-minor-mode my-read-only-nav-mode
  "Bare hjkl navigation, active only when buffer is read-only."
  :global nil
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "h") 'backward-char)
            (define-key map (kbd "j") 'next-line)
            (define-key map (kbd "k") 'previous-line)
            (define-key map (kbd "l") 'forward-char)
            (define-key map (kbd "w") 'forward-word)
            (define-key map (kbd "b") 'backward-word)
            (define-key map (kbd "C-p")
              (lambda () (interactive) (previous-line 8) (recenter)))
            (define-key map (kbd "C-n")
              (lambda () (interactive) (next-line 8) (recenter)))
            (define-key map (kbd "g") 'my/gg-beginning-of-buffer)
            (define-key map (kbd "G") 'end-of-buffer)
            map))

(defun my/read-only-nav-update ()
  "Toggle `my-read-only-nav-mode' to match `buffer-read-only'."
  (if buffer-read-only
      (my-read-only-nav-mode 1)
    (my-read-only-nav-mode -1)))

(add-hook 'post-command-hook #'my/read-only-nav-update)

;;; ============================================================
;;; PACKAGES
;;; ============================================================

;; Essential

(use-package magit)

(use-package vterm)

(use-package drag-stuff
  :config
  (drag-stuff-global-mode 1))

(use-package combobulate
   :custom
   (combobulate-key-prefix "C-c o")
   :hook ((prog-mode . combobulate-mode))
   :load-path ("~/Src/combobulate"))

(use-package expreg
  :bind (("C-=" . expreg-expand)
         ("C--" . expreg-contract)))

(use-package anzu
  :config
  (global-anzu-mode 1))

(use-package avy
  :bind
  ("C-:"   . avy-goto-char)
  ("M-j"   . avy-goto-word-1)
  ("M-g g" . avy-goto-line)
  :custom
  (avy-all-windows nil))


;; QOF

(use-package vertico
  :init (vertico-mode)
  :custom
  (vertico-resize t)
  (vertico-cycle  t))

(use-package emacs
  :custom
  (enable-recursive-minibuffers    t)
  (read-extended-command-predicate #'command-completion-default-include-p))

(use-package marginalia
  :init (marginalia-mode))

(use-package orderless
  :custom
  (completion-styles              '(orderless basic))
  (completion-category-defaults  nil)
  (completion-category-overrides '((file (styles partial-completion)))))


;; Org

(use-package olivetti
  :ensure t
  :init
  (setq olivetti-body-width 90)
  (setq olivetti-recall-visual-line-mode-entry-state t)
  :hook
  ((org-mode . olivetti-mode)
   (olivetti-mode . (lambda ()
                      (visual-line-mode 1)
                      (setq-local word-wrap t)
                      (setq-local bidi-paragraph-direction nil)
                      (setq org-modern-block-fringe t)
                      ))))

(use-package org-download
  :ensure t
  :config
  (setq-default org-download-heading-lvl nil)
  (setq-default org-download-image-dir "./images"))

;; (use-package org-modern
;;   :hook (org-mode . org-modern-mode))


;; UI

(use-package doom-themes
  :custom
  (doom-themes-enable-italic nil)
  :config
  (load-theme 'doom-gruvbox t)
  (custom-set-faces
   '(font-lock-preprocessor-face  ((t (:foreground "#b16286"))))
   '(font-lock-function-name-face ((t (:foreground "#98C379"))))))


(use-package nerd-icons
  :ensure t)

(use-package diff-hl
  :ensure t
  :config
  (global-diff-hl-mode 1)
  (diff-hl-flydiff-mode 1)
  (add-hook 'magit-pre-refresh-hook  'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh))


;; Formatters

(use-package clang-format
  :config
  (setq clang-format-style "file"))


;;; ============================================================
;;; MAJOR MODES
;;; ============================================================

;; Make
(dolist (hook '(makefile-mode-hook
                makefile-ts-mode-hook))
  (add-hook hook (lambda ()
                   (setq indent-tabs-mode t)
                   (setq tab-width 4))))


;;; ============================================================
;;; ORG-MODE
;;; ============================================================

;; Core
(add-hook 'org-mode-hook (lambda ()
                           (display-line-numbers-mode -1)
                           (display-fill-column-indicator-mode -1)
                           ))

(add-hook 'org-mode-hook #'font-lock-mode)

;; Code blocks
(setq org-src-fontify-natively t)
(setq org-src-tab-acts-natively t)


;; GRUVBOX SPECIFIC
(defun my-org-customization ()
(set-face-attribute 'bold nil :foreground "#458588" :weight 'bold)
(set-face-attribute 'italic nil :foreground "#b16286" :weight 'normal)
)
(add-hook 'org-mode-hook 'my-org-customization)



(with-eval-after-load 'org
  ;; Keybinds
  (define-key org-mode-map (kbd "M-n") #'org-next-item)
  (define-key org-mode-map (kbd "M-p") #'org-previous-item)

  ;; Fonts
  (dolist (face '((org-level-1 . 1.4)
                  (org-level-2 . 1.2)
                  (org-level-3 . 1.1)
                  (org-level-4 . 1.1)
                  (org-level-5 . 1.0)
                  (org-level-6 . 1.0)
                  (org-level-7 . 1.0)
                  (org-level-8 . 1.0)))
    (set-face-attribute (car face) nil :font "JetBrains Mono" :weight 'bold :height (cdr face)))
  )

;;; ============================================================
;;; KEYBINDINGS
;;; ============================================================

;; Editing
(global-set-key (kbd "M-k")   'kill-line)
(global-set-key (kbd "C-,")   'duplicate-line)
(global-set-key (kbd "C-'")   'hippie-expand)

;; Display
(global-set-key (kbd "M-l")   'recenter-top-bottom)

;; Help
(global-set-key (kbd "M-?")   'help-command)
(global-set-key (kbd "C-c h") 'help-command)

;; Input method
(global-set-key (kbd "s-\\")  'toggle-input-method)

(global-set-key (kbd "C-;")   'read-only-mode)

(global-set-key (kbd "M-b") 'my/man-at-point)

;; C-c
(global-set-key (kbd "C-c f") #'find-file-at-point)
(global-set-key (kbd "C-c F") #'ffap-other-window)
(global-set-key (kbd "C-c gg") 'vc-git-grep)
(define-key org-mode-map (kbd "C-c s") #'org-download-clipboard)

;; Preventing deletion from overwriting kill-ring
(global-set-key (kbd "DEL") 'my/delete-selected)
(global-set-key (kbd "M-k") 'my/delete-smart-to-end)
(global-set-key (kbd "<C-backspace>") 'my-backward-delete-word)
(global-set-key (kbd "M-DEL") 'my-backward-delete-word)
(global-set-key (kbd "M-d") 'my/forward-delete-word)

;; diff-hl
(with-eval-after-load 'diff-hl
  (with-eval-after-load 'prog-mode
    (define-key prog-mode-map (kbd "M-n") #'diff-hl-next-hunk)
    (define-key prog-mode-map (kbd "M-p") #'diff-hl-previous-hunk)))

;;; ============================================================
;;; LEADER KEY  (C-z prefix)
;;; ============================================================

(define-prefix-command 'my-leader-map)
(global-set-key (kbd "C-z") 'my-leader-map)

;; Files
(define-key my-leader-map (kbd "r")   'recentf-open-files)

;; Terminal
(define-key my-leader-map (kbd "t h") #'my/vterm-horizontal)
(define-key my-leader-map (kbd "t v") #'my/vterm-vertical)

;; Compile
(define-key my-leader-map (kbd "c c") #'compile)
; (define-key my-leader-map (kbd "c r") #'my/compile-root)

;; Window navigation
(define-key my-leader-map (kbd "h") #'windmove-left)
(define-key my-leader-map (kbd "j") #'windmove-down)
(define-key my-leader-map (kbd "k") #'windmove-up)
(define-key my-leader-map (kbd "l") #'windmove-right)

;; Window swapping
(define-key my-leader-map (kbd "H") #'windmove-swap-states-left)
(define-key my-leader-map (kbd "J") #'windmove-swap-states-down)
(define-key my-leader-map (kbd "K") #'windmove-swap-states-up)
(define-key my-leader-map (kbd "L") #'windmove-swap-states-right)

;; Magit
(define-key my-leader-map (kbd "m l") 'magit-list-repositories)

;; diff-hl
(define-key my-leader-map (kbd "C-u") 'diff-hl-revert-hunk)
(define-key my-leader-map (kbd "C-s") 'diff-hl-show-hunk)

;;; ============================================================
;;; MAGIT
;;; ============================================================

(define-prefix-command 'my-git-map)
(define-key my-leader-map (kbd "g") 'my-git-map)

(setq magit-repository-directories
      '(("~/dotfiles" . 0)
        ("~/Programming" . 1)))


(defun my-magit-diff-visit-file-reuse-window (orig-fn &rest args)
  "If the file is already open in another window, reuse it."
  (let ((display-buffer-overriding-action
         '((display-buffer-reuse-window display-buffer-same-window))))
    (apply orig-fn args)))


(with-eval-after-load 'magit
  (advice-add 'magit-diff-visit-file :around #'my-magit-diff-visit-file-reuse-window)
  (advice-add 'magit-diff-visit-worktree-file :around #'my-magit-diff-visit-file-reuse-window)

  ;; Leader bindings
  (define-key my-git-map (kbd "s") #'magit-status)
  (define-key my-git-map (kbd "b") #'magit-branch)
  (define-key my-git-map (kbd "c") #'magit-commit)
  (define-key my-git-map (kbd "p") #'magit-push)
  (define-key my-git-map (kbd "P") #'magit-pull)
  (define-key my-git-map (kbd "f") #'magit-fetch)
  (define-key my-git-map (kbd "l") #'magit-log)
  (define-key my-git-map (kbd "r") #'magit-rebase)
  (define-key my-git-map (kbd "m") #'magit-dispatch)
  (define-key my-git-map (kbd "z") #'magit-stash)
  (define-key my-git-map (kbd "X") #'magit-reset)
  (define-key my-git-map (kbd "w") #'magit-worktree)
  (define-key my-git-map (kbd "g") #'magit-refresh)

  ;; Navigation & Conflicts
  (with-eval-after-load 'magit
    (define-key magit-mode-map (kbd "M-n") #'magit-section-forward)
    (define-key magit-mode-map (kbd "M-p") #'magit-section-backward))

  (define-key magit-mode-map (kbd "M-k") nil))

(with-eval-after-load 'magit
  (defun my/add-magit-repos-to-project ()
    (dolist (repo (magit-list-repos))
      (let ((default-directory (expand-file-name repo)))
        (project-current t))))
  (add-hook 'after-init-hook #'my/add-magit-repos-to-project))

;;; ============================================================
;;; LOAD PATH & LOCAL MODES
;;; ============================================================

(defun my/add-to-load-path (dir)
  "Add DIR and all its subdirectories to `load-path'."
  (add-to-list 'load-path dir)
  (dolist (subdir (directory-files dir t "^[^.]"))
    (when (file-directory-p subdir)
      (add-to-list 'load-path subdir))))

(defun my/require-directory (dir)
  "Require all .el files in DIR."
  (when (file-directory-p dir)
    (my/add-to-load-path dir)
    (dolist (file (directory-files dir t "\\.el$"))
      (require (intern (file-name-sans-extension
                        (file-name-nondirectory file)))))))

(my/require-directory (expand-file-name "modes" user-emacs-directory))
(add-to-list 'custom-theme-load-path (expand-file-name "~/.emacs.d/themes/"))

;;; ============================================================
;;; TREESITTER – CONFIGURATION & NAVIGATION (EMACS 30+)
;;; ============================================================

;; ── 1. Grammars sources ──────────────────────────────────────
(setq treesit-language-source-alist
      '((c           "https://github.com/tree-sitter/tree-sitter-c"          "v0.21.4")
        (cpp         "https://github.com/tree-sitter/tree-sitter-cpp"        "v0.22.3")
        (python      "https://github.com/tree-sitter/tree-sitter-python"     "v0.21.0")
        (java        "https://github.com/tree-sitter/tree-sitter-java"       "v0.21.0")
        (javascript  "https://github.com/tree-sitter/tree-sitter-javascript" "v0.21.4" "src")
        (typescript  "https://github.com/tree-sitter/tree-sitter-typescript" "v0.21.2" "typescript/src")
        (tsx         "https://github.com/tree-sitter/tree-sitter-typescript" "v0.21.2" "tsx/src")
        (css         "https://github.com/tree-sitter/tree-sitter-css"        "v0.21.1")
        (html        "https://github.com/tree-sitter/tree-sitter-html"       "v0.20.3")
        (json        "https://github.com/tree-sitter/tree-sitter-json"       "v0.21.0")
        (bash        "https://github.com/tree-sitter/tree-sitter-bash"       "v0.21.0")
        (go          "https://github.com/tree-sitter/tree-sitter-go"         "v0.21.0" "src")
        (gomod       "https://github.com/camdencheek/tree-sitter-go-mod"     "v1.0.1")
        (yaml        "https://github.com/ikatyang/tree-sitter-yaml"          "v0.5.0")
        (toml        "https://github.com/tree-sitter-grammars/tree-sitter-toml" "v0.6.0")
        (cmake       "https://github.com/uyha/tree-sitter-cmake"             "v0.4.1")
        (make        "https://github.com/tree-sitter-grammars/tree-sitter-make" "v1.1.0")
        (asm         "https://github.com/RubixDev/tree-sitter-asm"           "main")
        (dockerfile  "https://github.com/camdencheek/tree-sitter-dockerfile"  "v0.2.0")
        (markdown    "https://github.com/ikatyang/tree-sitter-markdown"      "v0.7.1")))

(defvar my/ts-lang-aliases
  '((c++      . cpp)
    (js       . javascript)
    (makefile . make)
    (sh       . bash))
  "Map ts-mode lang names to grammar names.")

;; ── 2. Settings & Auto-Install Logic ─────────────────────────

(setq treesit-font-lock-level 4)

(defvar my/ts-auto-install 't)

(defun my/ts--maybe-install (lang)
  (let ((lang-sym (if (stringp lang) (intern lang) lang)))
    (unless (treesit-language-available-p lang-sym)
      (pcase my/ts-auto-install
        ('ask (when (y-or-n-p (format "Grammar for `%s` missing. Install? " lang-sym))
                (treesit-install-language-grammar lang-sym)))
        ('t (progn
              (message "TreeSitter: installing grammar for %s..." lang-sym)
              (treesit-install-language-grammar lang-sym)))))))

;; ── 3. Mode Remapping ────────────────────────────────────────

(defvar my/ts-mode-remap-alist
  '((c-mode          . c-ts-mode)
    (c++-mode        . c++-ts-mode)
    (python-mode     . python-ts-mode)
    (java-mode       . java-ts-mode)
    (js-mode         . js-ts-mode)
    (javascript-mode . js-ts-mode)
    (tsx-mode        . tsx-ts-mode)
    (go-mode         . go-ts-mode)
    (css-mode        . css-ts-mode)
    (sh-mode         . bash-ts-mode)
    (makefile-mode   . makefile-ts-mode)
    (asm-mode        . asm-ts-mode)
    (dockerfile-mode . dockerfile-ts-mode)
    (html-mode       . html-ts-mode)
    (markdown-mode   . markdown-ts-mode)))

(defun my/activate-ts-remaps ()
  (dolist (pair my/ts-mode-remap-alist)
    (let* ((ts-mode (cdr pair))
            (lang (intern (replace-regexp-in-string "-ts-mode$" "" (symbol-name ts-mode))))
            (lang (or (alist-get lang my/ts-lang-aliases) lang)))

      (if (treesit-language-available-p lang)
          (add-to-list 'major-mode-remap-alist pair)
        (when (and (not (eq my/ts-auto-install nil))
                   (my/ts--maybe-install lang))
          (add-to-list 'major-mode-remap-alist pair))))))

(add-hook 'after-init-hook #'my/activate-ts-remaps)

;; ── 3.1 Explicit file associations ───────────────────────────

(add-to-list 'auto-mode-alist '("\\.go\\'"             . go-ts-mode))
(add-to-list 'auto-mode-alist '("go\\.mod\\'"          . go-mod-ts-mode))
(add-to-list 'auto-mode-alist '("go\\.sum\\'"          . go-mod-ts-mode))
(add-to-list 'auto-mode-alist '("CMakeLists\\.txt\\'"  . cmake-ts-mode))
(add-to-list 'auto-mode-alist '("\\.cmake\\'"          . cmake-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'"            . tsx-ts-mode))

;;; ============================================================
;;; FUNCTIONS
;;; ============================================================

(defvar my/opening-vterm nil
  "Non-nil while a vterm window is being opened, to suppress focus stealing.")

(defun my/vterm-horizontal ()
  "Open vterm in a horizontal split below, cd to current directory."
  (interactive)
  (let ((dir default-directory)
        (my/opening-vterm t))
    (split-window-below)
    (windmove-down)
    (vterm)
    (vterm-send-string (concat "cd " (shell-quote-argument dir) " && clear"))
    (vterm-send-return)))

(defun my/vterm-vertical ()
  "Open vterm in a vertical split to the right, cd to current directory."
  (interactive)
  (let ((dir default-directory)
        (my/opening-vterm t))
    (split-window-right)
    (windmove-right)
    (vterm)
    (vterm-send-string (concat "cd " (shell-quote-argument dir) " && clear"))
    (vterm-send-return)))

(defun my/focus-new-window (orig-fun &rest args)
  "Make newly created windows take focus, unless opening a vterm."
  (let ((win (apply orig-fun args)))
    (when (and (windowp win)
               (not my/opening-vterm))
      (select-window win))
    win))

(advice-add 'split-window   :around #'my/focus-new-window)
(advice-add 'display-buffer :around #'my/focus-new-window)

(defun mark-whole-line ()
  "Mark the entire current line."
  (interactive)
  (beginning-of-line)
  (set-mark (line-beginning-position 2)))


(defun my/man-at-point ()
  "Look up the man page for the symbol at point and display it in the right window."
  (interactive)
  (let ((topic (thing-at-point 'symbol t)))
    (if topic
        (let ((new-window (split-window-right)))
          (with-selected-window new-window
            (man topic)))
      (message "Nothing at point to look up."))))


(defun my/delete-selected ()
  "Delete selected region without adding to kill ring."
  (interactive)
  (if (use-region-p)
      (delete-region (region-beginning) (region-end))
    (delete-char -1)))

(defun my/delete-smart-to-end ()
  "Delete to end of line, or delete newline if already at end of line."
  (interactive)
  (if (= (point) (line-end-position))
      (unless (eobp)        (delete-char 1))
    (delete-region (point) (line-end-position))))

(defun my-backward-delete-word ()
  (interactive)
  (delete-region (point) (progn (backward-word 1) (point))))

(defun my/forward-delete-word ()
  "Delete word forward without adding to kill-ring."
  (interactive)
  (delete-region (point)
                 (progn (forward-word 1) (point))))
