-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- alu.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a structural implementation of a
-- RISC-V ALU
--
-- Supports: add, sub, addi, subi, slt, and, or, xor, nor,
--           sll, srl, sra, slli, srli, srai
--
-- NOTES:
-- 10/22/25 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu is
  generic(N : integer := 32);
  port (
    i_A         : in  std_logic_vector(N-1 downto 0); -- Operand A input
    i_B         : in  std_logic_vector(N-1 downto 0); -- Operand B input
    i_imm       : in  std_logic_vector(N-1 downto 0); -- Immediate value input (used if i_ALUSrc = '1')
    
    i_ALUOp     : in  std_logic_vector(3 downto 0);   -- ALU operation control signal:
                                                      -- 0000 : ADD / ADDI (Add i_A and i_B or immediate)
                                                      -- 0001 : SUB / SUBI (Subtract i_B or immediate from i_A)
                                                      -- 0010 : SLT       (Set Less Than: i_A < i_B or immediate)
                                                      -- 0011 : AND       (Bitwise AND)
                                                      -- 0100 : OR        (Bitwise OR)
                                                      -- 0101 : XOR       (Bitwise XOR)
                                                      -- 0110 : NOR       (Bitwise NOR)
                                                      -- 0111 : SLL       (Logical Left Shift)
                                                      -- 1000 : SRL       (Logical Right Shift)
                                                      -- 1001 : SRA       (Arithmetic Right Shift)
                                                      -- 1010 : SLLI      (Logical Left Shift Immediate)
                                                      -- 1011 : SRLI      (Logical Right Shift Immediate)
                                                      -- 1100 : SRAI      (Arithmetic Right Shift Immediate)

    i_ALUSrc    : in  std_logic;                      -- Selects second ALU operand source:
                                                      -- '0' = i_B
                                                      -- '1' = i_imm (immediate)

    o_F         : out std_logic_vector(N-1 downto 0); -- ALU output result
    o_Zero      : out std_logic                       -- Zero flag, '1' if o_F is zero, else '0'
  );
end alu;


architecture structural of alu is

  -- COMPONENT DECLARATIONS
  component addiSubi_N is
    generic(N : integer := 32);
    port(i_A         : in std_logic_vector(N-1 downto 0);
         i_B         : in std_logic_vector(N-1 downto 0);
         i_immediate : in std_logic_vector(N-1 downto 0);
         i_nAdd_Sub  : in std_logic;
         i_ALU_SRC   : in std_logic;
         o_S         : out std_logic_vector(N-1 downto 0);
         o_Cout      : out std_logic);
  end component;

  component andg2_N is
    generic(N : integer := 32);
    port(i_A : in std_logic_vector(N-1 downto 0);
         i_B : in std_logic_vector(N-1 downto 0);
         o_F : out std_logic_vector(N-1 downto 0));
  end component;

  component org2_N is
    generic(N : integer := 32);
    port(i_A : in std_logic_vector(N-1 downto 0);
         i_B : in std_logic_vector(N-1 downto 0);
         o_F : out std_logic_vector(N-1 downto 0));
  end component;

  component xorg2_N is
    generic(N : integer := 32);
    port(i_A : in std_logic_vector(N-1 downto 0);
         i_B : in std_logic_vector(N-1 downto 0);
         o_F : out std_logic_vector(N-1 downto 0));
  end component;

  component invg_N is
    generic(N : integer := 32);
    port(i_A : in std_logic_vector(N-1 downto 0);
         o_F : out std_logic_vector(N-1 downto 0));
  end component;

  component slt_N is
    generic(N : integer := 32);
    port(i_A : in std_logic_vector(N-1 downto 0);
         i_B : in std_logic_vector(N-1 downto 0);
         o_F : out std_logic_vector(N-1 downto 0));
  end component;

  component barrelShifter is
    port (
      i_data       : in  std_logic_vector(31 downto 0);
      i_shiftAmnt  : in  std_logic_vector(4 downto 0);
      i_arith      : in  std_logic;
      i_dir        : in  std_logic; -- '0' = right shift, '1' = left shift
      o_data       : out std_logic_vector(31 downto 0)
    );
  end component;

  -- INTERNAL SIGNALS
  signal s_addsub_out, s_and_out, s_or_out, s_xor_out, s_nor_out : std_logic_vector(N-1 downto 0);
  signal s_slt_out, s_shift_out, s_ALU_out : std_logic_vector(N-1 downto 0);
  signal s_Cout : std_logic;
  signal s_arith, s_dir : std_logic;
  signal s_op2 : std_logic_vector(N-1 downto 0);  -- Selected second operand (i_B or i_imm)
  signal s_shift_amount : std_logic_vector(4 downto 0);
  signal zero_vector : std_logic_vector(N-1 downto 0) := (others => '0');
begin

  -- Select second operand based on i_ALUSrc
  s_op2 <= i_imm when i_ALUSrc = '1' else i_B;

  ---------------------------------------------------------------------------
  -- ADD / SUB / ADDI / SUBI
  ---------------------------------------------------------------------------
  ADD_SUB_UNIT : addiSubi_N
    generic map(N => N)
    port map(
      i_A         => i_A,
      i_B         => i_B,
	    i_immediate => i_imm,
      i_nAdd_Sub  => i_ALUOp(0),  -- 0=ADD, 1=SUB
	    i_ALU_SRC   => i_ALUSrc,
      o_S         => s_addsub_out,
      o_Cout      => s_Cout
    );

  ---------------------------------------------------------------------------
  -- LOGIC OPERATIONS
  ---------------------------------------------------------------------------
  AND_UNIT : andg2_N
    generic map(N => N)
    port map(
      i_A => i_A, 
      i_B => s_op2, 
      o_F => s_and_out
    );

  OR_UNIT : org2_N
    generic map(N => N)
    port map(
      i_A => i_A, 
      i_B => s_op2,
      o_F => s_or_out
    );

  XOR_UNIT : xorg2_N
    generic map(N => N)
    port map(
      i_A => i_A, 
      i_B => s_op2, 
      o_F => s_xor_out
    );

  NOR_UNIT : invg_N
    generic map(N => N)
    port map(
      i_A => s_or_out, -- NOTE: s_or_out goes in to create nor
      o_F => s_nor_out
    );

  ---------------------------------------------------------------------------
  -- SLT (Set Less Than)
  ---------------------------------------------------------------------------
  SLT_UNIT : slt_N
    generic map(N => N)
    port map(
      i_A => i_A, 
      i_B => s_op2, 
      o_F => s_slt_out
    );

  ---------------------------------------------------------------------------
  -- SHIFT OPERATIONS
  ---------------------------------------------------------------------------
  -- 0 = right, 1 = left
  s_dir <= '0' when (i_ALUOp = "1000" or i_ALUOp = "1001" or
                     i_ALUOp = "1011" or i_ALUOp = "1100") else '1';

  s_arith <= '1' when (i_ALUOp = "1001" or i_ALUOp = "1100") else '0'; -- SRA or SRAI

  s_shift_amount <= s_op2(4 downto 0); --Only grab the bottom 5 bits

  SHIFT_UNIT : barrelShifter
    port map(
      i_data      => i_A,
      i_shiftAmnt => s_shift_amount,
      i_arith     => s_arith,
      i_dir       => s_dir,
      o_data      => s_shift_out
    );

  ---------------------------------------------------------------------------
  -- OUTPUT MUX
  ---------------------------------------------------------------------------
  process(i_ALUOp, s_addsub_out, s_and_out, s_or_out, s_xor_out, s_nor_out,
          s_slt_out, s_shift_out)
  begin
    case i_ALUOp is
      when "0000" => s_ALU_out <= s_addsub_out;   -- ADD / ADDI
      when "0001" => s_ALU_out <= s_addsub_out;   -- SUB / SUBI
      when "0010" => s_ALU_out <= s_slt_out;      -- SLT
      when "0011" => s_ALU_out <= s_and_out;      -- AND
      when "0100" => s_ALU_out <= s_or_out;       -- OR
      when "0101" => s_ALU_out <= s_xor_out;      -- XOR
      when "0110" => s_ALU_out <= s_nor_out;      -- NOR
      when "0111" => s_ALU_out <= s_shift_out;    -- SLL
      when "1000" => s_ALU_out <= s_shift_out;    -- SRL
      when "1001" => s_ALU_out <= s_shift_out;    -- SRA
      when "1010" => s_ALU_out <= s_shift_out;    -- SLLI
      when "1011" => s_ALU_out <= s_shift_out;    -- SRLI
      when "1100" => s_ALU_out <= s_shift_out;    -- SRAI
      when others => s_ALU_out <= (others => '0');
    end case;
  end process;

  o_F <= s_ALU_out; --Set the output

  ---------------------------------------------------------------------------
  -- ZERO FLAG
  ---------------------------------------------------------------------------
  o_Zero <= '1' when (s_ALU_out = zero_vector) else '0';

end structural;

