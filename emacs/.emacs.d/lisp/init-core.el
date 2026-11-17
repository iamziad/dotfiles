;;; init-core.el --- Core and built-in modes -*- lexical-binding: t; -*-

(require 'subr-x)

;;; State directories ---------------------------------------------------------

(use-package no-littering
  :ensure t
  :demand t)
(elpaca-wait)

;;; External tools ------------------------------------------------------------

(defun my/add-to-exec-path (directory)
  "Add DIRECTORY to `exec-path' and PATH when it exists."
  (when (and directory (file-directory-p directory))
    (unless (member directory exec-path)
      (setq exec-path (append exec-path (list directory))))
    (let ((path (getenv "PATH")))
      (unless (member directory (split-string path ":" t))
        (setenv "PATH" (concat path ":" directory))))))

;;; Garbage collection --------------------------------------------------------

(use-package diminish
  :ensure t
  :demand t
  :config
  (with-eval-after-load 'which-key (diminish 'which-key-mode))
  (with-eval-after-load 'eldoc (diminish 'eldoc-mode))
  (with-eval-after-load 'whitespace (diminish 'whitespace-mode))
  (with-eval-after-load 'abbrev (diminish 'abbrev-mode))
  (with-eval-after-load 'subword (diminish 'subword-mode)))

(use-package gcmh
  :ensure t
  :diminish gcmh-mode
  :init
  (setq gcmh-idle-delay 5
        gcmh-high-cons-threshold (* 100 1024 1024)
        gc-cons-percentage 0.1)
  :hook (emacs-startup . gcmh-mode))

;;; Files and backups ---------------------------------------------------------

(setq create-lockfiles nil
      make-backup-files nil
      auto-save-default t
      auto-save-timeout 20
      auto-save-interval 200
      delete-by-moving-to-trash t)

;;; Interaction ---------------------------------------------------------------

(setq use-dialog-box nil
      use-file-dialog nil
      use-short-answers t
      ring-bell-function 'ignore
      x-gtk-use-system-tooltips nil
      help-window-select t
      echo-keystrokes 0.02
      suggest-key-bindings 5
      enable-recursive-minibuffers t
      large-file-warning-threshold (* 100 1024 1024)
      confirm-kill-processes nil
      kill-ring-max 200
      mark-ring-max 32
      set-mark-command-repeat-pop t
      mouse-yank-at-point t
      scroll-preserve-screen-position t
      scroll-margin 2
      scroll-conservatively 101
      scroll-step 1
      auto-window-vscroll nil
      fast-but-imprecise-scrolling t
      vc-follow-symlinks t
      warning-minimum-level :error
      initial-major-mode 'fundamental-mode
      read-process-output-max (* 1024 1024))

;;; Editing defaults ----------------------------------------------------------

(setq-default indent-tabs-mode nil
              tab-width 4
              standard-indent 4
              fill-column 100
              require-final-newline t
              sentence-end-double-space nil
              truncate-lines nil
              word-wrap t
              cursor-in-non-selected-windows nil
              case-fold-search t
              tab-always-indent 'complete
              indicate-empty-lines nil
              default-input-method "arabic"
              duplicate-line-final-position 1
              duplicate-region-final-position 1)

(setq show-paren-style 'parenthesis
      electric-pair-preserve-balance t
      electric-pair-delete-adjacent-pairs t
      blink-matching-paren t)

(prefer-coding-system 'utf-8)

;;; Built-in modes ------------------------------------------------------------

(setq global-auto-revert-non-file-buffers t)
(delete-selection-mode 1)
(electric-pair-mode 1)
(show-paren-mode 1)
(winner-mode 1)
(repeat-mode 1)
(column-number-mode 1)
(which-key-mode 1)
(global-auto-revert-mode 1)

;;; Search behaviour ----------------------------------------------------------

(setq isearch-lazy-count t
      lazy-count-prefix-format nil
      lazy-count-suffix-format " (%s/%s)"
      isearch-allow-motion t
      isearch-allow-scroll t
      isearch-wrap-pause 'no-ding
      isearch-repeat-on-direction-change t)

;;; Recent files, history and places -----------------------------------------

(use-package recentf
  :defer 2
  :config
  (add-to-list 'recentf-exclude "^/\\(?:ssh\\|su\\|sudo\\)?:")
  (add-to-list 'recentf-exclude no-littering-var-directory)
  (setq recentf-max-saved-items 500
        recentf-max-menu-items 15
        ;; disable recentf-cleanup on Emacs start, because it can cause
        ;; problems with remote files
        recentf-auto-cleanup 'never)
  (recentf-mode))

(setq history-length 500
      savehist-autosave-interval 30
      savehist-additional-variables
      '(extended-command-history
        command-history
        search-ring
        regexp-search-ring
        kill-ring
        corfu-history
        consult-history))

(savehist-mode 1)
(save-place-mode 1)

;;; Xref and imenu

(setq xref-search-program (if (executable-find "rg") 'ripgrep 'grep))
(setq imenu-auto-rescan t
      imenu-max-items 200)

;;; Diffs and grep ------------------------------------------------------------

(setq ediff-window-setup-function #'ediff-setup-windows-plain
      ediff-split-window-function #'split-window-horizontally
      diff-font-lock-prettify t
      grep-highlight-matches 'auto)

(provide 'init-core)
;;; init-core.el ends here
