;; -*- lexical-binding: t; -*-

(use-package elfeed
  :ensure t
  :config
  (setq elfeed-feeds
        '(
          ("https://archlinux.org/feeds/news/" unix)
          ("https://protesilaos.com/codelog.xml" emacs prot)
          )))

(provide 'init-elfeed)
