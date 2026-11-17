;;; init-keybindings.el --- Global keybindings and window commands -*- lexical-binding: t; -*-

(require 'seq)
(require 'winner)

(declare-function my/toggle-fold "init-prog" ())

;;; General bindings ----------------------------------------------------------

(bind-keys*
 ("C-}"      . forward-paragraph)
 ("C-{"      . backward-paragraph)
 ("C-,"      . duplicate-dwim)
 ("C-c f"    . find-file-at-point)
 ("C-c C-f"  . find-file-other-window)
 ("C-x C-k"  . kill-buffer-and-window)
 ("C-<tab>"  . mode-line-other-buffer)
 ("C-c ?"    . which-key-show-top-level))

;;; Leader map ----------------------------------------------------------------

(defvar-keymap my/leader-map
  :doc "Personal leader map (C-z).")
(keymap-global-set "C-z" my/leader-map)

;;; Window management ---------------------------------------------------------

(defvar-keymap my/window-map
  :doc "Window management (C-c w)."
  "h" #'windmove-left
  "j" #'windmove-down
  "k" #'windmove-up
  "l" #'windmove-right
  "o" #'other-window
  "d" #'delete-window
  "D" #'delete-other-windows
  "=" #'balance-windows
  "u" #'winner-undo
  "r" #'winner-redo
  "s" #'split-window-right
  "b" #'split-window-below
  "x" #'kill-buffer-and-window
  "1" #'my/kill-other-windows-and-buffers
  "B" #'my/window-right-to-below
  "R" #'my/window-below-to-right)

(defvar-keymap my/windmove-repeat-map
  :doc "Repeat map for window movement."
  :repeat t
  "h" #'windmove-left
  "j" #'windmove-down
  "k" #'windmove-up
  "l" #'windmove-right
  "d" #'delete-window
  "x" #'kill-buffer-and-window
  "1" #'delete-other-windows)

(keymap-global-set "C-c w" my/window-map)

;;; Toggle map ----------------------------------------------------------------

(defvar-keymap my/toggle-map
  :doc "Toggles (C-c t)."
  "f" #'my/toggle-fold
  "s" #'toggle-scroll-bar
  "l" #'display-line-numbers-mode)

(keymap-global-set "C-c t" my/toggle-map)

;;; Window commands -----------------------------------------------------------

(defun my/kill-other-windows-and-buffers ()
  "Kill buffers shown in other windows, then delete those windows.
The current buffer is never killed, even if it is shown elsewhere."
  (interactive)
  (let* ((current (selected-window))
         (buffers (seq-uniq
                   (mapcar #'window-buffer
                           (remq current (window-list nil 'no-minibuf))))))
    (dolist (buf (remq (current-buffer) buffers))
      (when (buffer-live-p buf)
        (kill-buffer buf)))
    (delete-other-windows)))

(defun my/window-right-to-below ()
  "Move the window to the right of any window to below the current one."
  (interactive)
  (let* ((curr (selected-window))
         (win (window-in-direction 'right curr)))
    (if (not win)
        (message "No window to the right")
      (let ((buf (window-buffer win)))
        (delete-window win)
        (select-window curr)
        (set-window-buffer (split-window-below) buf)))))

(defun my/window-below-to-right ()
  "Move the window below any window to the right of the current one."
  (interactive)
  (let* ((curr (selected-window))
         (win (window-in-direction 'below curr)))
    (if (not win)
        (message "No window below")
      (let ((buf (window-buffer win)))
        (delete-window win)
        (select-window curr)
        (set-window-buffer (split-window-right) buf)))))

(provide 'init-keybindings)
;;; init-keybindings.el ends here
