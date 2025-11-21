-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_slt_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the SLT (Set less than)
-- operation.
--              
-- 10/23/2025 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_slt_N is
  generic(gCLK_HPER   : time := 50 ns);   -- Generic for half of the clock cycle period
end tb_slt_N;

architecture mixed of tb_slt_N is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;
constant N         : integer := 32; -- 32 bit width

component slt_N is
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

  DUT0: slt_N
  port map(
            i_A       => s_iA,
            i_B       => s_iB,
            o_F       => s_oF);

    -- Testbench process
  P_TEST_CASES: process
  begin

    ----------------------------------------------------------------
    -- Test 1: SLT of all 1
    ----------------------------------------------------------------
    s_iA <= x"FFFFFFFF";
    s_iB <= x"FFFFFFFF";
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x00000000

    ----------------------------------------------------------------
    -- Test 2: SLT of all 1 and all 0
    ----------------------------------------------------------------
    s_iA <= x"FFFFFFFF";
    s_iB <= x"00000000";
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x00000001

    ----------------------------------------------------------------
    -- Test 3: SLT of all 0 and all 1
    ----------------------------------------------------------------
    s_iA <= x"00000000";
    s_iB <= x"FFFFFFFF";
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x00000000

    ----------------------------------------------------------------
    -- Test 4: SLT of two random values
    ----------------------------------------------------------------
    s_iA <= x"13579BDF";
    s_iB <= x"2468ACE0";
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x00000001

    wait;
  end process;

end mixed;
