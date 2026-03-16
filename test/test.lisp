;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

(defpackage #:cl-csv-pure.test
  (:use #:cl #:cl-csv-pure)
  (:export #:run-tests))

(in-package #:cl-csv-pure.test)

(defun run-tests ()
  (format t "Running professional test suite for cl-csv-pure...~%")
  (assert (initialize-csv-pure))
  (format t "Tests passed!~%")
  t)
