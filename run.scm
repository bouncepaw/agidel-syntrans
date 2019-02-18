(module
 agidel-syntrans.run
 (main)
 (import scheme
         (chicken base)
         (agidel aeval))

 ;; `source-tree` is a LIST, not a STRING!
 ;; This functions outputs a string though.
 (define (main source-tree plugins)
   (((<aeval> plugins) 'run) source-tree)))
