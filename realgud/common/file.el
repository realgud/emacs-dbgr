;;; Copyright (C) 2010, 2011 Rocky Bernstein <rocky@gnu.org>
; Should realgud-file-loc-from-line be here or elsewhere?
(require 'load-relative)
(require 'compile) ;; for compilation-find-file
(require-relative-list '("helper" "loc") "realgud-")

(fn-p-to-fn?-alias 'file-exists-p)
(declare-function file-exists?(file))

(defun realgud-file-line-count(filename)
  "Return the number of lines in file FILENAME, or nil FILENAME can't be
found"
  (if (file-exists? filename)
      (let ((file-buffer (find-file-noselect filename)))
	(with-current-buffer-safe file-buffer
	  (line-number-at-pos (point-max))))
    nil))

(defun realgud-file-loc-from-line(filename line-number
					&optional cmd-marker bp-num ignore-file-re)
  "Return a realgud-loc for FILENAME and LINE-NUMBER

CMD-MARKER and BP-NUM get stored in the realgud-loc object. IGNORE-FILE-RE
is a regular expression describing things that aren't expected to be
found. For example many debuggers create a pseudo file name for eval
expressions. For example (eval 1) of Perl <string> of Python.

If we're unable find the source code we return a string describing the
problem as best as we can determine."

  (unless (file-exists? filename)
    (if (and ignore-file-re (string-match ignore-file-re filename))
	(message "tracking ignored for psuedo-file %s" filename)
      ; else
      (setq filename
	    (buffer-file-name
	     (compilation-find-file (point-marker) filename nil)))
      )
    )
  (if (file-exists? filename)
      (if (integerp line-number)
	  (if (> line-number 0)
	      (lexical-let ((line-count))
		(if (setq line-count (realgud-file-line-count filename))
		    (if (> line-count line-number)
			; And you thought we'd never get around to
			; doing something other than validation?
			(make-realgud-loc
			 :num         bp-num
			 :cmd-marker  cmd-marker
			 :filename    filename
			 :line-number line-number
			 :marker      (make-marker)
			 )
		      (format "File %s has only %d lines. (Line %d requested.)"
			      filename line-count line-number))
		  (format "Problem getting line count for file `%s'" filename)))
	    (format "line number %s should be greater than 0" line-number))
	(format "%s is not an integer" line-number))
    ;; else
    (format "File named `%s' not found" filename))
  )

(provide-me "realgud-")
