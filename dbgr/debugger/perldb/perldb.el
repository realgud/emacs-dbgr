;;; Copyright (C) 2011 Rocky Bernstein <rocky@gnu.org>
;;  `perldb' Main interface to perl debugger via Emacs
(require 'load-relative)
(require-relative-list '("../../common/helper") "dbgr-")
(require-relative-list '("../../common/track") "dbgr-")
(require-relative-list '("core" "track-mode") "dbgr-perldb-")
;; This is needed, or at least the docstring part of it is needed to
;; get the customization menu to work in Emacs 23.
(defgroup dbgr-perldb nil
  "The Perl debugger"
  :group 'processes
  :group 'tools
  :version "23.1")

;; -------------------------------------------------------------------
;; User definable variables
;;

(defcustom dbgr-perldb-command-name
  "perl -d"
  "Option to needed to run the Perl debugger"
  :type 'string
  :group 'dbgr-perldb)

(declare-function dbgr-perldb-track-mode (bool))

;; -------------------------------------------------------------------
;; The end.
;;

;;;###autoload
(defun dbgr-perldb (&optional opt-command-line no-reset)
  "Invoke the Perl debugger and start the Emacs user interface.

String COMMAND-LINE specifies how to run perldb.

Normally command buffers are reused when the same debugger is
reinvoked inside a command buffer with a similar command. If we
discover that the buffer has prior command-buffer information and
NO-RESET is nil, then that information which may point into other
buffers and source buffers which may contain marks and fringe or
marginal icons is reset."

  
  (interactive)
  (let* (
	 (cmd-str (or opt-command-line (dbgr-perldb-query-cmdline "perldb")))
	 (cmd-args (split-string-and-unquote cmd-str))
	 (parsed-args (dbgr-perldb-parse-cmd-args cmd-args))
	 (script-args (cadr parsed-args))
	 (script-name (car script-args))
	 (cmd-buf))
  
    ;; Parse the command line and pick out the script
    (condition-case nil
	(setq cmd-buf 
	      (apply 'dbgr-exec-shell "perldb" script-name
		     (car cmd-args) no-reset (cdr cmd-args)))
      (error nil))
    ;; FIXME: Is there probably is a way to remove the
    ;; below test and combine in condition-case? 
    (let ((process (get-buffer-process cmd-buf)))
      (if (and process (eq 'run (process-status process)))
	  (progn
	    (switch-to-buffer cmd-buf)
	    (dbgr-perldb-track-mode 't)
	    (dbgr-cmdbuf-info-cmd-args= cmd-args)
	    )
	(message "Error running perldb command"))
    )))

(provide-me "dbgr-")

;;; perldb.el ends here
