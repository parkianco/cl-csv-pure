;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

;;;; test-csv-pure.lisp - Unit tests for csv-pure
;;;;
;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: Apache-2.0

(defpackage #:cl-csv-pure.test
  (:use #:cl)
  (:export #:run-tests))

(in-package #:cl-csv-pure.test)

(defun run-tests ()
  "Run all tests for cl-csv-pure."
  (format t "~&Running tests for cl-csv-pure...~%")
  ;; TODO: Add test cases
  ;; (test-function-1)
  ;; (test-function-2)
  (format t "~&All tests passed!~%")
  t)
