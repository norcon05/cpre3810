-- tb_pipelineUpdate.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for flushing and stalling the pipeline registers
--
-- NOTES:
-- 12/07/25 by CWM::Design created.
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY tb_pipelineUpdate IS
  GENERIC (gCLK_HPER : TIME := 50 ns);
END tb_pipelineUpdate;

ARCHITECTURE behavior OF tb_pipelineUpdate IS

  CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;
  CONSTANT N : INTEGER := 32; -- 32 bit width

  -- Pipeline Registers:
  COMPONENT IF_ID IS
    PORT (
      iCLK : IN STD_LOGIC;
      iFlush : IN STD_LOGIC;
      iStall : IN STD_LOGIC;
      iRST : IN STD_LOGIC;

      -- Inputs from IF stage
      i_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_inst : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

      -- Outputs to ID stage
      o_pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_inst : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT ID_EX IS
    PORT (
      iCLK : IN STD_LOGIC;
      iFlush : IN STD_LOGIC;
      iStall : IN STD_LOGIC;
      iRST : IN STD_LOGIC;

      -- Datapath inputs
      i_rs1_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_rs2_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_rs1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      i_rs2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      i_rd : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      i_imm : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

      -- Control inputs
      i_ALUOp : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      i_ALUSrc : IN STD_LOGIC;
      i_signed : IN STD_LOGIC;
      i_Branch : IN STD_LOGIC;
      i_func3 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      i_func7 : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
      i_opcode : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
      i_Jump : IN STD_LOGIC;
      i_auipc : IN STD_LOGIC;
      i_upperIMM : IN STD_LOGIC;
      i_MemWr : IN STD_LOGIC;
      i_MemReg : IN STD_LOGIC;
      i_RegWr : IN STD_LOGIC;
      i_Halt : IN STD_LOGIC;

      -- Datapath outputs
      o_rs1_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_rs2_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_rs1 : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
      o_rs2 : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
      o_rd : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
      o_imm : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

      -- Control outputs
      o_ALUOp : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      o_ALUSrc : OUT STD_LOGIC;
      o_signed : OUT STD_LOGIC;
      o_Branch : OUT STD_LOGIC;
      o_func3 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      o_func7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
      o_opcode : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
      o_Jump : OUT STD_LOGIC;
      o_auipc : OUT STD_LOGIC;
      o_upperIMM : OUT STD_LOGIC;
      o_MemWr : OUT STD_LOGIC;
      o_MemReg : OUT STD_LOGIC;
      o_RegWr : OUT STD_LOGIC;
      o_Halt : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT EX_MEM IS
    PORT (
      iCLK : IN STD_LOGIC;
      iFlush : IN STD_LOGIC;
      iStall : IN STD_LOGIC;
      iRST : IN STD_LOGIC;

      -- Datapath inputs
      i_ALU_result : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_rs2_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_rd : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      i_func3 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      i_func7 : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
      i_opcode : IN STD_LOGIC_VECTOR(6 DOWNTO 0);

      -- Control inputs
      i_Branch : IN STD_LOGIC;
      i_MemWr : IN STD_LOGIC;
      i_MemReg : IN STD_LOGIC;
      i_RegWr : IN STD_LOGIC;
      i_Halt : IN STD_LOGIC;

      -- Datapath outputs
      o_ALU_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_rs2_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_rd : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
      o_func3 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      o_func7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
      o_opcode : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);

      -- Control outputs
      o_Branch : OUT STD_LOGIC;
      o_MemWr : OUT STD_LOGIC;
      o_MemReg : OUT STD_LOGIC;
      o_RegWr : OUT STD_LOGIC;
      o_Halt : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT MEM_WB IS
    PORT (
      iCLK : IN STD_LOGIC;
      iFlush : IN STD_LOGIC;
      iStall : IN STD_LOGIC;
      iRST : IN STD_LOGIC;

      -- Datapath inputs
      i_MEM_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_ALU_result : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_rd : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      i_func3 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      i_func7 : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
      i_opcode : IN STD_LOGIC_VECTOR(6 DOWNTO 0);

      -- Control inputs
      i_MemReg : IN STD_LOGIC;
      i_RegWr : IN STD_LOGIC;
      i_Halt : IN STD_LOGIC;

      -- Datapath outputs
      o_MEM_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_ALU_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_rd : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
      o_func3 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      o_func7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
      o_opcode : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);

      -- Control outputs
      o_MemReg : OUT STD_LOGIC;
      o_RegWr : OUT STD_LOGIC;
      o_Halt : OUT STD_LOGIC
    );
  END COMPONENT;

  --------------------------------------------------------------------
  -- SIGNAL DECLARATIONS
  --------------------------------------------------------------------
  SIGNAL s_iCLK : STD_LOGIC := '0';
  SIGNAL s_iRST : STD_LOGIC := '0';

  -- Stall/flush control for each pipeline register
  SIGNAL s_stall_IFID, s_stall_IDEX, s_stall_EXMEM, s_stall_MEMWB : STD_LOGIC := '0';
  SIGNAL s_flush_IFID, s_flush_IDEX, s_flush_EXMEM, s_flush_MEMWB : STD_LOGIC := '0';

  --------------------------------------------------------------------
  -- PIPELINE SIGNALS (Reduced set for the testbench)
  --------------------------------------------------------------------
  SIGNAL s_pc_IF, s_pc_ID, s_pc_EX, s_pc_MEM, s_pc_WB : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_inst_IF, s_inst_ID : STD_LOGIC_VECTOR(31 DOWNTO 0);

  -- Signals for ID/EX outputs (not used in testbench)
  SIGNAL s_rs1_data_EX : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_rs2_data_EX : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_rs1_EX, s_rs2_EX, s_rd_EX : STD_LOGIC_VECTOR(4 DOWNTO 0);
  SIGNAL s_imm_EX : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_ALUOp_EX : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL s_ALUSrc_EX, s_signed_EX, s_Branch_EX, s_Jump_EX, s_auipc_EX, s_upperIMM_EX : STD_LOGIC;
  SIGNAL s_func3_EX : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL s_func7_EX : STD_LOGIC_VECTOR(6 DOWNTO 0);
  SIGNAL s_opcode_EX : STD_LOGIC_VECTOR(6 DOWNTO 0);
  SIGNAL s_MemWr_EX, s_MemReg_EX, s_RegWr_EX, s_Halt_EX : STD_LOGIC;

  -- Signals for EX/MEM outputs
  SIGNAL s_rs2_MEM : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_rd_MEM : STD_LOGIC_VECTOR(4 DOWNTO 0);
  SIGNAL s_func3_MEM : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL s_func7_MEM : STD_LOGIC_VECTOR(6 DOWNTO 0);
  SIGNAL s_opcode_MEM : STD_LOGIC_VECTOR(6 DOWNTO 0);
  SIGNAL s_Branch_MEM, s_MemWr_MEM, s_MemReg_MEM, s_RegWr_MEM, s_Halt_MEM : STD_LOGIC;

  -- Signals for MEM/WB outputs
  SIGNAL s_MEM_data_WB : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_rd_WB : STD_LOGIC_VECTOR(4 DOWNTO 0);
  SIGNAL s_func3_WB : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL s_func7_WB : STD_LOGIC_VECTOR(6 DOWNTO 0);
  SIGNAL s_opcode_WB : STD_LOGIC_VECTOR(6 DOWNTO 0);
  SIGNAL s_MemReg_WB, s_RegWr_WB, s_Halt_WB : STD_LOGIC;

  -- Single-bit control and status signals (default '0')
  SIGNAL s_iALUSrc_zero : STD_LOGIC := '0';
  SIGNAL s_iSigned_zero : STD_LOGIC := '0';
  SIGNAL s_iBranch_zero : STD_LOGIC := '0';
  SIGNAL s_iJump_zero : STD_LOGIC := '0';
  SIGNAL s_iAuipc_zero : STD_LOGIC := '0';
  SIGNAL s_iUpperIMM_zero : STD_LOGIC := '0';
  SIGNAL s_iMemWr_zero : STD_LOGIC := '0';
  SIGNAL s_iMemReg_zero : STD_LOGIC := '0';
  SIGNAL s_iRegWr_zero : STD_LOGIC := '0';
  SIGNAL s_iHalt_zero : STD_LOGIC := '0';

  -- ALU operation (4 bits)
  SIGNAL s_iALUOp_zero : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');

  -- Function codes and opcode
  SIGNAL s_iFunc3_zero : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL s_iFunc7_zero : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
  SIGNAL s_iOpcode_zero : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');

  -- Register addresses
  SIGNAL s_iRS1_zero : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
  SIGNAL s_iRS2_zero : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
  SIGNAL s_iRD_zero : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');

  -- Immediate value (32 bits)
  SIGNAL s_iImm_zero : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
BEGIN

  IFID_inst : IF_ID
  PORT MAP(
    iCLK => s_iCLK,
    iFlush => s_flush_IFID,
    iStall => s_stall_IFID,
    iRST => s_iRST,
    i_pc => s_pc_IF,
    i_inst => s_inst_IF,
    o_pc => s_pc_ID,
    o_inst => s_inst_ID
  );

  IDEX_inst : ID_EX
  PORT MAP(
    iCLK => s_iCLK,
    iFlush => s_flush_IDEX,
    iStall => s_stall_IDEX,
    iRST => s_iRST,
    i_rs1_data => s_pc_ID,
    i_rs2_data => s_inst_ID,
    i_rs1 => s_iRS1_zero,
    i_rs2 => s_iRS2_zero,
    i_rd => s_iRD_zero,
    i_imm => s_iImm_zero,
    i_pc => s_pc_ID,
    i_ALUOp => s_iALUOp_zero,
    i_ALUSrc => s_iALUSrc_zero,
    i_signed => s_iSigned_zero,
    i_Branch => s_iBranch_zero,
    i_func3 => s_iFunc3_zero,
    i_func7 => s_iFunc7_zero,
    i_opcode => s_iOpcode_zero,
    i_Jump => s_iJump_zero,
    i_auipc => s_iAuipc_zero,
    i_upperIMM => s_iUpperIMM_zero,
    i_MemWr => s_iMemWr_zero,
    i_MemReg => s_iMemReg_zero,
    i_RegWr => s_iRegWr_zero,
    i_Halt => s_iHalt_zero,
    o_rs1_data => s_rs1_data_EX,
    o_rs2_data => s_rs2_data_EX,
    o_rs1 => s_rs1_EX,
    o_rs2 => s_rs2_EX,
    o_rd => s_rd_EX,
    o_imm => s_imm_EX,
    o_pc => s_pc_EX,
    o_ALUOp => s_ALUOp_EX,
    o_ALUSrc => s_ALUSrc_EX,
    o_signed => s_signed_EX,
    o_Branch => s_Branch_EX,
    o_func3 => s_func3_EX,
    o_func7 => s_func7_EX,
    o_opcode => s_opcode_EX,
    o_Jump => s_Jump_EX,
    o_auipc => s_auipc_EX,
    o_upperIMM => s_upperIMM_EX,
    o_MemWr => s_MemWr_EX,
    o_MemReg => s_MemReg_EX,
    o_RegWr => s_RegWr_EX,
    o_Halt => s_Halt_EX
  );

  EXMEM_inst : EX_MEM
  PORT MAP(
    iCLK => s_iCLK,
    iFlush => s_flush_EXMEM,
    iStall => s_stall_EXMEM,
    iRST => s_iRST,
    i_ALU_result => s_pc_EX,
    i_rs2_data => s_iImm_zero,
    i_rd => s_iRD_zero,
    i_func3 => s_iFunc3_zero,
    i_func7 => s_iFunc7_zero,
    i_opcode => s_iOpcode_zero,
    i_Branch => s_iBranch_zero,
    i_MemWr => s_iMemWr_zero,
    i_MemReg => s_iMemReg_zero,
    i_RegWr => s_iRegWr_zero,
    i_Halt => s_iHalt_zero,
    o_ALU_result => s_pc_MEM,
    o_rs2_data => s_rs2_MEM,
    o_rd => s_rd_MEM,
    o_func3 => s_func3_MEM,
    o_func7 => s_func7_MEM,
    o_opcode => s_opcode_MEM,
    o_Branch => s_Branch_MEM,
    o_MemWr => s_MemWr_MEM,
    o_MemReg => s_MemReg_MEM,
    o_RegWr => s_RegWr_MEM,
    o_Halt => s_Halt_MEM
  );

  MEMWB_inst : MEM_WB
  PORT MAP(
    iCLK => s_iCLK,
    iFlush => s_flush_MEMWB,
    iStall => s_stall_MEMWB,
    iRST => s_iRST,
    i_MEM_data => s_pc_MEM,
    i_ALU_result => s_pc_MEM,
    i_rd => s_iRD_zero,
    i_func3 => s_iFunc3_zero,
    i_func7 => s_iFunc7_zero,
    i_opcode => s_iOpcode_zero,
    i_MemReg => s_iMemReg_zero,
    i_RegWr => s_iRegWr_zero,
    i_Halt => s_iHalt_zero,
    o_MEM_data => s_MEM_data_WB,
    o_ALU_result => s_pc_WB,
    o_rd => s_rd_WB,
    o_func3 => s_func3_WB,
    o_func7 => s_func7_WB,
    o_opcode => s_opcode_WB,
    o_MemReg => s_MemReg_WB,
    o_RegWr => s_RegWr_WB,
    o_Halt => s_Halt_WB
  );

  -- This process sets the clock value (low for gCLK_HPER, then high
  -- for gCLK_HPER). Absent a "wait" command, processes restart 
  -- at the beginning once they have reached the final statement.
  P_CLK : PROCESS
  BEGIN
    s_iCLK <= '0';
    WAIT FOR gCLK_HPER;
    s_iCLK <= '1';
    WAIT FOR gCLK_HPER;
  END PROCESS;

  -- Testbench process  
  P_TB : PROCESS
  BEGIN

    ------------------------------------------------------------
    -- RESET
    ------------------------------------------------------------
    s_iRST <= '1';
    s_pc_IF <= x"00000000";
    WAIT FOR cCLK_PER;
    s_iRST <= '0';
    -- EXPECT: All pipeline registers cleared to 0

    --------------------------------------------------------------------
    -- Test 1: Normal Pipeline Flow (PC=0x00000010, INST=0xAAAAAAAA)
    --------------------------------------------------------------------
    s_pc_IF <= x"00000010";
    s_inst_IF <= x"AAAAAAAA";
    WAIT FOR cCLK_PER;
    -- EXPECT: After 1 cycle -> IF/ID sees value
    --         After 2 cycles -> ID/EX sees value
    --         After 3 cycles -> EX/MEM sees value
    --         After 4 cycles -> MEM/WB outputs 0x00000010

    --------------------------------------------------------------------
    -- Test 2: Insert New Value Each Cycle (PC=0x00000020, INST=0xBBBBBBBB)
    --------------------------------------------------------------------
    s_pc_IF <= x"00000020";
    s_inst_IF <= x"BBBBBBBB";
    WAIT FOR cCLK_PER;
    -- EXPECT: Pipeline continues accepting new data every cycle

    --------------------------------------------------------------------
    -- Test 3: Stall IF/ID (Freeze previous value even though new input arrives)
    --------------------------------------------------------------------
    s_stall_IFID <= '1';
    s_pc_IF <= x"00000030"; -- SHOULD NOT propagate
    s_inst_IF <= x"CCCCCCCC"; -- SHOULD NOT propagate
    WAIT FOR cCLK_PER;
    -- EXPECT: IF/ID output remains unchanged

    --------------------------------------------------------------------
    -- Test 4: Insert New Value After Stall Releases (PC=0x00000040, INST=0xDDDDDDDD)
    --------------------------------------------------------------------
    s_stall_IFID <= '0'; -- release stall
    s_pc_IF <= x"00000040";
    s_inst_IF <= x"DDDDDDDD";
    WAIT FOR cCLK_PER;
    -- EXPECT: IF/ID updates normally and value flows again

    --------------------------------------------------------------------
    -- Test 5: Flush ID/EX (Clear ID/EX register regardless of input)
    --------------------------------------------------------------------
    s_flush_IDEX <= '1';
    WAIT FOR cCLK_PER;
    -- EXPECT: ID/EX outputs are zeroed or NOPed
    s_flush_IDEX <= '0';

    --------------------------------------------------------------------
    -- Test 6: Stall EX/MEM (Hold value constant during stall)
    --------------------------------------------------------------------
    s_stall_EXMEM <= '1';
    WAIT FOR cCLK_PER;
    -- EXPECT: EX/MEM output does not change even though inputs do
    s_stall_EXMEM <= '0';

    --------------------------------------------------------------------
    -- Test 7: Flush MEM/WB (Clear MEM/WB output)
    --------------------------------------------------------------------
    s_flush_MEMWB <= '1';
    WAIT FOR cCLK_PER;
    -- EXPECT: MEM/WB output forced to zero/NOP
    s_flush_MEMWB <= '0';
    WAIT;
  END PROCESS;

END behavior;