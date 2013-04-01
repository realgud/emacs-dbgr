;;; Copyright (C) 2012 Rocky Bernstein <rocky@gnu.org>
;;; "zshdb" Debugger tracking a comint or eshell buffer.

(eval-when-compile (require 'cl))
(require 'load-relative)
(require-relative-list '(
			 "../../common/cmds"
			 "../../common/menu"
			 "../../common/track"
			 "../../common/track-mode"
			 )
		       "realgud-")
(require-relative-list '("core" "init") "realgud-zshdb-")

(realgud-track-mode-vars "zshdb")
(realgud-posix-shell-populate-command-keys zshdb-track-mode-map)

(declare-function realgud-track-mode(bool))


(defun zshdb-track-mode-hook()
  (if zshdb-track-mode
      (progn
	(use-local-map zshdb-track-mode-map)
	(message "using zshdb mode map")
	)
    (message "zshdb track-mode-hook disable called"))
)

(define-minor-mode zshdb-track-mode
  "Minor mode for tracking ruby debugging inside a process shell."
  :init-value nil
  ;; :lighter " zshdb"   ;; mode-line indicator from realgud-track is sufficient.
  ;; The minor mode bindings.
  :global nil
  :group 'zshdb
  :keymap zshdb-track-mode-map

  (realgud-track-set-debugger "zshdb")
  (if zshdb-track-mode
      (progn
	(setq realgud-track-mode 't)
        (realgud-track-mode-setup 't)
        (zshdb-track-mode-hook))
    (progn
      (setq realgud-track-mode nil)
      ))
)

(provide-me "realgud-zshdb-")
