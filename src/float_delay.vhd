
library ieee;
use ieee.std_logic_1164.std_ulogic;
use ieee.std_logic_1164.rising_edge;

library work;
use work.float32.float_t;

entity float_delay is
  generic (
--    type float_t;
    expected_delay                   : integer        := -1;
    delay                            : integer        := -1;
    expected_delay_mismatch_severity : severity_level := warning);
  port (
    clk : in  std_ulogic;
    a   : in  float_t;
    q   : out float_t);
end entity float_delay;

architecture rtl of float_delay is

  function max(l, r : integer) return natural is
    variable x : natural;
  begin
    x :=  l when (l > r) else r;
    return x;
  end function max;

  constant max_delay : natural := max(expected_delay, delay); -- maximum(expected_delay, delay);

  type delay_t is array (0 to max_delay - 1) of float_t;

  signal d : delay_t;

begin

  process (clk) is
  begin
    if rising_edge(clk) then
      d <= d(1 to max_delay - 1) & a;
    end if;
  end process;

  process (ALL) is
  begin  
    q <= d(0);
    --pragma synthesis_off
    q.delay <= 0;
    --pragma synthesis_on
  end process;

  --pragma synthesis_off

  process is
  begin
    wait until a'event;
    assert (expected_delay < 0 or expected_delay = a.delay)
      report "Delay = " & integer'image(a.delay) &
      ", but expected = " & integer'image(expected_delay)
      severity expected_delay_mismatch_severity;
    wait;
  end process;

  --pragma synthesis_on

end architecture rtl;
