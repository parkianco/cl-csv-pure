;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: BSD-3-Clause

;;;; cl-csv-pure.asd
;;;; RFC 4180 CSV parsing with ZERO external dependencies

(asdf:defsystem #:cl-csv-pure
  :description "RFC 4180 compliant CSV parsing for Common Lisp"
  :author "Park Ian Co"
  :license "Apache-2.0"
  :version "0.1.0"
  :serial t
             (:module "src"
                :components ((:file "package")
                             (:file "conditions" :depends-on ("package"))
                             (:file "types" :depends-on ("package"))
                             (:file "cl-csv-pure" :depends-on ("package" "conditions" "types")))))))

(asdf:defsystem #:cl-csv-pure/test
  :description "Tests for cl-csv-pure"
  :depends-on (#:cl-csv-pure)
  :serial t
  :components ((:module "test"
                :components ((:file "test-csv-pure"))))
  :perform (asdf:test-op (o c)
             (let ((result (uiop:symbol-call :cl-csv-pure.test :run-tests)))
               (unless result
                 (error "Tests failed")))))
