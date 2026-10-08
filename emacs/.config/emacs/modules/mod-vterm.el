;;; -*- lexical-binding: t; -*-


(use-package vterm
  :init (setq vterm-always-compile-module t)
  :custom (vterm-max-scrollback 10000)
  :config
  (add-hook 'vterm-mode-hook            ; killing a vterm shouldn't nag
            (lambda ()
              (setq-local kill-buffer-query-functions
                          (remq 'process-kill-buffer-query-function
                                kill-buffer-query-functions)))))

(defun my/vterm-buffer ()
  "Return this project's vterm buffer, creating it if needed."
  (let* ((root (if-let* ((pr (project-current))) (project-root pr) default-directory))
         (name (format "*vterm: %s*" (abbreviate-file-name root))))
    (or (get-buffer name)
        (let ((default-directory root))
          (save-window-excursion (vterm name))
          (get-buffer name)))))

(defun my/vterm-project ()
  "Show the project vterm in this window; again to go back."
  (interactive)
  (let* ((buf (my/vterm-buffer))
         (win (get-buffer-window buf)))
    (cond ((and win (window-parameter win 'window-side)) ; panel -> full window
           (delete-window win)
           (switch-to-buffer buf))
          ((eq (current-buffer) buf) (switch-to-prev-buffer))
          (t (switch-to-buffer buf)))))

(defun my/vterm-toggle ()
  "Toggle the project vterm in a bottom side window."
  (interactive)
  (let* ((buf (my/vterm-buffer))
         (win (get-buffer-window buf)))
    (if (and win (window-parameter win 'window-side))
        (delete-window win)
      (when win (switch-to-prev-buffer win)) ; was full window: hand it back
      (when-let* ((w (display-buffer-in-side-window
                      buf '((side . bottom) (window-height . 0.40)))))
        (select-window w)))))

(defun my/vterm-new (name)
  "Create a new vterm buffer with a custom NAME and the project name."
  (interactive "sBuffer name: ")
  (let* ((root (if-let* ((pr (project-current))) (project-root pr) default-directory))
         (project-name (abbreviate-file-name root))
         (buf-name (format "*vterm: %s - %s*" project-name name)))
    (unless (get-buffer buf-name)
      (save-window-excursion (vterm buf-name)))
    (switch-to-buffer (get-buffer buf-name))))


(keymap-global-set "C-c t o" #'vterm-other-window)
(keymap-global-set "C-c t n" #'my/vterm-new)
(keymap-global-set "C-c k" #'my/vterm-project) ; project vterm, full window
(keymap-global-set "C-`"   #'my/vterm-toggle)  ; same buffer, bottom panel

(provide 'mod-vterm)
