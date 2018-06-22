
library ieee;
use ieee.std_logic_1164.all;

entity multiply is
  port (
    clk : in  std_logic;
    a   : in  std_logic_vector(0 to 31);
    b   : in  std_logic_vector(0 to 31);
    q   : out std_logic_vector(0 to 31));
end entity multiply;

library work;
use work.float32.float_t;
use work.float32.conv_float;
use work.float32.conv_std_ulogic_vector;
use work.float32."*";

architecture test of multiply is

  signal a_i : float_t;
  signal b_i : float_t;
  signal c_i : float_t;

  signal q_i : float_t;

begin

  a_i <= conv_float(a);

  b_i <= conv_float(b);

  c_i <= a_i * b_i;

  float_delay_1 : entity work.float_delay
    generic map (
--      float_t                          => float_t,
      expected_delay                   => 2)
    port map (
      clk => clk,
      a   => c_i,
      q   => q_i);

  q <= conv_std_ulogic_vector(q_i);

end architecture test;
