(export #t setup surf surf-clients newclient showview current-surf-driver start-surfing! gtk_surf_iteration
        Client Client-title)
(import :std/foreign
        :gerbil/gambit/foreign
        :gerbil/gambit/threads)

(def (surf-driver!)
  (def _sleep 0.00001)
  (def sleep 0.00001)
  (def (sleepy) (thread-sleep!
                 (max sleep 0.001))
    (+ sleep 0.0000001))
  (let lp ()
    (def events? (gtk_surf_iteration))
    (if events?
      (set! sleep _sleep)
      (sleepy))
    (lp)))

(def current-surf-driver (make-parameter #f))
(def (start-surfing!)
  (cond ((current-surf-driver) => values)
        (else
         (setup)
         (let (drv (spawn surf-driver!))
                (current-surf-driver drv)
                drv))))

(def surf-clients clients)

(def (surf (uri "about:blank") (rclient (surf-clients)))
  (start-surfing!)
  (let (client (newclient rclient))
    (showview client)
    (loaduri client uri)
    (updatetitle client)
    client))


(begin-ffi (setup newclient clients loaduri showview  gtk_surf_iteration updatetitle Client Client-title
                 abc abc-b)
  (c-declare "#include \"surf/surf.c\"")
  (define-c-lambda setup () void "setup")
  (define-c-struct Client ((title . char-string) (next . Client*)))
  (define-c-lambda newclient (Client*) Client* "newclient")
  (define-c-lambda clients () Client* "___return(clients);")
  (define-c-lambda loaduri (Client* char-string) void
    "Arg arg; arg.v = ___arg2 ; loaduri(___arg1, &arg); ")
  (define-c-lambda updatetitle (Client*) void "updatetitle")

  (define-c-lambda showview (Client*) void "showview(NULL, ___arg1);")

  (define-c-lambda start_surf (char-string) Client* "start_surf")
  (define-c-lambda testSurf () int "___return(1);")
  (define-c-lambda gtk_surf_iteration
    () bool "gboolean res = g_main_context_pending(NULL);
    while (g_main_context_pending(NULL)) {
      g_main_context_iteration(NULL, FALSE);
   }; ___return(res);"))