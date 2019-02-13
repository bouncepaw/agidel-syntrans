(module
 agidel-syntrans.prepare
 (main)
 (import scheme
         (chicken base)
         (prefix (agidel core) core/)
         (prefix (agidel plugin) plugin/)
         (srfi 1)
         (srfi 69)
         format)

 ;; `elt` is either a list or an atom.
 ;; if `elt` is a list, eval it according to (car `elt`) signature.
 ;; else return `elt`.
 (define (aeval elt)
   (if (list? elt)
       (let* ((λ-name (string->symbol (car elt)))
              (signature-parser (make-signature-parser λ-name)))
         (cons (symbol-append '/agidel/ λ-name) (signature-parser (cdr elt))))
       elt))

 (define (aquote elt)
   (eval (list 'quote elt)))
 
 ;; Hash-table of signatures.
 (define signatures (plugin/arities (plugin/needed-plugins)))

 ;; Return function that will transform (either quote or aeval) args of a
 ;; function.
 (define (make-signature-parser λ-name)
   (define signature (hash-table-ref signatures λ-name))

   ;; q → quote
   ;; e → aeval
   (define (q/e->λ q/e)
     (case q/e
       ((q) aquote)
       ((e) aeval)))

   ;; Signature parser for macros with signatures that are proper lists:
   ;; (a a a a).
   (define normal-signature
     (lambda (args)
       (let* ((signature-λ (map q/e->λ signature))
              (expected-length (length signature))
              (args-length (length args)))
         (if (eq? args-length expected-length)
             (map eval (zip signature-λ args))
             (begin
               (format (current-error-port)
                       "Error when expanding `~A`: got ~A args instead of ~A."
                       λ-name args-length expected-length)
               (exit 1))))))

   ;; Signature parser for macros with signatures that are dotted lists:
   ;; (a a a . a).
   (define normal+rest-signature
     (lambda args
       (let* ((normal-part-length (length+ args))
              (normal-part-signature
               (map q/e->λ (take args normal-part-length)))
              (normal-part (take args normal-part-length))
              (rest-part-q/e
               (q/e->λ (drop args normal-part-length)))
              (rest-part (drop args normal-part-length)))
         (append (map eval (zip normal-part-signature normal-part))
                 (map rest-part-q/e rest-part)))))

   ;; Signature parser for macros with signatures that are symbols: a.
   (define rest-signature
     (lambda args
       (map (q/e->λ signature) args)))

   (define signature-parser
     (cond
      ((symbol? signature) rest-signature)
      ((proper-list? signature) normal-signature)
      ((dotted-list? signature) normal+rest-signature)))

   signature-parser)


  (define (main source-string)
    source-string))
