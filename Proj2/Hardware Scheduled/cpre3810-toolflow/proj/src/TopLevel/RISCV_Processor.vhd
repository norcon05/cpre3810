-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- RISCV_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a RISCV_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-- 04/10/2025 by AP::Coverted to RISC-V.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.RISCV_types.all;

entity RISCV_Processor is
  generic(N : integer := DATA_WIDTH);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  RISCV_Processor;


architecture structure of RISCV_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemWrIn	    : std_logic; -- Initial Signal 
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrIn	    : std_logic; -- Initial Signal 
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrAddrIn	: std_logic_vector(4 downto 0); -- Initial Signal 
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Use WFI with Opcode: 111 0011)

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl         : std_logic;  -- TODO: this signal indicates an overflow exception would have been initiated

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
    end component;

  component alu is
    generic(N : integer := 32);
    port (
      i_A         : in  std_logic_vector(N-1 downto 0); -- Operand A input
      i_B         : in  std_logic_vector(N-1 downto 0); -- Operand B input
      i_imm       : in  std_logic_vector(N-1 downto 0); -- Immediate value input (used if i_ALUSrc = '1')
      i_sign	  : in  std_logic;			-- '1' when signed, '0' when unsigned
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

  component pcLogic is
    port(
    i_CLK          : in std_logic;                          -- Clock signal for synchronous PC updates
    i_RST          : in std_logic;                          -- Reset signal (typically sets PC to 0)
    i_PC_WE        : in std_logic;                          -- Enable signal for writing to PC (for wfi)
    i_rs1          : in std_logic_vector(31 downto 0);      -- Value from register rs1 (used for JALR)
    i_imm          : in std_logic_vector(31 downto 0);      -- 32-bit immediate from instruction (used in branches, JAL, JALR)
    i_current_PC   : in std_logic_vector(31 downto 0);      -- Current PC value (for calculating branch targets)
    i_PC_STALL     : in std_logic;                          -- Stall signal for PC
    i_PC_SEL       : in std_logic_vector(1 downto 0);       -- PC Next Value Selection: 
	                                                            -- 00: PC + 4         (Default)
                                                              -- 01: PC + imm       (Branch)
                                                              -- 10: PC + imm       (JAL)
                                                              -- 11: rs1 + imm      (JALR)
    o_PC           : out std_logic_vector(31 downto 0)      -- Output: current PC value (used by instruction memory)
    );
    end component;

  component Control is
    port(
       i_opcode         : in std_logic_vector(6 downto 0);
       i_func3		: in std_logic_vector(2 downto 0);
       i_func7		: in std_logic_vector(6 downto 0);
       o_ALUControl	: out std_logic_vector(3 downto 0);
       o_ImmType        : out std_logic_vector(1 downto 0);
       o_ALUSRC	 	: out std_logic;
       o_MemReg		: out std_logic;
       o_RegWr          : out std_logic;
       o_MemWr		: out std_logic;
       o_signed		: out std_logic; -- 1 when signed, 0 when unsigned
       o_Branch		: out std_logic;
       o_branchJump	: out std_logic;
       o_Jump		: out std_logic;
       o_upperIMM	: out std_logic;
       o_auipc		: out std_logic);
    end component;

  component extender is
    port (i_imm12bit  : in  STD_LOGIC_VECTOR(11 downto 0);   -- 12-bit input
          i_imm20bit  : in  STD_LOGIC_VECTOR(19 downto 0);   -- 20-bit input
          i_immType   : in  STD_LOGIC;    -- Immediate Types:
                                            -- 0: 12-bit immediate used
                                            -- 1: 20-bit immediate used
          i_branchJump    : in STD_LOGIC;			-- '1' for branch or jump, else '0'
	  i_upperIMM	      : in STD_LOGIC;                        -- '1' = shift upper, '0' = normal handling
          i_sign      : in  STD_LOGIC;                       -- '1' = sign-extend, '0' = zero-extend
          o_out       : out STD_LOGIC_VECTOR(31 downto 0));  -- 32-bit output
    end component;

  component regFile is
    port(
       i_CLK      : in std_logic;                         -- Clock
       i_RST      : in std_logic;                         -- Reset
       i_WE       : in std_logic;                         -- Write Enable
       i_rs1_addr : in std_logic_vector(4 downto 0);      -- Address of first register we want to read
	     i_rs2_addr : in std_logic_vector(4 downto 0);      -- Address of second register we want to read
	     i_rd_addr  : in std_logic_vector(4 downto 0);      -- Address of register we want to write to
	     i_rd_data  : in std_logic_vector(31 downto 0);	    -- The data we want to write
	     o_rs1_data : out std_logic_vector(31 downto 0);    -- The data held in the first register we read
       o_rs2_data : out std_logic_vector(31 downto 0));   -- The data held in the second register we read
    end component;

  component Decode is
    port(
      i_instr 	  : in std_logic_vector(31 downto 0);
      o_opcode	  : out std_logic_vector(6 downto 0); 
      o_rd	      : out std_logic_vector(4 downto 0); 
      o_func3	    : out std_logic_vector(2 downto 0); 
      o_rs1	      : out std_logic_vector(4 downto 0); 
      o_rs2	      : out std_logic_vector(4 downto 0); 
      o_func7	    : out std_logic_vector(6 downto 0);
      o_imm12bit	: out std_logic_vector(11 downto 0);
      o_imm20bit	: out std_logic_vector(19 downto 0);
      o_immType   : out std_logic -- Immediate Types:
                                    -- 0: 12-bit immediate used
                                    -- 1: 20-bit immediate used
      );
    end component;

  -- Pipeline Registers:
  component IF_ID is
    port (
      iCLK    : in  std_logic;
      iFlush  : in  std_logic;
      iStall  : in  std_logic;
      iRST    : in  std_logic;

      -- Inputs from IF stage
      i_pc    : in  std_logic_vector(31 downto 0);
      i_inst  : in  std_logic_vector(31 downto 0);

      -- Outputs to ID stage
      o_pc    : out std_logic_vector(31 downto 0);
      o_inst  : out std_logic_vector(31 downto 0)
    );
  end component;
  
  component ID_EX is
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
  end component;

  component EX_MEM is
    port (
      iCLK : in std_logic;
      iFlush : in std_logic;
      iStall : in std_logic;
      iRST : in std_logic;

      -- Datapath inputs
      i_ALU_result : in std_logic_vector(31 downto 0); 
      i_rs2_data   : in std_logic_vector(31 downto 0);
      i_rd         : in std_logic_vector(4 downto 0);
      i_func3      : in std_logic_vector(2 downto 0);
      i_func7      : in std_logic_vector(6 downto 0);
      i_opcode     : in std_logic_vector(6 downto 0);

      -- Control inputs
      i_Branch     : in std_logic;
      i_MemWr      : in std_logic;
      i_MemReg     : in std_logic;
      i_RegWr      : in std_logic;
      i_Halt       : in std_logic;

      -- Datapath outputs
      o_ALU_result : out std_logic_vector(31 downto 0);
      o_rs2_data   : out std_logic_vector(31 downto 0);
      o_rd         : out std_logic_vector(4 downto 0);
      o_func3      : out std_logic_vector(2 downto 0);
      o_func7      : out std_logic_vector(6 downto 0);
      o_opcode     : out std_logic_vector(6 downto 0);

      -- Control outputs
      o_Branch     : out std_logic;  
      o_MemWr      : out std_logic;
      o_MemReg     : out std_logic;    
      o_RegWr      : out std_logic;
      o_Halt       : out std_logic
    );  
  end component;

  component MEM_WB is
    port (
      iCLK : in std_logic;
      iFlush : in std_logic;
      iStall : in std_logic;
      iRST : in std_logic;

      -- Datapath inputs
      i_MEM_data   : in std_logic_vector(31 downto 0);
      i_ALU_result : in std_logic_vector(31 downto 0);
      i_rd         : in std_logic_vector(4 downto 0);
      i_func3      : in std_logic_vector(2 downto 0);
      i_func7      : in std_logic_vector(6 downto 0);
      i_opcode     : in std_logic_vector(6 downto 0);

      -- Control inputs
      i_MemReg     : in std_logic;
      i_RegWr      : in std_logic;
      i_Halt       : in std_logic;

      -- Datapath outputs
      o_MEM_data   : out std_logic_vector(31 downto 0);
      o_ALU_result : out std_logic_vector(31 downto 0);
      o_rd         : out std_logic_vector(4 downto 0);
      o_func3      : out std_logic_vector(2 downto 0);
      o_func7      : out std_logic_vector(6 downto 0);
      o_opcode     : out std_logic_vector(6 downto 0);

      -- Control outputs
      o_MemReg     : out std_logic;
      o_RegWr      : out std_logic;
      o_Halt       : out std_logic
    );
  end component;


  -- Instruction fields
  signal s_opcode  : std_logic_vector(6 downto 0);
  signal s_func3   : std_logic_vector(2 downto 0);
  signal s_func7   : std_logic_vector(6 downto 0);
  signal s_rs1     : std_logic_vector(4 downto 0);
  signal s_rs2     : std_logic_vector(4 downto 0);

  -- Register file data lines
  signal s_rs1_data  : std_logic_vector(N-1 downto 0);
  signal s_rs2_data  : std_logic_vector(N-1 downto 0);

  -- Immediate Signals
  signal s_imm       : std_logic_vector(N-1 downto 0);
  signal s_imm12bit  : std_logic_vector(11 downto 0);
  signal s_imm20bit  : std_logic_vector(19 downto 0);
  signal s_DecImmType: std_logic;


  -- Control signals
  signal s_ALUOp     : std_logic_vector(3 downto 0);
  signal s_ImmType   : std_logic_vector(1 downto 0);
  signal s_ALUSrc    : std_logic;
  signal s_MemReg    : std_logic;
  signal s_MemWr     : std_logic;
  signal s_signed    : std_logic;
  signal s_Branch    : std_logic;
  signal s_BranchJump: std_logic;
  signal s_Jump	     : std_logic;
  signal s_upperIMM     : std_logic;
  signal s_auipc	: std_logic;

  -- ALU outputs
  signal s_ALUResult : std_logic_vector(N-1 downto 0);
  signal s_Zero      : std_logic;
  signal s_Op1	     : std_logic_vector(N-1 downto 0);

  -- PC control
  signal s_PC        : std_logic_vector(N-1 downto 0);
  signal s_PC_SEL    : std_logic_vector(1 downto 0);
  signal s_PC_WE     : std_logic;
  signal s_PC_BA     : std_logic_vector(N-1 downto 0);
  signal s_four	     : std_logic_vector(N-1 downto 0);

  -- Load Byte, Half-Word
  signal s_LoadData : std_logic_vector(N-1 downto 0);

  -- IF/ID outputs
  signal s_IFID_PC     : std_logic_vector(31 downto 0);
  signal s_IFID_Inst   : std_logic_vector(31 downto 0);

  -- ID/EX outputs
  signal s_IDEX_rs1_data  : std_logic_vector(31 downto 0);
  signal s_IDEX_rs2_data  : std_logic_vector(31 downto 0);
  signal s_IDEX_rs1       : std_logic_vector(4 downto 0);
  signal s_IDEX_rs2       : std_logic_vector(4 downto 0);
  signal s_IDEX_rd        : std_logic_vector(4 downto 0);
  signal s_IDEX_imm       : std_logic_vector(31 downto 0);
  signal s_IDEX_pc        : std_logic_vector(31 downto 0);

  -- ID/EX controls
  signal s_IDEX_ALUOp     : std_logic_vector(3 downto 0);
  signal s_IDEX_ALUSrc    : std_logic;
  signal s_IDEX_signed    : std_logic;
  signal s_IDEX_Branch    : std_logic;
  signal s_IDEX_func3     : std_logic_vector(2 downto 0);
  signal s_IDEX_func7     : std_logic_vector(6 downto 0);
  signal s_IDEX_opcode    : std_logic_vector(6 downto 0);
  signal s_IDEX_Jump      : std_logic;
  signal s_IDEX_auipc     : std_logic;
  signal s_IDEX_upperIMM  : std_logic;
  signal s_IDEX_MemWr     : std_logic;
  signal s_IDEX_MemReg    : std_logic;
  signal s_IDEX_RegWr     : std_logic;
  signal s_IDEX_Halt      : std_logic;

  -- EX/MEM outputs
  signal s_EXMEM_ALU_result : std_logic_vector(31 downto 0);
  signal s_EXMEM_rs2_data   : std_logic_vector(31 downto 0);
  signal s_EXMEM_rd         : std_logic_vector(4 downto 0);
  signal s_EXMEM_func3      : std_logic_vector(2 downto 0);
  signal s_EXMEM_func7      : std_logic_vector(6 downto 0);
  signal s_EXMEM_opcode     : std_logic_vector(6 downto 0);

  -- EX/MEM controls
  signal s_EXMEM_Branch     : std_logic;
  signal s_EXMEM_MemWr      : std_logic;
  signal s_EXMEM_MemReg     : std_logic;
  signal s_EXMEM_RegWr      : std_logic;
  signal s_EXMEM_Halt       : std_logic;

  -- MEM/WB outputs
  signal s_MEMWB_MEM_data   : std_logic_vector(31 downto 0);
  signal s_MEMWB_ALU_result : std_logic_vector(31 downto 0);
  signal s_MEMWB_rd         : std_logic_vector(4 downto 0);
  signal s_MEMWB_func3      : std_logic_vector(2 downto 0);
  signal s_MEMWB_func7      : std_logic_vector(6 downto 0);
  signal s_MEMWB_opcode     : std_logic_vector(6 downto 0);

  -- MEM/WB controls
  signal s_MEMWB_MemReg     : std_logic;
  signal s_MEMWB_RegWr      : std_logic;
  signal s_MEMWB_Halt       : std_logic;

begin

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
      iInstAddr when others;

  IMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);
  
  DMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100)
  s_IDEX_Halt <= '1' when (s_opcode = "1110011" and s_func3 = "000") else '0';

  -- Disable PC updates when halted
  process(s_Halt)
  begin
    if (s_Halt = '1') then
      s_PC_WE <= '0';
    else
      s_PC_WE <= '1';
    end if;
  end process;

  -- TODO: Ensure that s_Ovfl is connected to the overflow output of your ALU
  -- NOT NEEDED FOR RISC-V Was This for MIPS???
  s_Ovfl <= '0';

  -- TODO: Implement the rest of your processor below this comment! 
  PC_LOGIC: pcLogic
    port map(
      i_CLK     => iCLK,
      i_RST     => iRST,
      i_PC_WE   => s_PC_WE,
      i_rs1     => s_IDEX_rs1_data,
      i_imm     => s_IDEX_imm,
      i_current_PC => s_IDEX_pc,
      i_PC_STALL  => '0',
      i_PC_SEL  => s_PC_SEL,
      o_PC      => s_NextInstAddr
    );

  --IF/ID Pipeline Register
  IF_ID_REG: IF_ID
    port map(
      iCLK   => iCLK,
      iFlush => '0',
      iStall => '0',
      iRST   => iRST,
      i_pc   => s_NextInstAddr,   -- PC going into IF/ID
      i_inst => s_Inst,           -- Instruction from IMEM

      o_pc   => s_IFID_PC,        -- Outputs to decode stage
      o_inst => s_IFID_Inst
    );
  
  -- Instruction Decode
  DECODER: Decode
    port map(
      i_instr    => s_IFID_Inst,
      o_opcode   => s_opcode,
      o_rd       => s_RegWrAddrIn,
      o_func3    => s_func3,
      o_rs1      => s_rs1,
      o_rs2      => s_rs2,
      o_func7    => s_func7,
      o_imm12bit => s_imm12bit,
      o_imm20bit => s_imm20bit,
      o_immType  => s_DecImmType
    );
    
   

  -- Control Unit
  CTRL: Control
    port map(
      i_opcode   => s_opcode,
      i_func3    => s_func3,
      i_func7    => s_func7,
      o_ALUControl => s_ALUOp,
      o_ImmType  => s_ImmType,
      o_ALUSRC   => s_ALUSrc,
      o_MemReg   => s_MemReg,
      o_RegWr    => s_RegWrIn,
      o_MemWr    => s_DMemWrIn,
      o_signed    => s_signed,
      o_Branch   => s_Branch,
      o_branchJump => s_BranchJump,
      o_Jump	  => s_Jump,
      o_upperIMM => s_upperIMM,
      o_auipc	 => s_auipc
    );

  -- Register File
  RF: regFile
    port map(
      i_CLK       => iCLK,
      i_RST       => iRST,
      i_WE        => s_RegWr,
      i_rs1_addr  => s_rs1,
      i_rs2_addr  => s_rs2,
      i_rd_addr   => s_RegWrAddr,
      i_rd_data   => s_RegWrData,
      o_rs1_data  => s_rs1_data,
      o_rs2_data  => s_rs2_data
    );

  IMM_EXT: extender
    port map(
      i_imm12bit => s_imm12bit,
      i_imm20bit => s_imm20bit,
      i_immType  => s_DecImmType,
      i_branchJump	 => s_BranchJump,
      i_sign     => s_signed, 
      i_upperIMM => s_upperIMM,
      o_out      => s_imm
    );
  
  --ID/EX Pipeline Register
  ID_EX_REG: ID_EX
    port map(
      iCLK => iCLK,
      iFlush => '0',
      iStall => '0',
      iRST => iRST,

      -- Datapath in
      i_rs1_data => s_rs1_data,
      i_rs2_data => s_rs2_data,
      i_rs1      => s_rs1,
      i_rs2      => s_rs2,
      i_rd       => s_RegWrAddrIn,
      i_imm      => s_imm,
      i_pc       => s_IFID_PC,

      -- Control in
      i_ALUOp    => s_ALUOp,
      i_ALUSrc   => s_ALUSrc,
      i_signed   => s_signed,
      i_Branch   => s_Branch,
      i_func3    => s_func3,
      i_func7    => s_func7,
      i_opcode   => s_opcode,
      i_Jump     => s_Jump,
      i_auipc    => s_auipc,
      i_upperIMM => s_upperIMM,
      i_MemWr    => s_DMemWrIn,
      i_MemReg   => s_MemReg,
      i_RegWr    => s_RegWrIn,
      i_Halt     => s_IDEX_Halt,

      -- Outputs
      o_rs1_data => s_IDEX_rs1_data,
      o_rs2_data => s_IDEX_rs2_data,
      o_rs1      => s_IDEX_rs1,
      o_rs2      => s_IDEX_rs2,
      o_rd       => s_IDEX_rd,
      o_imm      => s_IDEX_imm,
      o_pc       => s_IDEX_pc,

      o_ALUOp    => s_IDEX_ALUOp,
      o_ALUSrc   => s_IDEX_ALUSrc,
      o_signed   => s_IDEX_signed,
      o_Branch   => s_IDEX_Branch,
      o_func3    => s_IDEX_func3,
      o_func7    => s_IDEX_func7,
      o_opcode   => s_IDEX_opcode,
      o_Jump     => s_IDEX_Jump,
      o_auipc    => s_IDEX_auipc,
      o_upperIMM => s_IDEX_upperIMM,
      o_MemWr    => s_IDEX_MemWr,
      o_MemReg   => s_IDEX_MemReg,
      o_RegWr    => s_IDEX_RegWr,
      o_Halt     => s_EXMEM_Halt
    );


s_PC_BA <= x"00400000";
s_four <= x"00000004";
s_Op1 <= std_logic_vector(unsigned(s_IDEX_pc) + unsigned(s_PC_BA)) when s_IDEX_auipc = '1' else
    	 std_logic_vector(unsigned(s_IDEX_pc) + unsigned(s_PC_BA) + unsigned(s_four)) when s_IDEX_Jump = '1' else
    	 s_IDEX_rs1_data;
  -- ALU
  ALU_UNIT: alu
    generic map(N => N)
    port map(
      i_A      => s_Op1,
      i_B      => s_IDEX_rs2_data,
      i_imm    => s_IDEX_imm,
      i_sign   => s_IDEX_signed,
      i_ALUOp  => s_IDEX_ALUOp,
      i_ALUSrc => s_IDEX_ALUSrc,
      o_F      => s_ALUResult,
      o_Zero   => s_Zero
    );

  -----------------------------------------------------------
  -- Program Counter (PC) control logic
  -- Determines how the next PC is selected:
  --   00 : PC + 4        (Default)
  --   01 : PC + imm      (Branch target)
  --   10 : PC + imm      (JAL)
  --   11 : rs1 + imm     (JALR)
  -----------------------------------------------------------
  process(s_IDEX_opcode, s_IDEX_Branch, s_Zero, s_IDEX_func3)
    begin
    -- Default: increment PC normally
    s_PC_SEL <= "00";

    ---------------------------------------------------------
    -- Conditional branches
    -- Branch instructions have opcode = 1100011
    -- funct3 determines the type of branch:
    --   000 : BEQ   (Branch if Equal)
    --   001 : BNE   (Branch if Not Equal)
    --   100 : BLT   (Branch if Less Than, signed)
    --   101 : BGE   (Branch if Greater or Equal, signed)
    --   110 : BLTU  (Branch if Less Than, unsigned)
    --   111 : BGEU  (Branch if Greater or Equal, unsigned)
    ---------------------------------------------------------
    if (s_IDEX_Branch = '1') then
      case s_IDEX_func3 is
        when "000" =>  -- BEQ
          if (s_Zero = '1') then
            s_PC_SEL <= "01";  -- Take branch if rs1 == rs2
          end if;

        when "001" =>  -- BNE
          if (s_Zero = '0') then
            s_PC_SEL <= "01";  -- Take branch if rs1 != rs2
          end if;

        when "100" =>  -- BLT (signed)
          if (s_Zero = '0') then
            s_PC_SEL <= "01";  -- Take branch if rs1 < rs2
          end if;

        when "101" =>  -- BGE (signed)
          if (s_Zero = '1') then
            s_PC_SEL <= "01";  -- Take branch if rs1 >= rs2
          end if;

        when "110" =>  -- BLTU (unsigned)
          if (s_Zero = '0') then
            s_PC_SEL <= "01";  -- Take branch if rs1 < rs2 (unsigned)
          end if;

        when "111" =>  -- BGEU (unsigned)
          if (s_Zero = '1') then
            s_PC_SEL <= "01";  -- Take branch if rs1 >= rs2 (unsigned)
          end if;

        when others =>
          -- Default: increment PC normally
          s_PC_SEL <= "00";
      end case;
    end if;

    ---------------------------------------------------------
    -- Unconditional jumps
    ---------------------------------------------------------

    -- JAL (Jump and Link) -> opcode = 1101111
    if (s_IDEX_opcode = "1101111") then
      s_PC_SEL <= "10";  -- Jump to PC + immediate
    end if;

    -- JALR (Jump and Link Register) -> opcode = 1100111
    if (s_IDEX_opcode = "1100111") then
      s_PC_SEL <= "11";  -- Jump to (rs1 + immediate)
    end if;

  end process;

  --EX/MEM Pipeline Register
  EX_MEM_REG: EX_MEM
    port map(
      iCLK => iCLK,
      iFlush => '0',
      iStall => '0',
      iRST => iRST,

      i_ALU_result => s_ALUResult,
      i_rs2_data   => s_IDEX_rs2_data,
      i_rd         => s_IDEX_rd,
      i_func3      => s_IDEX_func3,
      i_func7      => s_IDEX_func7,
      i_opcode     => s_IDEX_opcode,

      i_Branch     => s_IDEX_Branch,
      i_MemWr      => s_IDEX_MemWr,
      i_MemReg     => s_IDEX_MemReg,
      i_RegWr      => s_IDEX_RegWr,
      i_Halt       => s_EXMEM_Halt,

      o_ALU_result => s_EXMEM_ALU_result,
      o_rs2_data   => s_EXMEM_rs2_data,
      o_rd         => s_EXMEM_rd,
      o_func3      => s_EXMEM_func3,
      o_func7      => s_EXMEM_func7,
      o_opcode     => s_EXMEM_opcode,

      o_Branch     => s_EXMEM_Branch,
      o_MemWr      => s_EXMEM_MemWr,
      o_MemReg     => s_EXMEM_MemReg,
      o_RegWr      => s_EXMEM_RegWr,
      o_Halt       => s_MEMWB_Halt
    );


  process(s_DMemOut, s_EXMEM_ALU_result, s_EXMEM_func3)
  begin
    case s_EXMEM_func3 is
      when "000" =>  -- LB
        s_LoadData <= std_logic_vector(resize(signed(s_DMemOut(7 downto 0)), 32));
      when "001" =>  -- LH
        s_LoadData <= std_logic_vector(resize(signed(s_DMemOut(15 downto 0)), 32));
      when "100" =>  -- LBU
        s_LoadData <= (others => '0');
        s_LoadData(7 downto 0) <= s_DMemOut(7 downto 0);
      when "101" =>  -- LHU
        s_LoadData <= (others => '0');
        s_LoadData(15 downto 0) <= s_DMemOut(15 downto 0);
      when others =>  -- LW
        s_LoadData <= s_DMemOut;
    end case;
  end process;

  --MEM/WB Pipeline Register
  MEM_WB_REG: MEM_WB
    port map(
      iCLK => iCLK,
      iFlush => '0',
      iStall => '0',
      iRST => iRST,

      i_MEM_data   => s_LoadData,
      i_ALU_result => s_EXMEM_ALU_result,
      i_rd         => s_EXMEM_rd,
      i_func3      => s_EXMEM_func3,
      i_func7      => s_EXMEM_func7,
      i_opcode     => s_EXMEM_opcode,

      i_MemReg     => s_EXMEM_MemReg,
      i_RegWr      => s_EXMEM_RegWr,
      i_Halt       => s_MEMWB_Halt,

      o_MEM_data   => s_MEMWB_MEM_data,
      o_ALU_result => s_MEMWB_ALU_result,
      o_rd         => s_MEMWB_rd,
      o_MemReg     => s_MEMWB_MemReg,
      o_RegWr      => s_MEMWB_RegWr,
      o_Halt       => s_Halt,
      o_func3      => s_MEMWB_func3,
      o_func7      => s_MEMWB_func7,
      o_opcode     => s_MEMWB_opcode
    );


  -- Write Back MUX
  s_RegWrData <= s_MEMWB_ALU_result when s_MEMWB_MemReg = '0'
               else s_MEMWB_MEM_data;

  s_RegWr     <= s_MEMWB_RegWr;
  s_RegWrAddr <= s_MEMWB_rd;


  -- Data Memory Address & Data Inputs
  s_DMemAddr <= s_EXMEM_ALU_result;
  s_DMemData <= s_EXMEM_rs2_data;
  s_DMemWr   <= s_EXMEM_MemWr;


  -- Connect ALU output to top-level port
  oALUOut <= s_ALUResult;

end structure;

