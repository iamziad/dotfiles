;;; mod-navigation.el --- Custom hjkl-style navigation layer -*- lexical-binding: t; -*-

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

;; Modes where C-h/C-j/C-k/C-l/C-f/C-b are meaningful REPL/terminal keys
;; and shouldn't be shadowed. Add to this list whenever you find another
;; mode with the same problem - this is the single place to check.
(defvar my-nav-excluded-modes
  '(term-mode vterm-mode shell-mode comint-mode eshell-mode))

(defun my-nav-mode--maybe-enable ()
  (unless (or (minibufferp)
              (apply #'derived-mode-p my-nav-excluded-modes))
    (my-nav-mode 1)))

(define-globalized-minor-mode global-my-nav-mode my-nav-mode my-nav-mode--maybe-enable)
(global-my-nav-mode 1)

;; Minibuffer gets its own light nav: history instead of line motion.
(defun my-setup-minibuffer-navigation ()
  (local-set-key (kbd "C-p") #'previous-history-element)
  (local-set-key (kbd "C-n") #'next-history-element)
  (local-set-key (kbd "C-h") #'backward-char)
  (local-set-key (kbd "C-l") #'forward-char))
(add-hook 'minibuffer-setup-hook #'my-setup-minibuffer-navigation)

;; --- Known per-mode conflicts ---------------------------------------------
;; Keep every "unbind C-j/C-k because mode X uses it" patch here, next to
;; the feature that causes the need for it, instead of scattered across
;; each mode's own module.
(with-eval-after-load 'magit
  (define-key magit-hunk-section-map (kbd "C-j") nil)
  (define-key magit-diff-section-base-map (kbd "C-j") nil)
  (define-key magit-file-section-map (kbd "C-j") nil)
  (define-key magit-diff-mode-map (kbd "C-j") nil))

(provide 'mod-navigation)
;;; mod-navigation.el ends here
