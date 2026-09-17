;;; mod-dired.el --- -*- lexical-binding: t; -*-

(require 'dired-x)

(setq delete-by-moving-to-trash t)


(use-package dired-subtree
  :commands (dired-subtree-toggle dired-subtree-cycle)
  :config
  (setq dired-subtree-line-prefix " ")
  (setq dired-subtree-use-backgrounds nil))

(use-package dired-sidebar
  :bind (("C-c e" . dired-sidebar-toggle-sidebar))
  :ensure t
  :commands (dired-sidebar-toggle-sidebar)
  :init
  (add-hook 'dired-sidebar-mode-hook
            (lambda ()
              (unless (file-remote-p default-directory)
                (auto-revert-mode))))
  :config
  (push 'toggle-window-split dired-sidebar-toggle-hidden-commands)
  (push 'rotate-windows dired-sidebar-toggle-hidden-commands)

  (setq dired-sidebar-theme 'vscode)
  (setq dired-sidebar-use-term-integration t)
  (setq dired-sidebar-use-custom-font t))

(use-package image-dired
  :ensure nil
  :config
  (setq image-dired-thumbnail-storage 'standard))
;; :bind (:map dired-mode-map
;;             ("C-d i" . image-dired)))

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
  (if (file-remote-p buffer-file-name)
      (find-alternate-file
       (tramp-file-name-localname
        (tramp-dissect-file-name buffer-file-name)))
    (find-alternate-file
     (concat "/sudo::" buffer-file-name))))

(provide 'mod-dired)
