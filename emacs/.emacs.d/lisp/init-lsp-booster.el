;;; init-lsp-booster.el --- LSP performance booster -*- lexical-binding: t; -*-

(require 'json)
(require 'subr-x)

(defun my/lsp-booster-json-parse-advice (old-fn &rest args)
  "Parse emacs-lsp-booster bytecode responses, or call OLD-FN."
  (or (when (equal (following-char) ?#)
        (let ((bytecode (read (current-buffer))))
          (when (byte-code-function-p bytecode)
            (funcall bytecode))))
      (apply old-fn args)))

(defun my/lsp-booster-final-command-advice (old-fn command &optional test?)
  "Wrap local LSP COMMAND with emacs-lsp-booster when supported."
  (let ((original (funcall old-fn command test?))
        (booster (executable-find "emacs-lsp-booster")))
    (if (and original
             booster
             (not test?)
             (not (file-remote-p default-directory))
             (bound-and-true-p lsp-use-plists)
             (not (functionp 'json-rpc-connection)))
        (progn
          (when-let ((resolved (executable-find (car original))))
            (setcar original resolved))
          (message "Using emacs-lsp-booster for %s" (car original))
          (cons booster original))
      original)))

(when (executable-find "emacs-lsp-booster")
  (let ((parser (if (fboundp 'json-parse-buffer)
                    'json-parse-buffer
                  'json-read)))
    (unless (advice-member-p #'my/lsp-booster-json-parse-advice parser)
      (advice-add parser :around #'my/lsp-booster-json-parse-advice))))

(with-eval-after-load 'lsp-mode
  (unless (advice-member-p #'my/lsp-booster-final-command-advice
                           'lsp-resolve-final-command)
    (advice-add 'lsp-resolve-final-command
                :around
                #'my/lsp-booster-final-command-advice)))

(provide 'init-lsp-booster)
;;; init-lsp-booster.el ends here
