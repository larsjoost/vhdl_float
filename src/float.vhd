
package techology is

  type vendors_t is (XILINX, ALTERA);

end package techology;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.techology.vendors_t;
use work.techology.XILINX;
use work.techology.ALTERA;

package float32 is

  constant  mantissa_width : positive  := 23;
  constant  exponent_width : positive  := 8;
  constant  vendor         : vendors_t := XILINX;

  type float_t is record
    sign     : std_ulogic;
    exponent : unsigned(0 to exponent_width - 1);
    mantissa : unsigned(0 to mantissa_width - 1);
    --pragma synthesis_off
    delay    : natural;
    value    : real;
  --pragma synthesis_on
  end record float_t;

  constant exponent_bias : natural := 2 ** (exponent_width - 1) - 1;

  --pragma synthesis_off

  function conv_real (
    l : float_t)
    return real;

  function conv_float (
    l : real)
    return float_t;

  --pragma synthesis_on

  function conv_std_ulogic_vector(
    l : float_t)
    return std_ulogic_vector;

  function conv_float(
    l : std_ulogic_vector)
    return float_t;
  
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

end package float32;

library ieee;
use ieee.math_real.log2;
use ieee.math_real.floor;
use ieee.math_real."**";

package body float32 is

  --pragma synthesis_off

  function max_delay (
    l, r : float_t)
    return natural is
    variable x : natural;
  begin
    x := l.delay when (l.delay > r.delay) else r.delay;
    return x;
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
    variable m : real;
    variable e : real;
    variable x : real;
  begin
    m := real(to_integer('1' & l.mantissa)) / real(2 ** mantissa_width - 1);
    e := 2.0 ** real(to_integer(l.exponent) - exponent_bias);
    x := m * e;
    if (l.sign = '1') then
      x := -x;
    end if;
    return x;
  end function conv_real;

  function conv_float (
    l : real)
    return float_t is
    variable q : float_t;
    variable e : natural;
    variable m : real;
  begin
    q.sign := '1' when (l < 0.0) else '0';
    e := integer(floor(log2(l)));
    q.exponent := to_unsigned(e + exponent_bias, exponent_width);
    m := l / (2.0 ** real(e)) * real(2 ** mantissa_width);
    q.mantissa := to_unsigned(integer(m), mantissa_width);
    return q;
  end function conv_float;

  --pragma synthesis_on

  function conv_std_ulogic_vector(
    l : float_t)
    return std_ulogic_vector is
  begin
    return l.sign & std_ulogic_vector(l.exponent) & std_ulogic_vector(l.mantissa);
  end function conv_std_ulogic_vector;

  function conv_float(
    l : std_ulogic_vector)
    return float_t is
    alias a : std_ulogic_vector(0 to l'length - 1) is l;
    variable x : float_t;
  begin
    x.sign := a(0);
    x.exponent := unsigned(a(1 to exponent_width));
    x.mantissa := unsigned(a(exponent_width + 1 to exponent_width + mantissa_width));
    return x;
  end function conv_float;

  function "*" (
    l, r : float_t)
    return float_t is
    variable x : float_t;
    variable m : unsigned(0 to 2*mantissa_width - 1);
  begin
    x.sign     := '0' when (l.sign = r.sign) else '1';
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

  type shift_lut_t is array(0 to 2 ** exponent_width - 1) of unsigned(0 to mantissa_width - 1);

  function get_shift_lut
    return shift_lut_t is
    variable x : shift_lut_t;
    variable m : unsigned(0 to mantissa_width - 1);
  begin
    for i in x'range loop
      m := (others => '0');
      if (i < mantissa_width) then
        m(i) := '1';
      end if;
      x(i) := m;
    end loop;
    return x;
  end function get_shift_lut;

  function round(
    l : unsigned)
    return unsigned is
    variable x : unsigned(l'length - 1 downto 0);
  begin
    x := l;
    if (x(0) = '1') then
      x := x + 1;
    end if;
    return x(x'left downto 1);
  end round;

  function right_shift(
    l : float_t;
    e : unsigned)
    return float_t is
    constant shift_lut : shift_lut_t := get_shift_lut;
    variable x         : unsigned(0 to mantissa_width - 1);
    variable m         : unsigned(0 to 2 * mantissa_width - 1);
    variable z         : float_t;
  begin
    x          := shift_lut(to_integer(unsigned(e)));
    m          := l.mantissa * x;
    z          := l;
    z.mantissa := round(m(0 to mantissa_width));
    return z;
  end function right_shift;

  function align_mantissa (
    l, r : float_t)
    return float_t is
    variable e : unsigned(0 to exponent_width - 1);
  begin
    e := l.exponent - r.exponent;
    return right_shift(r, e);
  end function align_mantissa;

  function select_one(
    l, r    : float_t;
    largest : boolean)
    return float_t is
    variable x        : float_t;
    variable select_l : boolean;
  begin
    select_l := l.exponent > r.exponent;
    select_l := select_l when (largest)  else not select_l;
    x        := l        when (select_l) else r;
    return x;
  end function select_one;

  function select_largest(
    l, r : float_t)
    return float_t is
  begin
    return select_one(l, r, true);
  end function select_largest;

  function select_smallest(
    l, r : float_t)
    return float_t is
  begin
    return select_one(l, r, false);
  end function select_smallest;

  function add(
    l, r : float_t)
    return float_t is
    variable m : unsigned(0 to mantissa_width);
  begin
    if (l.sign = r.sign) then
      m := l.mantissa + r.mantissa;
    else
      m := l.mantissa - r.mantissa;
    end if;

  end function add;

  function "+" (
    l, r : float_t)
    return float_t is
    variable x, y : float_t;
    variable m    : unsigned(0 to mantissa_width);
  begin
    x := select_largest(l, r);
    y := select_smallest(l, r);
    y := align_mantissa(x, y);
    return add(x, y);
  end function "+";

end package body float32;


