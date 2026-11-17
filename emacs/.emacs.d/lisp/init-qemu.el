;;; init-qemu.el --- Minimal QEMU VM launcher -*- lexical-binding: t; -*-

;;; Commentary:
;; A tiny interface for defining, booting, and killing QEMU virtual
;; machines without having to remember qemu-system-* flags every time.
;; No external packages required — just Emacs + qemu-img + qemu-system-x86_64
;; on your $PATH.
;;
;; Usage:
;;   M-x qemu-vm-new            -> define a new VM (creates a qcow2 disk)
;;   M-x qemu-vm-run            -> boot a defined VM
;;   C-u M-x qemu-vm-run        -> boot it while attaching an install ISO
;;   M-x qemu-vm-list-running   -> show currently running VMs
;;   M-x qemu-vm-kill           -> kill a running VM
;;   M-x qemu-vm-forget         -> remove a VM definition (disk file stays)
;;
;; VM definitions persist across Emacs restarts in a small .eld file
;; under `qemu-vm-directory'.

;;; Code:

(defgroup qemu-vm nil
  "Minimal QEMU VM management."
  :group 'external)

(defcustom qemu-vm-directory (expand-file-name "~/vms/")
  "Directory where VM disk images and VM metadata live."
  :type 'directory :group 'qemu-vm)

(defcustom qemu-vm-default-ram "4G"
  "Default RAM for a newly created VM."
  :type 'string :group 'qemu-vm)

(defcustom qemu-vm-default-disk-size "20G"
  "Default disk size for a newly created VM."
  :type 'string :group 'qemu-vm)

(defvar qemu-vm-list nil
  "Alist of (NAME . PLIST). PLIST keys: :disk :ram :cpus :iso.")

(defun qemu-vm--save-file ()
  (expand-file-name "qemu-vms.eld" qemu-vm-directory))

(defun qemu-vm--save ()
  (make-directory qemu-vm-directory t)
  (with-temp-file (qemu-vm--save-file)
    (prin1 qemu-vm-list (current-buffer))))

(defun qemu-vm--load ()
  (let ((f (qemu-vm--save-file)))
    (when (file-exists-p f)
      (setq qemu-vm-list
            (with-temp-buffer
              (insert-file-contents f)
              (read (current-buffer)))))))

(qemu-vm--load)

(defun qemu-vm--names () (mapcar #'car qemu-vm-list))

;;;###autoload
(defun qemu-vm-new (name)
  "Define a new VM NAME and create its disk image."
  (interactive "sVM name: ")
  (when (assoc name qemu-vm-list)
    (user-error "VM '%s' already exists" name))
  (make-directory qemu-vm-directory t)
  (let* ((disk (expand-file-name (concat name ".qcow2") qemu-vm-directory))
         (size (read-string (format "Disk size (default %s): " qemu-vm-default-disk-size)
                            nil nil qemu-vm-default-disk-size))
         (ram (read-string (format "RAM (default %s): " qemu-vm-default-ram)
                           nil nil qemu-vm-default-ram))
         (cpus (read-string "CPUs (default 2): " nil nil "2")))
    (unless (zerop (call-process "qemu-img" nil "*qemu-img*" nil
                                 "create" "-f" "qcow2" disk size))
      (pop-to-buffer "*qemu-img*")
      (user-error "qemu-img failed, see *qemu-img* buffer"))
    (push (cons name (list :disk disk :ram ram :cpus cpus :iso nil)) qemu-vm-list)
    (qemu-vm--save)
    (message "Created VM '%s' (%s CPUs, %s RAM, %s disk)" name cpus ram size)))

(defun qemu-vm--read-name (prompt)
  (completing-read prompt (qemu-vm--names) nil t))

;;;###autoload
(defun qemu-vm-run (name &optional attach-iso)
  "Boot VM NAME. With a prefix argument, attach an install ISO."
  (interactive (list (qemu-vm--read-name "Run VM: ") current-prefix-arg))
  (let* ((entry (assoc name qemu-vm-list))
         (plist (cdr entry))
         (disk (plist-get plist :disk))
         (ram (plist-get plist :ram))
         (cpus (plist-get plist :cpus))
         (iso (when attach-iso
                (read-file-name "ISO image: " qemu-vm-directory nil t)))
         (args (append
                (list "-m" ram "-smp" cpus
                      "-drive" (format "file=%s,format=qcow2,if=virtio" disk)
                      "-enable-kvm" "-cpu" "host"
                      "-display" "gtk" "-vga" "virtio"
                      "-net" "nic" "-net" "user")
                (when iso (list "-cdrom" iso "-boot" "d")))))
    (when iso
      (setcdr entry (plist-put plist :iso iso))
      (qemu-vm--save))
    (let ((buf (format "*qemu-%s*" name)))
      (when (get-buffer buf) (kill-buffer buf))
      (apply #'start-process (format "qemu-%s" name) buf
             "qemu-system-x86_64" args))
    (message "Booting '%s'%s — log in buffer *qemu-%s*"
             name (if iso " from ISO" "") name)))

;;;###autoload
(defun qemu-vm-list-running ()
  "Show currently running QEMU VMs."
  (interactive)
  (let ((procs (seq-filter (lambda (p) (string-prefix-p "qemu-" (process-name p)))
                           (process-list))))
    (if (null procs)
        (message "No QEMU VMs running")
      (with-current-buffer (get-buffer-create "*qemu-vm-running*")
        (erase-buffer)
        (dolist (p procs)
          (insert (format "%-25s pid=%-8s %s\n"
                          (substring (process-name p) 5)
                          (process-id p) (process-status p))))
        (pop-to-buffer (current-buffer))))))

;;;###autoload
(defun qemu-vm-kill (name)
  "Kill the running VM NAME."
  (interactive
   (list (completing-read
          "Kill VM: "
          (mapcar (lambda (p) (substring (process-name p) 5))
                  (seq-filter (lambda (p) (string-prefix-p "qemu-" (process-name p)))
                              (process-list)))
          nil t)))
  (let ((proc (get-process (concat "qemu-" name))))
    (if proc (progn (delete-process proc) (message "Killed '%s'" name))
      (message "No running VM named '%s'" name))))

;;;###autoload
(defun qemu-vm-forget (name)
  "Remove VM NAME's definition. Does not delete its disk file."
  (interactive (list (qemu-vm--read-name "Forget VM: ")))
  (setq qemu-vm-list (assoc-delete-all name qemu-vm-list))
  (qemu-vm--save)
  (message "Forgot '%s' (disk left at %s)" name qemu-vm-directory))

(provide 'init-qemu)
;;; init-qemu.el ends here
