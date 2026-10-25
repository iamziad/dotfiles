;;;; -*- lexical-binding: t; -*-

(use-package agent-shell
  :straight t)

;; Making Emacs interact with outside changes
(defvar-local my/revert-snapshot nil)

(defun my/revert-snapshot-before ()
  (setq my/revert-snapshot (buffer-string)))

(defface my/revert-ghost-face
  '((t :inherit diff-removed :extend t))
  "Face for lines deleted from outside Emacs.")

(defvar-local my/revert-ghosts nil)
(defvar-local my/revert-ghost-point nil)

(defun my/revert-clear-ghosts (&rest _)
  "Remove the ghost overlays showing externally deleted lines."
  (mapc #'delete-overlay my/revert-ghosts)
  (setq my/revert-ghosts nil)
  (remove-hook 'post-command-hook #'my/revert-ghost-clear-on-move t)
  (remove-hook 'after-change-functions #'my/revert-clear-ghosts t))

(defun my/revert-ghost-clear-on-move ()
  (unless (eq (point) my/revert-ghost-point)
    (my/revert-clear-ghosts)))

(defun my/revert-show-ghost-lines (pos lines)
  "Show LINES, deleted at POS, until point moves or the buffer is edited."
  (let ((overlay (make-overlay pos pos)))
    (overlay-put overlay 'before-string
                 (propertize (concat (mapconcat #'identity lines "\n") "\n")
                             'face 'my/revert-ghost-face))
    (push overlay my/revert-ghosts)
    (add-hook 'post-command-hook #'my/revert-ghost-clear-on-move nil t)
    (add-hook 'after-change-functions #'my/revert-clear-ghosts nil t)))

(defun my/revert-flash-after ()
  "Recenter on and pulse the lines that changed during a revert.
Externally deleted lines are shown in red until point moves."
  (let ((old my/revert-snapshot))
    (setq my/revert-snapshot nil)
    (my/revert-clear-ghosts)
    (when (and old (not (string= old (buffer-string))) (get-buffer-window))
      (let* ((old-lines (split-string old "\n"))
             (new-lines (split-string (buffer-string) "\n"))
             (prefix 0) (suffix 0))
        ;; Skip the common prefix and suffix of lines.
        (while (and (< prefix (length old-lines)) (< prefix (length new-lines))
                    (string= (nth prefix old-lines) (nth prefix new-lines)))
          (setq prefix (1+ prefix)))
        (while (and (< suffix (- (length old-lines) prefix))
                    (< suffix (- (length new-lines) prefix))
                    (string= (nth (- (length old-lines) suffix 1) old-lines)
                             (nth (- (length new-lines) suffix 1) new-lines)))
          (setq suffix (1+ suffix)))
        (let ((start (save-excursion (goto-char (point-min))
                                     (forward-line prefix) (point)))
              (end (save-excursion (goto-char (point-min))
                                   (forward-line (- (length new-lines) suffix))
                                   (point))))
          ;; A pure deletion leaves no new text behind; show the removed lines
          ;; as a red ghost block and flash the line at the deletion point.
          (when (= end start)
            (my/revert-show-ghost-lines
             start (cl-subseq old-lines prefix (- (length old-lines) suffix)))
            (goto-char start)
            (setq start (line-beginning-position))
            (setq end (line-end-position))
            (when (= end start)
              (setq start (line-beginning-position 0))
              (setq end (save-excursion (goto-char start) (line-end-position)))))
          (require 'pulse)
          (with-selected-window (get-buffer-window)
            (goto-char start)
            (recenter))
          (pulse-momentary-highlight-region start end)
          (setq my/revert-ghost-point (point)))))))

(add-hook 'before-revert-hook #'my/revert-snapshot-before)
(add-hook 'after-revert-hook #'my/revert-flash-after)

(provide 'ai)
