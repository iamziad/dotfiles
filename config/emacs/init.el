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

(setq straight-use-package-by-default t
      use-package-verbose nil
      use-package-expand-minimally t)

;; Load modules
(add-to-list 'load-path (expand-file-name "modules" user-emacs-directory))
(add-to-list 'custom-theme-load-path (expand-file-name "themes" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "themes" user-emacs-directory))
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;; Manage temp files
(defvar treesit-auto-install-grammar nil)

(use-package no-littering
  :config
  (setq auto-save-file-name-transforms
        `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))))

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
  (global-whitespace-mode 1)

  :custom
  ;; Input & Files
  (initial-buffer-choice "~/Documents/org/scratch.org")
  (make-backup-files nil)
  (auto-save-default nil)
  (create-lockfiles nil)
  (backup-by-copying t)
  (version-control t)
  (delete-old-versions t)
  (large-file-warning-threshold (* 50 1024 1024))
  (vc-follow-symlinks t)

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

;;; --------------------------------------------------------------------------
;;; Keybindings
;;; --------------------------------------------------------------------------

;; Unsets
(keymap-global-unset "C-q")

;; Windmove
;; (windmove-default-keybindings 'shift)

(bind-keys
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
 ("C-a"           . my/smart-move-beginning-of-line)
 ("C-o"           . my/smart-open-line)
 ;;
 ("M-k"           . my/delete-to-end)
 ("M-DEL"         . my/backward-delete-word)
 ("M-d"           . my/forward-delete-word)
 ("<C-backspace>" . my/backward-delete-word)
 ;;
 ("C-c C-x r"     . rename-visited-file)
 ("C-c C-x d"     . delete-visited-file)
 ("C-x C-k"       . kill-buffer-and-window)
 ;;
 ("C-,"           . duplicate-dwim)
 ("C-;"           . comment-line)
 ("C-<tab>"       . mode-line-other-buffer)
 ;;
 ("C-n"           . (lambda () (interactive) (forward-line 5)))
 ("C-p"           . (lambda () (interactive) (forward-line -5)))
 ;;
 ("C-x C-="       . (lambda () (interactive) (enlarge-window-horizontally 10)))
 ("C-x C--"       . (lambda () (interactive) (shrink-window-horizontally 10)))
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
 ("M-o"           . delete-other-windows)
 ("C-c y"         . company-yasnippet))

;; Leader Map
(bind-keys :prefix-map my-leader-map
           :prefix "C-z"
           ("h"     . help-command)
           ("c"     . org-capture)
           ("t"     . org-babel-tangle)
           ("s"     . org-download-clipboard)
           ("m l"      . magit-list-repositories))

;;; --------------------------------------------------------------------------
;;; UI, Theme & Fonts
;;; --------------------------------------------------------------------------

(when (fboundp 'menu-bar-mode)   (menu-bar-mode -1))
(when (fboundp 'tool-bar-mode)   (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(blink-cursor-mode -1)

;; Fonts
(defvar my/font-family "JetBrainsMono Nerd Font")
(defvar my/font-size 110)

(defun my/apply-fonts (&optional frame)
  (when (display-graphic-p frame)
    (set-face-attribute 'default frame :family my/font-family :height my/font-size :weight 'normal)
    (set-face-attribute 'fixed-pitch frame :family my/font-family :height my/font-size :weight 'normal)
    (set-face-attribute 'variable-pitch frame :family "PlaywriteGBJ" :height 120)
    (set-fontset-font t 'arabic (font-spec :family "Cairo" :size 15) frame)))

(my/apply-fonts)
(if (daemonp)
    (add-hook 'server-after-make-frame-hook #'my/apply-fonts)
  (add-to-list 'default-frame-alist (cons 'font (format "%s-%d" my/font-family (/ my/font-size 10)))))

;; Theme
(use-package zenburn-theme :defer t)
(use-package doom-themes :defer t)
(straight-use-package 'catppuccin-theme)
(setq catppuccin-flavor 'frappe)
(defvar my/theme 'gruvbox)
(load-theme my/theme t)
(require 'gruvbox-toggle)

;; Line numbers & Column indicator
(setq display-line-numbers-type 'relative
      display-line-numbers-width 2
      display-line-numbers-width-start t)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'conf-mode-hook #'display-line-numbers-mode)

(setq-default fill-column 80)
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

;; Modeline & Fringe
(column-number-mode 1)
(size-indication-mode 1)
(fringe-mode '(8 . 0))

;;; --------------------------------------------------------------------------
;;; Dired
;;; --------------------------------------------------------------------------

(require 'dired-x)

(use-package image-dired
  :ensure nil
  :config
  (setq image-dired-thumbnail-storage 'standard))
;; :bind (:map dired-mode-map
;;             ("C-d i" . image-dired)))

(defun my/dired-open-xdg ()
  (interactive)
  (let ((file (dired-get-file-for-visit)))
    (call-process "xdg-open" nil 0 nil file)))

(with-eval-after-load 'dired
  (keymap-set dired-mode-map "o" #'my/dired-open-xdg)
  (setq dired-omit-files (concat dired-omit-files "\\|^\\..+$"))
  (setq-default dired-dwim-target t)
  (setq dired-listing-switches "-alh --group-directories-first"
        dired-mouse-drag-files t))

(defun my/sudo-this-file ()
  (interactive)
  (if (file-remote-p buffer-file-name)
      (find-alternate-file
       (tramp-file-name-localname
        (tramp-dissect-file-name buffer-file-name)))
    (find-alternate-file
     (concat "/sudo::" buffer-file-name))))

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

(defun my/backward-delete-word ()
  (interactive)
  (let ((limit (line-beginning-position)))
    (if (> (point) limit)
        (let ((end (point)))
          (subword-backward 1)
          (when (< (point) limit) (goto-char limit))
          (delete-region (point) end))
      (delete-char -1))))

(defun my/forward-delete-word ()
  (interactive)
  (delete-region (point) (progn (forward-word 1) (point))))

(defun my/delete-to-end ()
  (interactive)
  (if (= (point) (line-end-position))
      (unless (eobp) (delete-char 1))
    (delete-region (point) (line-end-position))))

;;; --------------------------------------------------------------------------
(provide 'init)
;;; --------------------------------------------------------------------------

;;; init.el ends here
