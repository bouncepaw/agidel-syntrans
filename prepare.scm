(module
 agidel-syntrans.prepare
 (main)
 (import scheme
         (chicken base)
         (prefix (agidel core) core/)
         (agidel aeval))


 (define (main source-string plugins)
   (define A (<aeval> plugins))
   (->> source-string
        core/parse-string
        (map (A 'prepare)))))
