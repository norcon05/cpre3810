-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_decoder5t32.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- 5 to 32 decoder.
--
--
-- NOTES:
-- 09/20/25 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_decoder5t32 is
	generic(gCLK_HPER   : time := 10 ns);   -- Generic for half of the clock cycle period
end tb_decoder5t32;

architecture behavior of tb_decoder5t32 is

  component decoder5t32
    Port (
        i_In    : in std_logic_vector(4 downto 0);    -- 5-bit input
        o_Out   : out std_logic_vector(31 downto 0)); -- 32 outputs
  end component;

  -- Temporary signals to connect to the decoder component.
  signal CLK : std_logic := '0';
  signal s_iIn  : std_logic_vector(4 downto 0); -- 5-bit input
  signal s_oOut : std_logic_vector(31 downto 0); -- 32 outputs

begin

  DUT: decoder5t32 
  port map(i_In  => s_iIn, 
           o_Out => s_oOut);

  --This first process is to setup the clock for the test bench
  P_CLK: process
  begin
    CLK <= '1';         -- clock starts at 1
    wait for gCLK_HPER; -- after half a cycle
    CLK <= '0';         -- clock becomes a 0 (negative edge)
    wait for gCLK_HPER; -- after half a cycle, process begins evaluation again
  end process;
  
  -- Testbench process  
  P_TB: process
  begin
    wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges
	
    -- Test 00000
    s_iIn <= "00000";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000000000000000000000000001'

    -- Test 00001
    s_iIn <= "00001";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000000000000000000000000010'

    -- Test 00010
    s_iIn <= "00010";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000000000000000000000000100'

    -- Test 00011
    s_iIn <= "00011";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000000000000000000000001000'

    -- Test 00100
    s_iIn <= "00100";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000000000000000000000010000'

    -- Test 00101
    s_iIn <= "00101";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000000000000000000000100000'

    -- Test 00110
    s_iIn <= "00110";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000000000000000000001000000'

    -- Test 00111
    s_iIn <= "00111";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000000000000000000010000000'

    -- Test 01000
    s_iIn <= "01000";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000000000000000000100000000'

    -- Test 01001
    s_iIn <= "01001";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000000000000000001000000000'

    -- Test 01010
    s_iIn <= "01010";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000000000000000010000000000'

    -- Test 01011
    s_iIn <= "01011";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000000000000000100000000000'

    -- Test 01100
    s_iIn <= "01100";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000000000000001000000000000'

    -- Test 01101
    s_iIn <= "01101";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000000000000010000000000000'

    -- Test 01110
    s_iIn <= "01110";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000000000000100000000000000'

    -- Test 01111
    s_iIn <= "01111";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000000000001000000000000000'

    -- Test 10000
    s_iIn <= "10000";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000000000010000000000000000'

    -- Test 10001
    s_iIn <= "10001";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000000000100000000000000000'

    -- Test 10010
    s_iIn <= "10010";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000000001000000000000000000'

    -- Test 10011
    s_iIn <= "10011";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000000010000000000000000000'

    -- Test 10100
    s_iIn <= "10100";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000000100000000000000000000'

    -- Test 10101
    s_iIn <= "10101";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000001000000000000000000000'

    -- Test 10110
    s_iIn <= "10110";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000010000000000000000000000'

    -- Test 10111
    s_iIn <= "10111";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000000100000000000000000000000'

    -- Test 11000
    s_iIn <= "11000";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000001000000000000000000000000'

    -- Test 11001
    s_iIn <= "11001";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000010000000000000000000000000'

    -- Test 11010
    s_iIn <= "11010";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00000100000000000000000000000000'

    -- Test 11011
    s_iIn <= "11011";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00001000000000000000000000000000'

    -- Test 11100
    s_iIn <= "11100";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00010000000000000000000000000000'

    -- Test 11101
    s_iIn <= "11101";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '00100000000000000000000000000000'

    -- Test 11110
    s_iIn <= "11110";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '01000000000000000000000000000000'

    -- Test 11111
    s_iIn <= "11111";
    wait for gCLK_HPER*2;
    -- Expect o_Out to be '10000000000000000000000000000000'

    wait;
  end process;
  
end behavior;
