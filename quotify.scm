(module
 agidel-syntrans.quotify
 *
 (import scheme
         (chicken base)
         (only (agidel core) add-to-list add-to-list!))

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
           (add-to-list! acc ch)]
          [(list)
           (case ch
             [(#\")
              (add-to-list! acc (string->list "\"\\\""))
              (set! mode 'string)]
             [(#\()
              (add-to-list! acc ch)
              (set! nest-level (+ nest-level 1))]
             [(#\))
              (add-to-list! acc ch)
              (set! nest-level (- nest-level 1))]
             [(#\space #\newline #\tab)
              (add-to-list! acc ch)]
             [else
              (add-to-list! acc (list #\" ch))
              (set! mode 'symbol)])]
          [(symbol)
           (case ch
             [(#\()
              (set! mode 'list)
              (add-to-list! acc (string->list "\" ("))
              (set! nest-level (+ nest-level 1))]
             [(#\))
              (set! nest-level (- nest-level 1))
              (add-to-list! acc (string->list "\")"))
              (set! mode 'list)]
             [(#\space #\newline #\tab)
              (set! mode 'list)
              (add-to-list! acc (list #\" ch))]
             [else
              (add-to-list! acc ch)])]
          [(string)
           (case ch
             [(#\\)
              (add-to-list! acc ch)
              (set! mode 'escaping-char)]
             [(#\")
              (add-to-list! acc (string->list "\\\"\""))
              (set! mode 'list)]
             [else
              (add-to-list! acc ch)])]
          [(escaping-char)
           (add-to-list! acc ch)
           (set! mode 'string)]))
      (string->list source-string))
     (list->string (flatten acc)))))
