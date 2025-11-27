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

begin

  -------------------------------------------------------------------
  -- Datapath registers
  -------------------------------------------------------------------

  RS1_DATA_REG: reg_N
    generic map(N => 32)
    port map(
      i_CLK => iCLK,
      i_RST => iFlush or iRST,
      i_WE  => not iStall,
      i_D   => i_rs1_data,
      o_Q   => o_rs1_data
    );

  RS2_DATA_REG: reg_N
    generic map(N => 32)
    port map(
      i_CLK => iCLK,
      i_RST => iFlush or iRST,
      i_WE  => not iStall,
      i_D   => i_rs2_data,
      o_Q   => o_rs2_data
    );

  RS1_REG: reg_N
    generic map(N => 5)
    port map(
      i_CLK => iCLK,
      i_RST => iFlush or iRST,
      i_WE  => not iStall,
      i_D   => i_rs1,
      o_Q   => o_rs1
    );

  RS2_REG: reg_N
    generic map(N => 5)
    port map(
      i_CLK => iCLK,
      i_RST => iFlush or iRST,
      i_WE  => not iStall,
      i_D   => i_rs2,
      o_Q   => o_rs2
    );

  RD_REG: reg_N
    generic map(N => 5)
    port map(
      i_CLK => iCLK,
      i_RST => iFlush or iRST,
      i_WE  => not iStall,
      i_D   => i_rd,
      o_Q   => o_rd
    );

  IMM_REG: reg_N
    generic map(N => 32)
    port map(
      i_CLK => iCLK,
      i_RST => iFlush or iRST,
      i_WE  => not iStall,
      i_D   => i_imm,
      o_Q   => o_imm
    );

  PC_REG: reg_N
    generic map(N => 32)
    port map(
      i_CLK => iCLK,
      i_RST => iFlush or iRST,
      i_WE  => not iStall,
      i_D   => i_pc,
      o_Q   => o_pc
    );

  -------------------------------------------------------------------
  -- Control registers
  -------------------------------------------------------------------

  ALUOP_REG: reg_N
    generic map(N => 4)
    port map(
      i_CLK => iCLK,
      i_RST => iFlush or iRST,
      i_WE  => not iStall,
      i_D   => i_ALUOp,
      o_Q   => o_ALUOp
    );

  FUNC3_REG: reg_N
    generic map(N => 3)
    port map(
      i_CLK => iCLK,
      i_RST => iFlush or iRST,
      i_WE  => not iStall,
      i_D   => i_func3,
      o_Q   => o_func3
    );

  FUNC7_REG: reg_N
    generic map(N => 7)
    port map(
      i_CLK => iCLK,
      i_RST => iFlush or iRST,
      i_WE  => not iStall,
      i_D   => i_func7,
      o_Q   => o_func7
    );

  OPCODE_REG: reg_N
    generic map(N => 7)
    port map(
      i_CLK => iCLK,
      i_RST => iFlush or iRST,
      i_WE  => not iStall,
      i_D   => i_opcode,
      o_Q   => o_opcode
    );

  -- 1-bit controls now implemented with dffg

  ALUSRC_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iFlush or iRST,
      i_WE  => not iStall,
      i_D   => i_ALUSrc,
      o_Q   => o_ALUSrc
    );

  SIGNED_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iFlush or iRST,
      i_WE  => not iStall,
      i_D   => i_signed,
      o_Q   => o_signed
    );

  BRANCH_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iFlush or iRST,
      i_WE  => not iStall,
      i_D   => i_Branch,
      o_Q   => o_Branch
    );

  JUMP_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iFlush or iRST,
      i_WE  => not iStall,
      i_D   => i_Jump,
      o_Q   => o_Jump
    );

  AUIPC_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iFlush or iRST,
      i_WE  => not iStall,
      i_D   => i_auipc,
      o_Q   => o_auipc
    );

  UIMM_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iFlush or iRST,
      i_WE  => not iStall,
      i_D   => i_upperIMM,
      o_Q   => o_upperIMM
    );

  MEMWR_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iFlush or iRST,
      i_WE  => not iStall,
      i_D   => i_MemWr,
      o_Q   => o_MemWr
    );

  MEMREG_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iFlush or iRST,
      i_WE  => not iStall,
      i_D   => i_MemReg,
      o_Q   => o_MemReg
    );

  REGWR_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iFlush or iRST,
      i_WE  => not iStall,
      i_D   => i_RegWr,
      o_Q   => o_RegWr
    );

  HALT_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iFlush or iRST,
      i_WE  => not iStall,
      i_D   => i_Halt,
      o_Q   => o_Halt
    );

end structural;