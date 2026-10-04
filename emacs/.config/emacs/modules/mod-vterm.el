;;; -*- lexical-binding: t; -*-
(use-package vterm
  :commands (vterm)
  :init (setq vterm-always-compile-module t)
  :bind (("C-c k"         . my/vterm-full)
         ("C-`"           . my/vterm-toggle)
         ("C-c T"         . my/vterm-new))
  :custom
  (vterm-max-scrollback 10000)
  (vterm-kill-buffer-on-exit t)
  (vterm-timer-delay 0.01))

(add-hook 'vterm-mode-hook
          (lambda ()
            (setq-local kill-buffer-query-functions
                        (delq 'process-kill-buffer-query-function
                              kill-buffer-query-functions))))

(defun my/side-window-p (win)
  "Non-nil if WIN is a side window (the bottom panel)."
  (window-parameter win 'window-side))

(defun my/vterm--project-buffer ()
  "Return the vterm buffer for the current project, creating it if needed."
  (let* ((root (if-let* ((pr (project-current)))
                   (project-root pr)
                 default-directory))
         (name (format "*vterm: %s*" (abbreviate-file-name root))))
    (or (get-buffer name)
        (let ((default-directory root))
          (save-window-excursion (vterm name))
          (get-buffer name)))))

(defun my/vterm-full ()
  "Show the project vterm in the current window.
Pressing it again from inside that window goes back to the previous buffer."
  (interactive)
  (let ((buf (my/vterm--project-buffer)))
    (if (and (eq (current-buffer) buf)
             (not (my/side-window-p (selected-window))))
        (switch-to-prev-buffer)
      ;; Never show the same buffer twice: close the panel first.
      (dolist (w (get-buffer-window-list buf nil))
        (when (my/side-window-p w)
          (delete-window w)))
      ;; Always end up in a regular (non-side) window.
      (let ((target (if (my/side-window-p (selected-window))
                        (seq-find (lambda (x) (not (my/side-window-p x)))
                                  (window-list))
                      (selected-window))))
        (when target
          (select-window target)
          (switch-to-buffer buf))))))

(defun my/vterm-toggle ()
  "Toggle the project vterm in the bottom panel."
  (interactive)
  (let* ((buf   (my/vterm--project-buffer))
         (wins  (get-buffer-window-list buf nil))
         (panel (seq-find #'my/side-window-p wins)))
    (if panel
        (delete-window panel)
      ;; If it is currently full-window, hand that window its old buffer back.
      (dolist (w wins) (switch-to-prev-buffer w))
      (when-let* ((win (display-buffer buf)))
        (select-window win)))))

(defun my/vterm-new ()
  "Open a brand-new vterm in the current window."
  (interactive)
  (vterm (generate-new-buffer-name "*vterm*")))

;; Terminal and compilation share one bottom panel.
(add-to-list 'display-buffer-alist
             '("\\*\\(vterm: .*\\|compilation\\)\\*"
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . bottom) (slot . 0) (window-height . 0.40)))

(provide 'mod-vterm)
