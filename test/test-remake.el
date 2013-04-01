(require 'test-simple)
(load-file "../realgud/common/core.el") ;; for realgud-exec-shell
(load-file "../realgud/debugger/remake/remake.el")

(test-simple-start)

(defun realgud-exec-shell (debugger-name script-filename program
				      &optional no-reset &rest args)
  "Mock for realgud-exec-shell. We copy the part of the real realgud-exec-shell
file-name-directory that was failing"
  (let ((cmdproc-buffer (get-buffer-create "foo"))
	(starting-directory
		(or (file-name-directory script-filename)
		    default-directory "./")))
    (start-process "my-process" cmdproc-buffer "sleep" "10000")
    cmdproc-buffer
    )
  )

(note "can deal with no Makefile name")
;; If realgud-remake is successful we switch buffers
(setq my-buf (current-buffer))
(realgud-remake "remake --debugger")
(assert-t (not (eq (current-buffer) my-buf)))
(delete-process "foo")
(switch-to-buffer my-buf)

(end-tests)
