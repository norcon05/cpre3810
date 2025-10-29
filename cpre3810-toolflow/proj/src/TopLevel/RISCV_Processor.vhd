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
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
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
       o_MemRd	 	: out std_logic;
       o_MemWr		: out std_logic;
       o_signed		: out std_logic; -- 1 when signed, 0 when unsigned
       o_Branch		: out std_logic;
       o_upperIMM	: out std_logic;
       o_auipc		: out std_logic);
    end component;

  component extender is
    port (i_imm12bit  : in  STD_LOGIC_VECTOR(11 downto 0);   -- 12-bit input
          i_imm20bit  : in  STD_LOGIC_VECTOR(19 downto 0);   -- 20-bit input
          i_immType   : in  STD_LOGIC;    -- Immediate Types:
                                            -- 0: 12-bit immediate used
                                            -- 1: 20-bit immediate used
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

  -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment

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
  signal s_MemRd     : std_logic;
  signal s_MemWr     : std_logic;
  signal s_signed    : std_logic;
  signal s_Branch    : std_logic;
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
  s_Halt <= '1' when (s_opcode = "1110011" and s_func3 = "000") else '0';

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
      i_rs1     => s_rs1_data,
      i_imm     => s_imm,
      i_PC_SEL  => s_PC_SEL,
      o_PC      => s_NextInstAddr
    );
  
  -- Instruction Decode
  DECODER: Decode
    port map(
      i_instr    => s_Inst,
      o_opcode   => s_opcode,
      o_rd       => s_RegWrAddr,
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
      o_RegWr    => s_RegWr,
      o_MemRd    => s_MemRd,
      o_MemWr    => s_DMemWr,
      o_signed    => s_signed,
      o_Branch   => s_Branch,
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
      i_sign     => s_signed, 
      i_upperIMM => s_upperIMM,
      o_out      => s_imm
    );

process(s_auipc)
  begin
    if (s_auipc = '1') then
      s_Op1 <= s_iMemAddr;
    else
      s_Op1 <= s_rs1_data;
    end if;
  end process;


  -- ALU
  ALU_UNIT: alu
    generic map(N => N)
    port map(
      i_A      => s_Op1,
      i_B      => s_rs2_data,
      i_imm    => s_imm,
      i_ALUOp  => s_ALUOp,
      i_ALUSrc => s_ALUSrc,
      o_F      => s_ALUResult,
      o_Zero   => s_Zero
    );

  -----------------------------------------------------------
  -- Program Counter (PC) control logic
  -- Determines how the next PC is selected:
    --   00 : PC + 4        (Default)
    --   01 : PC + imm      (Branch)
    --   10 : PC + imm      (JAL)
    --   11 : rs1 + imm     (JALR)
  ------------------------------------------------------------
  process(s_opcode, s_Branch, s_Zero)
    begin
    -- Default behavior: increment PC
    s_PC_SEL <= "00";

    -- Conditional branches (BEQ, BNE, etc.)
    if (s_Branch = '1' and s_Zero = '1') then
      s_PC_SEL <= "01"; -- PC + immediate (branch target)
    end if;

    -- JAL (opcode = 1101111)
    if (s_opcode = "1101111") then
      s_PC_SEL <= "10"; -- Jump and link
    end if;

    -- JALR (opcode = 1100111)
    if (s_opcode = "1100111") then
      s_PC_SEL <= "11"; -- Jump and link register
    end if;
  end process;


  -- Write Back MUX
  s_RegWrData <=
      s_ALUResult when s_MemReg = '0' else
      s_DMemOut;

  -- Data Memory Address & Data Inputs
  s_DMemAddr <= s_ALUResult;
  s_DMemData <= s_rs2_data;

  -- Connect ALU output to top-level port
  oALUOut <= s_ALUResult;

end structure;

