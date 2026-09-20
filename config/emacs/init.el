;;; init.el --- Main configuration entry point -*- lexical-binding: t; -*-

;;; --------------------------------------------------------------------------
;;; Bootstrap
;;; --------------------------------------------------------------------------

;; Bootstrap straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p user-emacs-directory)
            "~/.emacs.d/")))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Integrate with use-package
(straight-use-package 'use-package)
(use-package project
  :straight (:type built-in))
(use-package xref
  :straight (:type built-in))

(setq straight-use-package-by-default t
      use-package-verbose nil
      use-package-expand-minimally t)

;; Load modules
(add-to-list 'custom-theme-load-path (expand-file-name "themes" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "themes" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "modules" user-emacs-directory))
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;; Manage temp files
(defvar treesit-auto-install-grammar nil)

(use-package no-littering
  :config
  (setq auto-save-file-name-transforms
        `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))))

(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-display-icons-p t)
  (setq dashboard-icon-type 'nerd-icons)
  (setq dashboard-center-content t)
  (setq dashboard-show-shortcuts t)
  (setq dashboard-items '((recents  . 5)
                          (projects . 5)
                          ;; (agenda . 5)
                          (bookmarks . 5))))

;;; --------------------------------------------------------------------------
;;; Modules & Custom-file Load
;;; --------------------------------------------------------------------------

(when (file-exists-p custom-file)
  (load custom-file 'noerror 'nomessage))

(require 'modules)

;;; --------------------------------------------------------------------------
;;; Core Emacs Defaults & Built-in Settings
;;; --------------------------------------------------------------------------

(use-package emacs
  :ensure nil
  :init
  ;; Language & Encoding
  (set-language-environment "UTF-8")
  (set-default-coding-systems 'utf-8)
  (prefer-coding-system 'utf-8)
  (setq default-input-method "arabic")

  ;; Aliases & Keymaps
  (defalias 'yes-or-no-p 'y-or-n-p)
  (global-set-key [remap dabbrev-expand] #'hippie-expand)

  ;; Modes activation
  (savehist-mode 1)
  (save-place-mode 1)
  (recentf-mode 1)
  (winner-mode 1)
  (delete-selection-mode 1)
  (global-auto-revert-mode 1)
  (setq auto-revert-use-notify t)
  (xterm-mouse-mode 1)
  (auto-save-visited-mode 1)
  (global-visual-line-mode 1)
  (electric-pair-mode 1)
  (electric-indent-mode 1)
  (show-paren-mode 1)
  (global-so-long-mode 1)
  (context-menu-mode 1)
  (setq whitespace-global-modes '(prog-mode))
  (global-whitespace-mode 1)

  :custom
  ;; Input & Files
  ;; (initial-buffer-choice "~/Documents/org/scratch.org")
  (initial-buffer-choice 'dashboard-open)
  (make-backup-files nil)
  (auto-save-default nil)
  (create-lockfiles nil)
  (backup-by-copying t)
  (version-control t)
  (delete-old-versions t)
  (large-file-warning-threshold (* 50 1024 1024))
  (vc-follow-symlinks t)
  (global-so-long-mode 1)  ;; Optimize minified/very-long-line files

  ;; Prompts & Behavior
  (use-dialog-box nil)
  (use-short-answers t)
  (confirm-kill-emacs 'yes-or-no-p)
  (ring-bell-function 'ignore)
  (visible-bell nil)
  (help-window-select t)

  ;; History
  (recentf-max-saved-items 200)
  (history-length 200)
  (savehist-additional-variables '(kill-ring search-ring regexp-search-ring))

  ;; Editing Niceties
  (duplicate-line-final-position 1)
  (require-final-newline t)
  (sentence-end-double-space nil)
  (tab-always-indent 'complete)
  (whitespace-style '(face tabs tab-mark trailing))
  (show-paren-delay 0)

  ;; Clipboard & Selection
  (select-enable-clipboard t)
  (select-enable-primary t)
  (select-active-regions nil)

  ;; Scrolling
  (isearch-allow-scroll t)
  (scroll-margin 3)
  (scroll-conservatively 101)
  (scroll-preserve-screen-position t)
  (isearch-wrap-pause 'no-ding)
  (pixel-scroll-mode)
  (setq pixel-dead-time 0) ; Never go back to the old scrolling behaviour.
  (setq pixel-resolution-fine-flag t) ; Scroll by number of pixels instead of lines (t = frame-char-height pixels).
  (setq mouse-wheel-scroll-amount '(1)) ; Distance in pixel-resolution to scroll each mouse wheel event.
  (setq mouse-wheel-progressive-speed nil)

  (setq image-use-external-converter t)

  ;; Windows & Buffers
  (window-combination-resize t)
  (switch-to-buffer-obey-display-actions t)

  ;; Undo Limits
  (undo-limit (* 8 1024 1024))
  (undo-strong-limit (* 12 1024 1024))

  ;; Minibuffer & Completion Defaults
  (read-extended-command-predicate #'command-completion-default-include-p)
  (minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt))
  (text-mode-ispell-word-completion nil)

  :hook
  (before-save . delete-trailing-whitespace)
  (prog-mode . (lambda () (setq show-trailing-whitespace t)))
  (isearch-mode-end . (lambda ()
                        (when (and isearch-forward (not isearch-mode-end-hook-quit))
                          (goto-char isearch-other-end)))))

;; Tabs
(setq tab-bar-show 1)
(dotimes (i 9)
  (global-set-key
   (kbd (format "M-%d" (1+ i)))
   `(lambda () (interactive) (tab-bar-select-tab ,(1+ i)))))

(defun my/word-includes-hyphen ()
  (modify-syntax-entry ?- "w"))

(add-hook 'text-mode-hook #'my/word-includes-hyphen)
(add-hook 'prog-mode-hook #'my/word-includes-hyphen)

(use-package undo-fu-session
  :hook (after-init . undo-fu-session-global-mode)
  :config
  (setq undo-fu-session-incompatible-files '("/COMMIT_EDITMSG\\'" "/git-rebase-todo\\'")))

(use-package project
  :straight nil
  :config
  (setq project-vc-extra-root-markers '(".git" "Makefile" "compile_commands.json"))
  (defun my/project-try-local-root (dir)
    (let ((root (or (locate-dominating-file dir "pom.xml")
                    (locate-dominating-file dir "package.json"))))
      (and root (cons 'transient root))))
  (add-to-list 'project-find-functions #'my/project-try-local-root))

;;; --------------------------------------------------------------------------
;;; Keybindings
;;; --------------------------------------------------------------------------

;; Unsets
(keymap-global-unset "C-q")

;; Windmove
;; (windmove-default-keybindings 'shift)

(bind-keys
 ("C-/"           . undo)
 ("C-?"           . undo-redo)
 ;;
 ("C-q C-h"       . windmove-left)
 ("C-q C-j"       . windmove-down)
 ("C-q C-k"       . windmove-up)
 ("C-q C-l"       . windmove-right)
 ;;
 ("M-s h"         . windmove-swap-states-left)
 ("M-s j"         . windmove-swap-states-down)
 ("M-s k"         . windmove-swap-states-up)
 ("M-s l"         . windmove-swap-states-right)
 ;;
 ("C-c C-k C-n"   . tab-new)
 ("C-c C-k C-k"   . tab-close)
 ("C-c C-k C-o"   . tab-close-other)
 ;;
 ("C-c h"         . persp-prev)
 ("C-c l"         . persp-next)
 ;;
 ("C-a"           . my/smart-move-beginning-of-line)
 ("C-o"           . my/smart-open-line)
 ;;
 ("M-k"           . (lambda () (interactive)
                      (delete-region (line-beginning-position) (line-end-position))))
 ("C-<backspace>" . my/backward-delete-word)
 ("M-d"           . my/delete-word)
 ("C-M-d"         . sp-delete-word)
 ("<M-backspace>" . sp-backward-delete-word)
 ;;
 ("C-c C-x r"     . rename-visited-file)
 ("C-c C-x d"     . delete-visited-file)
 ("C-x C-k"       . kill-buffer-and-window)
 ;;
 ("C-,"           . duplicate-dwim)
 ("C-;"           . comment-line)
 ("C-<tab>"       . mode-line-other-buffer)
 ;;
 ("M-p"           . backward-paragraph)
 ("M-n"           . forward-paragraph)
 ;;
 ("C-x C-="       . (lambda () (interactive) (enlarge-window-horizontally 10)))
 ("C-x C--"       . (lambda () (interactive) (shrink-window-horizontally 10)))
 ("C-x ="         . global-text-scale-adjust)
 ;;
 ("M-="           . text-scale-increase)
 ("M--"           . text-scale-decrease)
 ("M-0"           . (lambda () (interactive) (text-scale-set 0)))
 ;;
 ("C-}"           . forward-paragraph)
 ("C-{"           . backward-paragraph)
 ;;
 ("C-c p t"       . my/toggle-transparency)
 ("C-c p k"       . eldoc-doc-buffer)
 ("M-r"           . recenter-top-bottom)
 ("C-c f"         . find-file-at-point)
 ("C-c c"         . compile)
 ("M-o"           . delete-other-windows))


;; Leader Map
(bind-keys :prefix-map my-leader-map
           :prefix "C-z"
           ("h"     . help-command)
           ("c"     . org-capture)
           ("t"     . org-babel-tangle)
           ("s"     . org-download-clipboard)
           ("m l"   . magit-list-repositories))

;;; --------------------------------------------------------------------------
;;; UI, Theme & Fonts
;;; --------------------------------------------------------------------------

(when (fboundp 'menu-bar-mode)   (menu-bar-mode -1))
(when (fboundp 'tool-bar-mode)   (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(blink-cursor-mode -1)

;; Fonts

(defcustom my/font (font-spec :family "JetBrainsMono Nerd Font" :size 15)
  "Font for the `default' and `fixed-pitch' faces."
  :type '(restricted-sexp :match-alternatives (fontp stringp null))
  :group 'my)

(defcustom my/variable-pitch-font (font-spec :family "Dejavu Sans" :size 14)
  "Font for the `variable-pitch' face."
  :type '(restricted-sexp :match-alternatives (fontp stringp null))
  :group 'my)

(defcustom my/serif-font (font-spec :family "Noto Serif" :size 14)
  "Font for the `fixed-pitch-serif' face. Same format as `my/font'."
  :type '(restricted-sexp :match-alternatives (fontp stringp null))
  :group 'my)

(defcustom my/symbol-font (font-spec :family "Noto Sans Symbols 2")
  "Fallback font for symbol/mathematical glyphs outside `my/font'."
  :type '(restricted-sexp :match-alternatives (fontp stringp null))
  :group 'my)

(defcustom my/arabic-font (font-spec :family "Cairo" :size 15)
  "Font used specifically for the Arabic script, via `set-fontset-font'.
JetBrains Mono (and most programming fonts) either lack Arabic glyphs
entirely or render them without proper shaping; Cairo is a proper
Arabic-native font and looks right for comments, org notes, and prose."
  :type '(restricted-sexp :match-alternatives (fontp stringp null))
  :group 'my)

(defun my/init-fonts-h (&optional reload)
  (dolist (map `((default . ,my/font)
                 (fixed-pitch . ,my/font)
                 (fixed-pitch-serif . ,my/serif-font)
                 (variable-pitch . ,my/variable-pitch-font)))
    (when-let* ((face (car map))
                (font (cdr map)))
      (when (display-multi-font-p)
        (set-face-attribute face nil :width 'normal :weight 'normal
                            :slant 'normal :font font))))
  (when (and (fboundp 'set-fontset-font)
             (or reload (not (get 'my/font 'initialized))))
    ;; Nerd Fonts pack their icon glyphs into these Private Use Areas. This
    ;; registers a fallback so icon glyphs still render even in faces/modes
    ;; that aren't using the Nerd Font directly.
    (dolist (range '((#xe000 . #xf8ff) (#xf0000 . #xfffff)))
      (set-fontset-font t range "Symbols Nerd Font Mono"))
    (when my/symbol-font
      (dolist (script '(symbol mathematical))
        (set-fontset-font t script my/symbol-font)))
    (when my/arabic-font
      (set-fontset-font t 'arabic my/arabic-font)))
  (put 'my/font 'initialized t))

(defun my/reload-font ()
  "Reload fonts after changing `my/font' et al. interactively."
  (interactive)
  (my/init-fonts-h 'reload))

;; Apply once at startup, and again for every subsequent frame (relevant to
;; `emacsclient -c' / daemon workflows, where frames are created well after
;; init.el has finished running).
(if (daemonp)
    (add-hook 'server-after-make-frame-hook #'my/init-fonts-h)
  (add-hook 'emacs-startup-hook #'my/init-fonts-h))
(add-hook 'after-make-frame-functions (lambda (_frame) (my/init-fonts-h)))

(setq text-scale-mode-step 1.1)

;; Theme
;; (straight-use-package 'catppuccin-theme)
;; (setq catppuccin-flavor 'frappe)
(use-package zenburn-theme :defer t)
(use-package doom-themes)

(defvar my/theme 'gruvbox)
(load-theme my/theme t)
(require 'gruvbox-toggle)

(use-package sweet-theme
  :ensure t)

(use-package solarized-theme
  :straight t)

;;; Icons

(use-package nerd-icons
  :if (display-graphic-p))

(use-package nerd-icons-completion
  :after marginalia
  :config (nerd-icons-completion-mode 1))

;; Line numbers & Column indicator
(setq display-line-numbers-type 'relative
      display-line-numbers-width 2
      display-line-numbers-width-start t)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'conf-mode-hook #'display-line-numbers-mode)

(setq-default fill-column 80)
;; (add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

;; Modeline & Fringe
(column-number-mode 1)
(size-indication-mode 1)
(fringe-mode '(8 . 0))

;;; --------------------------------------------------------------------------
;;; Utility Functions
;;; --------------------------------------------------------------------------

;; Transparency
(defun my/toggle-transparency ()
  (interactive)
  (let ((alpha (frame-parameter nil 'alpha-background)))
    (set-frame-parameter nil 'alpha-background (if (or (null alpha) (= alpha 100)) 90 100))))

(defun my/smart-move-beginning-of-line ()
  (interactive)
  (let ((old-point (point)))
    (back-to-indentation)
    (when (= old-point (point))
      (move-beginning-of-line 1))))

(defun my/smart-open-line ()
  (interactive)
  (move-end-of-line 1)
  (newline-and-indent))

;; https://emacs.stackexchange.com/questions/22266/backspace-without-adding-to-kill-ring
(defun my/delete-word (arg)
  "Delete characters forward until encountering the end of a word.
With argument, do this that many times.
This command does not push text to `kill-ring'."
  (interactive "p")
  (delete-region
   (point)
   (progn
     (forward-word arg)
     (point))))

(defun my/backward-delete-word (arg)
  "Delete characters backward until encountering the beginning of a word.
With argument, do this that many times.
This command does not push text to `kill-ring'."
  (interactive "p")
  (my/delete-word (- arg)))

(defun my/delete-line-backward ()
  "Delete text between the beginning of the line to the cursor position.
This command does not push text to `kill-ring'."
  (interactive)
  (let (p1 p2)
    (setq p1 (point))
    (beginning-of-line 1)
    (setq p2 (point))
    (delete-region p1 p2)))

;;; --------------------------------------------------------------------------
(provide 'init)
;;; --------------------------------------------------------------------------

;;; init.el ends here
