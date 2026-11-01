;; -*- lexical-binding: t; -*-

(defun my/flyspell-maybe-enable ()
  (unless (or (> (buffer-size) 200000)
              (derived-mode-p 'special-mode))
    (flyspell-mode 1)))

(use-package flyspell
  :ensure nil
  :hook (text-mode . my/flyspell-maybe-enable)
  :diminish flyspell-mode
  :custom
  (flyspell-issue-message-flag nil)
  (flyspell-issue-welcome-flag nil)
  (flyspell-default-delay 1)
  (flyspell-delay 1)
  (ispell-program-name (or (executable-find "aspell")
                           (executable-find "hunspell")
                           "ispell"))
  :config
  (when (string-match-p "aspell" ispell-program-name)
    (setq ispell-extra-args '("--sug-mode=ultra" "--lang=en_US"))))

(provide 'init-flyspell)
