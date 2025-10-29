library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Decode is 
  port(
    i_instr 	  : in std_logic_vector(31 downto 0);
    o_opcode	  : out std_logic_vector(6 downto 0); 
    o_rd	      : out std_logic_vector(4 downto 0); 
    o_func3	    : out std_logic_vector(2 downto 0); 
    o_rs1	      : out std_logic_vector(4 downto 0); 
    o_rs2	      : out std_logic_vector(4 downto 0); 
    o_func7	    : out std_logic_vector(6 downto 0);
    o_imm12bit	: out std_logic_vector(11 downto 0);
    o_imm13bit	: out std_logic_vector(12 downto 0);
    o_imm20bit	: out std_logic_vector(19 downto 0);
    o_immType   : out std_logic_vector(1 downto 0) -- Immediate Types:
                                                      -- 00: No immediate used
                                                      -- 01: 12-bit immediate used
                                                      -- 10: 13-bit immediate used
                                                      -- 11: 20-bit immediate used
  ); 
end Decode;

architecture Dataflow of Decode is
begin
 process(i_instr)
  begin
    -- Default values
    o_opcode      <= i_instr(6 downto 0);
    o_rd          <= (others => '0');
    o_func3       <= (others => '0');
    o_rs1         <= (others => '0');
    o_rs2         <= (others => '0');
    o_func7       <= (others => '0');
    o_imm12bit    <= (others => '0');
    o_imm13bit    <= (others => '0');
    o_imm20bit    <= (others => '0');
    o_immType     <= (others => '0');

    case i_instr(6 downto 0) is
      ------------------------------------------------------------------------
      -- R-TYPE Instruction
      ------------------------------------------------------------------------
      when "0110011" =>
        o_rd          <= i_instr(11 downto 7);
        o_func3       <= i_instr(14 downto 12);
        o_rs1         <= i_instr(19 downto 15);
        o_rs2         <= i_instr(24 downto 20);
        o_func7       <= i_instr(31 downto 25);
        o_imm12bit    <= (others => '0');  -- not used
        o_imm13bit    <= (others => '0');  -- not used
        o_imm20bit    <= (others => '0');  -- not used
        o_immType     <= (others => '0');  -- No immediate

      ------------------------------------------------------------------------
      -- I-TYPE Instruction
      ------------------------------------------------------------------------
      when "0010011" | "0000011" | "1100111" =>
        o_rd        <= i_instr(11 downto 7);
        o_func3     <= i_instr(14 downto 12);
        o_rs1       <= i_instr(19 downto 15);
        o_rs2       <= (others => '0');
        o_func7     <= (others => '0');
        o_imm12bit  <= i_instr(31 downto 20);
        o_imm13bit  <= (others => '0');  -- not used
        o_imm20bit  <= (others => '0');  -- not used
        o_immType   <= "01";             -- 12-bit immediate

      ------------------------------------------------------------------------
      -- S-TYPE Instruction
      ------------------------------------------------------------------------
      when "0100011" =>
        o_rd        <= (others => '0');
        o_func3     <= i_instr(14 downto 12);
        o_rs1       <= i_instr(19 downto 15);
        o_rs2       <= i_instr(24 downto 20);
        o_func7     <= (others => '0');
        o_imm12bit  <= (others => '0');  -- not used
        o_imm13bit  <= i_instr(31 downto 25) & i_instr(11 downto 7);
        o_imm20bit  <= (others => '0');  -- not used
        o_immType   <= "10";             -- 13-bit immediate

      ------------------------------------------------------------------------
      -- SB-TYPE Instruction
      ------------------------------------------------------------------------
      when "1100011" =>
        o_rd        <= (others => '0');
        o_func3     <= i_instr(14 downto 12);
        o_rs1       <= i_instr(19 downto 15);
        o_rs2       <= i_instr(24 downto 20);
        o_func7     <= (others => '0');
        o_imm12bit  <= (others => '0');  -- not used
        o_imm13bit  <= i_instr(31) & i_instr(7) & i_instr(30 downto 25) & i_instr(11 downto 8);
        o_imm20bit  <= (others => '0');  -- not used
        o_immType   <= "10";             -- 13-bit immediate

      ------------------------------------------------------------------------
      -- U-TYPE Instruction
      ------------------------------------------------------------------------
      when "0110111" | "0010111" =>
        o_rd       <= i_instr(11 downto 7);
        o_func3    <= (others => '0');
        o_rs1      <= (others => '0');
        o_rs2      <= (others => '0');
        o_func7    <= (others => '0');
        o_imm12bit <= (others => '0');  -- not used
        o_imm13bit <= (others => '0');  -- not used
        o_imm20bit <= i_instr(31 downto 12);
        o_immType   <= "11";             -- 20-bit immediate

      ------------------------------------------------------------------------
      -- UJ-TYPE Instruction
      ------------------------------------------------------------------------
      when "1101111" =>
        o_rd       <= i_instr(11 downto 7);
        o_func3    <= (others => '0');
        o_rs1      <= (others => '0');
        o_rs2      <= (others => '0');
        o_func7    <= (others => '0');
        o_imm12bit <= (others => '0');  -- not used
        o_imm13bit <= (others => '0');  -- not used
        o_imm20bit <= i_instr(31) & i_instr(19 downto 12) & i_instr(20) & i_instr(30 downto 21);
        o_immType   <= "11";             -- 20-bit immediate

      ------------------------------------------------------------------------
      -- Default / Unknown opcode
      ------------------------------------------------------------------------
      when others =>
        o_rd       <= (others => '0');
        o_func3    <= (others => '0');
        o_rs1      <= (others => '0');
        o_rs2      <= (others => '0');
        o_func7    <= (others => '0');
        o_imm12bit <= (others => '0');
        o_imm13bit <= (others => '0');
        o_imm20bit <= (others => '0');
        o_immType  <= (others => '0');
    end case;
  end process;
end Dataflow;