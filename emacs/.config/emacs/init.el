;;; init.el -*- lexical-binding: t -*-

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

(require 'cl-lib)
(require 'seq)

(use-package no-littering
  :config
  (setq auto-save-file-name-transforms
        `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))))

;;;; Local Packages

(add-to-list 'load-path
             (expand-file-name "lisp" user-emacs-directory))

;;;; Custom file

(use-package cus-edit
  :straight nil
  :custom
  (custom-file (locate-user-emacs-file "custom.el"))
  :init
  (load custom-file :noerror))

;;;; PATH

(defconst my/lsp-bridge-venv
  (expand-file-name "~/.local/share/lsp-bridge-venv"))

(defun my/npm-global-bin ()
  "Return npm's global bin directory, or nil when npm is unavailable."
  (when-let* ((npm (executable-find "npm"))
              (raw (string-trim (shell-command-to-string
                                 (concat npm " config get prefix"))))
              ((not (string-empty-p raw)))
              (prefix (directory-file-name raw)))
    (expand-file-name "bin" prefix)))

(defun my/prepend-path (dir)
  "Prepend DIR to `exec-path' and to the PATH seen by subprocesses."
  (add-to-list 'exec-path dir)
  (let ((path (or (getenv "PATH") "")))
    (unless (member dir (split-string path path-separator t))
      (setenv "PATH" (concat dir path-separator path)))))

(dolist (dir (reverse (delq nil (list (expand-file-name "~/.local/bin")
                                      (my/npm-global-bin)
                                      (expand-file-name "bin" my/lsp-bridge-venv)))))
  (my/prepend-path dir))

;;;; Fonts

(setq text-scale-mode-step 1.1)

(set-face-attribute 'default nil
                    :family "JetBrainsMono Nerd Font"
                    :height 110)
(set-face-attribute 'fixed-pitch nil
                    :family "JetBrainsMono Nerd Font"
                    :height 110)
(set-face-attribute 'fixed-pitch-serif nil
                    :family "Noto Serif"
                    :height 110)
(set-face-attribute 'variable-pitch nil
                    :family "Dejavu Sans"
                    :height 120)

(defun my/setup-arabic-font (&optional frame)
  (let ((frame (or frame (selected-frame))))
    (when (display-graphic-p frame)
      (with-selected-frame frame
        (set-fontset-font t 'arabic (font-spec :family "" :size 20))))))

(if (daemonp)
    (add-hook 'after-make-frame-functions #'my/setup-arabic-font)
  (my/setup-arabic-font))

(defun my/set-font (family size)
  "Pick an installed font family and size, apply immediately."
  (interactive
   (list (completing-read "Font family: " (font-family-list))
         (read-number "Size (pt): " 12)))
  (set-face-attribute 'default nil :family family :height (* size 10)))

;;;; Defaults

;; Editing defaults (buffer-local).
(setq-default
 indent-tabs-mode nil
 tab-width 4
 truncate-lines t
 hscroll-step 1
 hscroll-margin 1)

;; Global behaviour.
(setq
 inhibit-startup-screen t
 initial-scratch-message nil
 use-short-answers t
 enable-recursive-minibuffers t
 completion-ignore-case t
 read-buffer-completion-ignore-case t
 read-file-name-completion-ignore-case t
 sentence-end-double-space nil
 ring-bell-function #'ignore
 scroll-conservatively 101
 auto-window-vscroll nil
 frame-resize-pixelwise t
 window-resize-pixelwise t
 window-sides-vertical t
 vc-follow-symlinks t
 kill-do-not-save-duplicates t
 create-lockfiles nil
 make-backup-files nil
 auto-save-default nil
 duplicate-line-final-position 1
 use-dialog-box nil
 uniquify-buffer-name-style 'forward
 load-prefer-newer t)

(defalias 'yes-or-no-p 'y-or-n-p)

;; Language & Encoding
(setq default-input-method "arabic")

;; Windows & Buffer
(when (window-system)
  (setq x-gtk-use-system-tooltips nil
        cursor-type 'box
        cursor-in-non-selected-windows nil))

(setq window-combination-resize t)
(setq switch-to-buffer-obey-display-actions t)
(advice-add 'split-window-right :filter-return
            (lambda (window)
              (select-window window)))

(use-package windmove
  :straight nil
  :config
  (defvar-keymap my/windmove-repeat-map
    :repeat t
    "h" #'windmove-left
    "l" #'windmove-right
    "k" #'windmove-up
    "j" #'windmove-down)

  (dolist (cmd '(windmove-left
                 windmove-right
                 windmove-up
                 windmove-down))
    (put cmd 'repeat-map 'my/windmove-repeat-map))

  (global-set-key (kbd "C-c w h") #'windmove-left)
  (global-set-key (kbd "C-c w l") #'windmove-right)
  (global-set-key (kbd "C-c w k") #'windmove-up)
  (global-set-key (kbd "C-c w j") #'windmove-down))

;; Clipboard & Selection
(setq select-enable-clipboard t
      select-enable-primary t
      select-active-regions nil)

;; Scrolling & Search
(setq scroll-margin 1
      isearch-allow-scroll t
      isearch-wrap-pause 'no-ding
      isearch-lazy-count t
      lazy-count-prefix-format "(%s/%s) ")

;; Line numbers & Column indicator
(setq display-line-numbers-type 'relative
      display-line-numbers-width 2
      display-line-numbers-width-start t)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'conf-mode-hook #'display-line-numbers-mode)

;; (setq-default fill-column 100)
;; (add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

(add-hook 'before-save-hook #'delete-trailing-whitespace)
(add-hook 'prog-mode-hook
          (lambda ()
            (setq-local show-trailing-whitespace t)))

;;;; Modes

(setq recentf-max-saved-items 200
      savehist-additional-variables '(search-ring regexp-search-ring)
      show-paren-when-point-inside-paren t
      global-auto-revert-non-file-buffers t
      global-auto-revert-ignore-remote t)

;; Modes to on
(add-hook
 'after-init-hook
 (lambda ()
   (dolist (mode '(global-hl-line-mode
                   recentf-mode
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
                   minibuffer-depth-indicate-mode
                   show-paren-mode
                   which-key-mode
                   editorconfig-mode
                   context-menu-mode))
     (funcall mode 1))))

;; Modes to off
(dolist (mode '(menu-bar-mode
                tool-bar-mode
                scroll-bar-mode
                size-indication-mode))
  (funcall mode -1))

(use-package diminish
  :ensure t)

(with-eval-after-load 'which-key
  (diminish 'which-key-mode))

(with-eval-after-load 'simple
  (diminish 'visual-line-mode))

(with-eval-after-load 'eldoc
  (diminish 'eldoc-mode))

(with-eval-after-load 'subword
  (diminish 'subword-mode))

;;;; Dired

(require 'dired-x)

(use-package dired
  :straight nil
  :custom
  (dired-listing-switches "-alh --group-directories-first")
  (dired-dwim-target t)
  (delete-by-moving-to-trash t)
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-auto-revert-buffer t)
  (dired-mouse-drag-files t)
  (setq dired-omit-files (concat dired-omit-files "\\|^\\..+$"))
  (setq image-dired-thumb-size 250)
  (setq image-dired-thumbnail-storage 'standard)
  :config
  (with-eval-after-load 'dired
    (put 'dired-jump 'repeat-map nil)))

(use-package async
  :ensure t
  :init
  (dired-async-mode 1))

(use-package dired-git-info
  :ensure t
  :after dired
  :custom
  (dgi-auto-hide-details-p nil)
  :bind
  (:map dired-mode-map
        (")" . dired-git-info-mode)))

(use-package nerd-icons-dired
  :config
  :hook (dired-mode . nerd-icons-dired-mode))

;;;; Remote files

(setq tramp-verbose 1
      remote-file-name-inhibit-cache 50
      remote-file-name-inhibit-locks t
      remote-file-name-inhibit-auto-save-visited t)

;;;; Spelling

(setq flyspell-issue-message-flag nil
      flyspell-issue-welcome-flag nil
      ispell-silently-savep t)

(use-package flyspell
  :straight t
  :when (or (executable-find "ispell")
            (executable-find "aspell")
            (executable-find "hunspell"))
  :hook ((org-mode git-commit-mode markdown-mode) . flyspell-mode))

;;;; Disabled commands

(dolist (command '(list-timers narrow-to-region narrow-to-page
                               upcase-region downcase-region list-threads
                               erase-buffer scroll-left dired-find-alternate-file
                               set-goal-column))
  (put command 'disabled nil))

;;;; Keybindings

(bind-keys
 ("C-/"           . undo-only)
 ("C-?"           . undo-redo)
 ("C-c C-f"       . find-file-other-window)
 ("C-}"           . forward-paragraph)
 ("C-{"           . backward-paragraph)
 ("C-c e"         . eshell)
 ("C-x C-b"       . projectile-ibuffer)
 ;; Compile & run
 ("C-c c"         . compile)
 ("C-c C"         . recompile)
 ;; Windows, buffers, tabs
 ("C-x C-k"       . kill-buffer-and-window)
 ("C-<tab>"       . mode-line-other-buffer)
 ;; Editing
 ("C-,"           . duplicate-dwim)
 ("C-c f"         . find-file-at-point)
 ;; Tabs
 ("C-c ;"       . tab-previous)
 ("C-c '"       . tab-next))

;;;; Tools

(defconst my/mason-dir
  (file-name-as-directory
   (if (boundp 'mason-dir)
       mason-dir
     (expand-file-name "mason" user-emacs-directory))))

(defvar my/mason-packages nil
  "Language servers installed by `my/mason-install-missing'.
Each language section adds its own packages with `my/mason-use'.")

(defun my/mason-use (&rest packages)
  "Install PACKAGES with mason when they are missing."
  (dolist (package packages)
    (add-to-list 'my/mason-packages package t)))

(defun my/mason-install-missing ()
  "Install missing mason packages, then refresh the Java debug jar link."
  (interactive)
  (require 'mason)
  (mason-log)
  (mason-setup
    (let* ((missing (seq-remove #'mason-installed-p my/mason-packages))
           (remaining (length missing)))
      (if (zerop remaining)
          (my/mason-refresh-java-debug-jar)
        (dolist (package missing)
          (mason-install
           package nil nil
           (lambda (_success)
             (when (<= (cl-decf remaining) 0)
               (my/mason-refresh-java-debug-jar)))))))))

(defun my/lsp-bridge-python ()
  "Return the lsp-bridge virtualenv Python, falling back to python3."
  (let ((python (expand-file-name "bin/python" my/lsp-bridge-venv)))
    (if (file-executable-p python) python "python3")))

(my/prepend-path (expand-file-name "bin" my/mason-dir))

(use-package mason
  :straight (mason :type git :host github :repo "mason-org/mason.el")
  :commands (mason-manager mason-install mason-installed-p mason-setup)
  :init
  (mason-setup))

;;;; Tree-sitter

(require 'treesit)

(dolist (feature '(js java-ts-mode typescript-ts-mode css-mode
                      html-ts-mode json-ts-mode))
  (require feature nil t))

(defvar my/treesit-languages nil
  "Tree-sitter grammars used by this configuration.")

(defvar my/treesit-remaps nil
  "Pending (LANGUAGE OLD-MODE NEW-MODE) triples, retried by
`my/install-treesit-grammars' after a grammar install so a remap
doesn't stay missing until the next Emacs restart.")

(defun my/treesit-grammar (language)
  "Register LANGUAGE so `my/install-treesit-grammars' can install it."
  (add-to-list 'my/treesit-languages language t))

(defun my/treesit-try-remap (language old-mode new-mode)
  "Add OLD-MODE -> NEW-MODE to `major-mode-remap-alist' if LANGUAGE is ready."
  (when (and (fboundp new-mode)
             (treesit-ready-p language t)
             (or (not (eq new-mode 'js-ts-mode))
                 (treesit-ready-p 'jsdoc t)))
    (add-to-list 'major-mode-remap-alist (cons old-mode new-mode))))

(defun my/treesit-remap (language old-mode new-mode)
  "Use NEW-MODE for OLD-MODE once the LANGUAGE grammar is available."
  (my/treesit-grammar language)
  (add-to-list 'my/treesit-remaps (list language old-mode new-mode) t)
  (my/treesit-try-remap language old-mode new-mode))

(defun my/install-treesit-grammars ()
  "Install every tree-sitter grammar this configuration uses, then
retry any remap that was skipped at init time because its grammar
wasn't installed yet."
  (interactive)
  (dolist (language my/treesit-languages)
    (unless (treesit-language-available-p language)
      (treesit-install-language-grammar language)))
  (dolist (remap my/treesit-remaps)
    (apply #'my/treesit-try-remap remap)))

;;;; Completion and UI

(setq which-key-idle-delay 0.4)

(setopt tab-always-indent 'complete
        completion-styles '(basic partial-completion flex)
        completion-auto-select 'second-tab
        completions-format 'vertical
        completions-max-height 12
        completions-detailed t
        completions-header-format nil
        completion-show-help nil)

(use-package vertico
  :custom
  (vertico-scroll-margin 0)
  (vertico-count 12)
  (vertico-resize t)
  (vertico-cycle t)
  :init
  (vertico-mode))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-pcm-leading-wildcard t))

(use-package consult
  :bind (("C-x b" . consult-buffer)
         ("C-c S" . consult-ripgrep)
         ("C-c i" . consult-imenu)
         ("M-g g" . consult-goto-line)
         ("M-g M-g" . consult-goto-line)))

(use-package marginalia
  :config
  (marginalia-mode 1))

;;;; Git

(use-package magit
  :straight t
  :after transient
  :commands (magit-status)
  :hook ((magit-mode git-commit-mode) . (lambda () (variable-pitch-mode -1)))
  :bind (("C-x g" . magit-status)
         ("C-x v" . magit-diff-visit-file-other-window)))

(setq magit-repository-directories '(("~/Projects"  . 2)))

(use-package diff-hl
  :straight t
  :bind (("M-{" . diff-hl-previous-hunk)
         ("M-}" . diff-hl-next-hunk))
  :init
  (global-diff-hl-mode)
  :custom
  (diff-hl-update-async t)
  :config
  (diff-hl-flydiff-mode 1))

;;;; Project Management

(use-package projectile
  :ensure t
  :init
  (setq projectile-project-search-path '("~/Projects/"))
  :config
  (define-key projectile-mode-map (kbd "C-x p") 'projectile-command-map)
  (projectile-mode 1))

(use-package hl-todo
  :hook ((prog-mode yaml-mode conf-mode) . hl-todo-mode))

;;;; Editing utilities

(use-package smartparens
  :straight t
  :bind (("C-c s r"   . sp-rewrap-sexp)
         ("C-c s u"   . sp-unwrap-sexp)
         ("C-c s w r" . sp-wrap-round)
         ("C-c s w c" . sp-wrap-curly)
         ("C-c s w s" . sp-wrap-square)
         ("C-c s c"   . sp-change-inner)
         ("M-m"       . sp-delete-sexp))
  :config
  (require 'smartparens-config)
  (sp-with-modes '(web-mode)
                 (sp-local-pair "%" "%" :unless '(sp-in-string-p) ...)
                 (sp-local-tag "%" "<% "  " %>")
                 (sp-local-tag "=" "<%= " " %>")
                 (sp-local-tag "#" "<%# " " %>")))

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
  (require 'mc-hide-unmatched-lines-mode)
  (setq mc/always-run-for-all t))

(use-package drag-stuff
  :straight t
  :diminish drag-stuff-mode
  :config
  (drag-stuff-global-mode 1)
  (drag-stuff-define-keys))

(use-package smart-hungry-delete
  :straight t
  :bind (([remap backward-delete-char-untabify] . smart-hungry-delete-backward-char)
	     ([remap delete-backward-char] . smart-hungry-delete-backward-char)
	     ([remap delete-char] . smart-hungry-delete-forward-char))
  :init (smart-hungry-delete-add-default-hooks))

;;;; Development/Environment

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x pgtk))
  :straight t
  :custom
  (exec-path-from-shell-arguments '("-l"))
  (exec-path-from-shell-variables '("PATH" "MANPATH" "JAVA_HOME"))
  :config (exec-path-from-shell-initialize))

(use-package envrc
  :config
  (when (executable-find "direnv")
    (envrc-global-mode 1)))

(use-package daemons :straight t)

(use-package proced :straight nil
  :bind ("C-c P" . proced))

(use-package yasnippet
  :ensure t
  :config
  (setq yas-snippet-dirs '("~/.config/emacs/snippets"))
  (yas-global-mode 1))

;;;; Compile

(use-package compile
  :ensure nil
  :custom
  (compilation-always-kill t)
  (compilation-ask-about-save nil)
  (compilation-max-output-line-length nil)
  (compilation-scroll-output 'first-error)
  ;; (display-buffer-alist
  ;;  '(("\\*compilation\\*" (display-buffer-reuse-window display-buffer-in-side-window)
  ;;     (side . bottom) (slot . -2) (window-height . 0.45))))
  :hook ((prog-mode . my/guess-compile-command)
         (compilation-filter . ansi-color-compilation-filter))
  :init
  (advice-add 'compilation-start :after
              (lambda (&rest _)
                (when-let ((w (get-buffer-window "*compilation*")))
                  (select-window w)))))

(defun my/guess-compile-command ()
  "Set a buffer-local `compile-command' from the nearest build file."
  (unless (file-remote-p default-directory)
    (cl-flet ((has (f) (locate-dominating-file default-directory f)))
      (cond
       ((has "package.json")   (setq-local compile-command "npm run build"))
       ((has "pom.xml")        (setq-local compile-command "mvn -q compile"))
       ((or (has "build.gradle") (has "build.gradle.kts"))
        (setq-local compile-command "./gradlew build"))
       ((has "CMakeLists.txt") (setq-local compile-command "cmake --build build"))
       ((has "Makefile")       (setq-local compile-command "make -k"))
       ((and buffer-file-name (derived-mode-p 'c-mode))
        (setq-local compile-command
                    (format "gcc -Wall -Wextra -g -o %s %s"
                            (shell-quote-argument (file-name-base buffer-file-name))
                            (shell-quote-argument
                             (file-name-nondirectory buffer-file-name)))))))))

;;;; LSP

(use-package lsp-bridge
  :straight (lsp-bridge :type git :host github :repo "manateelazycat/lsp-bridge"
                        :files (:defaults "*.py" "acm" "core" "langserver"
                                          "multiserver" "resources")
                        :build (:not compile))
  :custom
  (lsp-bridge-python-command (my/lsp-bridge-python))
  (lsp-bridge-diagnostic-overlays t)
  (lsp-bridge-enable-hover-diagnostic t)
  (lsp-bridge-complete-manually t)
  (lsp-bridge-enable-completion-in-string t)
  (lsp-bridge-typescript-lsp-server "typescript")
  (lsp-bridge-typescript-react-lsp-server "typescriptreact")
  (lsp-bridge-javascript-lsp-server "javascript")
  (lsp-bridge-javascript-react-lsp-server "javascriptreact")
  ;; (acm-enable-icon nil)
  :config
  ;; Combos that lsp-bridge ships itself.  Anything else is generated by
  ;; `my/lsp-combo-ensure' in the next section.
  (setq lsp-bridge-multi-lang-server-extension-list
        '((("vue") . "volar_emmet")
          (("component.html") . "angular_template_html")
          (("component.ts") . "angular_template_typescript")))
  (global-lsp-bridge-mode))

(defvar my/lsp-bridge-auto-complete-modes '(emacs-lisp-mode html-ts-mode css-ts-mode
                                                            mhtml-mode web-mode yaml-ts-mode json-ts-mode
                                                            c-mode)
  "Major modes where lsp-bridge completion should stay automatic.")

(dolist (mode my/lsp-bridge-auto-complete-modes)
  (add-hook (intern (format "%s-hook" mode))
            (lambda () (setq-local lsp-bridge-complete-manually nil))))

(defun my/lsp-bridge-tab-dwim ()
  "Pop the completion menu if mid-symbol and manual; otherwise indent."
  (interactive)
  (if (and lsp-bridge-complete-manually
           (> (point) (save-excursion (back-to-indentation) (point))))
      (lsp-bridge-popup-complete-menu)
    (indent-for-tab-command)))

(define-key lsp-bridge-mode-map (kbd "TAB") #'my/lsp-bridge-tab-dwim)

(defvar-keymap my/lsp-bridge-map
  :doc "LSP commands."
  "a" #'lsp-bridge-code-action
  "d" #'lsp-bridge-popup-documentation
  "f" #'lsp-bridge-code-format
  "i" #'lsp-bridge-find-impl
  "l" #'lsp-bridge-diagnostic-list
  "n" #'lsp-bridge-diagnostic-jump-next
  "p" #'lsp-bridge-diagnostic-jump-prev
  "r" #'lsp-bridge-rename
  "t" #'lsp-bridge-find-type-def
  "R" #'lsp-bridge-restart-process)

(keymap-global-set "C-c l" my/lsp-bridge-map)
(keymap-set lsp-bridge-mode-map "M-." #'lsp-bridge-find-def)
(keymap-set lsp-bridge-mode-map "M-," #'lsp-bridge-find-def-return)
(keymap-set lsp-bridge-mode-map "M-?" #'lsp-bridge-find-references)

;;;; LSP combos (multiserver)

(require 'json)

(defconst my/lsp-bridge-multiserver-dir
  (expand-file-name "lsp-bridge-multiserver" user-emacs-directory))

;; (FRAMEWORK SERVER FILES OPTIONAL-SERVERS)
(defconst my/lsp-combo-table
  '(("typescript"      "typescript"                  ("ts" "mts" "cts") (eslint))
    ("javascript"      "javascript"                  ("js" "mjs" "cjs") (eslint))
    ("typescriptreact" "typescriptreact"             ("tsx")            (eslint tailwind))
    ("javascriptreact" "javascriptreact"             ("jsx")            (eslint tailwind))
    ("vue"             "volar"                       ("vue")            (eslint tailwind))
    ("html"            "vscode-html-language-server" ("html")           (tailwind))
    ("css"             "vscode-css-language-server"  ("css" "scss")     (tailwind)))
  "Rows of (FRAMEWORK SERVER FILES OPTIONAL-SERVERS).
FRAMEWORK/SERVER name the combo and its base lsp-bridge server.  FILES
are the extensions `my/lsp-bridge-multiserver' matches against.
OPTIONAL-SERVERS lists which of `eslint'/`tailwind' may be layered on
top when detected in the project.")

(defconst my/eslint-config-names
  '("eslint.config.js" "eslint.config.mjs" "eslint.config.cjs"
    "eslint.config.ts" "eslint.config.mts" "eslint.config.cts"
    ".eslintrc" ".eslintrc.js" ".eslintrc.cjs" ".eslintrc.json"
    ".eslintrc.yaml" ".eslintrc.yml"))

(defconst my/tailwind-config-names
  '("tailwind.config.js" "tailwind.config.cjs" "tailwind.config.mjs"
    "tailwind.config.ts"))

(defun my/config-above-p (file names)
  "Return non-nil when one of NAMES exists in FILE's directory or above."
  (and (locate-dominating-file
        file
        (lambda (dir)
          (cl-some (lambda (name) (file-exists-p (expand-file-name name dir)))
                   names)))
       t))

(defun my/package-json-mentions-p (dir word)
  "Return non-nil when DIR's package.json mentions WORD."
  (let ((package (expand-file-name "package.json" dir)))
    (and (file-readable-p package)
         (ignore-errors
           (with-temp-buffer
             (insert-file-contents package nil 0 16384)
             (search-forward word nil t))))))

(defun my/project-tailwind-p (file)
  "Return non-nil when FILE belongs to a Tailwind project."
  (or (my/config-above-p file my/tailwind-config-names)
      (and (locate-dominating-file
            file (lambda (dir) (my/package-json-mentions-p dir "tailwindcss")))
           t)))

(defun my/lsp-combo-spec (server eslint tailwind)
  "Return the combo description combining SERVER with ESLINT and TAILWIND.
ESLINT and TAILWIND are the lsp-bridge server names, or nil."
  (let* ((servers (delq nil (list server eslint tailwind)))
         (completion (delq nil (list tailwind server)))
         ;; ESLint owns diagnostics when present; Tailwind fills in otherwise.
         (diagnostics (delq nil (list server (or eslint tailwind)))))
    `(("default" . ,server)
      ,@(when tailwind `(("completion" . ,completion)
                         ("completion_item_resolve" . ,completion)))
      ("diagnostics" . ,diagnostics)
      ("code_action" . ,servers)
      ("execute_command" . ,servers))))

(defun my/lsp-combo-file (name)
  "Return the path of the combo called NAME."
  (expand-file-name (concat name ".json") my/lsp-bridge-multiserver-dir))

(defun my/lsp-combo-bundled-p (name)
  "Return non-nil when lsp-bridge ships a combo called NAME."
  (when-let* ((library (locate-library "lsp-bridge")))
    (file-exists-p (expand-file-name
                    (concat name ".json")
                    (expand-file-name "multiserver"
                                      (file-name-directory library))))))

(defun my/lsp-combo-file-content (file)
  "Return FILE's content as a string, or nil if it doesn't exist."
  (and (file-exists-p file)
       (ignore-errors
         (with-temp-buffer
           (insert-file-contents file)
           (buffer-string)))))

(defun my/lsp-combo-ensure (row eslint tailwind &optional force)
  "Return the name of ROW's combo, writing its JSON file when needed.
ESLINT and TAILWIND are the lsp-bridge server names, or nil.  The file
is (re)written whenever FORCE is non-nil or its content no longer
matches what `my/lsp-combo-spec' currently produces, so a change to
the generator takes effect on the next file of that kind you open
instead of staying stuck with whatever was written the first time."
  (pcase-let* ((`(,framework ,server ,_files ,_optional) row)
               (name (concat framework
                             (and eslint "_eslint")
                             (and tailwind "_tailwindcss")))
               (file (my/lsp-combo-file name)))
    (unless (my/lsp-combo-bundled-p name)
      (let ((json (json-encode (my/lsp-combo-spec server eslint tailwind))))
        (when (or force (not (equal (my/lsp-combo-file-content file) json)))
          (make-directory my/lsp-bridge-multiserver-dir t)
          (write-region json nil file nil 'silent))))
    name))

(defun my/lsp-combo-refresh ()
  "Recreate every multiserver combo allowed by `my/lsp-combo-table'."
  (interactive)
  (dolist (row my/lsp-combo-table)
    (pcase-let ((`(,_framework ,_server ,_files ,optional) row))
      (dolist (eslint (if (memq 'eslint optional)
                          '(nil "vscode-eslint-language-server")
                        '(nil)))
        (dolist (tailwind (if (memq 'tailwind optional)
                              '(nil "tailwindcss")
                            '(nil)))
          (when (or eslint tailwind)
            (my/lsp-combo-ensure row eslint tailwind 'force)))))))

(defun my/lsp-bridge-static-combo-p (file)
  "Return non-nil when FILE is already owned by a compound-extension
entry in `lsp-bridge-multi-lang-server-extension-list' (Angular's
\"component.html\"/\"component.ts\", say).  `file-name-extension' only
sees the last dot-segment, so our generic \"html\"/\"ts\" rows in
`my/lsp-combo-table' would otherwise match those same files and
quietly steal them away from their framework-specific combo the
moment eslint or tailwind is also configured in the project."
  (let ((name (file-name-nondirectory file)))
    (cl-some (lambda (entry)
               (cl-some (lambda (key)
                          (and (string-match-p "\\." key)
                               (string-suffix-p (concat "." key) name)))
                        (car entry)))
             lsp-bridge-multi-lang-server-extension-list)))

(defun my/lsp-bridge-multiserver (_project-path file)
  "Choose the lsp-bridge combo for FILE, or nil for the default server."
  (when-let* (((not (my/lsp-bridge-static-combo-p file)))
              (extension (file-name-extension file))
              (row (seq-find (lambda (row) (member extension (nth 2 row)))
                             my/lsp-combo-table)))
    (let* ((optional (nth 3 row))
           (eslint (and (memq 'eslint optional)
                        (my/config-above-p file my/eslint-config-names)
                        "vscode-eslint-language-server"))
           (tailwind (and (memq 'tailwind optional)
                          (my/project-tailwind-p file)
                          "tailwindcss")))
      (when (or eslint tailwind)
        (my/lsp-combo-ensure row eslint tailwind)))))

(defun my/lsp-combo-for-file (file)
  "Return the name of the combo lsp-bridge would use for FILE.
Interactively, ask for a file and show the answer."
  (interactive "fFile: ")
  (let ((combo (my/lsp-bridge-multiserver nil (expand-file-name file))))
    (if (called-interactively-p 'interactive)
        (message "%s" (or combo "the default single server"))
      combo)))

(setq lsp-bridge-user-multiserver-dir my/lsp-bridge-multiserver-dir
      lsp-bridge-get-multi-lang-server-by-project #'my/lsp-bridge-multiserver)

;;;; Formatting

(use-package apheleia
  :diminish "Aphe"
  :config
  (apheleia-global-mode 1))

;;;; Debugging

(use-package dape
  :custom
  (dape-buffer-window-arrangement 'right)
  (dape-inlay-hints t)
  :config
  (when (fboundp 'dape-breakpoint-global-mode)
    (dape-breakpoint-global-mode 1))
  (require 'dape-scope-collapse nil t))

(defvar-keymap my/debug-map
  :doc "Debugging commands."
  "d" #'dape
  "b" #'dape-breakpoint-toggle
  "B" #'dape-breakpoint-remove-all
  "l" #'dape-breakpoint-log
  "x" #'dape-breakpoint-expression
  "c" #'dape-continue
  "n" #'dape-next
  "i" #'dape-step-in
  "o" #'dape-step-out
  "r" #'dape-restart
  "q" #'dape-quit
  "e" #'dape-evaluate-expression
  "w" #'dape-watch-dwim
  "R" #'dape-repl
  "I" #'dape-info
  "j" #'my/java-debug-on
  "J" #'my/java-debug-off)

(keymap-global-set "C-c d" my/debug-map)

;;;; JavaScript / TypeScript

(my/mason-use "typescript-language-server" "eslint-lsp"
              "tailwindcss-language-server" "js-debug-adapter")

;; Grammar registration for `my/install-treesit-grammars'.
(my/treesit-grammar 'jsdoc)
(my/treesit-grammar 'typescript)
(my/treesit-grammar 'tsx)

(my/treesit-remap 'javascript 'javascript-mode 'js-ts-mode)
(my/treesit-remap 'javascript 'js-mode 'js-ts-mode)
(my/treesit-remap 'javascript 'js-jsx-mode 'js-ts-mode)

(setq js-indent-level 2
      typescript-ts-mode-indent-offset 2)

(use-package add-node-modules-path
  :straight t
  :hook ((js-mode js-jsx-mode js-ts-mode
		          typescript-ts-mode tsx-ts-mode
		          json-ts-mode) . add-node-modules-path))

;; Prettier, through apheleia, when the project provides it.
(defun my/project-prettier ()
  "Return the nearest node_modules/.bin/prettier, or nil."
  (when-let* ((root (locate-dominating-file default-directory "node_modules")))
    (let ((binary (expand-file-name "node_modules/.bin/prettier" root)))
      (and (file-executable-p binary) binary))))

(defun my/apheleia-skip-without-project-prettier ()
  "Skip apheleia when a prettier formatter is configured but not installed."
  (when (and buffer-file-name
             (cl-some (lambda (formatter)
                        (string-prefix-p "prettier" (symbol-name formatter)))
                      (apheleia--get-formatters)))
    (unless (my/project-prettier)
      "no node_modules/.bin/prettier in this project")))

(with-eval-after-load 'apheleia
  (add-to-list 'apheleia-skip-functions
               #'my/apheleia-skip-without-project-prettier))

;; Debugging with the JS debug adapter.
(with-eval-after-load 'dape
  (let ((link (expand-file-name "js-debug" dape-adapter-dir))
        (target (expand-file-name "packages/js-debug-adapter/js-debug"
                                  my/mason-dir)))
    (unless (or (file-exists-p link) (file-symlink-p link))
      (make-directory (file-name-directory link) t)
      (make-symbolic-link target link t)))
  (dolist (config
           `((my-node
              modes (js-mode js-ts-mode typescript-mode typescript-ts-mode
                             tsx-ts-mode)
              command "js-debug-adapter" command-args (:autoport) port :autoport
              :type "pwa-node" :request "launch"
              :name "Node: launch current file"
              :cwd dape-cwd :program dape-buffer-default
              :sourceMaps t :console "internalConsole")
             (my-node-tsx
              modes (typescript-ts-mode tsx-ts-mode)
              command "js-debug-adapter" command-args (:autoport) port :autoport
              :type "pwa-node" :request "launch"
              :name "Node: launch TS file with tsx"
              :cwd dape-cwd :program dape-buffer-default
              :runtimeArgs ["--import" "tsx"]
              :sourceMaps t :console "internalConsole")
             (my-node-attach
              modes (js-mode js-ts-mode typescript-mode typescript-ts-mode
                             tsx-ts-mode)
              command "js-debug-adapter" command-args (:autoport) port :autoport
              :type "pwa-node" :request "attach"
              :name "Node: attach :9229"
              :port 9229 :cwd dape-cwd :sourceMaps t)
             (my-chrome
              modes (js-mode js-ts-mode typescript-mode typescript-ts-mode
                             tsx-ts-mode html-mode html-ts-mode)
              command "js-debug-adapter" command-args (:autoport) port :autoport
              :type "pwa-chrome" :request "launch"
              :name "Chrome: localhost:5173"
              :url "http://localhost:5173" :webRoot dape-cwd :sourceMaps t)))
    (add-to-list 'dape-configs config)))

;;;; Java

(my/mason-use "jdtls" "google-java-format" "java-debug-adapter")

;; Lombok and the java-debug plugin bundled with mason's jdtls.
(defconst my/mason-java-debug-jar-link
  (expand-file-name "java-debug-plugin.jar" my/mason-dir))

(defun my/mason-refresh-java-debug-jar ()
  "Point `my/mason-java-debug-jar-link' at the installed java-debug jar."
  (let ((dir (expand-file-name "packages/java-debug-adapter/extension/server"
                               my/mason-dir)))
    (when (file-directory-p dir)
      (when-let* ((target (car (directory-files dir t "\\.jar\\'"))))
        (unless (equal (ignore-errors
                         (file-chase-links my/mason-java-debug-jar-link))
                       target)
          (when (or (file-exists-p my/mason-java-debug-jar-link)
                    (file-symlink-p my/mason-java-debug-jar-link))
            (delete-file my/mason-java-debug-jar-link))
          (make-symbolic-link target my/mason-java-debug-jar-link))))))

(defun my/lombok-jar ()
  "Return the Lombok jar bundled with mason's jdtls, or the manual fallback."
  (let ((bundled (expand-file-name "packages/jdtls/lombok.jar" my/mason-dir))
        (manual (expand-file-name "~/.local/share/lombok/lombok.jar")))
    (cond ((file-exists-p bundled) bundled)
          ((file-exists-p manual) manual))))

(defun my/mason-java-debug-jar ()
  "Return the resolved java-debug plugin jar, or nil."
  (and (file-exists-p my/mason-java-debug-jar-link)
       (file-truename my/mason-java-debug-jar-link)))

(my/mason-refresh-java-debug-jar)

(setq lsp-bridge-jdtls-default-file
      (expand-file-name "lsp-bridge-langserver/jdtls.json" user-emacs-directory))

(defun my/prune-stale-jdtls-configs ()
  "Delete cached jdtls configs that predate the java-debug bundle fix.
One-off cleanup, not run automatically: now that freshly generated
configs always include \"bundles\", scanning and reading every cached
jdtls.json on every single startup is wasted I/O.  Call this by hand
(`M-x my/prune-stale-jdtls-configs') only if you ever need to force
regeneration of the cache again."
  (interactive)
  (let ((dir (expand-file-name "~/.cache/lsp-bridge-jdtls")))
    (dolist (file (and (file-directory-p dir)
                       (directory-files-recursively dir "jdtls\\.json")))
      (with-temp-buffer
        (insert-file-contents file)
        (unless (search-forward "bundles" nil t)
          (delete-file file))))))

(when-let* ((jar (my/lombok-jar)))
  (setq lsp-bridge-jdtls-jvm-args (list (concat "-javaagent:" jar))))

(use-package eglot
  :straight nil
  :config
  (add-to-list 'eglot-server-programs
               `((java-mode java-ts-mode)
                 . ("jdtls"
                    ,@(when-let* ((jar (my/lombok-jar)))
                        (list (concat "--jvm-arg=-javaagent:" jar)))
                    :initializationOptions
                    (:bundles ,(vconcat (delq nil (list (my/mason-java-debug-jar)))))))))

(with-eval-after-load 'apheleia
  (setf (alist-get 'google-java-format apheleia-formatters)
        '("google-java-format" "--aosp" "-")))

;; Build, test and run with Maven or Gradle.
(defun my/project-root ()
  "Return the current project root, or a Maven/Gradle directory."
  (or (when-let* ((project (project-current)))
        (project-root project))
      (locate-dominating-file default-directory "pom.xml")
      (locate-dominating-file default-directory "build.gradle")
      (locate-dominating-file default-directory "build.gradle.kts")
      default-directory))

(defun my/build-command (maven-goal gradle-task)
  "Build a shell command for MAVEN-GOAL or GRADLE-TASK."
  (let* ((root (my/project-root))
         (mvnw (expand-file-name "mvnw" root))
         (gradlew (expand-file-name "gradlew" root)))
    (cond
     ((file-executable-p mvnw) (format "./mvnw %s" maven-goal))
     ((file-executable-p gradlew) (format "./gradlew %s" gradle-task))
     ((file-exists-p (expand-file-name "pom.xml" root))
      (format "mvn %s" maven-goal))
     ((or (file-exists-p (expand-file-name "build.gradle" root))
          (file-exists-p (expand-file-name "build.gradle.kts" root)))
      (format "gradle %s" gradle-task))
     (t (user-error "No Maven or Gradle project found")))))

(defun my/run-build-command (maven-goal gradle-task)
  "Run MAVEN-GOAL or GRADLE-TASK from the project root."
  (let ((default-directory (my/project-root)))
    (compile (my/build-command maven-goal gradle-task))))

(defun my/java-compile ()
  "Compile the current Maven or Gradle project."
  (interactive)
  (my/run-build-command "compile" "classes"))

(defun my/java-test ()
  "Run the tests of the current Maven or Gradle project."
  (interactive)
  (my/run-build-command "test" "test"))

(defun my/spring-run ()
  "Run the current Spring Boot application."
  (interactive)
  (my/run-build-command "spring-boot:run" "bootRun"))

;; Debugging: eglot (jdtls) feeds dape.
(defvar my/java-debug-start-delay 3
  "Seconds to wait before each dape launch attempt.
jdtls keeps indexing in the background after the eglot handshake, so
a single fixed wait can be too short on a cold start; see
`my/java-debug--attempt', which retries instead of trusting one try.")

(defvar my/java-debug-max-attempts 3
  "How many times `my/java-debug--attempt' retries before giving up.")

(defun my/java-debug--attempt (buffer attempt)
  "Try to start dape in BUFFER; retry with backoff up to ATTEMPT times."
  (when (buffer-live-p buffer)
    (with-current-buffer buffer
      (condition-case err
          (call-interactively #'dape)
        (error
         (if (< attempt my/java-debug-max-attempts)
             (progn
               (message "[java-debug] not ready yet (%s), retrying (%d/%d)..."
                        (error-message-string err) attempt my/java-debug-max-attempts)
               (run-with-timer my/java-debug-start-delay nil
                               #'my/java-debug--attempt buffer (1+ attempt)))
           (message "[java-debug] giving up after %d attempts: %s"
                    my/java-debug-max-attempts (error-message-string err))))))))

(defun my/java-debug-on ()
  "Start a Java debug session through eglot and dape."
  (interactive)
  (unless (derived-mode-p 'java-mode 'java-ts-mode)
    (user-error "Not a Java buffer"))
  (require 'eglot)
  (let ((buffer (current-buffer)))
    (when (bound-and-true-p lsp-bridge-mode)
      (lsp-bridge-mode -1)
      (lsp-bridge-kill-process))
    (letrec ((start
              (lambda (&rest _)
                (remove-hook 'eglot-connect-hook start)
                (run-with-timer
                 my/java-debug-start-delay nil
                 #'my/java-debug--attempt buffer 1))))
      (if (eglot-current-server)
          (funcall start)
        (add-hook 'eglot-connect-hook start)
        (call-interactively #'eglot)))))

(defun my/java-debug-off ()
  "Stop eglot and return the buffer to lsp-bridge."
  (interactive)
  (when-let* ((server (and (fboundp 'eglot-current-server)
                           (eglot-current-server))))
    (eglot-shutdown server nil t))
  (lsp-bridge-restart-process)
  (lsp-bridge-mode 1))

(defvar-keymap my/java-map
  :doc "Java and Spring commands."
  "c" #'my/java-compile
  "t" #'my/java-test
  "r" #'my/spring-run
  "d" #'my/java-debug-on
  "D" #'my/java-debug-off)

(keymap-global-set "C-c j" my/java-map)

;;;; Web (HTML and CSS)

(my/mason-use "html-lsp" "css-lsp")

(my/treesit-remap 'css 'css-mode 'css-ts-mode)
(my/treesit-remap 'html 'html-mode 'html-ts-mode)
(my/treesit-remap 'html 'mhtml-mode 'html-ts-mode)
(my/treesit-remap 'json 'js-json-mode 'json-ts-mode)

(setq css-indent-offset 2
      json-ts-mode-indent-offset 2)

(use-package web-mode
  :mode (("\\.html\\'" . web-mode)
         ("\\.hbs\\'" . web-mode)
         ("\\.mustache\\'" . web-mode)
         ("\\.jsp\\'" . web-mode)
         ("\\.ejs\\'" . web-mode)
         ("\\.ftl\\'" . web-mode))
  :config
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-code-indent-offset 2))

(use-package emmet-mode
  :straight t
  :hook ((html-ts-mode mhtml-mode html-mode sgml-mode
		               css-ts-mode css-mode
		               js-jsx-mode tsx-ts-mode) . emmet-mode)
  :config
  (setq emmet-move-cursor-between-quotes t)
  (add-to-list 'emmet-css-major-modes 'css-ts-mode)
  (define-key emmet-mode-keymap (kbd "C-c >") #'emmet-expand-line))

(use-package auto-rename-tag
  :straight t
  :diminish auto-rename-tag-mode
  :hook ((html-ts-mode mhtml-mode html-mode
		               js-ts-mode tsx-ts-mode) . auto-rename-tag-mode))

(use-package rainbow-mode
  :hook ((css-mode css-ts-mode scss-mode web-mode html-ts-mode) . rainbow-mode))

;;;; Markup and data files

(my/mason-use "json-lsp" "yaml-language-server" "bash-language-server")

(use-package markdown-mode)

(use-package yaml-mode
  :mode "\\.ya?ml\\'")

(use-package dockerfile-mode
  :mode (("Dockerfile\\'" . dockerfile-mode)
         ("\\.dockerfile\\'" . dockerfile-mode)))

(use-package nix-mode
  :ensure t
  :mode "\\.nix\\'"
  :hook (nix-mode . (lambda ()
                      (add-hook 'before-save-hook #'nix-mode-format nil t))))

(use-package fish-mode
  :straight t
  :mode (("\\.fish\\'" . fish-mode))
  :hook (fish-mode . (lambda ()
                       (add-hook 'before-save-hook 'fish_indent-before-save))))

;;;; Theme

(use-package doom-themes
  :ensure t
  :config
  (defun my/apply-custom-faces ()
    "bla bla."
    (let ((bg     (doom-color 'bg))
          (fg     (doom-color 'fg))
          (grey   (doom-color 'grey))
          (bar    (doom-color 'vertical-bar))
          (red    (doom-color 'red))
          (orange (doom-color 'orange))
          (yellow (doom-color 'yellow))
          (green  (doom-color 'green))
          (blue   (doom-color 'blue))
          (violet (doom-color 'violet)))
      (custom-set-faces
       ;; Punctuation the theme leaves monochrome.
       `(font-lock-misc-punctuation-face ((t (:foreground ,orange))))

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

(use-package vi-tilde-fringe
  :straight t
  :init (global-vi-tilde-fringe-mode)
  :diminish vi-tilde-fringe-mode)

;;;; AI

(use-package agent-shell
  :straight t)

;; External edits

;; When a file changes outside Emacs (AI agent), recenter on the changed lines and
;; pulse them; lines that were deleted are shown in red as a "ghost" block
;; until point moves or the buffer is edited.

(defvar-local my/revert-snapshot nil)

(defun my/revert-snapshot-before ()
  (setq my/revert-snapshot (buffer-string)))

(defface my/revert-ghost-face
  '((t :inherit diff-removed :extend t))
  "Face for lines deleted from outside Emacs.")

(defvar-local my/revert-ghosts nil)
(defvar-local my/revert-ghost-point nil)

(defun my/revert-clear-ghosts (&rest _)
  "Remove the ghost overlays showing externally deleted lines."
  (mapc #'delete-overlay my/revert-ghosts)
  (setq my/revert-ghosts nil)
  (remove-hook 'post-command-hook #'my/revert-ghost-clear-on-move t)
  (remove-hook 'after-change-functions #'my/revert-clear-ghosts t))

(defun my/revert-ghost-clear-on-move ()
  (unless (eq (point) my/revert-ghost-point)
    (my/revert-clear-ghosts)))

(defun my/revert-show-ghost-lines (pos lines)
  "Show LINES, deleted at POS, until point moves or the buffer is edited."
  (let ((overlay (make-overlay pos pos)))
    (overlay-put overlay 'before-string
                 (propertize (concat (mapconcat #'identity lines "\n") "\n")
                             'face 'my/revert-ghost-face))
    (push overlay my/revert-ghosts)
    (add-hook 'post-command-hook #'my/revert-ghost-clear-on-move nil t)
    (add-hook 'after-change-functions #'my/revert-clear-ghosts nil t)))

(defun my/revert-flash-after ()
  "Recenter on and pulse the lines that changed during a revert.
Externally deleted lines are shown in red until point moves."
  (let ((old my/revert-snapshot))
    (setq my/revert-snapshot nil)
    (my/revert-clear-ghosts)
    (when (and old (not (string= old (buffer-string))) (get-buffer-window))
      (let* ((old-lines (split-string old "\n"))
             (new-lines (split-string (buffer-string) "\n"))
             (prefix 0) (suffix 0))
        ;; Skip the common prefix and suffix of lines.
        (while (and (< prefix (length old-lines)) (< prefix (length new-lines))
                    (string= (nth prefix old-lines) (nth prefix new-lines)))
          (setq prefix (1+ prefix)))
        (while (and (< suffix (- (length old-lines) prefix))
                    (< suffix (- (length new-lines) prefix))
                    (string= (nth (- (length old-lines) suffix 1) old-lines)
                             (nth (- (length new-lines) suffix 1) new-lines)))
          (setq suffix (1+ suffix)))
        (let ((start (save-excursion (goto-char (point-min))
                                     (forward-line prefix) (point)))
              (end (save-excursion (goto-char (point-min))
                                   (forward-line (- (length new-lines) suffix))
                                   (point))))
          ;; A pure deletion leaves no new text behind; show the removed lines
          ;; as a red ghost block and flash the line at the deletion point.
          (when (= end start)
            (my/revert-show-ghost-lines
             start (cl-subseq old-lines prefix (- (length old-lines) suffix)))
            (goto-char start)
            (setq start (line-beginning-position))
            (setq end (line-end-position))
            (when (= end start)
              (setq start (line-beginning-position 0))
              (setq end (save-excursion (goto-char start) (line-end-position)))))
          (require 'pulse)
          (with-selected-window (get-buffer-window)
            (goto-char start)
            (recenter))
          (pulse-momentary-highlight-region start end)
          (setq my/revert-ghost-point (point)))))))

(add-hook 'before-revert-hook #'my/revert-snapshot-before)
(add-hook 'after-revert-hook #'my/revert-flash-after)

;; Misc

(use-package expand-region
  :ensure t
  :bind ("C-=" . er/expand-region))

(use-package crux
  :bind (("C-k"          . crux-kill-whole-line)
         ("C-a"          . crux-move-beginning-of-line)
         ("C-^"          . crux-top-join-line)
         ("C-c K"        . crux-kill-other-buffers)
         ("C-c U"        . crux-reopen-as-root)
         ("C-c C-x r"    . crux-rename-file-and-buffer)
         ("C-c C-x d"    . crux-delete-file-and-buffer)))

(use-package elfeed
  :ensure t
  :config
  (setq elfeed-feeds
        '(
          ("https://archlinux.org/feeds/news/" unix)
          ("https://protesilaos.com/codelog.xml" emacs prot)
          )))


(use-package symbol-overlay
  :ensure t
  :diminish symbol-overlay-mode
  :bind
  (("M-n" . symbol-overlay-jump-next)
   ("M-p" . symbol-overlay-jump-prev))
  :hook
  (prog-mode . symbol-overlay-mode))

(use-package nerd-icons
  :ensure t)

(use-package neotree
  :ensure t
  :bind
  ("C-c t" . neotree-toggle)
  :config
  (setq neo-window-width 33)
  (setq neo-theme
        (if (display-graphic-p)
            'nerd-icons
          'arrow)))

(use-package undo-fu-session
  :hook (after-init . undo-fu-session-global-mode)
  :config
  (setq undo-fu-session-incompatible-files '("/COMMIT_EDITMSG\\'" "/git-rebase-todo\\'")))

(use-package iy-go-to-char
  :straight t
  :config
  :bind (("C-'" . iy-go-to-char)
         ("C-;" . iy-go-to-char-backward)))

;;;; Terminals

(defun my/eshell-prompt ()
  (let ((branch (car (ignore-errors (process-lines "git" "branch" "--show-current"))))
        (dirty  (ignore-errors (process-lines "git" "status" "--porcelain"))))
    (propertize
     (concat (propertize (abbreviate-file-name (eshell/pwd)) 'face 'eshell-ls-directory)
             (when branch
               (propertize (format " (%s%s)" branch (if dirty "*" "")) 'face 'font-lock-string-face))
             (propertize "\nλ " 'face 'font-lock-function-name-face))
     'read-only t 'rear-nonsticky t)))

;; Aliases
(setq eshell-prompt-function #'my/eshell-prompt
      eshell-banner-message ""
      eshell-prompt-regexp "^λ "
      eshell-highlight-prompt nil
      eshell-history-size 10000
      eshell-hist-ignoredups t
      eshell-scroll-to-bottom-on-input 'this
      eshell-destroy-buffer-when-process-dies t
      eshell-command-aliases-list
      '(("ll"  "ls -lh $*")
        ("la"  "ls -lah $*")
        ("e"   "find-file $1")
        ("d"   "dired $1")
        ("clear" "clear 1")
        ("gs"  "git status -sb")
        ("ga"  "git add $*")
        ("gc"  "git commit -m $*")
        ("gca" "git commit --amend")
        ("gp"  "git push")
        ("gpl" "git pull")
        ("gco" "git checkout $*")
        ("gb"  "git branch $*")
        ("gd"  "git --no-pager diff $*")
        ("gl"  "git --no-pager log --oneline --graph --decorate -15")
        ("gm"  "magit-status")))

(use-package ghostel
  :bind (("C-x m" . ghostel)
         :map ghostel-semi-char-mode-map
         ("C-s"  . consult-line)
         ("C-k"  . my/ghostel-send-C-k-and-kill)
         ;; I'm used to go up/down the shell history with M-n/p from eshell
         ;; Simulate this behavior in ghostel by sending C-p and C-n
         ("M-p" . (lambda () (interactive) (ghostel-send-key "p" "ctrl")))
         ("M-n" . (lambda () (interactive) (ghostel-send-key "n" "ctrl"))))
  :config
  (defun my/ghostel-send-C-k-and-kill ()
    "Send `C-k' to ghostel.
Like normal Emacs `C-k'.  Kill to end of line and put content in kill-ring."
    (interactive)
    (kill-ring-save (point) (line-end-position))
    (ghostel-send-key "k" "ctrl"))

  (add-to-list 'ghostel-eval-cmds '("magit-status-setup-buffer" magit-status-setup-buffer)))

(use-package ghostel-project
  :straight nil
  :bind (:map project-prefix-map
              ("m" . ghostel-project)
              ("M" . ghostel-project-list-buffers))
  :config
  (add-to-list 'project-switch-commands '(ghostel-project "Ghostel") t)
  (add-to-list 'project-switch-commands '(ghostel-project-list-buffers "Ghostel buffers") t))

(use-package ghostel-eshell
  :straight nil
  :hook (eshell-load . ghostel-eshell-visual-command-mode))

(use-package ghostel-compile
  :straight nil
  :hook (after-init . ghostel-compile-global-mode))

;;;; Org

(with-eval-after-load 'org
  (keymap-unset org-mode-map "C-c C-k"))

(setq
 org-directory "~/Documents/org"
 org-agenda-files (list "~/Documents/org")
 org-hide-leading-stars t
 org-ellipsis " ▾"
 org-hide-emphasis-markers t
 org-src-tab-acts-natively t
 org-src-fontify-natively t
 org-src-preserve-indentation t
 org-pretty-entities t
 org-preview-latex-default-process 'dvisvgm
 org-startup-with-latex-preview t
 org-image-actual-width nil
 org-image-max-width 450
 org-log-done 'note)

(add-hook 'org-mode-hook
          (lambda ()
            (visual-line-mode 1)
            (electric-pair-local-mode -1)
            (org-indent-mode 1)))

;;;; Org tempo

(with-eval-after-load 'org
  (require 'org-tempo))

(use-package org-download
  :config
  (setq-default org-download-heading-lvl nil
                org-download-image-dir "./images"))

;;;; Literate Programming

(setq org-confirm-babel-evaluate nil
      python-shell-completion-native-enable nil
      org-src-window-setup 'current-window)

(with-eval-after-load 'org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t) (C . t) (shell . t) (java . t) (js . t) (sql . t))))

(use-package verb
  :config
  (setq verb-json-use-mode 'json-ts-mode)

  (with-eval-after-load 'org
    (define-key org-mode-map
                (kbd "C-c C-r")
                verb-command-map))

  (define-key verb-response-body-mode-map
              (kbd "q")
              #'verb-kill-response-buffer-and-window))

;;;; Zen Mode

(use-package olivetti
  :hook ((eww-mode . olivetti-mode)
         (olivetti-mode . mod-olivetti--toggle))
  :bind ("C-c v o" . olivetti-mode)
  :custom (olivetti-body-width 90))

(defvar-local mod-olivetti--state nil)

(defun mod-olivetti--apply-fringes (&rest _)
  (when olivetti-mode
    (dolist (win (get-buffer-window-list (current-buffer) nil t))
      (set-window-fringes win 0 0 nil t))))

(defun mod-olivetti--toggle ()
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
        (add-hook 'window-configuration-change-hook #'mod-olivetti--apply-fringes nil t))
    (cl-destructuring-bind (ln fci ct) mod-olivetti--state
      (when ln (display-line-numbers-mode 1))
      (when fci (display-fill-column-indicator-mode 1))
      (setq-local cursor-type ct)
      (remove-hook 'window-configuration-change-hook #'mod-olivetti--apply-fringes t)
      (dolist (win (get-buffer-window-list (current-buffer) nil t))
        (set-window-fringes win nil nil nil nil)))))

;;;; SQL: Frequent Connections -------------------------------------------------------------------------

(use-package pgsql
  :ensure t)

(use-package sql-indent
  :hook (sql-mode . sqlind-minor-mode))

(use-package sqlup-mode
  :hook ((sql-mode . sqlup-mode)
         (sql-interactive-mode . sqlup-mode)))

;; (use-package sqlformat
;;   :ensure nil
;;   :commands (sqlformat sqlformat-buffer sqlformat-region)
;;   :hook (sql-mode . sqlformat-on-save-mode)
;;   :init
;;   (setq sqlformat-command 'pgformatter
;;         sqlformat-args '("-s2" "-g" "-u2")))

;;
(defun my/sql-send-buffer-to (target)
  "Send current buffer's SQL to TARGET SQLi buffer."
  (interactive
   (list (read-buffer "Send to SQLi: " nil t
                      (lambda (b)
                        (with-current-buffer (if (consp b) (cdr b) b)
                          (derived-mode-p 'sql-interactive-mode))))))
  (let ((sql-buffer (get-buffer target)))
    (sql-send-buffer)))

(global-set-key (kbd "C-c C-a") #'my/sql-send-buffer-to)

;;

(setq sql-postgres-login-params
      '((user :default "postgres")
        (database :default "postgres")
        (server :default "localhost")
        (port :default 5432)))

(add-hook 'sql-interactive-mode-hook
          (lambda ()
            (toggle-truncate-lines t)))

;; --- Clutch ---

;; (use-package clutch
;;   :config
;;   (setq clutch-connection-alist
;;         '(("MyDatabase" . (:backend pg
;;                                     :host "127.0.0.1"
;;                                     :port 5432
;;                                     :user "postgres"
;;                                     :password ""
;;                                     :database "MyDatabase"))
;;           ("talently" . (:backend pg
;;                                   :host "127.0.0.1"
;;                                   :port 5432
;;                                   :user "postgres"
;;                                   :password ""
;;                                   :database "talently")))))

;; --- Frequent Connections ---

(setq sql-connection-alist
      '((postgres
         (sql-product 'postgres)
         (sql-server "127.0.0.1")
         (sql-user "postgres")
         (sql-password "")
         (sql-database "postgres")
         (sql-port 5432))
        (MyDatabase
         (sql-product 'postgres)
         (sql-server "127.0.0.1")
         (sql-user "postgres")
         (sql-password "")
         (sql-database "MyDatabase")
         (sql-port 5432))
        (talently
         (sql-product 'postgres)
         (sql-server "127.0.0.1")
         (sql-user "postgres")
         (sql-password "")
         (sql-database "talently")
         (sql-port 5432))
        (salesdb
         (sql-product 'postgres)
         (sql-server "127.0.0.1")
         (sql-user "postgres")
         (sql-password "")
         (sql-database "salesdb")
         (sql-port 5432))))


;; lsp-mode

;; (setq lsp-sqls-connections
;;       '(((driver . "postgresql")
;;          (dataSourceName . "host=127.0.0.1 port=5432 user=postgres dbname=postgres sslmode=disable"))
;;         ((driver . "postgresql")
;;          (dataSourceName . "host=127.0.0.1 port=5432 user=postgres dbname=MyDatabase sslmode=disable"))
;;         ((driver . "postgresql")
;;          (dataSourceName . "host=127.0.0.1 port=5432 user=postgres dbname=talently sslmode=disable"))
;;         ((driver . "postgresql")
;;          (dataSourceName . "host=127.0.0.1 port=5432 user=postgres dbname=salesdb sslmode=disable"))))



;; --- Prodigy: Long-Running Services -------------------------------------------------------------------------

(use-package prodigy :straight t)

(provide 'init)
;;; init.el ends here
