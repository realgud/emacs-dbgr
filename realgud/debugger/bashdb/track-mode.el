;;; Copyright (C) 2012 Rocky Bernstein <rocky@gnu.org>
;;; Bash Debugger tracking a comint or eshell buffer.

(eval-when-compile (require 'cl))
(require 'load-relative)
(require-relative-list '(
			 "../../common/cmds"
			 "../../common/menu"
			 "../../common/track"
			 "../../common/track-mode"
			 )
		       "realgud-")
(require-relative-list '("core" "init") "realgud-bashdb-")

(realgud-track-mode-vars "bashdb")
(realgud-posix-shell-populate-command-keys bashdb-track-mode-map)

(declare-function realgud-track-mode(bool))

(defun bashdb-track-mode-hook()
  (if bashdb-track-mode
      (progn
	(use-local-map bashdb-track-mode-map)
	(message "using bashdb mode map")
	)
    (message "bashdb track-mode-hook disable called"))
)

(define-minor-mode bashdb-track-mode
  "Minor mode for tracking ruby debugging inside a process shell."
  :init-value nil
  ;; :lighter " bashdb"   ;; mode-line indicator from realgud-track is sufficient.
  ;; The minor mode bindings.
  :global nil
  :group 'bashdb
  :keymap bashdb-track-mode-map

  (realgud-track-set-debugger "bashdb")
  (if bashdb-track-mode
      (progn
	(setq realgud-track-mode 't)
        (realgud-track-mode-setup 't)
        (bashdb-track-mode-hook))
    (progn
      (setq realgud-track-mode nil)
      ))
)

(provide-me "realgud-bashdb-")
