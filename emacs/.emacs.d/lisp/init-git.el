;; -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'init-keybindings)

(use-package magit
  :ensure t
  :defer t
  :custom
  (magit-display-buffer-function
   #'magit-display-buffer-same-window-except-diff-v1)
  (magit-save-repository-buffers 'dontask)
  :bind (("C-x g" . my/magit-save-buffer-show-status))
  :config
  (keymap-set magit-mode-map "." #'magit-diff-toggle-refine-hunk))

(use-package gitignore-templates
  :ensure t
  :config
  (setq gitignore-templates-api 'github))

(keymap-set my/leader-map "m l" #'magit-list-repositories)

;; (use-package diff-hl
;;   :bind (("M-{" . diff-hl-previous-hunk)
;;          ("M-}" . diff-hl-next-hunk))
;;   :custom (diff-hl-update-async t)
;;   :init (global-diff-hl-mode)
;;   :config
;;   (diff-hl-show-hunk-mouse-mode 1)
;;   (diff-hl-flydiff-mode 1))

;;; Utilities

(defun my/magit-status ()
  "Open a `magit-status' buffer and close the other window so only Magit is visible.
If a file was visited in the buffer that was active when this
command was called, go to its unstaged changes section."
  (interactive)
  (let* ((buffer-file-path (when buffer-file-name
                             (file-relative-name buffer-file-name
                                                 (locate-dominating-file buffer-file-name ".git"))))
         (section-ident `((file . ,buffer-file-path) (unstaged) (status))))
    (call-interactively #'magit-status)
    (delete-other-windows)
    (when buffer-file-path
      (goto-char (point-min))
      (cl-loop until (when (equal section-ident (magit-section-ident (magit-current-section)))
                       (magit-section-show (magit-current-section))
                       (recenter)
                       t)
               do (condition-case nil
                      (magit-section-forward)
                    (error (cl-return (magit-status-goto-initial-section-1))))))))

(defun my/magit-save-buffer-show-status ()
  "Save buffer and show its changes in `magit-status'."
  (interactive)
  (save-buffer)
  (my/magit-status))

(provide 'init-git)
