;;; pomodoro.el --- Simple Pomodoro -*- lexical-binding: t; -*-
(require 'org-timer)

(defgroup my/pomodoro nil
  "Custom Pomodoro timer settings using org-timer."
  :group 'convenience)

(defcustom my/pomodoro-focus-duration 25
  "Focus duration in minutes."
  :type 'integer
  :group 'my/pomodoro)

(defcustom my/pomodoro-break-duration 5
  "Break duration in minutes."
  :type 'integer
  :group 'my/pomodoro)

(defvar my/pomodoro-loop-p nil "Should the pomodoro loop.")
(defvar my/pomodoro-state 'stopped "Current state: 'focus, 'break, or 'stopped.")

(defun my/pomodoro-play-sound ()
  (start-process
   "pomodoro-sound"
   nil
   "mpv"
   "--no-video"
   "--really-quiet"
   (expand-file-name "/home/ziad/.config/emacs/lisp/pomodoro/bell.wav")))

(defun my/pomodoro-append-state-to-mode-line (&rest _)
  "Advice to append current Pomodoro state to the org-timer mode-line string."
  (when (and (boundp 'org-timer-mode-line-string)
             org-timer-mode-line-string
             (not (eq my/pomodoro-state 'stopped)))
    (let ((state-str (if (eq my/pomodoro-state 'focus) "Focus" "Break")))
      (setq org-timer-mode-line-string
            (format "<%s %s>" state-str (substring org-timer-mode-line-string 2 -1))))))

(advice-add 'org-timer-update-mode-line :after #'my/pomodoro-append-state-to-mode-line)

(defun my/pomodoro-start (loop)
  "Start the Pomodoro timer using org-timer.
If LOOP is non-nil (called with C-u), it runs in a continuous loop."
  (interactive "P")
  (setq my/pomodoro-loop-p (if loop t nil))
  (setq my/pomodoro-state 'focus)
  (message "Pomodoro started: Focus for %d minutes!" my/pomodoro-focus-duration)
  (org-timer-set-timer my/pomodoro-focus-duration))

(defun my/pomodoro-stop ()
  "Stop the current Pomodoro timer and reset state."
  (interactive)
  (setq my/pomodoro-state 'stopped)
  (setq my/pomodoro-loop-p nil)
  (org-timer-stop)
  (message "Pomodoro stopped."))

(defun my/pomodoro-org-done-hook-fn ()
  "Function hooked into `org-timer-done-hook` to handle pomodoro logic."
  (unless (eq my/pomodoro-state 'stopped)
    (my/pomodoro-play-sound)
    (cond
     ((eq my/pomodoro-state 'focus)
      ;; Always start the break, loop or not
      (setq my/pomodoro-state 'break)
      (message "Work done! Break started for %d minutes." my/pomodoro-break-duration)
      (org-timer-set-timer my/pomodoro-break-duration))
     ((eq my/pomodoro-state 'break)
      (if my/pomodoro-loop-p
          (progn
            (setq my/pomodoro-state 'focus)
            (message "Break over! Back to work for %d minutes." my/pomodoro-focus-duration)
            (org-timer-set-timer my/pomodoro-focus-duration))
        (progn
          (setq my/pomodoro-state 'stopped)
          (message "Pomodoro finished! Good work.")))))))

(add-hook 'org-timer-done-hook #'my/pomodoro-org-done-hook-fn)

(provide 'pomodoro)
;;; pomodoro.el ends here
