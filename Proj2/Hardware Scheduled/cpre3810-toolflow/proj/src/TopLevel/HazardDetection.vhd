library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity HazardDetection is

   port(
       i_rs1	      : in std_logic_vector(4 downto 0); -- Source register 1 (What we are reading from)
       i_rs2	      : in std_logic_vector(4 downto 0); -- Source register 2 (What we are reading from)
       i_PC_SEL       : in std_logic_vector(1 downto 0); -- PC Next Value Selection: 
                                                            -- 00: PC + 4         (Default)  - Do nothing
                                                            -- 01: PC + imm       (Branch)   - Flush
                                                            -- 10: PC + imm       (JAL)      - Flush
                                                            -- 11: rs1 + imm      (JALR)     - Flush
       i_IDEX_rd      : in std_logic_vector(4 downto 0); -- Destination register in IDEX stage (What we are writing to)
       i_IDEX_RegWrite  : in std_logic;                  -- RegWrite signal in IDEX stage
       i_EXMEM_rd     : in std_logic_vector(4 downto 0); -- Destination register in EXMEM stage (What we are writing to)
       i_EXMEM_RegWrite : in std_logic;                  -- RegWrite signal in EXMEM stage
       i_MEMWB_rd     : in std_logic_vector(4 downto 0); -- Destination register in MEMWB stage (What we are writing to)
       i_MEMWB_RegWrite : in std_logic;                  -- RegWrite signal in MEMWB stage

       o_IFID_stall : out std_logic;                     -- Stall signal for IFID register
       o_IFID_flush : out std_logic;                     -- Flush signal for IFID register
       o_IDEX_stall : out std_logic;                     -- Stall signal for IDEX register
       o_IDEX_flush : out std_logic;                     -- Flush signal for IDEX register
       o_EXMEM_stall : out std_logic;                    -- Stall signal for EXMEM register
       o_EXMEM_flush : out std_logic;                    -- Flush signal for EXMEM register
       o_MEMWB_stall : out std_logic;                    -- Stall signal for MEMWB register
       o_MEMWB_flush : out std_logic;                    -- Flush signal for MEMWB register
       o_PC_stall   : out std_logic);                    -- Stall signal for PC

   end HazardDetection;
architecture dataflow of HazardDetection is

    signal load_use_hazard : std_logic;
    signal flush_ctl       : std_logic;

begin

    ----------------------------------------------------------------------
    -- Load-use hazard: only remaining data hazard with forwarding
    ----------------------------------------------------------------------
    load_use_hazard <= '1' when
        i_IDEX_MemRead = '1' and
        i_IDEX_rd /= "00000" and
        (i_IDEX_rd = i_rs1 or i_IDEX_rd = i_rs2)
    else '0';

    ----------------------------------------------------------------------
    -- Control hazard (branch/JAL/JALR)
    ----------------------------------------------------------------------
    flush_ctl <= '1' when (i_PC_SEL = "01" or i_PC_SEL = "10" or i_PC_SEL = "11")
                 else '0';

    ----------------------------------------------------------------------
    -- Stall / Flush Outputs
    ----------------------------------------------------------------------
    o_PC_stall   <= load_use_hazard;
    o_IFID_stall <= load_use_hazard;

    o_IFID_flush <= flush_ctl;

    o_IDEX_stall <= '0';
    o_IDEX_flush <= flush_ctl or load_use_hazard;

    o_EXMEM_stall <= '0';
    o_EXMEM_flush <= '0';
    o_MEMWB_stall <= '0';
    o_MEMWB_flush <= '0';

end dataflow;