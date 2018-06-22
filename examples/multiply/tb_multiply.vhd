
entity tb_multiply is
end entity tb_multiply;

library work;
use work.float32.float_t;
use work.float32.conv_float;
use work.float32.conv_std_ulogic_vector;
use work.float_test.assert_almost_equal;

library std;
use std.env.finish;

library ieee;
use ieee.std_logic_1164.all;

architecture test of tb_multiply is

  constant delay : positive := 2;

  signal clk_i : std_logic;
  signal a_i   : std_logic_vector(0 to 31);
  signal b_i   : std_logic_vector(0 to 31);
  signal q_i   : std_logic_vector(0 to 31);

begin 

  multiply_1: entity work.multiply
    port map (
      clk => clk_i,
      a   => a_i,
      b   => b_i,
      q   => q_i);

  process is
    variable a_v, b_v, q_v : real;
  begin
    a_v := 2.0;
    b_v := 4.0;
    q_v := a_v * b_v;
    a_i <= conv_std_ulogic_vector(conv_float(a_v));
    b_i <= conv_std_ulogic_vector(conv_float(b_v));
    for i in 0 to delay loop
      wait until rising_edge(clk_i);
    end loop;  
    assert_almost_equal(conv_float(q_i), q_v);
    report "Done" severity note;
    finish(0);
  end process;
  
  process is
  begin
    clk_i <= '0';
    wait for 5 ns;
    clk_i <= '1';
    wait for 5 ns;
  end process;
  
end architecture test;
