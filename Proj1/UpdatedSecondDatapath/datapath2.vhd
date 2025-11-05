-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- datapath2.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of the second RISCV-like datapath
--
--
-- NOTES:
-- 09/23/25 by CWM::Created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity datapath2 is
  port(i_rs1           : in std_logic_vector(4 downto 0);
       i_rs2           : in std_logic_vector(4 downto 0);
	     i_rd 	       : in std_logic_vector(4 downto 0);
	     i_imm 	       : in std_logic_vector(11 downto 0);
	     i_CLK           : in std_logic;
	     i_RST           : in std_logic;
	     i_write_enable  : in std_logic;
	     i_ALU_SRC       : in std_logic;   -- Second value in ALU (0 - rs2, 1 - immediate)
	     i_ALUOp         : in  std_logic_vector(3 downto 0);   -- ALU operation control signal:
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
	     i_sign          : in std_logic;   -- Extension of Immediate (0 - zero extended, 1 - sign extended)
	     i_MemWrite      : in std_logic;   -- Can Write to memory?
	     i_MemToReg      : in std_logic;   -- Choose rd data (0 - ALU Result, 1 - Memory output)
       o_ALU_Result    : out std_logic_vector(31 downto 0); -- Output result of ALU for testing
       o_ALU_Zero      : out std_logic;  -- ALU Zero Output
	     o_rd_data       : out std_logic_vector(31 downto 0)); -- Output the data getting written to rd for testing
end datapath2;

architecture structural of datapath2 is

  component alu is
    generic(N : integer := 32);
    port (
      i_A         : in  std_logic_vector(N-1 downto 0); -- Operand A input
      i_B         : in  std_logic_vector(N-1 downto 0); -- Operand B input
      i_imm       : in  std_logic_vector(N-1 downto 0); -- Immediate value input (used if i_ALUSrc = '1')
      i_sign	    : in  std_logic;		                  -- '1' is signed, '0' is unsigned
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
  end component;
  
  component regFile is
    port(i_CLK      : in std_logic;                         -- Clock
         i_RST      : in std_logic;                         -- Reset
         i_WE       : in std_logic;                         -- Write Enable
         i_rs1_addr : in std_logic_vector(4 downto 0);      -- Address of first register we want to read
	     i_rs2_addr : in std_logic_vector(4 downto 0);      -- Address of second register we want to read
	     i_rd_addr  : in std_logic_vector(4 downto 0);      -- Address of register we want to write to
	     i_rd_data  : in std_logic_vector(31 downto 0);	    -- The data we want to write
	     o_rs1_data : out std_logic_vector(31 downto 0);    -- The data held in the first register we read
         o_rs2_data : out std_logic_vector(31 downto 0));   -- The data held in the second register we read
  end component;
  
  component extender is
    port (i_in  : in  STD_LOGIC_VECTOR(11 downto 0);   -- 12-bit input
          i_sel : in  STD_LOGIC;                       -- '1' = sign-extend, '0' = zero-extend
          o_out : out STD_LOGIC_VECTOR(31 downto 0));  -- 32-bit output
  end component;
  
  component mem is
    generic (DATA_WIDTH : natural := 32;
	         ADDR_WIDTH : natural := 10);
	port (clk		: in std_logic;
		  addr	    : in std_logic_vector((ADDR_WIDTH-1) downto 0);
		  data	    : in std_logic_vector((DATA_WIDTH-1) downto 0);
		  we		: in std_logic := '1';
		  q		    : out std_logic_vector((DATA_WIDTH -1) downto 0));
  end component;
  
  component mux2t1_N is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_S          : in std_logic;
         i_D0         : in std_logic_vector(N-1 downto 0);
         i_D1         : in std_logic_vector(N-1 downto 0);
         o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  signal s_iA          : std_logic_vector(31 downto 0);           -- A in the ALU
  signal s_iB          : std_logic_vector(31 downto 0);           -- B in the ALU
  signal s_iimm        : std_logic_vector(31 downto 0);           -- immediate in the ALU
  signal s_q           : std_logic_vector(31 downto 0);           -- Output from memory
  signal s_oALU_Result : std_logic_vector(31 downto 0);           -- The result of the ALU
  signal s_ord_data    : std_logic_vector(31 downto 0);           -- The result of the 2 to 1 mux
begin
  RegFileInst : regFile
    port map(
      i_CLK      => i_CLK,
      i_RST      => i_RST,
      i_WE       => i_write_enable,
      i_rs1_addr => i_rs1,
      i_rs2_addr => i_rs2,
      i_rd_addr  => i_rd,
      i_rd_data  => s_ord_data,
      o_rs1_data => s_iA,
      o_rs2_data => s_iB
    );
	
  ExtenderInst : extender
    port map(
      i_in       => i_imm,
      i_sel      => i_sign,
      o_out      => s_iimm
    );
	
  ALUInst : alu
    generic map(N => 32)
    port map(
      i_A         => s_iA,
      i_B         => s_iB,
	    i_imm       => s_iimm,
	    i_sign      => i_sign,
      i_ALUOp     => i_ALUOp,
	    i_ALUSrc    => i_ALU_SRC,
      o_F         => s_oALU_Result,
	    o_Zero      => o_ALU_Zero
    );
  
  MemoryInst : mem
    generic map(
	  DATA_WIDTH => 32,
	  ADDR_WIDTH => 10
	)
    port map(
	  clk        => i_CLK,
      addr       => s_oALU_Result(11 downto 2),
      data       => s_iB,
	  we         => i_MemWrite,
      q          => s_q
    );
	
  MuxInst : mux2t1_N
    port map(
      i_S       => i_MemToReg,
      i_D0      => s_oALU_Result,
      i_D1      => s_q,
	  o_O       => s_ord_data
    );

  o_ALU_Result <= s_oALU_Result;
  o_rd_data    <= s_ord_data;
  
end structural;
