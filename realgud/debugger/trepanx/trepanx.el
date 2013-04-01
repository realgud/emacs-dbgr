;;; Copyright (C) 2010, 2011 Rocky Bernstein <rocky@gnu.org>
;;  `trepanx' Main interface to trepanx via Emacs
(require 'load-relative)
(require-relative-list '("../../common/helper") "realgud-")
(require-relative-list '("../../common/track") "realgud-")
(require-relative-list '("core" "track-mode") "realgud-trepanx-")
;; This is needed, or at least the docstring part of it is needed to
;; get the customization menu to work in Emacs 23.
(defgroup trepanx nil
  "The Rubinius \"trepanning\" debugger"
  :group 'processes
  :group 'ruby
  :group 'dbgr
  :version "23.1")

;; -------------------------------------------------------------------
;; User definable variables
;;

(defcustom trepanx-command-name
  ;;"trepanx --emacs 3"
  "trepanx"
  "File name for executing the Ruby debugger and command options.
This should be an executable on your path, or an absolute file name."
  :type 'string
  :group 'trepanx)

;; -------------------------------------------------------------------
;; The end.
;;

;;;###autoload
(defun realgud-trepanx (&optional opt-command-line no-reset)
  "Invoke the trepanx Ruby debugger and start the Emacs user interface.

String COMMAND-LINE specifies how to run trepanx.

Normally command buffers are reused when the same debugger is
reinvoked inside a command buffer with a similar command. If we
discover that the buffer has prior command-buffer information and
NO-RESET is nil, then that information which may point into other
buffers and source buffers which may contain marks and fringe or
marginal icons is reset."
  (interactive)
  (let* (
	 (cmd-str (or opt-command-line (trepanx-query-cmdline "trepanx")))
	 (cmd-args (split-string-and-unquote cmd-str))
	 (parsed-args (trepanx-parse-cmd-args cmd-args))
	 (script-args (cdr cmd-args))
	 (script-name (car script-args))
	 (cmd-buf))
    (realgud-run-process "trepanx" script-name cmd-args
		      'trepanx-track-mode no-reset)
    )
  )

(defalias 'trepanx 'realgud-trepanx)

(provide-me "realgud-")
;;; trepanx.el ends here
