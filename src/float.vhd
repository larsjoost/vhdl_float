
package techology is

  type vendors_t is (XILINX, ALTERA);

end package techology;

library ieee;
use ieee.numeric_std.unsigned;
use ieee.numeric_std."+";
use ieee.numeric_std."*";
use ieee.numeric_std."-";

library work;
use work.techology.vendors_t;
use work.techology.XILINX;
use work.techology.ALTERA;

package float is
  generic (
    mantissa_width : positive  := 23;
    exponent_width : positive  := 8;
    vendor         : vendors_t := XILINX);

  type float_t is record
    sign     : boolean;
    exponent : unsigned(0 to exponent_width - 1);
    mantissa : unsigned(0 to mantissa_width - 1);
    --pragma synthesis_off
    delay    : natural;
    value    : real;
  --pragma synthesis_on
  end record float_t;

  --pragma synthesis_off

  function conv_real (
    l : float_t)
    return real;

  function conv_float (
    l : real)
    return float_t;

  --pragma synthesis_on

  function "*" (
    l, r : float_t)
    return float_t;

  function "-" (
    l : float_t)
    return float_t;

  function "+" (
    l, r : float_t)
    return float_t;

  function "-" (
    l, r : float_t)
    return float_t;

end package float;

package body float is

  --pragma synthesis_off

  function max_delay (
    l, r : float_t)
    return natural is
  begin
    return maximum(l.delay, r.delay);
  end function max_delay;

  function get_delay (
    constant operator : string)
    return natural is
    type delay_t is array (vendors_t) of natural;
    constant mul_delay : delay_t := (XILINX => 1, ALTERA => 1);
    variable x         : natural;
  begin
    if operator = "*" then
      x := mul_delay(vendor);
    end if;
    return x;
  end function get_delay;

  function conv_real (
    l : float_t)
    return real is
  begin

  end function conv_real;

  function conv_float (
    l : real)
    return float_t is
  begin

  end function conv_float;

  --pragma synthesis_on

  function "*" (
    l, r : float_t)
    return float_t is
    variable x : float_t;
    variable m : unsigned(0 to 2*mantissa_width - 1);
  begin
    x.sign     := (l.sign = r.sign);
    x.exponent := l.exponent + r.exponent;
    m          := l.mantissa * r.mantissa;
    x.mantissa := m(0 to mantissa_width - 1);
    --pragma synthesis_off
    x.delay    := max_delay(l, r) + get_delay("*");
    x.value    := conv_real(x);
    --pragma synthesis_on
    return x;
  end function "*";

  function "-" (
    l : float_t)
    return float_t is
    variable x : float_t;
  begin
    x      := l;
    x.sign := not l.sign;
    return x;
  end function "-";

  function "-" (
    l, r : float_t)
    return float_t is
    variable x : float_t;
  begin
    x := -r;
    return l + x;
  end function "-";

  function barrel_shift (
    l, r : float_t)
    return float_t is
    variable e : unsigned(0 to exponent_width - 1);
  begin
    e := l.exponent - r.exponent;
  end function barrel_shift;

  function "+" (
    l, r : float_t)
    return float_t is
    variable x, y : float_t;
  begin
    x := barrel_shift(l, r);
    y := barrel_shift(r, l);

  end function "+";

end package body float;

package single_float is new work.float generic map (mantissa_width => 23, exponent_width => 8);

