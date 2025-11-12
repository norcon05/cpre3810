-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_invg_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the N-bit wide
-- NOT gate (inverter).
--              
-- 10/23/2025 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_invg_N is
  generic(gCLK_HPER   : time := 50 ns);   -- Generic for half of the clock cycle period
end tb_invg_N;

architecture mixed of tb_invg_N is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;
constant N         : integer := 32; -- 32 bit width

component invg_N is
  generic(N : integer := 32);
  port(i_A          : in std_logic_vector(N-1 downto 0);
       o_F          : out std_logic_vector(N-1 downto 0));
end component;

  -- Temporary signals to connect to the register component.
  signal s_iA       : std_logic_vector(N-1 downto 0);
  signal s_oF       : std_logic_vector(N-1 downto 0);
begin

  DUT0: invg_N
  port map(
            i_A       => s_iA,
            o_F       => s_oF);

    -- Testbench process
  P_TEST_CASES: process
  begin

    ----------------------------------------------------------------
    -- Test 1: NOT of all 1
    ----------------------------------------------------------------
    s_iA <= x"FFFFFFFF";
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x00000000

    ----------------------------------------------------------------
    -- Test 2: NOT of all 0
    ----------------------------------------------------------------
    s_iA <= x"00000000";
    wait for cCLK_PER;
    -- EXPECT: o_F = 0xFFFFFFFF

    ----------------------------------------------------------------
    -- Test 3: NOT of random value
    ----------------------------------------------------------------
    s_iA <= x"13579BDF";
    wait for cCLK_PER;
    -- EXPECT: o_F = 0xECA86420

    wait;
  end process;

end mixed;
