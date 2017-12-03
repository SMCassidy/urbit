::  Collatz conjecture network app
::  Handles even numbers
::
::::  /===/app/even/hoon
  ::
!:
|%
++  move  {bone card}
++  card  $%  {$poke wire dock poke-content}
          ==
++  poke-content  $%  {$atom @}
                  ==
--
::
|_  {bow/bowl $~}                                       ::<  stateless
::
++  poke-atom
  |=  num/@                                             :: create gate
  ^-  {(list move) _+>.$}                               :: cast
  ?:  =((mod num 2) 0)                                  :: if even
  ~&  even+num                                          :: print num
     $(num (div num 2))                                 :: recurse with num/2
  :_  +>.$
  ~[[ost.bow %poke /sending [our.bow %odd] %atom num]]  :: poke odd app
::
++  coup  |=(* [~ +>.$])
::
--
