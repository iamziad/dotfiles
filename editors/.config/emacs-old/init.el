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
(require 'use-package)

(setq straight-vc-git-default-protocol 'https)
(setq straight-use-package-by-default t)
(setq native-comp-async-report-warnings-errors 'silent)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(dolist (dir (directory-files (expand-file-name "lisp" user-emacs-directory) t "^[^.]" t))
  (when (file-directory-p dir)
    (add-to-list 'load-path dir)))

(require 'pomodoro nil t)

(use-package no-littering
  :ensure t
  :config
  (setq auto-save-file-name-transforms
        `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))))

(use-package emacs
  :init
  (defalias 'yes-or-no-p 'y-or-n-p)
  (global-set-key [remap dabbrev-expand] #'hippie-expand)

  (setq custom-file (expand-file-name "custom.el" user-emacs-directory))
  (when (file-exists-p custom-file)
    (load custom-file t))

  (fringe-mode '(10 . 10))

  (setq
   scroll-margin 5
   scroll-conservatively 10
   scroll-preserve-screen-position t)

  (save-place-mode 1)
  (column-number-mode t)
  (recentf-mode t)
  (savehist-mode t)
  (winner-mode 1)
  (delete-selection-mode 1)
  (global-auto-revert-mode t)
  (xterm-mouse-mode t)
  (auto-save-visited-mode t)
  (global-visual-line-mode t)
  (electric-pair-mode t)
  (electric-indent-mode nil)
  (global-whitespace-mode t)
  (blink-cursor-mode 0)

  :custom
  (duplicate-line-final-position 1)
  (isearch-allow-scroll t)
  (global-auto-revert-non-file-buffers t)
  (switch-to-buffer-obey-display-actions t)
  (tab-always-indent 'complete)
  (whitespace-style '(face tabs tab-mark trailing))
  (isearch-wrap-pause 'no-ding)
  (vc-follow-symlinks t)
  (use-dialog-box nil)
  (help-window-select t)
  (use-short-answers t)
  (confirm-kill-emacs 'yes-or-no-p)
  (select-enable-clipboard t)
  (select-enable-primary t)
  (select-active-regions nil)
  (display-line-numbers-width 2)
  (initial-buffer-choice "~/Documents/org/scratch.org")
  (default-input-method "arabic")

  ;; Minibuffer & Completion Defaults
  (context-menu-mode t)
  (enable-recursive-minibuffers t)
  (read-extended-command-predicate #'command-completion-default-include-p)
  (minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt))
  (text-mode-ispell-word-completion nil)

  :hook
  (before-save . delete-trailing-whitespace)
  (isearch-mode-end-hook . (lambda ()
                             (when (and isearch-forward (not isearch-mode-end-hook-quit))
                               (goto-char isearch-other-end)))))

(use-package recentf
  :ensure nil
  :config
  (setq recentf-auto-cleanup 'never
        recentf-max-menu-items 0
        recentf-max-saved-items 200
        recentf-filename-handlers (append '(abbreviate-file-name) recentf-filename-handlers)))

;; Tabs Setup
(setq tab-bar-show 1)
(dotimes (i 9)
  (global-set-key
   (kbd (format "M-%d" (1+ i)))
   `(lambda () (interactive) (tab-bar-select-tab ,(1+ i)))))

(use-package minions
  :ensure t
  :config
  (setq minions-prominent-modes '(olivetti-mode flymake-mode lsp-mode))
  (minions-mode 1))

(use-package ace-window
  :ensure t
  :bind ("M-o" . ace-window)
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

(use-package buffer-move
  :ensure t
  :bind (:map my-leader-map
              ("w k" . buf-move-up)
              ("w j" . buf-move-down)
              ("w h" . buf-move-left)
              ("w l" . buf-move-right)))

(defvar my-nav-map (make-sparse-keymap))
(define-key my-nav-map (kbd "C-h") #'backward-char)
(define-key my-nav-map (kbd "C-j") #'next-line)
(define-key my-nav-map (kbd "C-k") #'previous-line)
(define-key my-nav-map (kbd "C-l") #'forward-char)
(define-key my-nav-map (kbd "C-f") #'forward-word)
(define-key my-nav-map (kbd "C-b") #'backward-word)

(define-minor-mode my-nav-mode
  "Custom navigation mode."
  :lighter ""
  :keymap my-nav-map)

(defvar my-nav-excluded-modes
  '(term-mode vterm-mode shell-mode comint-mode))

(defun my-nav-mode--maybe-enable ()
  (unless (or (minibufferp)
              (apply #'derived-mode-p my-nav-excluded-modes))
    (my-nav-mode 1)))

(define-globalized-minor-mode global-my-nav-mode my-nav-mode my-nav-mode--maybe-enable)
(global-my-nav-mode 1)

(defun my-setup-minibuffer-navigation ()
  (local-set-key (kbd "C-p") #'previous-history-element)
  (local-set-key (kbd "C-n") #'next-history-element)
  (local-set-key (kbd "C-h") #'backward-char)
  (local-set-key (kbd "C-l") #'forward-char))

(add-hook 'minibuffer-setup-hook #'my-setup-minibuffer-navigation)

(with-eval-after-load 'magit
  (define-key magit-hunk-section-map (kbd "C-j") nil)
  (define-key magit-diff-section-base-map (kbd "C-j") nil)
  (define-key magit-file-section-map (kbd "C-j") nil)
  (define-key magit-diff-mode-map (kbd "C-j") nil))

(use-package crux
  :ensure t
  :bind (("C-a"     . crux-move-beginning-of-line)
         ("C-c o"   . crux-smart-open-line)
         ("C-c d d" . crux-duplicate-current-line-or-region)
         ("C-c d c" . crux-duplicate-and-comment-current-line-or-region)
         ("C-c D"   . crux-delete-file-and-buffer)
         ("C-c r"   . crux-rename-file-and-buffer)))

(bind-keys
 ("C-,"        . duplicate-line)
 ("C-<tab>"    . mode-line-other-buffer)
 ("C-n"        . (lambda () (interactive) (forward-line 5)))
 ("C-p"        . (lambda () (interactive) (forward-line -5)))
 ("M-n"        . recenter-top-bottom)
 ("C-x C-="    . (lambda () (interactive) (enlarge-window-horizontally 10)))
 ("C-x C--"    . (lambda () (interactive) (shrink-window-horizontally 10)))
 ("M-="        . text-scale-increase)
 ("M--"        . text-scale-decrease)
 ("M-0"        . (lambda () (interactive) (text-scale-set 0)))
 ("C-}"        . forward-paragraph)
 ("C-{"        . backward-paragraph)
 ("C-c f"      . find-file-at-point)
 ("C-c k"      . eldoc-doc-buffer)
 ("C-c c"      . compile)
 ("C-c g g"    . grep)
 ("C-c w"      . delete-other-windows)
 ("C-c d s"    . my/sudo-this-file)
 ("C-c d f"    . my/dired-home)
 ("C-c p t u"  . my/pdf-tmp-url)
 ("C-c p u"    . my/pdf-url))

(bind-keys :prefix-map my-leader-map
           :prefix "C-z"
           ("h"     . help-command)
           ("c"     . org-capture)
           ("t"     . org-babel-tangle)
           ("p p s" . my/pomodoro-start)
           ("p p q" . my/pomodoro-stop)
           ("m l"   . magit-list-repositories))

(require 'subword)

(defun my/delete-selected ()
  (interactive)
  (if (use-region-p)
      (delete-region (region-beginning) (region-end))
    (delete-char -1)))

(defun my/delete-smart-to-end ()
  (interactive)
  (if (= (point) (line-end-position))
      (unless (eobp) (delete-char 1))
    (delete-region (point) (line-end-position))))

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

(bind-keys
 ("M-k"           . my/delete-smart-to-end)
 ("DEL"           . my/delete-selected)
 ("M-DEL"         . my/backward-delete-word)
 ("M-d"           . my/forward-delete-word)
 ("<C-backspace>" . my/backward-delete-word))

(use-package multiple-cursors
  :ensure t
  :bind (("C->"     . mc/mark-next-like-this)
         ("C-<"     . mc/mark-previous-like-this)
         ("C-M-<"   . mc/skip-to-previous-like-this)
         ("C-M->"   . mc/skip-to-next-like-this)
         ("C-c m d" . mc/mark-all-dwim)
         ("C-c m a" . mc/mark-all-like-this)
         ("C-c m n" . electric-newline-and-maybe-indent)
         ("C-c m e" . mc/edit-lines))
  :config
  (setq mc/always-run-for-all t))

(use-package expand-region
  :ensure t
  :bind (("C-=" . er/expand-region)
         ("C--" . er/contract-region)))

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

(setq-default line-spacing 0.12)

(setq-default fill-column 80)
(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

(defun my/toggle-transparency ()
  (interactive)
  (let ((alpha (frame-parameter nil 'alpha-background)))
    (set-frame-parameter nil 'alpha-background (if (or (null alpha) (= alpha 100)) 90 100))))

(global-set-key (kbd "C-c a t") #'my/toggle-transparency)

(use-package vertico
  :ensure t
  :init (vertico-mode)
  :bind (:map vertico-map
              ("C-j" . vertico-next)
              ("C-k" . vertico-previous))
  :custom
  (vertico-resize t)
  (vertico-cycle  t)
  (vertico-scroll-margin 0))

(use-package marginalia
  :ensure t
  :init (marginalia-mode))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package company
  :ensure t
  :hook (after-init . global-company-mode)
  :custom
  (company-idle-delay 0.2)
  (company-minimum-prefix-length 1)
  (company-tooltip-maximum-width 60)
  (company-tooltip-minimum-width 20)
  (company-tooltip-width-grow-only t)
  :bind (:map company-active-map
              ("C-j" . company-select-next)
              ("C-k" . company-select-previous)))

(use-package yasnippet
  :ensure t
  :config
  (setq yas-snippet-dirs '("~/.config/emacs/snippets"))
  (yas-global-mode 1))

(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown")
  :bind (:map markdown-mode-map
              ("C-c C-m C-d" . markdown-do))
  :hook (markdown-mode . variable-pitch-mode))

(require 'dired-x)

(use-package image-dired
  :ensure nil
  :config
  (setq image-dired-thumbnail-storage 'standard)
  :bind (:map dired-mode-map
              ("C-t d" . image-dired)))

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
  (when buffer-file-name (find-alternate-file (concat "/sudo::" buffer-file-name))))

(defun my/dired-home ()
  (interactive)
  (dired "~"))

(setq-default indent-tabs-mode nil
              tab-width 4
              standard-indent 4
              c-basic-offset 4
              js-indent-level 2
              css-indent-offset 2)

(use-package make-mode
  :ensure nil
  :hook (makefile-mode . (lambda ()
                            (setq indent-tabs-mode t
                                  tab-width 4))))

(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

(use-package apheleia
  :ensure t
  :config
  (apheleia-global-mode +1)
  (setf (alist-get 'typescript-ts-mode apheleia-mode-alist) 'prettier)
  (setf (alist-get 'tsx-ts-mode apheleia-mode-alist)        'prettier)
  (setf (alist-get 'html-ts-mode apheleia-mode-alist)       'prettier)
  (setf (alist-get 'css-ts-mode apheleia-mode-alist)        'prettier)
  (setf (alist-get 'json-ts-mode apheleia-mode-alist)       'prettier)
  (setf (alist-get 'bash-ts-mode apheleia-mode-alist)       'shfmt)
  (setf (alist-get 'c-ts-mode apheleia-mode-alist)          'clang-format)
  (setf (alist-get 'c++-ts-mode apheleia-mode-alist)        'clang-format))

(use-package treesit
  :straight nil
  :mode (("\\.js\\'"            . typescript-ts-mode)
         ("\\.mjs\\'"           . typescript-ts-mode)
         ("\\.ts\\'"            . typescript-ts-mode)
         ("\\.tsx?\\'"          . tsx-ts-mode)
         ("\\.jsx?\\'"          . tsx-ts-mode)
         ("CMakeLists\\.txt\\'" . cmake-ts-mode)
         ("\\.cmake\\'"         . cmake-ts-mode)
         ("\\.dockerfile\\'"    . dockerfile-ts-mode)
         ("Dockerfile\\'"       . dockerfile-ts-mode)
         ("\\.go\\'"            . go-ts-mode)
         ("/go\\.mod\\'"        . go-mod-ts-mode)
         ("\\.ya?ml\\'"         . yaml-ts-mode))

  :preface
  (defun my/setup-install-grammars ()
    (interactive)
    (dolist (grammar
             '((c "https://github.com/tree-sitter/tree-sitter-c" "v0.24.1")
               (cpp "https://github.com/tree-sitter/tree-sitter-cpp")
               (python "https://github.com/tree-sitter/tree-sitter-python")
               (java "https://github.com/tree-sitter/tree-sitter-java")
               (javascript "https://github.com/tree-sitter/tree-sitter-javascript")
               (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
               (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
               (json "https://github.com/tree-sitter/tree-sitter-json")
               (html "https://github.com/tree-sitter/tree-sitter-html")
               (bash "https://github.com/tree-sitter/tree-sitter-bash")
               (go "https://github.com/tree-sitter/tree-sitter-go")
               (gomod "https://github.com/camdencheek/tree-sitter-go-mod")
               (yaml "https://github.com/ikatyang/tree-sitter-yaml")
               (cmake "https://github.com/uyha/tree-sitter-cmake")
               (make "https://github.com/tree-sitter-grammars/tree-sitter-make")
               (dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile")
               (css "https://github.com/tree-sitter/tree-sitter-css")
               (markdown "https://github.com/tree-sitter-grammars/tree-sitter-markdown" "split_parser" "tree-sitter-markdown/src")
               (markdown-inline "https://github.com/tree-sitter-grammars/tree-sitter-markdown" "split_parser" "tree-sitter-markdown-inline/src")))
      (add-to-list 'treesit-language-source-alist grammar)
      (unless (treesit-language-available-p (car grammar))
        (treesit-install-language-grammar (car grammar)))))

  (dolist (mapping
           '((c-mode          . c-ts-mode)
             (c++-mode        . c++-ts-mode)
             (c-or-c++-mode   . c-or-c++-ts-mode)
             (python-mode     . python-ts-mode)
             (java-mode       . java-ts-mode)
             (js-mode         . typescript-ts-mode)
             (typescript-mode . typescript-ts-mode)
             (json-mode       . json-ts-mode)
             (sh-mode         . bash-ts-mode)
             (bash-mode       . bash-ts-mode)
             (html-mode       . html-ts-mode)
             (mhtml-mode       . html-ts-mode)
             (css-mode        . css-ts-mode)
             (makefile-mode   . makefile-ts-mode)))
    (add-to-list 'major-mode-remap-alist mapping))

  :config
  (my/setup-install-grammars))

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook ((c-ts-mode          . lsp-deferred)
         (c++-ts-mode        . lsp-deferred)
         (java-ts-mode       . lsp-deferred)
         (typescript-ts-mode . lsp-deferred)
         (tsx-ts-mode        . lsp-deferred)
         (html-ts-mode       . lsp-deferred)
         (css-ts-mode        . lsp-deferred)
         (go-ts-mode         . lsp-deferred)
         (bash-ts-mode       . lsp-deferred))
  :init
  (setq lsp-keymap-prefix "C-c l")
  :custom
  (lsp-diagnostics-provider :flymake)
  (lsp-completion-provider :capf)
  (lsp-headerline-breadcrumb-enable nil)
  :bind (:map lsp-mode-map
              ("M-."     . lsp-find-definition)
              ("M-,"     . lsp-find-references)
              ("C-c l r" . lsp-rename)
              ("M-RET"   . lsp-execute-code-action)
              ("C-c l f" . lsp-format-buffer)
              ("C-c l b" . lsp-headerline-breadcrumb-mode)))

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-delay 0.3)
  (lsp-ui-sideline-show-hover nil)
  :bind (:map lsp-ui-mode-map
              ("C-c l k" . lsp-ui-doc-glance)))

(use-package lsp-java
  :ensure t
  :after lsp-mode)

(use-package flymake
  :hook (prog-mode . flymake-mode)
  :bind
  (("M-n"     . flymake-goto-next-error)
   ("M-p"     . flymake-goto-prev-error)
   ("C-c ! l" . flymake-show-buffer-diagnostics)
   ("C-c ! p" . flymake-show-project-diagnostics)))

(defun my/project-try-local-root (dir)
  (let ((root (or (locate-dominating-file dir "pom.xml")
                  (locate-dominating-file dir "package.json"))))
    (and root (cons 'transient root))))

(with-eval-after-load 'project
  (add-to-list 'project-find-functions #'my/project-try-local-root))

(use-package emmet-mode
  :ensure t
  :hook ((html-ts-mode web-mode css-ts-mode sgml-mode css-mode) . emmet-mode)
  :config
  (setq emmet-move-cursor-between-quotes t)
  (define-key emmet-mode-keymap (kbd "TAB") 'emmet-expand-line)
  (with-eval-after-load 'emmet-mode
    (define-key emmet-mode-keymap (kbd "C-j") nil)))

(setq org-hide-leading-stars t
      org-ellipsis " ▾"
      org-hide-emphasis-markers t
      org-src-tab-acts-natively t
      org-src-fontify-natively t
      org-src-preserve-indentation t
      org-pretty-entities t
      org-preview-latex-default-process 'dvisvgm
      org-startup-with-latex-preview t
      org-log-done 'note
      org-format-latex-options (plist-put org-format-latex-options :scale 1.4))

(with-eval-after-load 'org
  (require 'org-tempo))

(add-hook 'org-mode-hook
          (lambda ()
            (visual-line-mode 1)
            (electric-pair-local-mode -1)
            (org-indent-mode 1)))

;; Babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t) (C . t) (shell . t) (java . t) (js . t)))

(setq org-confirm-babel-evaluate nil
      python-shell-completion-native-enable nil
      org-src-window-setup 'current-window)

;; Org Capture
(add-to-list 'display-buffer-alist
             '("\\*Org Select\\*\\|CAPTURE"
               (display-buffer-below-selected)
               (window-height . 0.6)))

(setq org-directory "~/Documents/org")

(setq org-capture-templates
      `(("a" "Anki Card" entry
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

(use-package olivetti
  :defer t
  :init
  (setq olivetti-body-width 90
        olivetti-recall-visual-line-mode-entry-state t)
  :hook
  (eww-mode . olivetti-mode))

(use-package anki-editor
  :straight (anki-editor :type git :host github :repo "louietan/anki-editor"))

(defun my/anki-push-after-capture ()
  (let ((file (expand-file-name "/tmp/anki.org")))
    (when (file-exists-p file)
      (with-current-buffer (find-file-noselect file)
        (condition-case err
            (progn
              (anki-editor-push-notes)
              (message "Anki: flashcard pushed successfully!"))
          (error (message "Anki: failed to push — %s" (error-message-string err))))))))

(add-hook 'org-capture-after-finalize-hook #'my/anki-push-after-capture)

(use-package toc-org
  :straight (:host github :repo "iamziad/toc-org" :branch "toc-side-window" :files ("*.el"))
  :commands toc-org-enable
  :bind (:map my-leader-map ("o" . toc-org-navigation-pane))
  :config
  (setq toc-org-side-window-side 'left
        toc-org-side-window-size '40)
  :init
  (add-hook 'markdown-mode-hook #'toc-org-enable)
  (add-hook 'org-mode-hook #'toc-org-enable))

(use-package org-download
  :defer t
  :bind (:map org-mode-map ("C-c s" . org-download-clipboard))
  :config
  (setq-default org-download-heading-lvl nil
                org-download-image-dir "./images"))

(use-package magit
  :ensure t
  :after transient
  :commands (magit-status)
  :hook ((magit-mode git-commit-mode) . (lambda () (variable-pitch-mode -1)))
  :bind (("C-x g" . magit-status)
         ("C-x v" . magit-diff-visit-file-other-window)))

(setq magit-repository-directories '(("~/Dotfiles/" . 0) ("~/Projects"  . 2)))

(use-package diff-hl
  :ensure t
  :config
  (global-diff-hl-mode 1)
  (setq diff-hl-fringe-bmp-function #'diff-hl-fringe-bmp-from-type)
  (diff-hl-show-hunk-mouse-mode)
  (diff-hl-flydiff-mode 1)
  (add-hook 'magit-pre-refresh-hook  'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
  (add-hook 'dired-mode-hook 'diff-hl-dired-mode))

(use-package eww
  :defer t
  :config
  (setq browse-url-handlers
        '(("wikipedia\\.org" . eww-browse-url)
          ("github"          . browse-url-default-browser)
          ("youtube.com"     . browse-url-default-browser)
          ("reddit.com"      . browse-url-default-browser)))

  (setq shr-use-colors nil
        shr-use-fonts nil
        shr-max-image-proportion 0.6
        shr-image-animate nil
        shr-width fill-column
        shr-max-width fill-column
        shr-discard-aria-hidden t
        shr-cookie-policy nil)

  (setq eww-search-prefix "https://duckduckgo.com/html/?q="
        eww-history-limit 150
        eww-use-external-browser-for-content-type "\\`\\(video/\\|audio\\)"))

(defun my/eshell-git-branch ()
  (when (and (executable-find "git")
             (eq 0 (call-process "git" nil nil nil "rev-parse" "--is-inside-work-tree")))
    (string-trim (shell-command-to-string "git branch --show-current 2>/dev/null"))))

(defun my/eshell-trim-pwd (path)
  (let* ((abbr-path (abbreviate-file-name path))
         (parts (split-string abbr-path "/" t)))
    (if (<= (length parts) 2) abbr-path
      (string-join (last parts 2) "/"))))

(defun my/eshell-prompt ()
  (let* ((branch (my/eshell-git-branch))
         (host   (car (split-string (system-name) "\\."))))
    (concat
     (propertize "["               'face '(:foreground "#d75f5f"))
     (propertize (user-login-name) 'face '(:foreground "#fabd2f"))
     (propertize "@"               'face '(:foreground "#fabd2f"))
     (propertize host              'face '(:foreground "#87afaf"))
     " "
     (propertize (my/eshell-trim-pwd (eshell/pwd)) 'face '(:foreground "#afaf00"))
     (when branch
       (concat
        " "
        (propertize " " 'face '(:foreground "#d75f5f"))
        (propertize branch 'face '(:foreground "#d787af"))))
     (propertize "]" 'face '(:foreground "#d75f5f"))
     (propertize "$ " 'face 'default))))

(setq eshell-prompt-function #'my/eshell-prompt
      eshell-prompt-regexp "\\$ ")

(defun my/toggle-eshell-bottom ()
  (interactive)
  (let* ((eshell-buffer (get-buffer "*eshell*"))
         (desired-height (floor (* (frame-height) 0.45)))
         (new-window (split-window (frame-root-window) (- desired-height) 'below)))
    (select-window new-window)
    (if eshell-buffer (switch-to-buffer eshell-buffer) (eshell))))
(global-set-key (kbd "C-c e") #'my/toggle-eshell-bottom)

(defun my/project-eshell-bottom ()
  (interactive)
  (let* ((project (project-current t))
         (default-directory (project-root project))
         (buffer (project-eshell))
         (desired-height (floor (* (frame-height) 0.45)))
         (window (split-window (frame-root-window) (- desired-height) 'below)))
    (select-window window)
    (switch-to-buffer buffer)))
(keymap-global-set "C-c p e" #'my/project-eshell-bottom)

(defun my/toggle-eshell-right ()
  (interactive)
  (let* ((eshell-buffer (get-buffer "*eshell*"))
         (desired-width (floor (* (frame-width) 0.45)))
         (new-window (split-window (frame-root-window) (- desired-width) 'right)))
    (select-window new-window)
    (if eshell-buffer (switch-to-buffer eshell-buffer) (eshell))))
(global-set-key (kbd "C-c v e") #'my/toggle-eshell-right)

(defun my/project-eshell-right ()
  (interactive)
  (let* ((project (project-current t))
         (default-directory (project-root project))
         (buffer (project-eshell))
         (desired-width (floor (* (frame-width) 0.45)))
         (window (split-window (frame-root-window) (- desired-width) 'right)))
    (select-window window)
    (switch-to-buffer buffer)))
(keymap-global-set "C-c p v e" #'my/project-eshell-right)

(defun eshell/clear ()
  (interactive)
  (let ((inhibit-read-only t))
    (erase-buffer)
    (eshell-send-input)))

(add-hook 'eshell-mode-hook (lambda () (local-set-key (kbd "C-n") #'eshell/clear)))

(use-package pdf-tools
  :ensure t
  :mode "\\.pdf\\'"
  :bind (:map pdf-view-mode-map
              ("j"       . pdf-view-next-line-or-next-page)
              ("k"       . pdf-view-previous-line-or-previous-page)
              ("C-c p d" . pdf-view-midnight-minor-mode)
              ("="       . pdf-view-enlarge)
              ("-"       . pdf-view-shrink))
  :hook (pdf-tools-install)
  :config
  (setq pdf-view-use-scaling t
        pdf-view-midnight-colors '("#ebdbb2" . "#282828")))

(defun my/pdf-tmp-url (url)
  (interactive "sPDF URL: ")
  (let ((file (concat "/tmp/" (file-name-nondirectory url))))
    (url-copy-file url file t)
    (find-file file)))

(defun my/pdf-url (url directory)
  (interactive (list (read-string "PDF URL: ") (read-directory-name "Download to: ")))
  (let* ((filename (file-name-nondirectory (url-filename (url-generic-parse-url url))))
         (file (expand-file-name filename directory)))
    (url-copy-file url file t)
    (find-file file)))

(use-package anzu
  :ensure t
  :config (global-anzu-mode 1))

(use-package xclip
  :ensure t
  :config (xclip-mode 1))

(define-minor-mode my/focus-mode
  "Toggle Focus Mode for distraction-free writing."
  :lighter " Focus"
  (if my/focus-mode
      (progn
        (olivetti-mode 1)
        (display-line-numbers-mode 0)
        (setq-local display-fill-column-indicator-mode -1
                    cursor-type 'bar))
    (progn
      (olivetti-mode -1)
      (display-line-numbers-mode 1)
      (display-fill-column-indicator-mode 1))))

(defun my/focus-mode-on-input-change ()
  (when (derived-mode-p 'org-mode 'text-mode 'markdown-mode)
    (if current-input-method
        (my/focus-mode 1)
      (my/focus-mode -1))))

(add-hook 'input-method-activate-hook #'my/focus-mode-on-input-change)
(add-hook 'input-method-inactivate-hook #'my/focus-mode-on-input-change)
