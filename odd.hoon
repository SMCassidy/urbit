::  Collatz Conjecture network app
::  Handles odd numbers
::
::::  /===/app/odd/hoon
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
  ?:  =(num 1)                                          :: if num=1
  ~&  %success                                          :: print success
    [~ +>.$]                                            :: finish
  ?:  !=((mod num 2) 0)                                 :: if num=odd
  ~&  odd+num                                           :: print num
    $(num (add 1 (mul 3 num)))                          :: recurse, (num*3)+1
  :_  +>.$
  ~[[ost.bow %poke /sending [our.bow %even] %atom num]] :: poke even app
::
++  coup  |=(* [~ +>.$])
--
