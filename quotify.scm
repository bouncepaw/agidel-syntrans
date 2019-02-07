(module
 agidel-syntrans.quotify
 *
 (import scheme
         (chicken base))

 (define (add-to-list lst elt)
   (append lst (list elt)))

 (define (main source-string)
   (let [[mode 'nowhere] ; nowhere string sym list escaping-char
         [nest-level 0]
         [acc '()]]
     (for-each
      (lambda (ch)
        (case mode
          [(nowhere)
           (when (eq? ch #\()
             (set! nest-level (+ nest-level 1))
             (set! mode 'list))
           (set! acc (add-to-list acc ch))]
          [(list)
           (case ch
             [(#\")
              (set! acc (add-to-list acc (string->list "\"\\\"")))
              (set! mode 'string)]
             [(#\()
              (set! acc (add-to-list acc ch))
              (set! nest-level (+ nest-level 1))]
             [(#\))
              (set! acc (add-to-list acc ch))
              (set! nest-level (- nest-level 1))]
             [(#\space #\newline #\tab)
              (set! acc (add-to-list acc ch))]
             [else
              (set! acc (add-to-list acc (list #\" ch)))
              (set! mode 'symbol)])]
          [(symbol)
           (case ch
             [(#\()
              (set! mode 'list)
              (set! acc (add-to-list acc (string->list "\" (")))
              (set! nest-level (+ nest-level 1))]
             [(#\))
              (set! nest-level (- nest-level 1))
              (set! acc (add-to-list acc (string->list "\")")))
              (set! mode 'list)]
             [(#\space #\newline #\tab)
              (set! mode 'list)
              (set! acc (add-to-list acc (list #\" ch)))]
             [else
              (set! acc (add-to-list acc ch))])]
          [(string)
           (case ch
             [(#\\)
              (set! acc (add-to-list acc ch))
              (set! mode 'escaping-char)]
             [(#\")
              (set! acc (add-to-list acc (string->list "\\\"\"")))
              (set! mode 'list)]
             [else
              (set! acc (add-to-list acc ch))])]
          [(escaping-char)
           (set! acc (add-to-list acc ch))
           (set! mode 'string)]))
      (string->list source-string))
     (list->string (flatten acc)))))
