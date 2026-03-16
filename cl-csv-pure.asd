(asdf:defsystem #:cl-csv-pure
  :depends-on (#:alexandria #:bordeaux-threads)
  :components ((:module "src"
                :components ((:file "package")
                             (:file "cl-csv-pure" :depends-on ("package"))))))