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
 
 (define (main source-tree plugin-list)
   source-tree))
