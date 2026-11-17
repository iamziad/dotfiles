;; -*- lexical-binding: t; -*-

(defvar-keymap my/net-utils-map
  :doc "Network utilities (C-c n)."
  "p" #'ping
  "i" #'ifconfig
  "w" #'iwconfig
  "n" #'netstat
  "a" #'arp
  "r" #'route
  "h" #'nslookup-host
  "d" #'dig
  "s" #'smbclient
  "t" #'traceroute)

(keymap-set mode-specific-map "n" my/net-utils-map)

(use-package net-utils
  :ensure nil
  :config
  ;; List all open ports together with their processes.
  (setq netstat-program-options '("-tulpn")))

(use-package verb
  :ensure t
  :config
  (setq verb-json-use-mode 'json-ts-mode)

  (with-eval-after-load 'org
    (keymap-set org-mode-map "C-c C-r" verb-command-map))

  (keymap-set verb-response-body-mode-map "q"
              (lambda ()
                (interactive)
                (quit-window t))))

(provide 'init-net)
