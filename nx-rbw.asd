;;;; nx-rbw.asd

(asdf:defsystem #:nx-rbw
		:description "A RBW integration for Nyxt browser."
		:author "Andrew Burch"
		:license "GPL v3"
		:depends-on ("nyxt")
		:serial t
		:components ((:file "package")
								 (:file "rbw")))
