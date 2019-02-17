(module
 agidel-syntrans.run
 (main)
 (import scheme
         (chicken base)
         (prefix (agidel core) core/)
         (prefix (agidel plugin) plugin/)
         (srfi 1)
         (srfi 13)
         (srfi 69)
         (clojurian syntax)
         format)

 ;; `source-tree` is a LIST, not a STRING!
 ;; This functions outputs a string though.
 (define (main source-tree plugins)
   ;; Import all plugins, prefixing Agidel macros from them with '/agidel/.
   (->> plugins
        (map (lambda (p)
               `(prefix ,(symbol-append 'agidel-plugin. p) /agidel/)))
        (cons 'import)
        eval)
   ;; Eval it, convert to string.
   (-> source-tree
       eval
       (string-join "\n" 'infix))))
