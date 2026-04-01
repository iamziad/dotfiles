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

;;; ============================================================
;;; BACKUP & AUTO-SAVE
;;; ============================================================

(setq make-backup-files t)
(setq backup-directory-alist '((".*" . "~/.emacs.d/backup-files/")))
(setq auto-save-default nil)

;;; ============================================================
;;; INDENTATION
;;; ============================================================

(setq-default indent-tabs-mode nil
              tab-width        4
              standard-indent  4
              c-basic-offset   4)

(add-hook 'prog-mode-hook
          (lambda ()
            (setq indent-tabs-mode nil
                  tab-width 4)))

;;; ============================================================
;;; WHITESPACE
;;; ============================================================

(global-whitespace-mode 1)
(setq whitespace-style '(face trailing tabs))

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

;; Enable bidirectional text support
(setq-default bidi-display-reordering t)
(setq-default bidi-paragraph-direction nil)   ; auto-detect per paragraph

;; Avoid visual glitches with mixed RTL/LTR on long lines
(setq bidi-inhibit-bpa nil)

;; Use Noto Naskh Arabic for Arabic characters
(set-fontset-font "fontset-default"
                  '(#x0600 . #x06FF)   ; Arabic block
                  (font-spec :family "Noto Sans Arabic" :size 13))

(set-fontset-font "fontset-default"
                  '(#x0750 . #x077F)   ; Arabic Supplement
                  (font-spec :family "Noto Sans Arabic" :size 13))

(set-fontset-font "fontset-default"
                  '(#xFB50 . #xFDFF)   ; Arabic Presentation Forms-A
                  (font-spec :family "Noto Sans Arabic" :size 13))

(set-fontset-font "fontset-default"
                  '(#xFE70 . #xFEFF)   ; Arabic Presentation Forms-B
                  (font-spec :family "Noto Sans Arabic" :size 13))

;; Bump Arabic font size relative to Latin (optional — adjust ratio to taste)
(defun my/arabic-font-rescale ()
  (setf (alist-get "Noto Sans Arabic"
                   face-font-rescale-alist nil nil #'equal)
        1.2))
(my/arabic-font-rescale)

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

;; Optional: default new org paragraphs to RTL when Arabic input is active
(defun my/set-paragraph-direction-from-input ()
  "Switch bidi base direction to match the active input method."
  (when (derived-mode-p 'org-mode)
    (setq bidi-paragraph-direction
          (if (and current-input-method
                   (string-match-p "arabic" current-input-method))
              'right-to-left
            nil))))

(add-hook 'input-method-activate-hook   #'my/set-paragraph-direction-from-input)
(add-hook 'input-method-deactivate-hook #'my/set-paragraph-direction-from-input)

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

;; Terminal
(use-package vterm)
(add-hook 'vterm-mode-hook (lambda () 
                            (display-line-numbers-mode nil)
                            (display-fill-column-indicator-mode nil)))

;; Drag lines/regions up and down
(use-package drag-stuff
  :config
  (drag-stuff-global-mode 1))

;; Show search match count in mode line
(use-package anzu
  :config
  (global-anzu-mode 1))

;; Markdown support
(use-package markdown-mode
  :mode ("\\.\\(md\\|markdown\\)$" . gfm-mode)
  :init
  (setq markdown-command "multimarkdown"))

;; Jump to visible text
(use-package avy
  :bind
  ("C-:"   . avy-goto-char)
  ("M-j"   . avy-goto-word-1)
  ("M-g g" . avy-goto-line)
  :custom
  (avy-all-windows nil))

;; Vertical completion UI
(use-package vertico
  :init (vertico-mode)
  :custom
  (vertico-resize t)
  (vertico-cycle  t))

;; Recursive minibuffers + M-x filtering
(use-package emacs
  :custom
  (enable-recursive-minibuffers    t)
  (read-extended-command-predicate #'command-completion-default-include-p))

;; Annotations in the minibuffer
(use-package marginalia
  :init (marginalia-mode))

;; Fuzzy / out-of-order matching
(use-package orderless
  :custom
  (completion-styles              '(orderless basic))
  (completion-category-defaults  nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package magit)

(use-package doom-themes)

(use-package nerd-icons
  :ensure t)

(use-package diff-hl
  :ensure t
  :config
  (global-diff-hl-mode 1)
  (add-hook 'magit-pre-refresh-hook  'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh))

;; doom-modeline
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom
  ;; General
  (doom-modeline-height 28)
  (doom-modeline-bar-width 4)
  (doom-modeline-icon t)
  (doom-modeline-major-mode-icon t)
  (doom-modeline-major-mode-color-icon t)
  (doom-modeline-minor-modes nil)
  (doom-modeline-percent-position nil)
  (doom-modeline-position-line-format '("L%l"))
  (doom-modeline-buffer-encoding nil)

  ;; Buffer
  (doom-modeline-buffer-file-name-style 'truncate-upto-project)
  (doom-modeline-buffer-modification-icon t)
  (doom-modeline-buffer-state-icon t)

  ;; Git
  (doom-modeline-vcs-max-length 20)
  (doom-modeline-github nil))


;;; ============================================================
;;; KEYBINDINGS
;;; ============================================================

;; Selection
(global-set-key (kbd "C-v")   'set-mark-command)
(global-set-key (kbd "M-v")   'mark-whole-line)

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


;;; ============================================================
;;; LEADER KEY  (C-z prefix)
;;; ============================================================

(define-prefix-command 'my-leader-map)
(global-set-key (kbd "C-z") 'my-leader-map)

;; Files
(define-key my-leader-map (kbd "r")   'recentf-open-files)
(define-key my-leader-map (kbd "g f") 'ffap)
(define-key my-leader-map (kbd "d r") 'revert-buffer)
(define-key my-leader-map (kbd "C-z") #'read-only-mode)

;; Terminal
(define-key my-leader-map (kbd "t h") #'my/vterm-horizontal)
(define-key my-leader-map (kbd "t v") #'my/vterm-vertical)

;; Compile
(define-key my-leader-map (kbd "c c") #'compile)
(define-key my-leader-map (kbd "c r") #'my/compile-root)

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
