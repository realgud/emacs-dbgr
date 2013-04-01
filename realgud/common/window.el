;;; Copyright (C) 2010 Rocky Bernstein <rocky@gnu.org>
(require 'load-relative)
(require-relative-list '("helper") "realgud-")
(require-relative-list '("buffer/helper") "realgud-buffer-")

(fn-p-to-fn?-alias 'one-window-p)
(declare-function one-window?(bool))

(defun realgud-window-update-position (buffer marker)
  "Update BUFFER to position specified with MARKER.
We assume MARKER points inside BUFFER"
  (with-current-buffer buffer
    (let ((window (get-buffer-window buffer)))
      (if window
	  (progn
	    (select-window window)
	    (if marker
		(progn
		  (goto-char marker)
		  (redisplay)
		  ))
	    )
	)))
  )


(defun realgud-window-src ( &optional opt-buffer )
  "Make sure the source buffer is displayed in a window
We don't care if the command buffer is also displayed.
See also `realgud-window-src-undisturb-cmd'"
  (let* ((buffer (or opt-buffer (current-buffer)))
	 (src-buffer (realgud-get-srcbuf buffer))
	 (src-window (get-buffer-window src-buffer 'visible))
	 (window (selected-window)))
    (if src-buffer
	(unless (and src-window (not (window-minibuffer-p)))
	  (set-window-buffer window src-buffer))
	)
    ))

(defun realgud-window-src-undisturb-cmd ( &optional opt-buffer )
  "Make sure the source buffers is displayed in windows without
disturbing the command window if it is also displayed. Returns
the command window
See also `realgud-window-src'"
  (interactive)
  (let* ((buffer (or opt-buffer (current-buffer)))
	 (src-buffer (realgud-get-srcbuf buffer))
	 (src-window (get-buffer-window src-buffer))
	 (cmd-buffer (realgud-get-cmdbuf buffer))
	 (cmd-window (get-buffer-window cmd-buffer))
	 (window (selected-window))
	 )
    (if src-buffer
	(unless src-window
	  (setq src-window
		(if (eq window cmd-window)
		    ;; FIXME: generalize what to do here.
		    (if (one-window? 't)
			(split-window)
		      (next-window window 'no-minibuf))
		  window))
	  (set-window-buffer src-window src-buffer))
	)
    (select-window src-window)
    cmd-window)
  )

(defun realgud-window-cmd-undisturb-src ( &optional opt-buffer switch?)
  "Make sure the source buffer is displayed in windows without
disturbing the command window if it is also displayed. Returns
the source window.
See also `realgud-window-src'"
  (interactive)
  (let* ((buffer (or opt-buffer (current-buffer)))
	 (src-buffer (realgud-get-srcbuf buffer))
	 (src-window (get-buffer-window src-buffer))
	 (cmd-buffer (realgud-get-cmdbuf buffer))
	 (cmd-window (get-buffer-window cmd-buffer))
	 (window (selected-window))
	 )
    (if cmd-buffer
	(progn
	  (unless cmd-window
	    (setq cmd-window
		  (if (eq window src-window)
		      ;; FIXME: generalize what to do here.
		      (if (one-window? 't)
			  (split-window)
			(next-window window 'no-minibuf))
		    window))
	    (set-window-buffer cmd-window cmd-buffer)
	    )
	  (if switch?
	      (and (select-window cmd-window)
		   (switch-to-buffer cmd-buffer))))

      )
    (select-window cmd-window)
    src-window)
  )

(defun realgud-window-bt-undisturb-src ( &optional opt-buffer switch?)
  "Make sure the backtrace buffer is displayed in windows without
disturbing the source window if it is also displayed. Returns
the source window
See also `realgud-window-src'"
  (interactive)
  (let* ((buffer (or opt-buffer (current-buffer)))
	 (src-buffer (realgud-get-srcbuf buffer))
	 (src-window (get-buffer-window src-buffer))
	 (cmd-buffer (realgud-get-cmdbuf buffer))
	 (cmd-window (get-buffer-window cmd-buffer))
	 (bt-buffer (realgud-get-backtrace-buf cmd-buffer))
	 (bt-window (get-buffer-window bt-buffer))
	 (window (selected-window))
	 )
    (if cmd-buffer
	(progn
	  (unless bt-window
	    (setq bt-window
		  (if (eq window src-window)
		      ;; FIXME: generalize what to do here.
		      (if (one-window? 't)
			  (split-window)
			(next-window window 'no-minibuf))
		    window))
	    (set-window-buffer bt-window bt-buffer)
	    )
	  (if switch?
	      (and (select-window bt-window)
		   (switch-to-buffer bt-buffer))))

      )
    src-window)
  )

(defun realgud-window-bt()
  "Refresh backtrace information and display that in a buffer"
  (interactive)
  (with-current-buffer-safe (realgud-get-cmdbuf)
    (realgud-backtrace-init)
    (realgud-window-bt-undisturb-src)
    )
  )


;; (defun realgud-window-src-and-cmd ( &optional opt-buffer )
;;   "Make sure the source buffers is displayed in windows without
;; disturbing the command window if it is also displayed. Returns
;; the command window
;; See also `realgud-window-src-window'"
;;   (interactive)
;;   (let* ((buffer (or opt-buffer (current-buffer)))
;; 	 (src-buffer (realgud-get-srcbuf buffer))
;; 	 (src-window (get-buffer-window src-buffer))
;; 	 (cmd-buffer (realgud-get-cmdbuf buffer))
;; 	 (cmd-window (get-buffer-window cmd-buffer))
;; 	 (window (selected-window))
;; 	 )
;;     (if src-buffer
;; 	(unless src-window
;; 	  (setq src-window
;; 		(if (eq window cmd-window)
;; 		    (if (one-window? 't) (split-window) (next-window window))
;; 		  window))
;; 	  (set-window-buffer src-window src-buffer))
;; 	)
;;     cmd-window)
;;   )

(provide-me "realgud-")
