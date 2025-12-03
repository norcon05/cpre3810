-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- ID_EX.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an ID/EX Pipeline Register
--
--
-- NOTES:
-- 11/16/25 by CWM::Created.
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity ID_EX is
  port (
    iCLK : in std_logic;
    iFlush : in std_logic;
    iStall : in std_logic;
    iRST : in std_logic;

    -- Datapath inputs
    i_rs1_data  : in std_logic_vector(31 downto 0);
    i_rs2_data  : in std_logic_vector(31 downto 0);
    i_rs1       : in std_logic_vector(4 downto 0);
    i_rs2       : in std_logic_vector(4 downto 0);
    i_rd        : in std_logic_vector(4 downto 0);
    i_imm       : in std_logic_vector(31 downto 0);
    i_pc        : in std_logic_vector(31 downto 0);

    -- Control inputs
    i_ALUOp     : in std_logic_vector(3 downto 0);
    i_ALUSrc    : in std_logic;
    i_signed    : in std_logic;
    i_Branch    : in std_logic;
    i_func3     : in std_logic_vector(2 downto 0);
    i_func7     : in std_logic_vector(6 downto 0);
    i_opcode    : in std_logic_vector(6 downto 0);
    i_Jump      : in std_logic;
    i_auipc     : in std_logic;
    i_upperIMM  : in std_logic;
    i_MemWr     : in std_logic;
    i_MemReg    : in std_logic;
    i_RegWr     : in std_logic;
    i_Halt      : in std_logic;

    -- Datapath outputs
    o_rs1_data  : out std_logic_vector(31 downto 0);
    o_rs2_data  : out std_logic_vector(31 downto 0);
    o_rs1       : out std_logic_vector(4 downto 0);
    o_rs2       : out std_logic_vector(4 downto 0);
    o_rd        : out std_logic_vector(4 downto 0);
    o_imm       : out std_logic_vector(31 downto 0);
    o_pc        : out std_logic_vector(31 downto 0);

    -- Control outputs
    o_ALUOp     : out std_logic_vector(3 downto 0);
    o_ALUSrc    : out std_logic;
    o_signed    : out std_logic;
    o_Branch    : out std_logic;
    o_func3     : out std_logic_vector(2 downto 0);
    o_func7     : out std_logic_vector(6 downto 0);
    o_opcode    : out std_logic_vector(6 downto 0);
    o_Jump      : out std_logic;
    o_auipc     : out std_logic;
    o_upperIMM  : out std_logic;
    o_MemWr     : out std_logic;
    o_MemReg    : out std_logic;
    o_RegWr     : out std_logic;
    o_Halt      : out std_logic
  );
end entity;


architecture structural of ID_EX is

  component reg_N is
    generic(N : integer := 32);
    port(
      i_CLK : in std_logic;
      i_RST : in std_logic;
      i_WE  : in std_logic;
      i_D   : in std_logic_vector(N-1 downto 0);
      o_Q   : out std_logic_vector(N-1 downto 0)
    );
  end component;

  component dffg is
    port(
      i_CLK : in std_logic;
      i_RST : in std_logic;
      i_WE  : in std_logic;
      i_D   : in std_logic;
      o_Q   : out std_logic
    );
  end component;

  signal s_rs1_data_in : std_logic_vector(31 downto 0);
  signal s_rs2_data_in : std_logic_vector(31 downto 0);
  signal s_rs1_in      : std_logic_vector(4 downto 0);
  signal s_rs2_in      : std_logic_vector(4 downto 0);
  signal s_rd_in       : std_logic_vector(4 downto 0);
  signal s_imm_in      : std_logic_vector(31 downto 0);
  signal s_pc_in       : std_logic_vector(31 downto 0);
  signal s_aluop_in    : std_logic_vector(3 downto 0);
  signal s_func3_in    : std_logic_vector(2 downto 0);
  signal s_func7_in    : std_logic_vector(6 downto 0);
  signal s_opcode_in   : std_logic_vector(6 downto 0);
  signal s_alusrc_in   : std_logic;
  signal s_signed_in   : std_logic;
  signal s_branch_in   : std_logic;
  signal s_jump_in     : std_logic;
  signal s_auipc_in    : std_logic;
  signal s_upperimm_in : std_logic;
  signal s_memwr_in    : std_logic;
  signal s_memreg_in   : std_logic;
  signal s_regwr_in    : std_logic;
  signal s_halt_in     : std_logic;

begin

  -------------------------------------------------------------------
  -- Datapath registers
  -------------------------------------------------------------------
  
  s_rs1_data_in <= (others => '0') when iFlush = '1' else i_rs1_data;

  RS1_DATA_REG: reg_N
    generic map(N => 32)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_rs1_data_in,
      o_Q   => o_rs1_data
    );

  s_rs2_data_in <= (others => '0') when iFlush = '1' else i_rs2_data;

  RS2_DATA_REG: reg_N
    generic map(N => 32)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_rs2_data_in,
      o_Q   => o_rs2_data
    );

  s_rs1_in <= (others => '0') when iFlush = '1' else i_rs1;

  RS1_REG: reg_N
    generic map(N => 5)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_rs1_in,
      o_Q   => o_rs1
    );

  s_rs2_in <= (others => '0') when iFlush = '1' else i_rs2;

  RS2_REG: reg_N
    generic map(N => 5)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_rs2_in,
      o_Q   => o_rs2
    );

  s_rd_in <= (others => '0') when iFlush = '1' else i_rd;

  RD_REG: reg_N
    generic map(N => 5)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_rd_in,
      o_Q   => o_rd
    );

  s_imm_in <= (others => '0') when iFlush = '1' else i_imm;

  IMM_REG: reg_N
    generic map(N => 32)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_imm_in,
      o_Q   => o_imm
    );

  s_pc_in <= (others => '0') when iFlush = '1' else i_pc;

  PC_REG: reg_N
    generic map(N => 32)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_pc_in,
      o_Q   => o_pc
    );

  -------------------------------------------------------------------
  -- Control registers
  -------------------------------------------------------------------

  s_aluop_in <= (others => '0') when iFlush = '1' else i_ALUOp;

  ALUOP_REG: reg_N
    generic map(N => 4)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_aluop_in,
      o_Q   => o_ALUOp
    );

  s_func3_in <= (others => '0') when iFlush = '1' else i_func3;

  FUNC3_REG: reg_N
    generic map(N => 3)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_func3_in,
      o_Q   => o_func3
    );

  s_func7_in <= (others => '0') when iFlush = '1' else i_func7;

  FUNC7_REG: reg_N
    generic map(N => 7)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_func7_in,
      o_Q   => o_func7
    );

  s_opcode_in <= (others => '0') when iFlush = '1' else i_opcode;

  OPCODE_REG: reg_N
    generic map(N => 7)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_opcode_in,
      o_Q   => o_opcode
    );

  s_alusrc_in <= '0' when iFlush = '1' else i_ALUSrc;

  ALUSRC_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_alusrc_in,
      o_Q   => o_ALUSrc
    );

  s_signed_in <= '0' when iFlush = '1' else i_signed;

  SIGNED_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_signed_in,
      o_Q   => o_signed
    );

  s_branch_in <= '0' when iFlush = '1' else i_Branch;

  BRANCH_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_branch_in,
      o_Q   => o_Branch
    );

  s_jump_in <= '0' when iFlush = '1' else i_Jump;

  JUMP_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_jump_in,
      o_Q   => o_Jump
    );

  s_auipc_in <= '0' when iFlush = '1' else i_auipc;

  AUIPC_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_auipc_in,
      o_Q   => o_auipc
    );

  s_upperimm_in <= '0' when iFlush = '1' else i_upperIMM;

  UIMM_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_upperimm_in,
      o_Q   => o_upperIMM
    );

  s_memwr_in <= '0' when iFlush = '1' else i_MemWr;

  MEMWR_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_memwr_in,
      o_Q   => o_MemWr
    );

  s_memreg_in <= '0' when iFlush = '1' else i_MemReg;

  MEMREG_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_memreg_in,
      o_Q   => o_MemReg
    );

  s_regwr_in <= '0' when iFlush = '1' else i_RegWr;

  REGWR_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_regwr_in,
      o_Q   => o_RegWr
    );

  s_halt_in <= '0' when iFlush = '1' else i_Halt;
  
  HALT_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_halt_in,
      o_Q   => o_Halt
    );

end structural;