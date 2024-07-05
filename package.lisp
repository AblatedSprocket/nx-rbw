;;;; package.lisp

(defpackage #:nx-rbw
	(:nicknames #:rbw)
	(:import-from #:nyxt
								#:define-class
								#:user-class)
	(:import-from #:serapeum
								#:resolve-executable)
	(:import-from #:password
								#:*interfaces*
								#:clip-password
								#:clip-username
								#:executable
								#:execute
								#:list-passwords
								#:password-correct-p
								#:password-interface
								#:save-password
								#:sleep-timer)
	(:export #:rbw-interface
					 #:list-passwords
					 #:clip-password
					 #:save-password
					 #:rbw-login)
	(:use #:cl)
	(:documentation "A RBW integration for Nyxt browser."))
