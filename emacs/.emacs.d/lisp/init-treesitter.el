;;; init-treesitter.el --- Tree-sitter grammar setup -*- lexical-binding: t; -*-

(require 'seq)
(require 'treesit)

(setq treesit-font-lock-level 4)

(setq treesit-language-source-alist
      '((javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
        (tsx        "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
        (html       "https://github.com/tree-sitter/tree-sitter-html"       "master" "src")
        (css        "https://github.com/tree-sitter/tree-sitter-css"        "master" "src")
        (json       "https://github.com/tree-sitter/tree-sitter-json"       "master" "src")
        (jsdoc      "https://github.com/tree-sitter/tree-sitter-jsdoc"      "master" "src")))

(defvar my/treesit-grammars
  '(javascript typescript tsx html css json jsdoc)
  "Tree-sitter grammars used by this configuration.")

(defun my/treesit-missing-grammars ()
  "Return the tree-sitter grammars that are not installed."
  (seq-remove #'treesit-language-available-p my/treesit-grammars))

(defun my/treesit-ensure-grammars ()
  "Install any missing tree-sitter grammars."
  (interactive)
  (if-let* ((missing (my/treesit-missing-grammars)))
      (progn
        (dolist (language missing)
          (message "Installing tree-sitter grammar: %s" language)
          (treesit-install-language-grammar language))
        (message "Tree-sitter grammars installed: %s"
                 (mapconcat #'symbol-name missing ", ")))
    (message "All tree-sitter grammars are installed.")))

(defun my/treesit-report-missing-grammars ()
  "Report missing tree-sitter grammars without installing them."
  (interactive)
  (if-let* ((missing (my/treesit-missing-grammars)))
      (message "Missing tree-sitter grammars: %s (run M-x my/treesit-ensure-grammars)"
               (mapconcat #'symbol-name missing ", "))
    (message "All tree-sitter grammars are installed.")))

;; Keep the old command name working.
(defalias 'my/treesit-setup #'my/treesit-ensure-grammars)

(provide 'init-treesitter)
;;; init-treesitter.el ends here
