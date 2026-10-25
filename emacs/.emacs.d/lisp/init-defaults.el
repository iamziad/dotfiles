;; -*- lexical-binding: t; -*-

(require 'use-package)
(setq use-package-always-ensure t)

(use-package no-littering
  :ensure t
  :demand t)

(use-package diminish
  :ensure t
  :demand t
  :config
  (with-eval-after-load 'which-key
    (diminish 'which-key-mode))
  (with-eval-after-load 'eldoc
    (diminish 'eldoc-mode)))

(setq make-backup-files nil
      create-lockfiles nil
      version-control t
      kept-new-versions 5
      kept-old-versions 2
      delete-old-versions t
      require-final-newline t
      vc-follow-symlinks t
      vc-allow-remote-status t)

(setq-default initial-major-mode 'org-mode
              indent-tabs-mode nil
              tab-width 4
              fill-column 100
              truncate-lines nil
              duplicate-line-final-position 1
              default-input-method "arabic")

(dolist (hook '(prog-mode-hook org-mode-hook markdown-mode-hook))
  (add-hook hook #'display-line-numbers-mode))

(setq display-line-numbers-type 'relative
      sentence-end-double-space nil
      use-short-answers t
      kill-do-not-save-duplicates t
      confirm-kill-emacs 'yes-or-no-p
      kill-ring-max 200
      mark-ring-max 32
      save-interprogram-paste-before-kill t
      select-enable-clipboard t
      mouse-yank-at-point t
      ;; Mode line
      line-number-mode t
      column-number-mode t
      x-underline-at-descent-line nil
      ;; Parens
      show-paren-delay 0
      show-paren-mode t
      show-paren-style 'parenthesis
      show-paren-context-when-offscreen 'overlay
      ;; Scroll
      scroll-preserve-screen-position 1
      scroll-conservatively 10
      scroll-margin 10
      scroll-error-top-bottom t
      auto-window-vscroll nil
      ;; Misc
      ring-bell-function 'ignore
      shell-command-prompt-show-cwd t
      inhibit-compacting-font-caches t
      frame-resize-pixelwise t
      help-window-select t
      ediff-window-setup-function #'ediff-setup-windows-plain
      large-file-warning-threshold (* 50 1024 1024))

(setq-default cursor-in-non-selected-windows nil)

(setq lazy-count-prefix-format "(%s/%s) "
      isearch-lazy-count t
      isearch-allow-motion t
      isearch-allow-scroll t
      isearch-repeat-on-direction-change t
      isearch-wrap-pause 'no-ding)

(subword-mode 1)
(blink-cursor-mode -1)
(delete-selection-mode 1)
(electric-pair-mode 1)
(show-paren-mode 1)
(winner-mode 1)
(repeat-mode 1)
(global-hl-line-mode 1)
(size-indication-mode -1)
(which-key-mode 1)
(setq show-paren-delay 0.1)
(when (boundp 'show-paren-context-when-offscreen)
  (setq show-paren-context-when-offscreen 'overlay))

(setq undo-limit (* 16 1024 1024)
      undo-strong-limit (* 32 1024 1024)
      undo-outer-limit (* 64 1024 1024))

(setq enable-recursive-minibuffers nil
      completion-ignore-case t
      read-file-name-completion-ignore-case t
      history-length 1000
      history-delete-duplicates t
      tab-always-indent 'complete)

(minibuffer-depth-indicate-mode 1)

(setq recentf-max-saved-items 200)
(recentf-mode 1)
(savehist-mode 1)
(save-place-mode 1)

(dolist (dir '("elpa" "var" ".cache" "tree-sitter"))
  (add-to-list 'recentf-exclude (expand-file-name dir user-emacs-directory)))

(global-auto-revert-mode 1)
(setq auto-revert-verbose nil
      global-auto-revert-non-file-buffers t)

(global-so-long-mode 1)

(setq read-process-output-max (* 4 1024 1024))

(setq explicit-shell-file-name (or (executable-find "bash") "/bin/sh"))

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x pgtk))
  :custom
  (exec-path-from-shell-arguments '("-l"))
  (exec-path-from-shell-variables '("PATH" "MANPATH" "JAVA_HOME"))
  :config (exec-path-from-shell-initialize))

(setq xref-search-program (if (executable-find "rg") 'ripgrep 'grep))
(setq warning-minimum-level :warning)

;;;; Emacs Lisp
(use-package rainbow-delimiters
  :hook (emacs-lisp-mode . rainbow-delimiters-mode))

;; imenu
(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (add-to-list 'imenu-generic-expression
                         '("Sections" "^;;;\\{1,4\\} \\(.+?\\)[ -]*$" 1))))


(provide 'init-defaults)
