;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: Apache-2.0

;;;; src/csv.lisp
;;;; RFC 4180 CSV parsing and writing

(in-package #:cl-csv-pure)

;;; Configuration

(defparameter *default-separator* #\,
  "Default field separator character.")

(defparameter *default-quote-char* #\"
  "Default quote character for escaping fields.")

;;; Conditions

(define-condition csv-parse-error (error)
  ((message :initarg :message :reader csv-parse-error-message)
   (line :initarg :line :reader csv-parse-error-line :initform nil)
   (column :initarg :column :reader csv-parse-error-column :initform nil))
  (:report (lambda (c s)
             (format s "CSV parse error~@[ at line ~A~]~@[, column ~A~]: ~A"
                     (csv-parse-error-line c)
                     (csv-parse-error-column c)
                     (csv-parse-error-message c)))))

;;; Reading

(defun read-csv-row (stream &key (separator *default-separator*)
                                 (quote-char *default-quote-char*))
  "Read a single CSV row from STREAM. Returns list of strings or NIL at EOF."
  (let ((fields nil)
        (field (make-array 64 :element-type 'character :adjustable t :fill-pointer 0))
        (in-quotes nil)
        (char nil))
    (flet ((save-field ()
             (push (copy-seq field) fields)
             (setf (fill-pointer field) 0)))
      (loop
        (setf char (read-char stream nil :eof))
        (cond
          ;; EOF
          ((eq char :eof)
           (if (and (null fields) (zerop (length field)))
               (return nil)  ; True EOF
               (progn
                 (save-field)
                 (return (nreverse fields)))))

          ;; Quote character
          ((char= char quote-char)
           (if in-quotes
               ;; Check for escaped quote
               (let ((next (peek-char nil stream nil :eof)))
                 (if (and (characterp next) (char= next quote-char))
                     (progn
                       (read-char stream)  ; consume the escaped quote
                       (vector-push-extend quote-char field))
                     (setf in-quotes nil)))
               (setf in-quotes t)))

          ;; Field separator (only if not in quotes)
          ((and (char= char separator) (not in-quotes))
           (save-field))

          ;; Line ending (only if not in quotes)
          ((and (char= char #\Return) (not in-quotes))
           (let ((next (peek-char nil stream nil :eof)))
             (when (and (characterp next) (char= next #\Newline))
               (read-char stream)))
           (save-field)
           (return (nreverse fields)))

          ((and (char= char #\Newline) (not in-quotes))
           (save-field)
           (return (nreverse fields)))

          ;; Regular character
          (t
           (vector-push-extend char field)))))))

(defun read-csv (stream &key (separator *default-separator*)
                             (quote-char *default-quote-char*))
  "Read entire CSV from STREAM. Returns list of rows (each row is list of strings)."
  (loop for row = (read-csv-row stream :separator separator :quote-char quote-char)
        while row
        collect row))

(defmacro with-csv-reader ((row-var stream &key (separator '*default-separator*)
                                              (quote-char '*default-quote-char*))
                           &body body)
  "Iterate over CSV rows. ROW-VAR is bound to each row in turn."
  (let ((stream-var (gensym "STREAM")))
    `(let ((,stream-var ,stream))
       (loop for ,row-var = (read-csv-row ,stream-var
                                          :separator ,separator
                                          :quote-char ,quote-char)
             while ,row-var
             do (progn ,@body)))))

(defun parse-csv-string (string &key (separator *default-separator*)
                                     (quote-char *default-quote-char*))
  "Parse CSV from STRING. Returns list of rows."
  (with-input-from-string (stream string)
    (read-csv stream :separator separator :quote-char quote-char)))

;;; Writing

(defun needs-quoting-p (string separator quote-char)
  "Return T if STRING needs to be quoted in CSV output."
  (or (find separator string)
      (find quote-char string)
      (find #\Newline string)
      (find #\Return string)))

(defun write-csv-field (stream field &key (separator *default-separator*)
                                          (quote-char *default-quote-char*))
  "Write a single CSV field to STREAM."
  (let ((str (princ-to-string field)))
    (if (needs-quoting-p str separator quote-char)
        (progn
          (write-char quote-char stream)
          (loop for char across str
                do (when (char= char quote-char)
                     (write-char quote-char stream))  ; escape by doubling
                   (write-char char stream))
          (write-char quote-char stream))
        (write-string str stream))))

(defun write-csv-row (stream row &key (separator *default-separator*)
                                      (quote-char *default-quote-char*)
                                      (newline :crlf))
  "Write a single CSV row to STREAM."
  (loop for (field . rest) on row
        do (write-csv-field stream field :separator separator :quote-char quote-char)
        when rest do (write-char separator stream))
  (ecase newline
    (:crlf (write-char #\Return stream) (write-char #\Newline stream))
    (:lf (write-char #\Newline stream))
    (:cr (write-char #\Return stream))))

(defun write-csv (stream rows &key (separator *default-separator*)
                                   (quote-char *default-quote-char*)
                                   (newline :crlf))
  "Write ROWS as CSV to STREAM."
  (dolist (row rows)
    (write-csv-row stream row :separator separator :quote-char quote-char :newline newline)))

(defmacro with-csv-writer ((row-var stream &key (separator '*default-separator*)
                                             (quote-char '*default-quote-char*)
                                             (newline :crlf))
                           &body body)
  "Execute BODY with ROW-VAR as a function that writes a row."
  (let ((stream-var (gensym "STREAM")))
    `(let ((,stream-var ,stream))
       (flet ((,row-var (row)
                (write-csv-row ,stream-var row
                               :separator ,separator
                               :quote-char ,quote-char
                               :newline ,newline)))
         ,@body))))
