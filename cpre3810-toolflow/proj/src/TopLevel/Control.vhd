library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Control is

   port(
       i_opcode         : in std_logic_vector(6 downto 0);
       i_func3		: in std_logic_vector(2 downto 0);
       i_func7		: in std_logic_vector(6 downto 0);
       o_ALUControl	: out std_logic_vector(3 downto 0);
       o_ImmType        : out std_logic_vector(1 downto 0);
       o_ALUSRC	 	: out std_logic;
       o_MemReg		: out std_logic;
       o_RegWr          : out std_logic;
       o_MemRd	 	: out std_logic;
       o_MemWr		: out std_logic;
       o_signed		: out std_logic; -- 1 when signed, 0 when unsigned
       o_Branch		: out std_logic);

   end Control;

architecture dataflow of Control is

    -- Instruction type constants
    constant OP_RTYPE : std_logic_vector(6 downto 0) := "0110011";
    constant OP_ITYPE : std_logic_vector(6 downto 0) := "0010011";
    constant OP_LOAD  : std_logic_vector(6 downto 0) := "0000011";
    constant OP_STORE : std_logic_vector(6 downto 0) := "0100011";
    constant OP_BRANCH: std_logic_vector(6 downto 0) := "1100011";
    constant OP_JAL   : std_logic_vector(6 downto 0) := "1101111";
    constant OP_JALR  : std_logic_vector(6 downto 0) := "1100111";
    constant OP_LUI   : std_logic_vector(6 downto 0) := "0110111";
    constant OP_AUIPC : std_logic_vector(6 downto 0) := "0010111";
    constant OP_SYSTEM: std_logic_vector(6 downto 0) := "1110011";

begin
    ---------------------------------------------------
    -- Example concurrent assignments (dataflow style)
    ---------------------------------------------------

    -- ALU Source: 1 if I-type, Load, or Store (immediate or memory)
    o_ALUSRC <= '1' when (i_opcode = OP_ITYPE or
                          i_opcode = OP_LOAD  or
                          i_opcode = OP_STORE or
                          i_opcode = OP_JAL   or
                          i_opcode = OP_JALR  or
                          i_opcode = OP_LUI   or
                          i_opcode = OP_AUIPC)
                else '0';

    -- Register Write Enable
    o_RegWr <= '1' when (i_opcode = OP_RTYPE or
                         i_opcode = OP_ITYPE or
                         i_opcode = OP_LOAD  or
                         i_opcode = OP_JAL   or
                         i_opcode = OP_JALR  or
                         i_opcode = OP_LUI   or
                         i_opcode = OP_AUIPC)
               else '0';
    
    -- Signed flag: 1 = signed, 0 = unsigned
    o_signed <= '0' when ((i_opcode = OP_RTYPE and i_func3 = "011") or  -- SLTU
                          (i_opcode = OP_ITYPE and i_func3 = "011") or  -- SLTIU
                          (i_opcode = OP_BRANCH and 
                          (i_func3 = "110" or i_func3 = "111")))     -- BLTU, BGEU
                else '1';


    o_MemRd <= '1' when (i_opcode = OP_LOAD) else '0';
    o_MemWr <= '1' when (i_opcode = OP_STORE) else '0';
    o_MemReg <= '1' when (i_opcode = OP_LOAD) else '0';
    o_Branch <= '1' when (i_opcode = OP_BRANCH) else '0';

    --------------------------------------------------------------------
    -- Immediate type selection
    --------------------------------------------------------------------
    o_ImmType <=
        "00" when (i_opcode = OP_RTYPE) else  -- R-type
        "01" when (i_opcode = OP_ITYPE or i_opcode = OP_LOAD or i_opcode = OP_JALR) else  -- I-type
        "10" when (i_opcode = OP_LUI or i_opcode = OP_AUIPC or i_opcode = OP_JAL) else    -- U/J-type
        "11" when (i_opcode = OP_STORE or i_opcode = OP_BRANCH) else                      -- S/B-type
        "00"; -- default

    --------------------------------------------------------------------
    -- ALU control decoding (aligned with ALU)
    --------------------------------------------------------------------
    o_ALUControl <=
        -- Arithmetic ops
        "0000" when (i_opcode = "0110011" and i_func3 = "000" and i_func7 = "0000000") else -- ADD
        "0001" when (i_opcode = "0110011" and i_func3 = "000" and i_func7 = "0100000") else -- SUB
        "0010" when (i_opcode = "0110011" and i_func3 = "010") else -- SLT
        "0011" when (i_opcode = "0110011" and i_func3 = "111") else -- AND
        "0100" when (i_opcode = "0110011" and i_func3 = "110") else -- OR
        "0101" when (i_opcode = "0110011" and i_func3 = "100") else -- XOR

        -- Shift ops (R-type)
        "0111" when (i_opcode = "0110011" and i_func3 = "001") else -- SLL
        "1000" when (i_opcode = "0110011" and i_func3 = "101" and i_func7 = "0000000") else -- SRL
        "1001" when (i_opcode = "0110011" and i_func3 = "101" and i_func7 = "0100000") else -- SRA

        -- I-type immediate versions
        "0000" when (i_opcode = "0010011" and i_func3 = "000") else -- ADDI
        "0010" when (i_opcode = "0010011" and i_func3 = "010") else -- SLTI
        "0011" when (i_opcode = "0010011" and i_func3 = "111") else -- ANDI
        "0100" when (i_opcode = "0010011" and i_func3 = "110") else -- ORI
        "0101" when (i_opcode = "0010011" and i_func3 = "100") else -- XORI
        "1010" when (i_opcode = "0010011" and i_func3 = "001") else -- SLLI
        "1011" when (i_opcode = "0010011" and i_func3 = "101" and i_func7 = "0000000") else -- SRLI
        "1100" when (i_opcode = "0010011" and i_func3 = "101" and i_func7 = "0100000") else -- SRAI

        -- Branches use subtraction or set-less-than
        "0001" when (i_opcode = "1100011" and (i_func3 = "000" or i_func3 = "001")) else -- BEQ/BNE ? SUB
        "0010" when (i_opcode = "1100011" and (i_func3 = "100" or i_func3 = "101" or
                                               i_func3 = "110" or i_func3 = "111")) else -- BLT, BGE, BLTU, BGEU ? SLT

        -- Loads, stores, LUI, AUIPC, JAL, JALR use ADD
        "0000" when (i_opcode = "0000011" or i_opcode = "0100011" or
                     i_opcode = "0110111" or i_opcode = "0010111" or
                     i_opcode = "1101111" or i_opcode = "1100111") else

        -- HALT / WFI
        "1111" when (i_opcode = "1110011") else

        (others => '0');
end dataflow;