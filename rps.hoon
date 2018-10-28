::
::  Rock, Paper, Scissors in Urbit
::
::  Usage: start with |start %rps
::
::  There are two modes, initiate a game and receive a game.
::  Once the app is running anyone can initiate a game with you.
::
::  To initiate a game with someone use :rps [%init ~their-ship %rock ~]
::  To respond to a game use :rps [%resp ~their-ship %rock ~]
::
::  To see a list of ships currently awaiting a response use :rps [%show ~]
::
::::  /===/app/rps/hoon
  ::
!:
|%
+=  move  [bone card]
+=  card  $%  [%poke wire dock poke-contents]
          ==
+=  poke-contents  $%  [%atom @]
                   ==
+=  args  $%  [%show ~]
              [%init p=[q=ship r=hand]]
              [%resp p=[q=ship r=hand]]
          ==
+=  hand  $%  [%rock ~]
              [%paper ~]
              [%scissors ~]
          ==
+=  shad  [ship hand]
++  state  $:  inbx/(list ship)
               outx/(map ship @ud)
           ==
--
|_  [bow=bowl:gall game=state]                                  ::<
::
++  poke-noun
  |=  a=args
  ^-  [(list move) _+>.$]
  ?-  -.a
     %show
       ~&  rps+game
       [~ +>.$]
     %init
       (init p.a)
     %resp
       (resp p.a)
  ==
++  poke-atom                        :: Basically using this as a state machine
  |=  atm=@
  ^-    [(list move) _+>.$]
  ?:  =(atm 4)                       :: Received an init request
      ~&  'Someone wants to play Rock, Paper, Scissors..!'
      ~&  'Use :rsp [%show ~] to see who it is.'
      ~&  'Reply with... :rsp [%resp ~ship ~hand ~]'
  [~ +>.$(inbx.game (weld inbx.game ~[src.bow]))]
  ?:  (lth atm 3)
     =+  cde=(calc-game atm)         :: Initiator calculates game result
     ?:  =(cde 11)                   :: Sends result code to opponent.
          ~&  'Result from your match with...'
          ~&  src.bow
          ~&  '...You Drew!'
          (msg cde)
     ?:  =(cde 12)
          ~&  'Result from your match with...'
          ~&  src.bow
          ~&  '...You Won!'
          (msg cde)
     ?:  =(cde 13)
          ~&  'Result from your match with...'
          ~&  src.bow
          ~&  '...You Lost!'
          (msg cde)
         [~ +>.$]
  ?:  =(atm 11)                      :: Only recipients will get here.
      ~&  'Result from your match with...'
      ~&  src.bow
      ~&  '...You Drew!'
      [~ +>.$]
  ?:  =(atm 12)
      ~&  'Result from your match with...'
      ~&  src.bow
      ~&  '...You Lost!'
      [~ +>.$]
  ?:  =(atm 13)
      ~&  'Result from your match with...'
      ~&  src.bow
      ~&  '...You Won!'
      [~ +>.$]
  [~ +>.$]
++  coup
  |=  a=*
  ^-  [(list move) _+>.$]
 :: ?~  (find ~[src.bow] inbx.game)
 :: [~ +>.$(inbx.game (weld inbx.game ~[src.bow]))]
 :: ~&  'Already in inbox...'
  [~ +>.$]
++  hand-to-atom
   |=  hnd=hand
   ^-  @
   ?:  =(hnd [%rock ~])
     0
   ?:  =(hnd [%paper ~])
     1
   ?:  =(hnd [%scissors ~])
     2
   99
++  init
   |=  shd=shad
   ^-  [(list move) _+>.$]
   =+  atm=(hand-to-atom +.shd)
   =+  par=[-.shd atm]
   ?~  (~(get by outx.game) -.shd)
      ~&  'Sending request...'
  :_  +>.$(outx.game (~(put by outx.game) par))
  :~  :*   ost.bow
           %poke
           /init
           [[-.shd %rps] [%atom 4]]
      ==
  ==
  ~&  'A - You already sent that ship a request!'
  [~ +>.$]
++  resp
   |=  shd=shad
   ^-  [(list move) _+>.$]
  :: ~&  shd
   =+  atm=(hand-to-atom +.shd)
   =+  indx=(find ~[-.shd] inbx.game)
   ?~  indx
   ~&  'That ship has not started a game with you!'
       [~ +>.$]
   :_  +>.$(inbx.game (oust [(need indx) 1] inbx.game))
   :~  :*  ost.bow
           %poke
           /resp
           [[-.shd %rps] [%atom atm]]
       ==
   ==
++  msg
    |=  cde=@
    ^-  [(list move) _+>.$]
    :_  +>.$(outx.game (~(del by outx.game) src.bow))
    :~  :*  ost.bow
            %poke
            /msg
            [[src.bow %rps] [%atom cde]]
        ==
    ==
++  calc-game
    |=  opp=@
    ^-  @
    =+  you=(~(got by outx.game) src.bow)
    ?:  =(opp you)                      :: 11 - draw
        11                              :: 12 - win
    ?:  =(opp 0)                        :: 13 - lose
        ?:  =(you 1)
            12
            13                          :: these can definitely
    ?:  =(opp 1)                        :: be condensed
        ?:  =(you 0)                    :: with a (gth )
            13
            12
    ?:  =(opp 2)
        ?:  =(you 0)
            12
            13
    99
--
