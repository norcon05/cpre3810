-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- mux32t1_N.vhd
-----------------------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 32 to 1 Multiplexer
--
-- NOTES:
-- 09/20/25 by CWM::Design created.
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux32t1_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port (
    i_S   : in std_logic_vector(4 downto 0);         -- 5-bit select input'
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
  

end mux32t1_N;

architecture dataflow of mux32t1_N is

begin
    process(i_S,
            i_D0, i_D1, i_D2, i_D3, i_D4, i_D5, i_D6, i_D7,
            i_D8, i_D9, i_D10, i_D11, i_D12, i_D13, i_D14, i_D15,
            i_D16, i_D17, i_D18, i_D19, i_D20, i_D21, i_D22, i_D23,
            i_D24, i_D25, i_D26, i_D27, i_D28, i_D29, i_D30, i_D31)
    begin
        case i_S is
            when "00000" => o_O <= i_D0;
            when "00001" => o_O <= i_D1;
            when "00010" => o_O <= i_D2;
            when "00011" => o_O <= i_D3;
            when "00100" => o_O <= i_D4;
            when "00101" => o_O <= i_D5;
            when "00110" => o_O <= i_D6;
            when "00111" => o_O <= i_D7;
            when "01000" => o_O <= i_D8;
            when "01001" => o_O <= i_D9;
            when "01010" => o_O <= i_D10;
            when "01011" => o_O <= i_D11;
            when "01100" => o_O <= i_D12;
            when "01101" => o_O <= i_D13;
            when "01110" => o_O <= i_D14;
            when "01111" => o_O <= i_D15;
            when "10000" => o_O <= i_D16;
            when "10001" => o_O <= i_D17;
            when "10010" => o_O <= i_D18;
            when "10011" => o_O <= i_D19;
            when "10100" => o_O <= i_D20;
            when "10101" => o_O <= i_D21;
            when "10110" => o_O <= i_D22;
            when "10111" => o_O <= i_D23;
            when "11000" => o_O <= i_D24;
            when "11001" => o_O <= i_D25;
            when "11010" => o_O <= i_D26;
            when "11011" => o_O <= i_D27;
            when "11100" => o_O <= i_D28;
            when "11101" => o_O <= i_D29;
            when "11110" => o_O <= i_D30;
            when "11111" => o_O <= i_D31;
            when others => o_O <= (others => '0'); -- Default
        end case;
    end process;
end dataflow;
