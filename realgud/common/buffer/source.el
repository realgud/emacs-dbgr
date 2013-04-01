;;; Copyright (C) 2010, 2012 Rocky Bernstein <rocky@gnu.org>
;;; source-code buffer code
(eval-when-compile
  (require 'cl)
  (defvar realgud-srcbuf-info) ;; is buffer local
  (defvar realgud-cmdbuf-info) ;; in the cmdbuf, this is buffer local
  )

(require 'load-relative)
(require-relative-list '("../helper" "../key") "realgud-")

(defstruct realgud-srcbuf-info
  "debugger object/structure specific to a (top-level) source program
to be debugged."
  debugger-name  ;; Name of debugger. We could get this from the
                 ;; process command buffer, but we want to store it
                 ;; here in case the command buffer disappears. Used
                 ;; in recomputing a suitiable debugger invocation.
  cmd-args       ;; Debugger command invocation as a list of strings
                 ;; or nil. See above about why we don't get from the
                 ;; process command buffer. Used to suggest a debugger
                 ;; invocation.
  cmdproc        ;; buffer of the associated debugger process
  cur-pos        ;; If not nil, the debugger thinks we are currently
		 ;; positioned at a corresponding place in the
		 ;; program.
  short-key?     ;; Was the source buffer previously in short-key
		 ;; mode? Used to deterimine when short-key mode
		 ;; changes state in a source buffer, so we need to
		 ;; perform on/off actions.
  was-read-only? ;; Was buffer initially read only? (i.e. the original
		 ;; value of the buffer's buffer-read-only
		 ;; variable. Short-key-mode may change the read-only
		 ;; state, so we need restore this value when leaving
		 ;; short-key mode

  loc-hist       ;; ring of locations seen

  ;; FILL IN THE FUTURE
  ;;(brkpt-alist '())  ;; alist of breakpoints the debugger has referring
                       ;; to this buffer. Each item is (brkpt-name . marker)
  ;;
)

(declare-function realgud-get-srcbuf(&optional opt-buffer opt-loc))

(defun realgud-srcbuf-info-describe (&optional buffer)
  "Display realgud-srcbuf-info fields of BUFFER.
BUFFER is either a debugger command or source buffer. If BUFFER is not given
the current buffer is used as a starting point.
Information is put in an internal buffer called *Describe*."
  (interactive "")
  (setq buffer (realgud-get-srcbuf buffer))
  (if buffer
      (with-current-buffer buffer
	(let ((info realgud-srcbuf-info)
	      (srcbuf-name (buffer-name)))
	  (switch-to-buffer (get-buffer-create "*Describe*"))
	  (delete-region (point-min) (point-max))
	  (mapc 'insert
		(list
		 (format "realgud-srcbuf-info for %s\n\n" srcbuf-name)
		 (format "Debugger name (debugger-name): %s\n"
			 (realgud-srcbuf-info-debugger-name info))
		 (format "Command-line args (cmd-args): %s\n"
			 (realgud-srcbuf-info-cmd-args info))
		 (format "Command process buffer (cmdproc): %s\n"
			 (realgud-srcbuf-info-cmdproc info))
		 (format "Current debugger position (cur-pos): %s\n"
			 (realgud-srcbuf-info-cur-pos info))
		 (format "Was source previously in short-key mode? (short-key?): %s\n"
			 (realgud-srcbuf-info-short-key? info))

		 (format "Was source previously read only? (was-read-only): %s\n"
			 (realgud-srcbuf-info-was-read-only? info))

		 )))
	)
    (message "Buffer %s is not a debugger buffer; nothing done."
	     (or buffer (current-buffer)))
    )
  )


(defalias 'realgud-srcbuf-info? 'realgud-srcbuf-p)

;; FIXME: figure out how to put in a loop.
(realgud-struct-field-setter "realgud-srcbuf-info" "cmd-args")
(realgud-struct-field-setter "realgud-srcbuf-info" "cmdproc")
(realgud-struct-field-setter "realgud-srcbuf-info" "debugger-name")
(realgud-struct-field-setter "realgud-srcbuf-info" "short-key?")
(realgud-struct-field-setter "realgud-srcbuf-info" "was-read-only?")

(defun realgud-srcbuf-info-set? ()
  "Return true if `realgud-srcbuf-info' is set."
  (and (boundp 'realgud-srcbuf-info)
       realgud-srcbuf-info
       (realgud-srcbuf-info? realgud-srcbuf-info)))

(defun realgud-srcbuf? ( &optional buffer)
  "Return true if BUFFER is a debugger source buffer."
  (with-current-buffer-safe (or buffer (current-buffer))
    (and (realgud-srcbuf-info-set?)
	 (not (buffer-killed? (realgud-sget 'srcbuf-info 'cmdproc)))
   )))

(defun realgud-srcbuf-debugger-name (&optional src-buf)
  "Return the debugger name recorded in the debugger command-process buffer."
  (with-current-buffer-safe (or src-buf (current-buffer))
    (realgud-sget 'srcbuf-info 'debugger-name))
)

(defun realgud-srcbuf-loc-hist(src-buf)
  "Return the history ring of locations that a debugger process has stored."
  (with-current-buffer-safe src-buf
    (realgud-sget 'srcbuf-info 'loc-hist))
)

(declare-function fn-p-to-fn?-alias(sym))
(fn-p-to-fn?-alias 'realgud-srcbuf-info-p)
(declare-function realgud-srcbuf-info?(var))
(declare-function realgud-cmdbuf-info-name(cmdbuf-info))

;; FIXME: support a list of cmdprocs's since we want to allow
;; a source buffer to potentially participate in several debuggers
;; which might be active.
(make-variable-buffer-local 'realgud-srcbuf-info)

(defun realgud-srcbuf-init
  (src-buffer cmdproc-buffer debugger-name cmd-args)
  "Initialize SRC-BUFFER as a source-code buffer for a debugger.
CMDPROC-BUFFER is the process-command buffer containing the
debugger.  DEBUGGER-NAME is the name of the debugger.  as a main
program."
  (with-current-buffer cmdproc-buffer
    (set-buffer src-buffer)
    (set (make-local-variable 'realgud-srcbuf-info)
	 (make-realgud-srcbuf-info
	  :debugger-name debugger-name
	  :cmd-args cmd-args
	  :cmdproc cmdproc-buffer
	  :loc-hist (make-realgud-loc-hist)))
    (put 'realgud-srcbuf-info 'variable-documentation
	 "Debugger information for a buffer containing source code.")))

(defun realgud-srcbuf-init-or-update (src-buffer cmdproc-buffer)
  "Call `realgud-srcbuf-init' for SRC-BUFFER update `realgud-srcbuf-info' variables
in it with those from CMDPROC-BUFFER"
  (let ((debugger-name)
	(cmd-args))
   (with-current-buffer-safe cmdproc-buffer
     (setq debugger-name (realgud-sget 'cmdbuf-info 'debugger-name))
     (setq cmd-args (realgud-cmdbuf-info-cmd-args realgud-cmdbuf-info)))
  (with-current-buffer-safe src-buffer
    (realgud-populate-common-keys
     ;; use-local-map returns nil so e have to call (current-local-map)
     ;; again in this case.
     (or (current-local-map) (use-local-map (make-sparse-keymap))
	 (current-local-map)))
    (if (realgud-srcbuf-info? realgud-srcbuf-info)
	(progn
	  (realgud-srcbuf-info-cmdproc= cmdproc-buffer)
	  (realgud-srcbuf-info-debugger-name= debugger-name)
	  (realgud-srcbuf-info-cmd-args= cmd-args)
	  )
      (realgud-srcbuf-init src-buffer cmdproc-buffer "unknown" nil)))))

(defun realgud-srcbuf-command-string(src-buffer)
  "Get the command string invocation for this source buffer"
  (with-current-buffer-safe src-buffer
    (cond
     ((and (realgud-srcbuf? src-buffer)
	   (realgud-sget 'srcbuf-info 'cmd-args))
      (mapconcat (lambda(x) x)
		 (realgud-sget 'srcbuf-info 'cmd-args)
		 " "))
     (t nil))))

(provide-me "realgud-buffer-")
