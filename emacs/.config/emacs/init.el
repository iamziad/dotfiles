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
 frame-title-format "Emacs"
 use-short-answers t
 enable-recursive-minibuffers t
 tab-always-indent 'complete
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

;; Language & Encoding
(setq default-input-method "arabic"
      eshell-banner-message "")

;; Aliases & Keybindings
(defalias 'yes-or-no-p 'y-or-n-p)

(when (window-system)
  (setq x-gtk-use-system-tooltips nil
        cursor-type 'box
        cursor-in-non-selected-windows nil))

;; Clipboard & Selection
(setq select-enable-clipboard t
      select-enable-primary t
      select-active-regions nil)

;; Scrolling & Search
(setq scroll-margin 0
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

(add-hook
 'after-init-hook
 (lambda ()
   (dolist (mode '(hl-line-mode
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
                   size-indication-mode
                   minibuffer-depth-indicate-mode
                   show-paren-mode
                   which-key-mode
                   editorconfig-mode
                   context-menu-mode))
     (funcall mode 1))))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;;;; Remote files

(setq tramp-verbose 1
      remote-file-name-inhibit-cache 50
      remote-file-name-inhibit-locks t
      remote-file-name-inhibit-auto-save-visited t)

;;;; Spelling

(setq flyspell-issue-message-flag nil
      flyspell-issue-welcome-flag nil
      ispell-silently-savep t)

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
 ("C-x t h"       . tab-previous)
 ("C-x t l"       . tab-next))

;;;; External edits

;; When a file changes outside Emacs, recenter on the changed lines and
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

;;;; Tools

;; Shared helpers: the mason package installer and the tree-sitter support
;; used by the language sections further down.

(defconst my/mason-dir
  (expand-file-name "mason" user-emacs-directory))

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
  :commands (mason-manager mason-install mason-installed-p mason-setup))

;;;; Tree-sitter

(require 'treesit)

(dolist (feature '(js java-ts-mode typescript-ts-mode css-mode
                      html-ts-mode json-ts-mode))
  (require feature nil t))

(defvar my/treesit-languages nil
  "Tree-sitter grammars used by this configuration.")

(defun my/treesit-grammar (language)
  "Register LANGUAGE so `my/install-treesit-grammars' can install it."
  (add-to-list 'my/treesit-languages language t))

(defun my/treesit-remap (language old-mode new-mode)
  "Use NEW-MODE for OLD-MODE once the LANGUAGE grammar is available."
  (my/treesit-grammar language)
  (when (and (fboundp new-mode)
             (treesit-ready-p language t)
             (or (not (eq new-mode 'js-ts-mode))
                 (treesit-ready-p 'jsdoc t)))
    (add-to-list 'major-mode-remap-alist (cons old-mode new-mode))))

(defun my/install-treesit-grammars ()
  "Install every tree-sitter grammar this configuration uses."
  (interactive)
  (dolist (language my/treesit-languages)
    (unless (treesit-language-available-p language)
      (treesit-install-language-grammar language))))

;;;; Completion and UI

(setq which-key-idle-delay 0.4)

(use-package vertico
  :custom
  (vertico-scroll-margin 0)
  (vertico-count 15)
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
         ("C-c s" . consult-line)
         ("C-c S" . consult-ripgrep)
         ("C-c i" . consult-imenu)
         ("M-g g" . consult-goto-line)
         ("M-g M-g" . consult-goto-line)))

(use-package marginalia
  :config
  (marginalia-mode 1))

;;;; Git

(use-package magit
  :bind ("C-x g" . magit-status))

(use-package diff-hl
  :config
  (global-diff-hl-mode 1)
  :bind (("M-{" . diff-hl-previous-hunk)
         ("M-}" . diff-hl-next-hunk)))

;;;; Editing utilities

(use-package hl-todo
  :hook ((prog-mode yaml-mode conf-mode) . hl-todo-mode))

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

;;;; LSP

(use-package yasnippet
  :config
  (yas-global-mode 1))

(use-package lsp-bridge
  :straight (lsp-bridge :type git :host github :repo "manateelazycat/lsp-bridge"
                        :files (:defaults "*.py" "acm" "core" "langserver"
                                          "multiserver" "resources")
                        :build (:not compile))
  :custom
  (lsp-bridge-python-command (my/lsp-bridge-python))
  (lsp-bridge-enable-hover-diagnostic t)
  (acm-enable-icon nil)
  :config
  ;; Combos that lsp-bridge ships itself.  Anything else is generated by
  ;; `my/lsp-combo-ensure' in the next section.
  (setq lsp-bridge-multi-lang-server-extension-list
        '((("vue") . "volar_emmet")
          (("component.html") . "angular_template_html")
          (("component.ts") . "angular_template_typescript")))
  (global-lsp-bridge-mode))

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

;; lsp-bridge runs one server per buffer unless it finds a combo file
;; describing how to combine several (say TypeScript + ESLint + Tailwind).
;; Rather than hand-writing those JSON files, the combos are described here
;; and written on demand by `my/lsp-combo-ensure'.
;;
;; To support another framework, add one row to `my/lsp-combo-table'.
;; `eslint' and `tailwind' are optional servers: a combo only uses them
;; when the project actually configures them.  Run `M-x my/lsp-combo-refresh'
;; after changing the table; `M-x my/lsp-combo-for-file' shows which combo
;; a file would use.

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
  "Multiserver combos, one row per framework.

FRAMEWORK names the combo; SERVER is the lsp-bridge language server that
does the real work.  FILES lists the extensions handled by the combo, and
OPTIONAL-SERVERS the extra servers it may add:

  eslint    ./eslint.config.* or ./.eslintrc* above the file
  tailwind  a tailwind.config.* or a package.json mentioning tailwindcss")

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

(defun my/lsp-combo-ensure (row eslint tailwind &optional force)
  "Return the name of ROW's combo, writing its JSON file when needed.
ESLINT and TAILWIND are the lsp-bridge server names, or nil.  With FORCE,
overwrite an existing file."
  (pcase-let* ((`(,framework ,server ,_files ,_optional) row)
               (name (concat framework
                             (and eslint "_eslint")
                             (and tailwind "_tailwindcss")))
               (file (my/lsp-combo-file name)))
    (when (and (or force (not (file-exists-p file)))
               (not (my/lsp-combo-bundled-p name)))
      (make-directory my/lsp-bridge-multiserver-dir t)
      (write-region (json-encode (my/lsp-combo-spec server eslint tailwind))
                    nil file nil 'silent))
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

(defun my/lsp-bridge-multiserver (_project-path file)
  "Choose the lsp-bridge combo for FILE, or nil for the default server."
  (when-let* ((extension (file-name-extension file))
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

;; npm / pnpm / yarn / bun scripts -> compilation buffer
(defun my/npm--manager (root)
  (cond ((file-exists-p (expand-file-name "pnpm-lock.yaml" root)) "pnpm")
        ((file-exists-p (expand-file-name "yarn.lock" root)) "yarn")
        ((or (file-exists-p (expand-file-name "bun.lockb" root))
             (file-exists-p (expand-file-name "bun.lock" root))) "bun")
        (t "npm")))

(defun my/npm-run ()
  "Pick a script from the nearest package.json and run it with `compile'."
  (interactive)
  (let* ((root (or (locate-dominating-file default-directory "package.json")
                   (user-error "No package.json found")))
         (default-directory root)
         (pkg (with-temp-buffer
                (insert-file-contents "package.json")
                (goto-char (point-min))
                (json-parse-buffer :object-type 'alist)))
         (scripts (mapcar (lambda (c) (symbol-name (car c))) (alist-get 'scripts pkg)))
         (script (completing-read "Run script: " scripts nil t)))
    (compile (format "%s run %s" (my/npm--manager root) script))))

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

(my/treesit-remap 'java 'java-mode 'java-ts-mode)

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
  "Delete cached jdtls configs generated before the java-debug bundle fix."
  (let ((dir (expand-file-name "~/.cache/lsp-bridge-jdtls")))
    (dolist (file (and (file-directory-p dir)
                       (directory-files-recursively dir "jdtls\\.json")))
      (with-temp-buffer
        (insert-file-contents file)
        (unless (search-forward "bundles" nil t)
          (delete-file file))))))

(my/prune-stale-jdtls-configs)

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
(defvar my/java-debug-start-delay 3)

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
                 (lambda ()
                   (when (buffer-live-p buffer)
                     (with-current-buffer buffer
                       (call-interactively #'dape))))))))
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
  :mode (("\\.hbs\\'" . web-mode)
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
    (custom-set-faces
     `(font-lock-misc-punctuation-face ((t (:foreground ,(doom-color 'orange)))))
     ))

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
  :init (global-vi-tilde-fringe-mode))

;;;; AI

(use-package agent-shell
  :straight t)

(provide 'init)
;;; init.el ends here

