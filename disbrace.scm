(module
 agidel-syntrans.disbrace
 *
 (import scheme
         (chicken base))

 (define (add-to-list lst elt)
   (append lst (list elt)))
 
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
              (set! acc (add-to-list acc ch))
              (set! escaping-char? #f)]
             [in-string?
              (cond
               [(eq? ch #\")
                (set! in-string? #f)
                (when wrapping-brace-expr? (set! acc (add-to-list acc #\\)))]
               [(eq? ch #\\) (set! escaping-char? #t)])
              (set! acc (add-to-list acc ch))])
            (cond
             [(eq? ch #\{)
              (if wrapping-brace-expr?
                  (set! acc (add-to-list acc #\{))
                  (begin (set! acc (add-to-list acc (string->list
                                                     "(_brace \"")))
                         (set! wrapping-brace-expr? #t)))
              (set! pairs-in-search (+ 1 pairs-in-search))]
             [(eq? ch #\})
              (set! pairs-in-search (- pairs-in-search 1))
              (if (zero? pairs-in-search)
                  (begin (set! acc (add-to-list acc (string->list "\")")))
                         (set! wrapping-brace-expr? #f))
                  (set! acc (add-to-list acc #\})))
              ]
             [(eq? ch #\")
              (if wrapping-brace-expr?
                  (begin (set! acc (add-to-list acc (string->list "\\\"")))
                         (set! in-string? #t))
                  (begin (set! in-string? #t)
                         (set! acc (add-to-list acc ch))))]
             [else
              (set! acc (add-to-list acc ch))])))
      (string->list source-string))
     (when (not (zero? pairs-in-search))
       (display "Agidel: unmatched brace pair. Exiting.")
       (exit 1))
     (list->string (flatten acc)))))
