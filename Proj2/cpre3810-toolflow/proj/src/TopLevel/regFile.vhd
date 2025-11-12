-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- regFile.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of register file 
-- that has 32 32-bit registers.
--
--
-- NOTES:
-- 09/21/25 by CWM::Created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity regFile is
  port(i_CLK      : in std_logic;                         -- Clock
       i_RST      : in std_logic;                         -- Reset
       i_WE       : in std_logic;                         -- Write Enable
       i_rs1_addr : in std_logic_vector(4 downto 0);      -- Address of first register we want to read
	   i_rs2_addr : in std_logic_vector(4 downto 0);      -- Address of second register we want to read
	   i_rd_addr  : in std_logic_vector(4 downto 0);      -- Address of register we want to write to
	   i_rd_data  : in std_logic_vector(31 downto 0);	  -- The data we want to write
	   o_rs1_data : out std_logic_vector(31 downto 0);    -- The data held in the first register we read
       o_rs2_data : out std_logic_vector(31 downto 0));   -- The data held in the second register we read

end regFile;

architecture structural of regFile is

  component reg_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32. 
	port(i_CLK : in std_logic;                         -- Clock
         i_RST : in std_logic;                         -- Reset
         i_WE  : in std_logic;                         -- Write Enable
         i_D   : in std_logic_vector(N-1 downto 0);    -- Input data
         o_Q   : out std_logic_vector(N-1 downto 0));  -- Output data
  end component;
  
  component decoder5t32 is
    port (i_In    : in std_logic_vector(4 downto 0);    -- 5-bit input
          o_Out   : out std_logic_vector(31 downto 0)); -- 32 outputs
  end component;
  
  component mux32t1_N is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
	port (i_S   : in std_logic_vector(4 downto 0);         -- 5-bit select input'
          i_D0  : in std_logic_vector(N-1 downto 0);       -- Input 0
		  i_D1  : in std_logic_vector(N-1 downto 0);       -- Input 1
		  i_D2  : in std_logic_vector(N-1 downto 0);       -- Input 2
		  i_D3  : in std_logic_vector(N-1 downto 0);       -- Input 3
		  i_D4  : in std_logic_vector(N-1 downto 0);       -- Input 4
		  i_D5  : in std_logic_vector(N-1 downto 0);       -- Input 5
		  i_D6  : in std_logic_vector(N-1 downto 0);       -- Input 6
		  i_D7  : in std_logic_vector(N-1 downto 0);       -- Input 7
		  i_D8  : in std_logic_vector(N-1 downto 0);       -- Input 8
		  i_D9  : in std_logic_vector(N-1 downto 0);       -- Input 9
		  i_D10 : in std_logic_vector(N-1 downto 0);       -- Input 10
		  i_D11 : in std_logic_vector(N-1 downto 0);       -- Input 11
		  i_D12 : in std_logic_vector(N-1 downto 0);       -- Input 12
		  i_D13 : in std_logic_vector(N-1 downto 0);       -- Input 13
		  i_D14 : in std_logic_vector(N-1 downto 0);       -- Input 14
		  i_D15 : in std_logic_vector(N-1 downto 0);       -- Input 15
		  i_D16 : in std_logic_vector(N-1 downto 0);       -- Input 16
		  i_D17 : in std_logic_vector(N-1 downto 0);       -- Input 17
		  i_D18 : in std_logic_vector(N-1 downto 0);       -- Input 18
		  i_D19 : in std_logic_vector(N-1 downto 0);       -- Input 19
		  i_D20 : in std_logic_vector(N-1 downto 0);       -- Input 20
		  i_D21 : in std_logic_vector(N-1 downto 0);       -- Input 21
		  i_D22 : in std_logic_vector(N-1 downto 0);       -- Input 22
		  i_D23 : in std_logic_vector(N-1 downto 0);       -- Input 23
		  i_D24 : in std_logic_vector(N-1 downto 0);       -- Input 24
		  i_D25 : in std_logic_vector(N-1 downto 0);       -- Input 25
		  i_D26 : in std_logic_vector(N-1 downto 0);       -- Input 26
		  i_D27 : in std_logic_vector(N-1 downto 0);       -- Input 27
		  i_D28 : in std_logic_vector(N-1 downto 0);       -- Input 28
		  i_D29 : in std_logic_vector(N-1 downto 0);       -- Input 29
		  i_D30 : in std_logic_vector(N-1 downto 0);       -- Input 30
		  i_D31 : in std_logic_vector(N-1 downto 0);       -- Input 31
		  o_O   : out std_logic_vector(N-1 downto 0));     -- Selected output
	end component;

    --TODO: Create signals to attach all of the components
	signal s_RD_decoded : std_logic_vector(31 downto 0); -- Decoded Resgister Address of the Register we want to write to.
	signal s_reg_out0   : std_logic_vector(31 downto 0); -- Register 0 output
    signal s_reg_out1   : std_logic_vector(31 downto 0); -- Register 1 output
	signal s_reg_out2   : std_logic_vector(31 downto 0); -- Register 2 output
    signal s_reg_out3   : std_logic_vector(31 downto 0); -- Register 3 output
	signal s_reg_out4   : std_logic_vector(31 downto 0); -- Register 4 output
    signal s_reg_out5   : std_logic_vector(31 downto 0); -- Register 5 output
	signal s_reg_out6   : std_logic_vector(31 downto 0); -- Register 6 output
    signal s_reg_out7   : std_logic_vector(31 downto 0); -- Register 7 output
	signal s_reg_out8   : std_logic_vector(31 downto 0); -- Register 8 output
    signal s_reg_out9   : std_logic_vector(31 downto 0); -- Register 9 output
	signal s_reg_out10  : std_logic_vector(31 downto 0); -- Register 10 output
    signal s_reg_out11  : std_logic_vector(31 downto 0); -- Register 11 output
	signal s_reg_out12  : std_logic_vector(31 downto 0); -- Register 12 output
    signal s_reg_out13  : std_logic_vector(31 downto 0); -- Register 13 output
	signal s_reg_out14  : std_logic_vector(31 downto 0); -- Register 14 output
    signal s_reg_out15  : std_logic_vector(31 downto 0); -- Register 15 output
	signal s_reg_out16  : std_logic_vector(31 downto 0); -- Register 16 output
    signal s_reg_out17  : std_logic_vector(31 downto 0); -- Register 17 output
	signal s_reg_out18  : std_logic_vector(31 downto 0); -- Register 18 output
    signal s_reg_out19  : std_logic_vector(31 downto 0); -- Register 19 output
	signal s_reg_out20  : std_logic_vector(31 downto 0); -- Register 20 output
    signal s_reg_out21  : std_logic_vector(31 downto 0); -- Register 21 output
	signal s_reg_out22  : std_logic_vector(31 downto 0); -- Register 22 output
    signal s_reg_out23  : std_logic_vector(31 downto 0); -- Register 23 output
	signal s_reg_out24  : std_logic_vector(31 downto 0); -- Register 24 output
    signal s_reg_out25  : std_logic_vector(31 downto 0); -- Register 25 output
	signal s_reg_out26  : std_logic_vector(31 downto 0); -- Register 26 output
    signal s_reg_out27  : std_logic_vector(31 downto 0); -- Register 27 output
	signal s_reg_out28  : std_logic_vector(31 downto 0); -- Register 28 output
    signal s_reg_out29  : std_logic_vector(31 downto 0); -- Register 29 output
	signal s_reg_out30  : std_logic_vector(31 downto 0); -- Register 30 output
    signal s_reg_out31  : std_logic_vector(31 downto 0); -- Register 31 output
	signal s_we0  : std_logic;                           -- Write enable value of register 0
	signal s_we1  : std_logic;                           -- Write enable value of register 1
	signal s_we2  : std_logic;                           -- Write enable value of register 2
	signal s_we3  : std_logic;                           -- Write enable value of register 3
	signal s_we4  : std_logic;                           -- Write enable value of register 4
	signal s_we5  : std_logic;                           -- Write enable value of register 5
	signal s_we6  : std_logic;                           -- Write enable value of register 6
	signal s_we7  : std_logic;                           -- Write enable value of register 7
	signal s_we8  : std_logic;                           -- Write enable value of register 8
	signal s_we9  : std_logic;                           -- Write enable value of register 9
	signal s_we10 : std_logic;                           -- Write enable value of register 10
	signal s_we11 : std_logic;                           -- Write enable value of register 11
	signal s_we12 : std_logic;                           -- Write enable value of register 12
	signal s_we13 : std_logic;                           -- Write enable value of register 13
	signal s_we14 : std_logic;                           -- Write enable value of register 14
	signal s_we15 : std_logic;                           -- Write enable value of register 15
	signal s_we16 : std_logic;                           -- Write enable value of register 16
	signal s_we17 : std_logic;                           -- Write enable value of register 17
	signal s_we18 : std_logic;                           -- Write enable value of register 18
	signal s_we19 : std_logic;                           -- Write enable value of register 19
	signal s_we20 : std_logic;                           -- Write enable value of register 20
	signal s_we21 : std_logic;                           -- Write enable value of register 21
	signal s_we22 : std_logic;                           -- Write enable value of register 22
	signal s_we23 : std_logic;                           -- Write enable value of register 23
	signal s_we24 : std_logic;                           -- Write enable value of register 24
	signal s_we25 : std_logic;                           -- Write enable value of register 25
	signal s_we26 : std_logic;                           -- Write enable value of register 26
	signal s_we27 : std_logic;                           -- Write enable value of register 27
	signal s_we28 : std_logic;                           -- Write enable value of register 28
	signal s_we29 : std_logic;                           -- Write enable value of register 29
	signal s_we30 : std_logic;                           -- Write enable value of register 30
	signal s_we31 : std_logic;                           -- Write enable value of register 31


begin

  decoder_inst: decoder5t32
    port map(i_In  => i_rd_addr,
             o_Out => s_RD_decoded);
			 
  s_reg_out0 <= (others => '0');
  
  s_we0  <= '0'; -- Register 0 is hardwired to zero
  s_we1  <= i_WE and s_RD_decoded(1);
  s_we2  <= i_WE and s_RD_decoded(2);
  s_we3  <= i_WE and s_RD_decoded(3);
  s_we4  <= i_WE and s_RD_decoded(4);
  s_we5  <= i_WE and s_RD_decoded(5);
  s_we6  <= i_WE and s_RD_decoded(6);
  s_we7  <= i_WE and s_RD_decoded(7);
  s_we8  <= i_WE and s_RD_decoded(8);
  s_we9  <= i_WE and s_RD_decoded(9);
  s_we10 <= i_WE and s_RD_decoded(10);
  s_we11 <= i_WE and s_RD_decoded(11);
  s_we12 <= i_WE and s_RD_decoded(12);
  s_we13 <= i_WE and s_RD_decoded(13);
  s_we14 <= i_WE and s_RD_decoded(14);
  s_we15 <= i_WE and s_RD_decoded(15);
  s_we16 <= i_WE and s_RD_decoded(16);
  s_we17 <= i_WE and s_RD_decoded(17);
  s_we18 <= i_WE and s_RD_decoded(18);
  s_we19 <= i_WE and s_RD_decoded(19);
  s_we20 <= i_WE and s_RD_decoded(20);
  s_we21 <= i_WE and s_RD_decoded(21);
  s_we22 <= i_WE and s_RD_decoded(22);
  s_we23 <= i_WE and s_RD_decoded(23);
  s_we24 <= i_WE and s_RD_decoded(24);
  s_we25 <= i_WE and s_RD_decoded(25);
  s_we26 <= i_WE and s_RD_decoded(26);
  s_we27 <= i_WE and s_RD_decoded(27);
  s_we28 <= i_WE and s_RD_decoded(28);
  s_we29 <= i_WE and s_RD_decoded(29);
  s_we30 <= i_WE and s_RD_decoded(30);
  s_we31 <= i_WE and s_RD_decoded(31);


  reg1 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we1,
      i_D   => i_rd_data,
      o_Q   => s_reg_out1
    );

  reg2 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we2,
      i_D   => i_rd_data,
      o_Q   => s_reg_out2
    );

  reg3 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we3,
      i_D   => i_rd_data,
      o_Q   => s_reg_out3
    );

  reg4 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we4,
      i_D   => i_rd_data,
      o_Q   => s_reg_out4
    );

  reg5 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we5,
      i_D   => i_rd_data,
      o_Q   => s_reg_out5
    );

  reg6 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we6,
      i_D   => i_rd_data,
      o_Q   => s_reg_out6
    );

  reg7 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we7,
      i_D   => i_rd_data,
      o_Q   => s_reg_out7
    );

  reg8 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we8,
      i_D   => i_rd_data,
      o_Q   => s_reg_out8
    );

  reg9 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we9,
      i_D   => i_rd_data,
      o_Q   => s_reg_out9
    );

  reg10 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we10,
      i_D   => i_rd_data,
      o_Q   => s_reg_out10
    );

  reg11 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we11,
      i_D   => i_rd_data,
      o_Q   => s_reg_out11
    );

  reg12 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we12,
      i_D   => i_rd_data,
      o_Q   => s_reg_out12
    );

  reg13 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we13,
      i_D   => i_rd_data,
      o_Q   => s_reg_out13
    );

  reg14 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we14,
      i_D   => i_rd_data,
      o_Q   => s_reg_out14
    );

  reg15 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we15,
      i_D   => i_rd_data,
      o_Q   => s_reg_out15
    );

  reg16 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we16,
      i_D   => i_rd_data,
      o_Q   => s_reg_out16
    );

  reg17 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we17,
      i_D   => i_rd_data,
      o_Q   => s_reg_out17
    );

  reg18 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we18,
      i_D   => i_rd_data,
      o_Q   => s_reg_out18
    );

  reg19 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we19,
      i_D   => i_rd_data,
      o_Q   => s_reg_out19
    );

  reg20 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we20,
      i_D   => i_rd_data,
      o_Q   => s_reg_out20
    );

  reg21 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we21,
      i_D   => i_rd_data,
      o_Q   => s_reg_out21
    );

  reg22 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we22,
      i_D   => i_rd_data,
      o_Q   => s_reg_out22
    );

  reg23 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we23,
      i_D   => i_rd_data,
      o_Q   => s_reg_out23
    );

  reg24 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we24,
      i_D   => i_rd_data,
      o_Q   => s_reg_out24
    );

  reg25 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we25,
      i_D   => i_rd_data,
      o_Q   => s_reg_out25
    );

  reg26 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we26,
      i_D   => i_rd_data,
      o_Q   => s_reg_out26
    );

  reg27 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we27,
      i_D   => i_rd_data,
      o_Q   => s_reg_out27
    );

  reg28 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we28,
      i_D   => i_rd_data,
      o_Q   => s_reg_out28
    );

  reg29 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we29,
      i_D   => i_rd_data,
      o_Q   => s_reg_out29
    );

  reg30 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we30,
      i_D   => i_rd_data,
      o_Q   => s_reg_out30
    );

  reg31 : reg_N
    generic map(N => 32)
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_we31,
      i_D   => i_rd_data,
      o_Q   => s_reg_out31
    );

  mux_rs1: mux32t1_N
    generic map(N => 32)
    port map(i_S   => i_rs1_addr,
             i_D0  => s_reg_out0,
			 i_D1  => s_reg_out1,
			 i_D2  => s_reg_out2,
			 i_D3  => s_reg_out3,
			 i_D4  => s_reg_out4,
			 i_D5  => s_reg_out5,
			 i_D6  => s_reg_out6,
			 i_D7  => s_reg_out7,
			 i_D8  => s_reg_out8,
			 i_D9  => s_reg_out9,
			 i_D10 => s_reg_out10,
			 i_D11 => s_reg_out11,
			 i_D12 => s_reg_out12,
			 i_D13 => s_reg_out13,
			 i_D14 => s_reg_out14,
			 i_D15 => s_reg_out15,
			 i_D16 => s_reg_out16,
			 i_D17 => s_reg_out17,
			 i_D18 => s_reg_out18,
			 i_D19 => s_reg_out19,
			 i_D20 => s_reg_out20,
			 i_D21 => s_reg_out21,
			 i_D22 => s_reg_out22,
			 i_D23 => s_reg_out23,
			 i_D24 => s_reg_out24,
			 i_D25 => s_reg_out25,
			 i_D26 => s_reg_out26,
			 i_D27 => s_reg_out27,
			 i_D28 => s_reg_out28,
			 i_D29 => s_reg_out29,
			 i_D30 => s_reg_out30,
			 i_D31 => s_reg_out31,
			 o_O   => o_rs1_data);

  mux_rs2: mux32t1_N
    generic map(N => 32)
    port map(i_S   => i_rs2_addr,
             i_D0  => s_reg_out0,
			 i_D1  => s_reg_out1,
			 i_D2  => s_reg_out2,
			 i_D3  => s_reg_out3,
			 i_D4  => s_reg_out4,
			 i_D5  => s_reg_out5,
			 i_D6  => s_reg_out6,
			 i_D7  => s_reg_out7,
			 i_D8  => s_reg_out8,
			 i_D9  => s_reg_out9,
			 i_D10 => s_reg_out10,
			 i_D11 => s_reg_out11,
			 i_D12 => s_reg_out12,
			 i_D13 => s_reg_out13,
			 i_D14 => s_reg_out14,
			 i_D15 => s_reg_out15,
			 i_D16 => s_reg_out16,
			 i_D17 => s_reg_out17,
			 i_D18 => s_reg_out18,
			 i_D19 => s_reg_out19,
			 i_D20 => s_reg_out20,
			 i_D21 => s_reg_out21,
			 i_D22 => s_reg_out22,
			 i_D23 => s_reg_out23,
			 i_D24 => s_reg_out24,
			 i_D25 => s_reg_out25,
			 i_D26 => s_reg_out26,
			 i_D27 => s_reg_out27,
			 i_D28 => s_reg_out28,
			 i_D29 => s_reg_out29,
			 i_D30 => s_reg_out30,
			 i_D31 => s_reg_out31,
			 o_O   => o_rs2_data);
			 
end structural;
