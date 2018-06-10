library ieee;
use ieee.std_logic_1164.all;

package complex_float is
  generic (
    type float_t);

  type complex_float_t is record
    re : float_t;
    im : float_t;
  end record complex_float_t;

  function conv_std_ulogic_vector (
    l : complex_float_t)
    return std_ulogic_vector;
  
end package complex_float;

package body complex_float is

  function conv_std_ulogic_vector (
    l : complex_float_t)
    return std_ulogic_vector is
  begin
    return conv_std_ulogic_vector(l.re) & conv_std_ulogic_vector(r.re);
  end function conv_std_ulogic_vector;
  

end package body complex_float;
