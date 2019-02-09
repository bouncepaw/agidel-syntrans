(module
 agidel-syntrans.disbrace
 *
 (import scheme
         (chicken base)
         (only (agidel core) add-to-list add-to-list!))

 (define (main source-string)
   (let [[in-string? #f]
         [escaping-char? #f]
         [pairs-in-search 0]
         [wrapping-brace-expr? #f]
         [acc '()]]
     (for-each
      (lambda (ch)
        (if in-string?
            (cond
             [escaping-char?
              (add-to-list! acc ch)
              (set! escaping-char? #f)]
             [in-string?
              (cond
               [(eq? ch #\")
                (set! in-string? #f)
                (when wrapping-brace-expr? (add-to-list! acc #\\))]
               [(eq? ch #\\) (set! escaping-char? #t)])
              (add-to-list! acc ch)])
            (cond
             [(eq? ch #\{)
              (if wrapping-brace-expr?
                  (add-to-list! acc #\{)
                  (begin (set! acc (add-to-list acc (string->list
                                                     "(_brace \"")))
                         (set! wrapping-brace-expr? #t)))
              (set! pairs-in-search (+ 1 pairs-in-search))]
             [(eq? ch #\})
              (set! pairs-in-search (- pairs-in-search 1))
              (if (zero? pairs-in-search)
                  (begin (add-to-list! acc (string->list "\")"))
                         (set! wrapping-brace-expr? #f))
                  (add-to-list! acc #\}))]
             [(eq? ch #\")
              (add-to-list! acc
                            (if wrapping-brace-expr? (string->list "\\\"") ch))
              (set! in-string? #t)]
             [else
              (add-to-list! acc ch)])))
      (string->list source-string))
     (when (not (zero? pairs-in-search))
       (display "Agidel: unmatched brace pair. Exiting.")
       (exit 1))
     (list->string (flatten acc)))))
