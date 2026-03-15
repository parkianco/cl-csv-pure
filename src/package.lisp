;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: Apache-2.0

;;;; package.lisp
;;;; cl-csv-pure package definition

(defpackage #:cl-csv-pure
  (:use #:cl)
  (:nicknames #:csv-pure)
  (:export
   #:memoize-function
   #:deep-copy-list
   #:group-by-count
   #:identity-list
   #:flatten
   #:map-keys
   #:now-timestamp
#:with-csv-pure-timing
   #:csv-pure-batch-process
   #:csv-pure-health-check;; Reading
   #:read-csv
   #:read-csv-row
   #:with-csv-reader
   #:parse-csv-string
   ;; Writing
   #:write-csv
   #:write-csv-row
   #:with-csv-writer
   ;; Configuration
   #:*default-separator*
   #:*default-quote-char*
   ;; Conditions
   #:csv-parse-error))
