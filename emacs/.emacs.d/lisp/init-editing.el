;;; init-editing.el --- Editing enhancements -*- lexical-binding: t; -*-

(require 'init-keybindings)

(declare-function selected-off "selected" ())

;;; Whitespace and deleting ---------------------------------------------------

(use-package smart-hungry-delete
  :ensure t
  :bind (([remap backward-delete-char-untabify] . smart-hungry-delete-backward-char)
         ([remap delete-backward-char]          . smart-hungry-delete-backward-char)
         ([remap delete-char]                   . smart-hungry-delete-forward-char))
  :init
  (smart-hungry-delete-add-default-hooks))

(use-package whitespace-cleanup-mode
  :ensure t
  :custom
  (whitespace-cleanup-mode-preserve-point t)
  (whitespace-cleanup-mode-only-if-initially-clean nil)
  :diminish whitespace-cleanup-mode
  :config
  (global-whitespace-cleanup-mode 1))

;;; Structural editing --------------------------------------------------------

(use-package expand-region
  :ensure t
  :bind ("C-=" . er/expand-region))

(use-package drag-stuff
  :ensure t
  :diminish drag-stuff-mode
  :config
  (drag-stuff-global-mode 1)
  (drag-stuff-define-keys))

(use-package multiple-cursors
  :ensure t
  :bind (("C->"           . mc/mark-next-like-this)
         ("C-<"           . mc/mark-previous-like-this)
         ("C-M-<"         . mc/skip-to-previous-like-this)
         ("C-M->"         . mc/skip-to-next-like-this)
         ("C-c m d"       . mc/mark-all-dwim)
         ("C-c m a"       . mc/mark-all-like-this)
         ("C-c m n"       . mc/insert-numbers)
         ("C-c m e"       . mc/edit-lines)
         ("<C-M-mouse-1>" . mc/add-cursor-on-click))
  :config
  (require 'mc-hide-unmatched-lines-mode)
  (setq mc/always-run-for-all t))

;;; Crux ----------------------------------------------------------------------

(use-package crux
  :ensure t
  :bind
  (("C-j"                              . crux-top-join-line)
   ("M-C-m"                            . crux-smart-open-line)
   ("M-<backspace>"                    . crux-kill-whole-line)
   ("C-c K"                            . crux-kill-other-buffers)
   ("C-c U"                            . crux-reopen-as-root-mode)
   ("C-c C-x r"                        . crux-rename-file-and-buffer)
   ("C-c C-x d"                        . crux-delete-file-and-buffer)
   ("<remap> <move-beginning-of-line>" . crux-move-beginning-of-line)))

;;; Region commands -----------------------------------------------------------

(use-package selected
  :ensure t
  :diminish selected-minor-mode
  :hook ((text-mode prog-mode) . selected-minor-mode)
  :init
  (defvar selected-org-mode-map (make-sparse-keymap))
  :config
  ;; Bind after `selected' is loaded: `selected-keymap' does not exist before
  ;; then, so a :bind form would fail during startup.
  (keymap-set selected-keymap "q" #'selected-off)
  (keymap-set selected-keymap "u" #'upcase-region)
  (keymap-set selected-keymap "d" #'downcase-region)
  (keymap-set selected-keymap "w" #'count-words-region)
  ;; Multiple cursors
  (keymap-set selected-keymap "v" #'mc/vertical-align-with-space)
  (keymap-set selected-keymap "a" #'mc/mark-all-dwim)
  (keymap-set selected-keymap "A" #'mc/mark-all-like-this)
  (keymap-set selected-keymap "m" #'mc/mark-more-like-this-extended)
  (keymap-set selected-keymap "p" #'mc/mark-previous-like-this)
  (keymap-set selected-keymap "P" #'mc/unmark-previous-like-this)
  (keymap-set selected-keymap "S" #'mc/skip-to-previous-like-this)
  (keymap-set selected-keymap "n" #'mc/mark-next-like-this)
  (keymap-set selected-keymap "N" #'mc/unmark-next-like-this)
  (keymap-set selected-keymap "s" #'mc/skip-to-next-like-this)
  (keymap-set selected-keymap "r" #'mc/edit-lines)
  (keymap-set selected-org-mode-map "t" #'org-table-convert-region))

;;; Register helpers ----------------------------------------------------------

(defun my/quick-mark (char)
  "Save the current position in register CHAR."
  (interactive (list (read-char "Mark to register: ")))
  (point-to-register char)
  (message "Saved to register %c" char))

(defun my/quick-jump (char)
  "Jump to the position stored in register CHAR."
  (interactive (list (read-char "Jump to register: ")))
  (jump-to-register char))

(keymap-set my/leader-map "r" #'my/quick-mark)
(keymap-set my/leader-map "j" #'my/quick-jump)

(provide 'init-editing)
;;; init-editing.el ends here
