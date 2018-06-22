
library work;
use work.float32.float_t;
use work.float32.conv_real;

package float_test is

  function almost_equal(
    l, r : real;
    e    : real := 0.001)
    return boolean;

  procedure assert_almost_equal(
    l, r : in real;
    e    : in real := 0.001);

  procedure assert_almost_equal(
    l : in float_t;
    r : in real;
    e : in real := 0.001);

end package float_test;

package body float_test is

  function almost_equal(
    l, r : real;
    e    : real := 0.001)
    return boolean is
  begin
    return abs(l - r) < e;
  end function almost_equal;

  procedure assert_almost_equal(
    l, r : in real;
    e    : in real := 0.001) is
  begin
    assert (almost_equal(l, r, e))
      report "Value = " & real'image(l) &
      ", but expected = " & real'image(r)
      severity failure;
  end procedure assert_almost_equal;

  procedure assert_almost_equal(
    l : in float_t;
    r : in real;
    e : in real := 0.001) is
  begin
    assert_almost_equal(conv_real(l), r, e);
  end procedure assert_almost_equal;

end package body float_test;
