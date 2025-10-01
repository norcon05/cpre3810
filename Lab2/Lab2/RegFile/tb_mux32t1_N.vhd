-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_mux32t1_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- N-bit 32 to 1 Multiplexer
--
--
-- NOTES:
-- 09/20/25 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_mux32t1_N is
  generic(gCLK_HPER   : time := 50 ns);
end tb_mux32t1_N;

architecture behavior of tb_mux32t1_N is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;
  constant N         : integer := 32; -- Set register width here


  component mux32t1_N
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
	port (i_S   : in std_logic_vector(4 downto 0);         -- 5-bit select input'
		  i_D0  : in std_logic_vector(N-1 downto 0);       -- Input 0
		  i_D1  : in std_logic_vector(N-1 downto 0);       -- Input 1
		  i_D2  : in std_logic_vector(N-1 downto 0);       -- Input 2
		  i_D3  : in std_logic_vector(N-1 downto 0);       -- Input 3
		  i_D4  : in std_logic_vector(N-1 downto 0);       -- Input 4
		  i_D5  : in std_logic_vector(N-1 downto 0);       -- Input 5
		  i_D6  : in std_logic_vector(N-1 downto 0);       -- Input 6
		  i_D7  : in std_logic_vector(N-1 downto 0);       -- Input 7
		  i_D8  : in std_logic_vector(N-1 downto 0);       -- Input 8
		  i_D9  : in std_logic_vector(N-1 downto 0);       -- Input 9
		  i_D10 : in std_logic_vector(N-1 downto 0);       -- Input 10
		  i_D11 : in std_logic_vector(N-1 downto 0);       -- Input 11
		  i_D12 : in std_logic_vector(N-1 downto 0);       -- Input 12
		  i_D13 : in std_logic_vector(N-1 downto 0);       -- Input 13
		  i_D14 : in std_logic_vector(N-1 downto 0);       -- Input 14
		  i_D15 : in std_logic_vector(N-1 downto 0);       -- Input 15
		  i_D16 : in std_logic_vector(N-1 downto 0);       -- Input 16
		  i_D17 : in std_logic_vector(N-1 downto 0);       -- Input 17
		  i_D18 : in std_logic_vector(N-1 downto 0);       -- Input 18
		  i_D19 : in std_logic_vector(N-1 downto 0);       -- Input 19
		  i_D20 : in std_logic_vector(N-1 downto 0);       -- Input 20
		  i_D21 : in std_logic_vector(N-1 downto 0);       -- Input 21
		  i_D22 : in std_logic_vector(N-1 downto 0);       -- Input 22
		  i_D23 : in std_logic_vector(N-1 downto 0);       -- Input 23
		  i_D24 : in std_logic_vector(N-1 downto 0);       -- Input 24
		  i_D25 : in std_logic_vector(N-1 downto 0);       -- Input 25
		  i_D26 : in std_logic_vector(N-1 downto 0);       -- Input 26
		  i_D27 : in std_logic_vector(N-1 downto 0);       -- Input 27
		  i_D28 : in std_logic_vector(N-1 downto 0);       -- Input 28
		  i_D29 : in std_logic_vector(N-1 downto 0);       -- Input 29
		  i_D30 : in std_logic_vector(N-1 downto 0);       -- Input 30
		  i_D31 : in std_logic_vector(N-1 downto 0);       -- Input 31
		  o_O   : out std_logic_vector(N-1 downto 0));     -- Selected output
  end component;

  -- Temporary signals to connect to the multiplexer component.
  signal s_iS                                   : std_logic_vector(4 downto 0);
  signal s_iD0, s_iD1, s_iD2, s_iD3, s_iD4      : std_logic_vector(N-1 downto 0);
  signal s_iD5, s_iD6, s_iD7, s_iD8, s_iD9      : std_logic_vector(N-1 downto 0);
  signal s_iD10, s_iD11, s_iD12, s_iD13, s_iD14 : std_logic_vector(N-1 downto 0);
  signal s_iD15, s_iD16, s_iD17, s_iD18, s_iD19 : std_logic_vector(N-1 downto 0);
  signal s_iD20, s_iD21, s_iD22, s_iD23, s_iD24 : std_logic_vector(N-1 downto 0);
  signal s_iD25, s_iD26, s_iD27, s_iD28, s_iD29 : std_logic_vector(N-1 downto 0);
  signal s_iD30, s_iD31                         : std_logic_vector(N-1 downto 0);
  signal s_oO                                   : std_logic_vector(N-1 downto 0);

begin

  DUT: mux32t1_N 
  port map(i_S   => s_iS, 
           i_D0  => s_iD0,
           i_D1  => s_iD1,
		   i_D2  => s_iD2,
           i_D3  => s_iD3,
		   i_D4  => s_iD4,
           i_D5  => s_iD5,
		   i_D6  => s_iD6,
           i_D7  => s_iD7,
		   i_D8  => s_iD8,
           i_D9  => s_iD9,
		   i_D10 => s_iD10,
           i_D11 => s_iD11,
		   i_D12 => s_iD12,
           i_D13 => s_iD13,
		   i_D14 => s_iD14,
           i_D15 => s_iD15,
		   i_D16 => s_iD16,
           i_D17 => s_iD17,
		   i_D18 => s_iD18,
           i_D19 => s_iD19,
		   i_D20 => s_iD20,
           i_D21 => s_iD21,
		   i_D22 => s_iD22,
           i_D23 => s_iD23,
		   i_D24 => s_iD24,
           i_D25 => s_iD25,
		   i_D26 => s_iD26,
           i_D27 => s_iD27,
		   i_D28 => s_iD28,
           i_D29 => s_iD29,
		   i_D30 => s_iD30,
           i_D31 => s_iD31,
           o_O   => s_oO);

  
  -- Testbench process  
  P_TB: process
  begin
	-- Initialize all inputs to distinct values
    s_iD0  <= X"00000000";
    s_iD1  <= X"00000001";
    s_iD2  <= X"00000002";
    s_iD3  <= X"00000003";
    s_iD4  <= X"00000004";
    s_iD5  <= X"00000005";
    s_iD6  <= X"00000006";
    s_iD7  <= X"00000007";
    s_iD8  <= X"00000008";
    s_iD9  <= X"00000009";
    s_iD10 <= X"00000010";
    s_iD11 <= X"00000011";
    s_iD12 <= X"00000012";
    s_iD13 <= X"00000013";
    s_iD14 <= X"00000014";
    s_iD15 <= X"00000015";
    s_iD16 <= X"00000016";
    s_iD17 <= X"00000017";
    s_iD18 <= X"00000018";
    s_iD19 <= X"00000019";
    s_iD20 <= X"00000020";
    s_iD21 <= X"00000021";
    s_iD22 <= X"00000022";
    s_iD23 <= X"00000023";
    s_iD24 <= X"00000024";
    s_iD25 <= X"00000025";
    s_iD26 <= X"00000026";
    s_iD27 <= X"00000027";
    s_iD28 <= X"00000028";
    s_iD29 <= X"00000029";
    s_iD30 <= X"00000030";
    s_iD31 <= X"00000031";
	
	-- Test Case 1: Select input 0
  s_iS <= "00000";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000000

  -- Test Case 2: Select input 1
  s_iS <= "00001";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000001

  -- Test Case 3: Select input 2
  s_iS <= "00010";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000002

  -- Test Case 4: Select input 3
  s_iS <= "00011";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000003

  -- Test Case 5: Select input 4
  s_iS <= "00100";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000004

  -- Test Case 6: Select input 5
  s_iS <= "00101";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000005

  -- Test Case 7: Select input 6
  s_iS <= "00110";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000006

  -- Test Case 8: Select input 7
  s_iS <= "00111";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000007

  -- Test Case 9: Select input 8
  s_iS <= "01000";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000008

  -- Test Case 10: Select input 9
  s_iS <= "01001";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000009

  -- Test Case 11: Select input 10
  s_iS <= "01010";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000010

  -- Test Case 12: Select input 11
  s_iS <= "01011";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000011

  -- Test Case 13: Select input 12
  s_iS <= "01100";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000012

  -- Test Case 14: Select input 13
  s_iS <= "01101";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000013

  -- Test Case 15: Select input 14
  s_iS <= "01110";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000014

  -- Test Case 16: Select input 15
  s_iS <= "01111";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000015

  -- Test Case 17: Select input 16
  s_iS <= "10000";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000016

  -- Test Case 18: Select input 17
  s_iS <= "10001";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000017

  -- Test Case 19: Select input 18
  s_iS <= "10010";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000018

  -- Test Case 20: Select input 19
  s_iS <= "10011";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000019

  -- Test Case 21: Select input 20
  s_iS <= "10100";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000020

  -- Test Case 22: Select input 21
  s_iS <= "10101";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000021

  -- Test Case 23: Select input 22
  s_iS <= "10110";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000022

  -- Test Case 24: Select input 23
  s_iS <= "10111";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000023

  -- Test Case 25: Select input 24
  s_iS <= "11000";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000024

  -- Test Case 26: Select input 25
  s_iS <= "11001";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000025

  -- Test Case 27: Select input 26
  s_iS <= "11010";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000026

  -- Test Case 28: Select input 27
  s_iS <= "11011";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000027

  -- Test Case 29: Select input 28
  s_iS <= "11100";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000028

  -- Test Case 30: Select input 29
  s_iS <= "11101";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000029

  -- Test Case 31: Select input 30
  s_iS <= "11110";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000030

  -- Test Case 32: Select input 31
  s_iS <= "11111";
  wait for cCLK_PER;
  -- EXPECT: o_O = 0x00000031
	
    wait;
  end process;
  
end behavior;
