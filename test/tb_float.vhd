
library ieee;
use ieee.std_logic_1164.all;

entity tb_float is
end entity tb_float;

library work;
use work.float32.float_t;
use work.float32.conv_float;
use work.float32.conv_real;
use work.float32."*";
use work.float_test.assert_almost_equal;

library std;
use std.env.finish;

architecture behavior of tb_float is


begin

  process 
    variable x, y, z : real;
    variable s : std_ulogic_vector(0 to 31);
    variable f, g, h : float_t;
  begin
    s := x"3F800000";
    f := conv_float(s);
    x := conv_real(f);
    assert_almost_equal(x, 1.0);
    x := 2.0;
    y := 4.0;
    z := x * y;
    g := conv_float(x);
    h := conv_float(y);
    f := g * h;
    assert_almost_equal(conv_real(f), z);
    report "Done" severity note;
    finish(0);
  end process;
  

end architecture behavior;
