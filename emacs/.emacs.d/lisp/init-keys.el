;; -*- lexical-binding: t; -*-

(bind-keys*
 ("C-}" . forward-paragraph)
 ("C-{" . backward-paragraph)
 ("C-," . duplicate-dwim)
 ("C-c e" . eshell)
 ("C-c c" . project-compile)
 ("C-c C" . recompile)
 ("C-c f" . find-file-at-point)
 ("C-c C-f" . find-file-other-window)
 ("C-x C-k" . kill-buffer-and-window)
 ("C-<tab>" . mode-line-other-buffer)
 ("C-x C-j" . dired-jump)
 ("C-c p" . project-prefix-map)
 ("C-x g" . magit-status)
 ("C-c ?" . which-key-show-top-level)
 )

(defun my/kill-other-windows-and-buffers ()
  "Kill the buffers shown in other windows, then delete those windows.
The current buffer is never killed, even if it is also shown elsewhere."
  (interactive)
  (let* ((current (selected-window))
         (buffers (seq-uniq
                   (mapcar #'window-buffer
                           (remq current (window-list nil 'no-minibuf))))))
    (dolist (buf (remq (current-buffer) buffers))
      (when (buffer-live-p buf)
        (kill-buffer buf)))
    (delete-other-windows)))

(keymap-global-set "C-c w 1" #'my/kill-other-windows-and-buffers)

;; Windmove
(defvar-keymap my/windmove-repeat-map
  :repeat t
  "h" #'windmove-left
  "l" #'windmove-right
  "k" #'windmove-up
  "j" #'windmove-down)
(keymap-global-set "C-c w h" #'windmove-left)
(keymap-global-set "C-c w l" #'windmove-right)
(keymap-global-set "C-c w k" #'windmove-up)
(keymap-global-set "C-c w j" #'windmove-down)

;; Tabs
(setq tab-bar-show 1)

(dolist (i (number-sequence 1 9))
  (keymap-global-set (format "M-%d" i)
                     (lambda () (interactive) (tab-bar-select-tab i))))
(keymap-global-set "C-x t k" #'tab-close)
(keymap-global-set "C-x t o" #'tab-close-other)

(use-package crux
  :bind
  (("C-j"                              . crux-top-join-line)
   ("M-<return>"                       . crux-smart-open-line)
   ("M-<backspace>"                    . crux-kill-whole-line)
   ;; ("C-k"                              . crux-kill-whole-line)
   ("C-c K"                            . crux-kill-other-buffers)
   ("C-c U"                            . crux-reopen-as-root)
   ("C-c C-x r"                        . crux-rename-file-and-buffer)
   ("C-c C-x d"                        . crux-delete-file-and-buffer)
   ("<remap> <move-beginning-of-line>" . crux-move-beginning-of-line)))

(provide 'init-keys)
