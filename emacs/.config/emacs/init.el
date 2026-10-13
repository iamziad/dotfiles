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

;; Load modules
;; (add-to-list 'custom-theme-load-path (expand-file-name "themes" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "modules" user-emacs-directory))
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

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
  (setq default-input-method "arabic")

  ;; Aliases & Keymaps
  (defalias 'yes-or-no-p 'y-or-n-p)
  (global-set-key [remap dabbrev-expand] #'hippie-expand)

  (setq auto-revert-use-notify t)
  (setq whitespace-global-modes '(prog-mode))
  (setq eshell-banner-message "")

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
  (scroll-margin 0)
  (scroll-conservatively 100000)
  (scroll-preserve-screen-position 1)

  (isearch-allow-scroll t)
  (isearch-wrap-pause 'no-ding)
  (isearch-lazy-count t)
  (lazy-count-prefix-format "(%s/%s) ")
  (pixel-scroll-mode)
  (image-use-external-converter t)

  ;; Eldoc
  (eldoc-echo-area-use-multiline-p nil)
  (eldoc-display-functions '(eldoc-display-in-echo-area))

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

;; Built-in modes, enabled after init.
(dolist (mode '(recentf-mode
                savehist-mode
                save-place-mode
                global-auto-revert-mode
                delete-selection-mode
                electric-pair-mode
                electric-indent-mode
                global-subword-mode
                repeat-mode
                winner-mode
                global-so-long-mode
                column-number-mode
                size-indication-mode
                minibuffer-depth-indicate-mode
                show-paren-mode
                which-key-mode
                context-menu-mode))
  (add-hook 'after-init-hook mode))

(require 'so-long)
(setq so-long-variable-overrides
      (append '((truncate-lines . t)
                (bidi-inhibit-bpa . t)
                (line-move-visual . nil))
              so-long-variable-overrides)
      so-long-minor-modes
      (append '(font-lock-mode
                display-line-numbers-mode
                hl-line-mode
                show-paren-mode)
              so-long-minor-modes))


;; Tabs
(setq tab-bar-show 1)

;;; --------------------------------------------------------------------------
;;; Keybindings
;;; --------------------------------------------------------------------------

(bind-keys
 ("C-/"           . undo-only)
 ("C-?"           . undo-redo)
 ("M-j"           . recenter-top-bottom)
 ("C-c C-f"       . find-file-other-window)
 ;; Compile & run
 ("C-c r"         . recompile)
 ("C-c c"         . compile)
 ;; Windows, buffers, tabs
 ("C-x C-k"       . kill-buffer-and-window)
 ("C-<tab>"       . mode-line-other-buffer)
 ;; Editing
 ("C-a"           . crux-move-beginning-of-line)
 ("C-,"           . duplicate-dwim)
 ("C-<backspace>" . my/backward-delete-word)
 ("M-d"           . my/delete-word)
 ("C-c f"         . find-file-at-point)
 ;; Paragraphs
 ("C-n"           . forward-paragraph)
 ("C-p"           . backward-paragraph)
 ;; Tabs
 ("C-x t h"           . tab-previous)
 ("C-x t l"           . tab-next))

(use-package crux
  :bind (("M-k"          . crux-kill-whole-line)
         ("C-^"          . crux-top-join-line)
         ("C-c n"        . crux-cleanup-buffer-or-region)
         ("C-c K"        . crux-kill-other-buffers)
         ("C-c U"        . crux-reopen-as-root)
         ("C-c C-x r"    . crux-rename-file-and-buffer)
         ("C-c C-x d"    . crux-delete-file-and-buffer)))

(use-package smartparens
  :hook (web-mode . smartparens-mode)
  :config
  (require 'smartparens-config)

  ;; ERB/EJS-style template tags
  (sp-with-modes '(web-mode)
                 (sp-local-pair "%" "%"
                                :unless '(sp-in-string-p)
                                :post-handlers '(((lambda (&rest _ignored)
                                                    (just-one-space)
                                                    (save-excursion (insert " ")))
                                                  "SPC" "=" "#")))
                 (sp-local-tag "%" "<% "  " %>")
                 (sp-local-tag "=" "<%= " " %>")
                 (sp-local-tag "#" "<%# " " %>"))

  :bind
  ("C-c s r"   . sp-rewrap-sexp)
  ("C-c s u"   . sp-unwrap-sexp)
  ("C-c s w r" . sp-wrap-round)
  ("C-c s w c" . sp-wrap-curly)
  ("C-c s w s" . sp-wrap-square)
  ("C-c s c"   . sp-change-inner)
  ("M-m"       . sp-delete-sexp))

;; Leader
(bind-keys :prefix-map my-leader-map
           :prefix "C-z"
           ("h"   . help-command)
           ("c"   . org-capture)
           ("t"   . org-babel-tangle)
           ("s"   . org-download-clipboard)
           ("m l" . magit-list-repositories)
           ("r"   . my/quick-mark)
           ("j"   . my/quick-jump))

;;; --------------------------------------------------------------------------
;;; UI, Theme & Fonts
;;; --------------------------------------------------------------------------

(when (fboundp 'menu-bar-mode)   (menu-bar-mode -1))
(when (fboundp 'tool-bar-mode)   (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(blink-cursor-mode -1)

;; Fonts
(set-face-attribute 'default nil
                    :family "FiraCode Nerd Font Mono"
                    :height 120)
(set-face-attribute 'fixed-pitch nil
                    :family "FiraCode Nerd Font Mono"
                    :height 120)
(set-face-attribute 'fixed-pitch-serif nil
                    :family "Noto Serif"
                    :height 120)
(set-face-attribute 'variable-pitch nil
                    :family "Noto Sans"
                    :height 120)

(defun my/setup-arabic-font (&optional frame)
  (let ((frame (or frame (selected-frame))))
    (when (display-graphic-p frame)
      (with-selected-frame frame
        (set-fontset-font t 'arabic (font-spec :family "" :size 20))))))

(if (daemonp)
    (add-hook 'after-make-frame-functions #'my/setup-arabic-font)
  (my/setup-arabic-font))

(setq text-scale-mode-step 1.1)

;; Theme
;; (defvar my/theme 'gruvbox)
;; (use-package zenburn-theme :demand t)
;; (condition-case _err
;;     (load-theme my/theme t)
;;   (error (load-theme 'zenburn t)))


(use-package doom-themes
  :ensure t
  :config
  (defun my/apply-custom-faces ()
    (custom-set-faces
     `(font-lock-misc-punctuation-face
       ((t (:foreground ,(doom-color 'orange)))))))

  (defun my/load-theme (theme)
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme theme t)
    (my/apply-custom-faces))

  (defun toggle-theme (&optional mode)
    "Switch theme. MODE can be `light', `dark', or nil to toggle."
    (interactive)
    (my/load-theme
     (pcase mode
       ('light 'doom-gruvbox-light)
       ('dark  'doom-gruvbox)
       (_ (if (member 'doom-gruvbox custom-enabled-themes)
              'doom-gruvbox-light
            'doom-gruvbox)))))

  (my/load-theme 'doom-gruvbox))

;; Line numbers & Column indicator
(setq display-line-numbers-type 'relative
      display-line-numbers-width 2
      display-line-numbers-width-start t)
(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'conf-mode-hook #'display-line-numbers-mode)

;; (setq-default fill-column 100)
;; (add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

;; Modeline & Fringe
(column-number-mode 1)
(size-indication-mode 1)

;;; --------------------------------------------------------------------------
;;; Utility Functions
;;; --------------------------------------------------------------------------

;; https://emacs.stackexchange.com/questions/22266/backspace-without-adding-to-kill-ring
(defun my/delete-word (arg)
  "Delete forward to the end of a word, without touching `kill-ring'."
  (interactive "p")
  (delete-region (point) (progn (forward-word arg) (point))))

(defun my/backward-delete-word (arg)
  "Delete backward to the start of a word, without touching `kill-ring'."
  (interactive "p")
  (my/delete-word (- arg)))

(defun my/delete-line-backward ()
  "Delete from line start to point, without touching `kill-ring'."
  (interactive)
  (let ((p1 (point)))
    (beginning-of-line 1)
    (delete-region (point) p1)))

(defun my/quick-mark (char)
  "Save current position in register CHAR."
  (interactive (list (read-char "Mark to register: ")))
  (point-to-register char)
  (message "Saved to register %c" char))

(defun my/quick-jump (char)
  "Jump to the position stored in register CHAR."
  (interactive (list (read-char "Jump to register: ")))
  (jump-to-register char))

(defun my/set-font (family size)
  "Pick an installed font family and size, apply immediately."
  (interactive
   (list (completing-read "Font family: " (font-family-list))
         (read-number "Size (pt): " 12)))
  (set-face-attribute 'default nil :family family :height (* size 10)))

;;; --------------------------------------------------------------------------
(provide 'init)
;;; --------------------------------------------------------------------------

;;; init.el ends here
