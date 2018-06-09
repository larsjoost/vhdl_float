# vhdl_float
Synthesizable VHDL operator floating point library that enables writing floating point expression using operators and then
delay the result by a series of registers. The synthesize tool must implement retiming.

Example:

q <= (a + b) / c;

registers_i: entity work.float_delay
generic (delay => 10)
port (a => q, q => q_out);