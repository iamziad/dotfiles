;; -*- lexical-binding: t; -*-

(bind-keys*
 ("C-}"      . forward-paragraph)
 ("C-{"      . backward-paragraph)
 ("C-,"      . duplicate-dwim)
 ("C-c e e"  . eshell)
 ("C-c e o"  . my/eshell-other-window)
 ("C-c c"    . compile)
 ("C-c C"    . recompile)
 ("C-c f"    . find-file-at-point)
 ("C-c C-f"  . find-file-other-window)
 ("C-x C-k"  . kill-buffer-and-window)
 ("C-<tab>"  . mode-line-other-buffer)
 ("C-x C-j"  . dired-jump)
 ("C-x g"    . magit-status)
 ("C-c ?"    . which-key-show-top-level)
 ("C-c w 1"  . my/kill-other-windows-and-buffers)
 ("C-c w b"  . my/window-right-to-below)
 ("C-c w r"  . my/window-below-to-right)
 )

(bind-keys :prefix-map my-leader-map
           :prefix "C-z"
           ("c"   . org-capture)
           ("t"   . org-babel-tangle)
           ("s"   . org-download-clipboard)
           ("m l" . magit-list-repositories)
           ("r"   . my/quick-mark)
           ("j"   . my/quick-jump)
           )

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

;; (use-package ace-window
;;   :ensure t
;;   :bind (("M-o" . ace-window)
;;          ("M-s s" . ace-swap-window))
;;   :config
;;   (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

;; Tabs
(setq tab-bar-show 1)

(dolist (i (number-sequence 1 9))
  (keymap-global-set (format "M-%d" i)
                     (lambda () (interactive) (tab-bar-select-tab i))))
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

;;; Utilities

(defun my/quick-mark (char)
  "Save current position in register CHAR."
  (interactive (list (read-char "Mark to register: ")))
  (point-to-register char)
  (message "Saved to register %c" char))

(defun my/quick-jump (char)
  "Jump to the position stored in register CHAR."
  (interactive (list (read-char "Jump to register: ")))
  (jump-to-register char))

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

(defun my/window-right-to-below ()
  "Move the window to the right of the selected window to below it."
  (interactive)
  (let ((win (window-in-direction 'right)))
    (if (not win)
        (message "No window at the right")
      (let ((buf (window-buffer win)))
        (delete-window win)
        (set-window-buffer (split-window-below) buf)))))

(defun my/window-below-to-right ()
  "Move the window below the selected window to the right of it."
  (interactive)
  (let ((win (window-in-direction 'below)))
    (if (not win)
        (message "No window at the bottom")
      (let ((buf (window-buffer win)))
        (delete-window win)
        (set-window-buffer (split-window-right) buf)))))

(defun my/eshell-other-window ()
  "."
  (interactive)
  (let ((buf (save-window-excursion (eshell))))
    (pop-to-buffer buf)))

(provide 'init-keys)
