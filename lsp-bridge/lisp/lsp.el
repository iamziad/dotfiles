;;; lsp.el --- LSP setup with lsp-bridge -*- lexical-binding: t; -*-

;;;; Completion behaviour

(defvar my/lsp-bridge-auto-complete-modes
  '(emacs-lisp-mode lisp-interaction-mode
                    html-mode html-ts-mode web-mode
                    css-mode css-ts-mode)
  "Modes where lsp-bridge completes automatically instead of on TAB.")

(defun my/lsp-bridge-maybe-auto-complete ()
  "Enable automatic completion in `my/lsp-bridge-auto-complete-modes'."
  (when (memq major-mode my/lsp-bridge-auto-complete-modes)
    (setq-local lsp-bridge-complete-manually nil)))

(defun my/lsp-bridge-tab ()
  "Do the most useful thing for TAB, in this order:
1. Accept the selected ACM candidate if the menu is visible.
2. Indent if point is in the leading whitespace of a line.
3. Open the lsp-bridge completion menu if lsp-bridge is active.
4. Fall back to `dabbrev-expand'."
  (interactive)
  (cond
   ((and (bound-and-true-p lsp-bridge-mode)
         (acm-frame-visible-p acm-menu-frame))
    (acm-complete))
   ((save-excursion (skip-chars-backward " \t") (bolp))
    (indent-for-tab-command))
   ((bound-and-true-p lsp-bridge-mode)
    (lsp-bridge-popup-complete-menu))
   (t
    (dabbrev-expand nil))))

(keymap-global-set "TAB" #'my/lsp-bridge-tab)

;;;; Keybindings

(defvar-keymap my/lsp-bridge-map
  :doc "LSP commands (bound under C-c l)."
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

;;;; lsp-bridge

(use-package lsp-bridge
  :straight '(lsp-bridge
              :type git
              :host github
              :repo "manateelazycat/lsp-bridge"
              :files (:defaults "*.el" "*.py" "acm" "core"
                                "langserver" "multiserver" "resources")
              :build (:not compile))
  :hook ((prog-mode . lsp-bridge-mode)
         (lsp-bridge-mode . my/lsp-bridge-maybe-auto-complete))
  :diminish lsp-bridge-mode
  :bind (:map lsp-bridge-mode-map
              ("M-." . lsp-bridge-find-def)
              ("M-," . lsp-bridge-find-def-return)
              ("M-?" . lsp-bridge-find-references))
  :init
  ;; Python from the dedicated venv that runs the lsp-bridge server.
  (setq lsp-bridge-python-command
        (expand-file-name "~/.local/share/lsp-bridge-venv/bin/python"))
  :config
  ;; --- General options ---
  (setq lsp-bridge-complete-manually t          ; auto only in modes listed above
        lsp-bridge-diagnostic-enable-overlays t
        lsp-bridge-enable-hover-diagnostic t
        lsp-bridge-signature-show-function 'lsp-bridge-signature-show-with-frame
        lsp-bridge-enable-with-tramp t
        lsp-bridge-enable-org-babel t
        lsp-bridge-semantic-tokens t)
  (setq-default lsp-bridge-semantic-tokens-ignore-modifier-limit-types ["variable"])

  ;; --- ACM (completion menu) ---
  (setq acm-enable-capf nil
        acm-enable-quick-access t
        acm-doc-frame-max-lines 10
        acm-backend-yas-match-by-trigger-keyword t)

  ;; --- Custom multi-server configs ---
  (setq lsp-bridge-user-multiserver-dir
        (expand-file-name "lsp-bridge/multiserver/" user-emacs-directory))
  (make-directory lsp-bridge-user-multiserver-dir t)

  (add-to-list 'lsp-bridge-multi-lang-server-extension-list
               '(("html") . "html_emmet_tailwindcss")))

;; (add-to-list 'lsp-bridge-multi-lang-server-extension-list '(("css") . "css_tailwindcss"))
;; (add-to-list 'lsp-bridge-multi-lang-server-extension-list '(("js" "mjs" "cjs") . "javascript_eslint"))
;; (add-to-list 'lsp-bridge-multi-lang-server-extension-list '(("ts" "mts" "cts") . "typescript_eslint"))
;; (add-to-list 'lsp-bridge-multi-lang-server-extension-list '(("jsx") . "javascriptreact_eslint"))
;; (add-to-list 'lsp-bridge-multi-lang-server-extension-list '(("tsx") . "typescriptreact_eslint")))

(provide 'lsp)
;;; lsp.el ends here
