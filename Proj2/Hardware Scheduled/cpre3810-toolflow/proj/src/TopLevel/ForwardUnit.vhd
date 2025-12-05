library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ForwardUnit is
  port(
    -- Current instruction source registers (ID/EX stage)
    i_IDEX_rs1       : in std_logic_vector(4 downto 0);
    i_IDEX_rs2       : in std_logic_vector(4 downto 0);

    -- One stage ahead (EX/MEM)
    i_EXMEM_rd       : in std_logic_vector(4 downto 0);
    i_EXMEM_RegWrite : in std_logic;

    -- Two stages ahead (MEM/WB)
    i_MEMWB_rd       : in std_logic_vector(4 downto 0);
    i_MEMWB_RegWrite : in std_logic;

    -- Forwarding control outputs
    o_ForwardA       : out std_logic_vector(1 downto 0);  -- Forwarding rs1 signal:
                                                            -- 00: No Forwarding
                                                            -- 01: Forward from MEM/WB
                                                            -- 10: Forward from EX/MEM
                                                            -- 11: XX
    o_ForwardB       : out std_logic_vector(1 downto 0)); -- Forwarding rs2 signal
                                                            -- 00: No Forwarding
                                                            -- 01: Forward from MEM/WB
                                                            -- 10: Forward from EX/MEM
                                                            -- 11: XX
end ForwardUnit;

architecture Dataflow of ForwardUnit is

  -- Hazard detection signals
  signal exmem_hazard_rs1 : std_logic;
  signal exmem_hazard_rs2 : std_logic;
  signal memwb_hazard_rs1 : std_logic;
  signal memwb_hazard_rs2 : std_logic;

begin

  ----------------------------------------------------
  -- Hazard Conditions (TRUE/FALSE)
  ----------------------------------------------------

  exmem_hazard_rs1 <= '1' when 
        (i_EXMEM_RegWrite = '1' and
         i_EXMEM_rd /= "00000" and
         i_EXMEM_rd = i_IDEX_rs1)
      else '0';

  exmem_hazard_rs2 <= '1' when 
        (i_EXMEM_RegWrite = '1' and
         i_EXMEM_rd /= "00000" and
         i_EXMEM_rd = i_IDEX_rs2)
      else '0';

  memwb_hazard_rs1 <= '1' when 
        (i_MEMWB_RegWrite = '1' and
         i_MEMWB_rd /= "00000" and
         i_MEMWB_rd = i_IDEX_rs1)
      else '0';

  memwb_hazard_rs2 <= '1' when 
        (i_MEMWB_RegWrite = '1' and
         i_MEMWB_rd /= "00000" and
         i_MEMWB_rd = i_IDEX_rs2)
      else '0';


  ----------------------------------------------------
  -- ForwardA (2 bits)
  -- Priority:
  --   1. EX/MEM hazard → "10"
  --   2. MEM/WB hazard → "01"
  --   3. Otherwise     → "00"
  ----------------------------------------------------
  o_ForwardA <= 
        "10" when exmem_hazard_rs1 = '1' else
        "01" when memwb_hazard_rs1 = '1' else
        "00";


  ----------------------------------------------------
  -- ForwardB (2 bits)
   -- Priority:
  --   1. EX/MEM hazard → "10"
  --   2. MEM/WB hazard → "01"
  --   3. Otherwise     → "00"
  ----------------------------------------------------
  o_ForwardB <= 
        "10" when exmem_hazard_rs2 = '1' else
        "01" when memwb_hazard_rs2 = '1' else
        "00";

end Dataflow;