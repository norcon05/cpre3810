-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_andg2_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the N-bit wide
-- AND gate.
--              
-- 10/23/2025 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_andg2_N is
  generic(gCLK_HPER   : time := 50 ns);   -- Generic for half of the clock cycle period
end tb_andg2_N;

architecture mixed of tb_andg2_N is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;
constant N         : integer := 32; -- 32 bit width

component andg2_N is
  generic(N : integer := 32);
  port(i_A          : in std_logic_vector(N-1 downto 0);
       i_B          : in std_logic_vector(N-1 downto 0);
       o_F          : out std_logic_vector(N-1 downto 0));
end component;

  -- Temporary signals to connect to the register component.
  signal s_iA       : std_logic_vector(N-1 downto 0);
  signal s_iB       : std_logic_vector(N-1 downto 0);
  signal s_oF       : std_logic_vector(N-1 downto 0);
begin

  DUT0: andg2_N
  port map(
            i_A       => s_iA,
            i_B       => s_iB,
            o_F       => s_oF);

    -- Testbench process
  P_TEST_CASES: process
  begin

    ----------------------------------------------------------------
    -- Test 1: AND of all 1s and all 1s
    ----------------------------------------------------------------
    s_iA <= x"FFFFFFFF";
    s_iB <= x"FFFFFFFF";
    wait for cCLK_PER;
    -- EXPECT: o_F = 0xFFFFFFFF

    ----------------------------------------------------------------
    -- Test 2: AND of all 1s and all 0s
    ----------------------------------------------------------------
    s_iA <= x"FFFFFFFF";
    s_iB <= x"00000000";
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x00000000

    ----------------------------------------------------------------
    -- Test 3: AND of random values
    ----------------------------------------------------------------
    s_iA <= x"8239D238";
    s_iB <= x"A48C32F3";
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x80081230

    ----------------------------------------------------------------
    -- Test 4: AND of alternating bits
    ----------------------------------------------------------------
    s_iA <= x"AAAAAAAA"; 
    s_iB <= x"55555555";  
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x00000000

    wait;
  end process;

end mixed;
