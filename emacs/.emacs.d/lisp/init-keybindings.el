;;; init-keybindings.el --- Mod keybindings -*- lexical-binding: t; -*-

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
 ("C-x g"    . magit-status)
 ("C-c ?"    . which-key-show-top-level))

(bind-keys :prefix-map my-leader-map
           :prefix "C-z"
           ("c"   . org-capture)
           ("t"   . org-babel-tangle)
           ("s"   . org-download-clipboard)
           ("m l" . magit-list-repositories)
           ("r"   . my/quick-mark)
           ("j"   . my/quick-jump)
           )

(defvar-keymap my/window-map
  :doc "Window management"
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
  :repeat t
  "h" #'windmove-left
  "j" #'windmove-down
  "k" #'windmove-up
  "l" #'windmove-right
  "d" #'delete-window
  "x" #'kill-buffer-and-window
  "1" #'delete-other-windows)

(keymap-global-set "C-c w" my/window-map)

(defvar-keymap my/search-map
  :doc "Search commands (C-c s)."
  "s" #'consult-line
  "r" #'my/search-project
  "g" #'consult-grep
  "o" #'consult-outline
  "i" #'consult-imenu
  "m" #'consult-mark)

(keymap-global-set "C-c s" my/search-map)

(defvar-keymap my/toggle-map
  :doc "Toggles (C-c t)."
  "f" #'my/toggle-fold
  "s" #'toggle-scroll-bar
  "l" #'display-line-numbers-mode)

(keymap-global-set "C-c t" my/toggle-map)

;; (use-package ace-window
;;   :ensure t
;;   :bind (("M-o" . ace-window)
;;          ("M-s s" . ace-swap-window))
;;   :config
;;   (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

(use-package crux
  :bind
  (("C-j"                              . crux-top-join-line)
   ("M-C-m"                            . crux-smart-open-line)
   ("M-<backspace>"                    . crux-kill-whole-line)
   ;; ("C-k"                              . crux-kill-whole-line)
   ("C-c K"                            . crux-kill-other-buffers)
   ("C-c U"                            . crux-reopen-as-root-mode)
   ("C-c C-x r"                        . crux-rename-file-and-buffer)
   ("C-c C-x d"                        . crux-delete-file-and-buffer)
   ("<remap> <move-beginning-of-line>" . crux-move-beginning-of-line)))

(use-package net-utils
  :straight nil
  :bind (:map mode-specific-map
              :prefix-map net-utils-prefix-map
              :prefix "n"
              ("p" . ping)
              ("i" . ifconfig)
              ("w" . iwconfig)
              ("n" . netstat)
              ("a" . arp)
              ("r" . route)
              ("h" . nslookup-host)
              ("d" . dig)
              ("s" . smbclient)
              ("t" . traceroute))
  :config
  ;; Set default netstat options
  ;; so when I call it, it will list all open ports with processes
  (setq netstat-program-options '("-tulpn")))

(use-package selected
  :hook ((text-mode prog-mode) . selected-minor-mode)
  :init (defvar selected-org-mode-map (make-sparse-keymap))
  :bind (:map selected-keymap
              ("q" . selected-off)
              ("u" . upcase-region)
              ("d" . downcase-region)
              ("w" . count-words-region)
              ("m" . apply-macro-to-region-lines)
              ;; multiple cursors
              ("v" . mc/vertical-align-with-space)
              ("a" . mc/mark-all-dwim)
              ("A" . mc/mark-all-like-this)
              ("m" . mc/mark-more-like-this-extended)
              ("p" . mc/mark-previous-like-this)
              ("P" . mc/unmark-previous-like-this)
              ("S" . mc/skip-to-previous-like-this)
              ("n" . mc/mark-next-like-this)
              ("N" . mc/unmark-next-like-this)
              ("s" . mc/skip-to-next-like-this)
              ("r" . mc/edit-lines)
              :map selected-org-mode-map
              ("t" . org-table-convert-region)))

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
  "Move the window to the right of *any* window in the frame to below the current one."
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
  "Move the window below *any* window in the frame to the right of the current one."
  (interactive)
  (let* ((curr (selected-window))
         (win (window-in-direction 'below curr)))
    (if (not win)
        (message "No window below")
      (let ((buf (window-buffer win)))
        (delete-window win)
        (select-window curr)
        (set-window-buffer (split-window-right) buf)))))

(defun my/eshell-other-window ()
  "."
  (interactive)
  (let ((buf (save-window-excursion (eshell))))
    (pop-to-buffer buf)))

(provide 'init-keybindings)
;;; init-keybindings.el ends here
