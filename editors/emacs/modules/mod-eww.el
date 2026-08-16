;;; mod-eww.el

(use-package eww
  :straight nil
  :config
  (setq browse-url-handlers
        '(("wikipedia\\.org" . eww-browse-url)
          ("github"          . browse-url-default-browser)
          ("youtube.com"     . browse-url-default-browser)
          ("reddit.com"      . browse-url-default-browser)))

  (setq shr-use-colors nil
        shr-use-fonts nil
        shr-max-image-proportion 0.6
        shr-image-animate nil
        shr-width fill-column
        shr-max-width fill-column
        shr-discard-aria-hidden t
        shr-cookie-policy nil)

  (setq eww-search-prefix "https://duckduckgo.com/html/?q="
        eww-history-limit 150
        eww-use-external-browser-for-content-type "\\`\\(video/\\|audio\\)"))

(provide 'mod-eww)
;;; mod-eww.el ends here
