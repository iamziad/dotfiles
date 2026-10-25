;; -*- lexical-binding: t; -*-

(setq org-directory "~/Documents/org"
      org-agenda-files (list "~/Documents/org")
      org-hide-leading-stars t
      org-ellipsis " ▾"
      org-hide-emphasis-markers t
      org-pretty-entities t
      org-log-done 'note
      ;; Source blocks (literate programming)
      org-confirm-babel-evaluate nil
      org-src-window-setup 'current-window
      org-src-tab-acts-natively t
      org-src-fontify-natively t
      org-src-preserve-indentation t
      python-shell-completion-native-enable nil
      ;; Images and LaTeX
      org-preview-latex-default-process 'dvisvgm
      org-startup-with-latex-preview t
      org-image-actual-width nil
      org-image-max-width 450)

(add-hook 'org-mode-hook
          (lambda ()
            (visual-line-mode 1)
            (electric-pair-local-mode -1)
            (org-indent-mode 1)))

(add-to-list 'display-buffer-alist
             '("\\*Org Select\\*\\|CAPTURE"
               (display-buffer-below-selected)
               (window-height . 0.6)))

(setq org-capture-templates
      '(("a" "Anki Card" entry
         (file+headline "/tmp/anki.org" "Anki flashcards for today")
         "* \n:PROPERTIES:\n:ANKI_DECK:\n:ANKI_NOTE_TYPE: Basic\n:END:\n\n** Front\n\n** Back\n")
        ("d" "Deadline Task" entry
         (file+headline "~/Documents/org/tasks.org" "Deadlines")
         "* TODO %?\n DEADLINE: %^{Deadline}t\n %a\n")
        ("i" "Idea" entry
         (file "~/Documents/org/ideas.org")
         "* TODO %?\n %a %U\n\n")
        ("s" "Scheduled Task" entry
         (file+headline "~/Documents/org/tasks.org" "Schedules")
         "* TODO %?\n SCHEDULED: %^{Date}t\n %a\n")
        ("t" "Todo Inbox" entry
         (file "~/Documents/org/inbox.org")
         "* TODO %?\n %a %U\n\n")
        ("w" "Watch/Read Later" entry
         (file+headline "~/Documents/org/later.org" "Watch/Read Later")
         "* TODO %^{Title}\n [[%x][Link]]\n :PROPERTIES:\n :TYPE: %^{Type|Video|Article|Tutorial|Lecture/Conference}\n :END:\n\n %?\n %U\n")))

(use-package org-download
  :custom
  (org-download-heading-lvl nil)
  (org-download-image-dir "./images"))

(provide 'init-org)
