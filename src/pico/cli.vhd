--
-------------------------------------------------------------------------------------------
-- Copyright © 2010-2013, Xilinx, Inc.
-- This file contains confidential and proprietary information of Xilinx, Inc. and is
-- protected under U.S. and international copyright and other intellectual property laws.
-------------------------------------------------------------------------------------------
--
-- Disclaimer:
-- This disclaimer is not a license and does not grant any rights to the materials
-- distributed herewith. Except as otherwise provided in a valid license issued to
-- you by Xilinx, and to the maximum extent permitted by applicable law: (1) THESE
-- MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY
-- DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY,
-- INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT,
-- OR FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable
-- (whether in contract or tort, including negligence, or under any other theory
-- of liability) for any loss or damage of any kind or nature related to, arising
-- under or in connection with these materials, including for any direct, or any
-- indirect, special, incidental, or consequential loss or damage (including loss
-- of data, profits, goodwill, or any type of loss or damage suffered as a result
-- of any action brought by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-safe, or for use in any
-- application requiring fail-safe performance, such as life-support or safety
-- devices or systems, Class III medical devices, nuclear facilities, applications
-- related to the deployment of airbags, or any other applications that could lead
-- to death, personal injury, or severe property or environmental damage
-- (individually and collectively, "Critical Applications"). Customer assumes the
-- sole risk and liability of any use of Xilinx products in Critical Applications,
-- subject only to applicable laws and regulations governing limitations on product
-- liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
--
-------------------------------------------------------------------------------------------
--
--
-- Definition of a program memory for KCPSM6 including generic parameters for the 
-- convenient selection of device family, program memory size and the ability to include 
-- the JTAG Loader hardware for rapid software development.
--
-- This file is primarily for use during code development and it is recommended that the 
-- appropriate simplified program memory definition be used in a final production design. 
--
--    Generic                  Values             Comments
--    Parameter                Supported
--  
--    C_FAMILY                 "S6"               Spartan-6 device
--                             "V6"               Virtex-6 device
--                             "7S"               7-Series device 
--                                                  (Artix-7, Kintex-7, Virtex-7 or Zynq)
--
--    C_RAM_SIZE_KWORDS        1, 2 or 4          Size of program memory in K-instructions
--
--    C_JTAG_LOADER_ENABLE     0 or 1             Set to '1' to include JTAG Loader
--
-- Notes
--
-- If your design contains MULTIPLE KCPSM6 instances then only one should have the 
-- JTAG Loader enabled at a time (i.e. make sure that C_JTAG_LOADER_ENABLE is only set to 
-- '1' on one instance of the program memory). Advanced users may be interested to know 
-- that it is possible to connect JTAG Loader to multiple memories and then to use the 
-- JTAG Loader utility to specify which memory contents are to be modified. However, 
-- this scheme does require some effort to set up and the additional connectivity of the 
-- multiple BRAMs can impact the placement, routing and performance of the complete 
-- design. Please contact the author at Xilinx for more detailed information. 
--
-- Regardless of the size of program memory specified by C_RAM_SIZE_KWORDS, the complete 
-- 12-bit address bus is connected to KCPSM6. This enables the generic to be modified 
-- without requiring changes to the fundamental hardware definition. However, when the 
-- program memory is 1K then only the lower 10-bits of the address are actually used and 
-- the valid address range is 000 to 3FF hex. Likewise, for a 2K program only the lower 
-- 11-bits of the address are actually used and the valid address range is 000 to 7FF hex.
--
-- Programs are stored in Block Memory (BRAM) and the number of BRAM used depends on the 
-- size of the program and the device family. 
--
-- In a Spartan-6 device a BRAM is capable of holding 1K instructions. Hence a 2K program 
-- will require 2 BRAMs to be used and a 4K program will require 4 BRAMs to be used. It 
-- should be noted that a 4K program is not such a natural fit in a Spartan-6 device and 
-- the implementation also requires a small amount of logic resulting in slightly lower 
-- performance. A Spartan-6 BRAM can also be split into two 9k-bit memories suggesting 
-- that a program containing up to 512 instructions could be implemented. However, there 
-- is a silicon errata which makes this unsuitable and therefore it is not supported by 
-- this file.
--
-- In a Virtex-6 or any 7-Series device a BRAM is capable of holding 2K instructions so 
-- obviously a 2K program requires only a single BRAM. Each BRAM can also be divided into 
-- 2 smaller memories supporting programs of 1K in half of a 36k-bit BRAM (generally 
-- reported as being an 18k-bit BRAM). For a program of 4K instructions, 2 BRAMs are used.
--
--
-- Program defined by 'Z:\home\dean\public_html\Xilinx\nexys3_mezz_test\src\pico\cli.psm'.
--
-- Generated by KCPSM6 Assembler: 04 Jun 2014 - 10:56:08. 
--
-- Assembler used ROM_form template: ROM_form_JTAGLoader_14March13.vhd
--
-- Standard IEEE libraries
--
--
package jtag_loader_pkg is
 function addr_width_calc (size_in_k: integer) return integer;
end jtag_loader_pkg;
--
package body jtag_loader_pkg is
  function addr_width_calc (size_in_k: integer) return integer is
   begin
    if (size_in_k = 1) then return 10;
      elsif (size_in_k = 2) then return 11;
      elsif (size_in_k = 4) then return 12;
      else report "Invalid BlockRAM size. Please set to 1, 2 or 4 K words." severity FAILURE;
    end if;
    return 0;
  end function addr_width_calc;
end package body;
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.jtag_loader_pkg.ALL;
--
-- The Unisim Library is used to define Xilinx primitives. It is also used during
-- simulation. The source can be viewed at %XILINX%\vhdl\src\unisims\unisim_VCOMP.vhd
--  
library unisim;
use unisim.vcomponents.all;
--
--
entity cli is
  generic(             C_FAMILY : string := "S6"; 
              C_RAM_SIZE_KWORDS : integer := 1;
           C_JTAG_LOADER_ENABLE : integer := 0);
  Port (      address : in std_logic_vector(11 downto 0);
          instruction : out std_logic_vector(17 downto 0);
               enable : in std_logic;
                  rdl : out std_logic;                    
                  clk : in std_logic);
  end cli;
--
architecture low_level_definition of cli is
--
signal       address_a : std_logic_vector(15 downto 0);
signal        pipe_a11 : std_logic;
signal       data_in_a : std_logic_vector(35 downto 0);
signal      data_out_a : std_logic_vector(35 downto 0);
signal    data_out_a_l : std_logic_vector(35 downto 0);
signal    data_out_a_h : std_logic_vector(35 downto 0);
signal   data_out_a_ll : std_logic_vector(35 downto 0);
signal   data_out_a_lh : std_logic_vector(35 downto 0);
signal   data_out_a_hl : std_logic_vector(35 downto 0);
signal   data_out_a_hh : std_logic_vector(35 downto 0);
signal       address_b : std_logic_vector(15 downto 0);
signal       data_in_b : std_logic_vector(35 downto 0);
signal     data_in_b_l : std_logic_vector(35 downto 0);
signal    data_in_b_ll : std_logic_vector(35 downto 0);
signal    data_in_b_hl : std_logic_vector(35 downto 0);
signal      data_out_b : std_logic_vector(35 downto 0);
signal    data_out_b_l : std_logic_vector(35 downto 0);
signal   data_out_b_ll : std_logic_vector(35 downto 0);
signal   data_out_b_hl : std_logic_vector(35 downto 0);
signal     data_in_b_h : std_logic_vector(35 downto 0);
signal    data_in_b_lh : std_logic_vector(35 downto 0);
signal    data_in_b_hh : std_logic_vector(35 downto 0);
signal    data_out_b_h : std_logic_vector(35 downto 0);
signal   data_out_b_lh : std_logic_vector(35 downto 0);
signal   data_out_b_hh : std_logic_vector(35 downto 0);
signal        enable_b : std_logic;
signal           clk_b : std_logic;
signal            we_b : std_logic_vector(7 downto 0);
signal          we_b_l : std_logic_vector(3 downto 0);
signal          we_b_h : std_logic_vector(3 downto 0);
-- 
signal       jtag_addr : std_logic_vector(11 downto 0);
signal         jtag_we : std_logic;
signal       jtag_we_l : std_logic;
signal       jtag_we_h : std_logic;
signal        jtag_clk : std_logic;
signal        jtag_din : std_logic_vector(17 downto 0);
signal       jtag_dout : std_logic_vector(17 downto 0);
signal     jtag_dout_1 : std_logic_vector(17 downto 0);
signal         jtag_en : std_logic_vector(0 downto 0);
-- 
signal picoblaze_reset : std_logic_vector(0 downto 0);
signal         rdl_bus : std_logic_vector(0 downto 0);
--
constant BRAM_ADDRESS_WIDTH  : integer := addr_width_calc(C_RAM_SIZE_KWORDS);
--
--
component jtag_loader_6
generic(                C_JTAG_LOADER_ENABLE : integer := 1;
                                    C_FAMILY : string  := "V6";
                             C_NUM_PICOBLAZE : integer := 1;
                       C_BRAM_MAX_ADDR_WIDTH : integer := 10;
          C_PICOBLAZE_INSTRUCTION_DATA_WIDTH : integer := 18;
                                C_JTAG_CHAIN : integer := 2;
                              C_ADDR_WIDTH_0 : integer := 10;
                              C_ADDR_WIDTH_1 : integer := 10;
                              C_ADDR_WIDTH_2 : integer := 10;
                              C_ADDR_WIDTH_3 : integer := 10;
                              C_ADDR_WIDTH_4 : integer := 10;
                              C_ADDR_WIDTH_5 : integer := 10;
                              C_ADDR_WIDTH_6 : integer := 10;
                              C_ADDR_WIDTH_7 : integer := 10);
port(              picoblaze_reset : out std_logic_vector(C_NUM_PICOBLAZE-1 downto 0);
                           jtag_en : out std_logic_vector(C_NUM_PICOBLAZE-1 downto 0);
                          jtag_din : out STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                         jtag_addr : out STD_LOGIC_VECTOR(C_BRAM_MAX_ADDR_WIDTH-1 downto 0);
                          jtag_clk : out std_logic;
                           jtag_we : out std_logic;
                       jtag_dout_0 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_1 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_2 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_3 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_4 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_5 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_6 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_7 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0));
end component;
--
begin
  --
  --  
  ram_1k_generate : if (C_RAM_SIZE_KWORDS = 1) generate
 
    s6: if (C_FAMILY = "S6") generate 
      --
      address_a(13 downto 0) <= address(9 downto 0) & "0000";
      instruction <= data_out_a(33 downto 32) & data_out_a(15 downto 0);
      data_in_a <= "0000000000000000000000000000000000" & address(11 downto 10);
      jtag_dout <= data_out_b(33 downto 32) & data_out_b(15 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b <= "00" & data_out_b(33 downto 32) & "0000000000000000" & data_out_b(15 downto 0);
        address_b(13 downto 0) <= "00000000000000";
        we_b(3 downto 0) <= "0000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b <= "00" & jtag_din(17 downto 16) & "0000000000000000" & jtag_din(15 downto 0);
        address_b(13 downto 0) <= jtag_addr(9 downto 0) & "0000";
        we_b(3 downto 0) <= jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom: RAMB16BWER
      generic map ( DATA_WIDTH_A => 18,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 18,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"90005000D008900020089000D008900020041000D00490002637014D006F00C5",
                    INIT_01 => X"003100205000D00290005000D01090005000D00490005000D02090005000D001",
                    INIT_02 => X"400E100050000030400E10010300E02E0031001043064306430643060300E02E",
                    INIT_03 => X"1000A042D010100AA03F902AA042D010100AA03F9011A042D00AA03F90305000",
                    INIT_04 => X"1137310F01009207204DE04DD2411237420E420E420E420E020050005000400E",
                    INIT_05 => X"0004110AD1010004110D5000D1010004D20100040043500091072054E054D141",
                    INIT_06 => X"1F01500020663B001A01D1010004206ED1004BA05000D101113E00045000D101",
                    INIT_07 => X"500000A700B5009E00B400A45000009A00B500A400B4009E00A75000DF045F02",
                    INIT_08 => X"00A45000608B9D0100AA1D08208190004D0E009000A7208600A46085CED01D80",
                    INIT_09 => X"DF045F01500000B4DF043FFE5000DE0100AA209000A75000009A00B5009E00B4",
                    INIT_0A => X"DC029C0200B7009E00B400A75000DF045F025000DF043FFD500020A0DC019C02",
                    INIT_0B => X"114C1143500060BB9C011C01500000BA00BA00BA00BA00BA5000009A00B74E00",
                    INIT_0C => X"0004D20100040043100100661ABE1B00B001B03100D41100113A115611201149",
                    INIT_0D => X"D0051000E0E2D404B42C210BD300B3235000F023F020100050000062005BD101",
                    INIT_0E => X"4E061E280073006F20E89401450620ECD40015109404B42CD005100120E6B42C",
                    INIT_0F => X"03E0008A009700804E071E280073006F022F022F007A009700800E5000970080",
                    INIT_10 => X"00D8F62C1600F62316015000005B0055004000550030007A009504E0008A008F",
                    INIT_11 => X"1174112011641165116C11691161116611201143113211495000610ED6081601",
                    INIT_12 => X"00661A141B01005B006F110011211164116E116F11701173116511721120116F",
                    INIT_13 => X"007A01411E21160101411E23160101411E27162CD00510025000D009B02C205B",
                    INIT_14 => X"1E27D0051002500000970080AE60009700801E09009700804E060073006F5000",
                    INIT_15 => X"1E00009700801E00009700804E060073006F5000007A01571E2101571E230157",
                    INIT_16 => X"4206410042064100420641004206A1001001A2001030D0051002500000970080",
                    INIT_17 => X"0E20009700800E10009700804E60B62C1E30009700804E061E730073006F4100",
                    INIT_18 => X"21863B001A01D10100042194D1FF2190D1004BA01AC31B045000007A00970080",
                    INIT_19 => X"0080BE34009700804E06BE300073006FD005B02C5000005B21863B001A03005B",
                    INIT_1A => X"04E0008A008F03E0008A009700804E07BE300073006FD005B02C5000007A0097",
                    INIT_1B => X"B1285000005B005590065000D006B02C5000005B0055004000550030007A0095",
                    INIT_1C => X"ED101101EC101101EB101141AE009001AD009001AC009001AB001003102CF140",
                    INIT_1D => X"102CAE001001AD001001AC001001AB001041625AC050B528B0405000EE101101",
                    INIT_1E => X"0210020712001100022102210221021BA9009001A8009001A7009001A6001003",
                    INIT_1F => X"112070010221021B021002070221021B021002070221021B021002070221021B",
                    INIT_20 => X"5000022744204410320402A0310101F014005000005B61EE95017000D1010004",
                    INIT_21 => X"4F004E084D084C084B0E50007000D0011030221810316217D001900600047001",
                    INIT_22 => X"900110195000022E340DD4065402022ED40650004A00490848084708460E5000",
                    INIT_23 => X"1164116E116111201153114D11541120113A1152114F1152115211455000622F",
                    INIT_24 => X"1120116F116411201173116811741167116E1165116C1120114F114411541120",
                    INIT_25 => X"B42C5000005B00661A321B0211001168116311741161116D11201174116F116E",
                    INIT_26 => X"4406A440140142004306420043064200430642004306A3401200143002841545",
                    INIT_27 => X"0043A05015010055A05002841545B42C5000E3501501E2504240440644064406",
                    INIT_28 => X"1504190618261E001D03500022849401150115011000D4005000005BD2010004",
                    INIT_29 => X"4708460E4708460E4708460E4708460EA7401401A640696068601600144502BD",
                    INIT_2A => X"4708460F4708460FA7401401A6406292D4611401700002BD150370016E706D60",
                    INIT_2B => X"02210221021B500002BD150617FF18F819000E700D601CFF4708460F4708460F",
                    INIT_2C => X"95010221021B02070221021B02070221021B02070221021B0207120011000221",
                    INIT_2D => X"0980031403140314031419001800164502BD1504190618261E001D03500062C3",
                    INIT_2E => X"62D9D6631601005BE9601601E860031403140314031403140314031403141800",
                    INIT_2F => X"0314031403140314190018001C0602BD1504190618261E401D0122921445005B",
                    INIT_30 => X"00550090D2010004004300800314031403140314031403140314031418000980",
                    INIT_31 => X"500002BD150219FF18FF1E0050004808450E950602271400231A62FA9C01005B",
                    INIT_32 => X"18261E201D015000005B0055A07007501763B52C5000E67007501763B630B52C",
                    INIT_33 => X"70016DD06EE0ADF09F01AEF09F010227A4F01F0A1F631200130202BD15041906",
                    INIT_34 => X"9F014EA04A064A064A06AAF09F01AEF09F01700002BD15041600170018001900",
                    INIT_35 => X"4A08490EA9F09F014DA04A064A06AAF09F010D904EA04A0049064A004906A9F0",
                    INIT_36 => X"6DD06EE04BA04A06AAF09F010B904CA049004A06AAF09F010C904DA04A08490E",
                    INIT_37 => X"9301700002BD150270012384D2016EE0AEF09F01700002BD150770016BB06CC0",
                    INIT_38 => X"022702BD1504190618261E201D01500002BD150418FF1980233512016335D300",
                    INIT_39 => X"E890990103A780C0100803BB03AC18001609E89003A710070314190A19631800",
                    INIT_3A => X"10009C01031403BB23A79001480E1000D00050002335130212006398D6FF9601",
                    INIT_3B => X"4BA03B000A601AB11B031C081C081C031C031C041C041C031C081C031C0823AD",
                    INIT_3C => X"0043A030D00110200004D001103A0004D1010004D20100040043003013005000",
                    INIT_3D => X"04215000005B23C2005B63CED00330031301003023DDD3FFD1010004D2010004",
                    INIT_3E => X"5000D00310005000D00310FF50000421060B05BC0210B12BB227A3E9D004B023",
                    INIT_3F => X"116F115711001120113A117211651166116611751142500000C55000D00AB02C",
                   INITP_00 => X"AAAAAAA8296B6A2A8A2AAA7D41F5552935DD7776484785538820820820B0B0AA",
                   INITP_01 => X"2A4AAA8A4A9744888D34A8AAAA20AAAAAB4AAAA90AAA28B08A88AAAAAD8B6AB0",
                   INITP_02 => X"28A029295554422A28A6AA2222A28A6AA18608A282AAAAAAAAAAAAB5A22A228A",
                   INITP_03 => X"3AAAAAAAA0AA111104443429998111122A28A88A28A92A2A8A4A8A9696B760AA",
                   INITP_04 => X"8620A615455554082A0AAAAAAAAAAAAAAAAAAAAB4A22A556556E234BA0002B7A",
                   INITP_05 => X"AA020022D69AAAA82A80800B6AAAAA82AA80005555135E355555114200295DAA",
                   INITP_06 => X"78F51E35511051055114415445447800D446102002A10A40A00948B68A8AAAA0",
                   INITP_07 => X"AAAAAAA8A28AA434AAB44DAA88A2AA82942AAAAADA97683599282890A002808D")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a(31 downto 0),
                  DOPA => data_out_a(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b(31 downto 0),
                  DOPB => data_out_b(35 downto 32), 
                   DIB => data_in_b(31 downto 0),
                  DIPB => data_in_b(35 downto 32), 
                   WEB => we_b(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
    --               
    end generate s6;
    --
    --
    v6 : if (C_FAMILY = "V6") generate
      --
      address_a(13 downto 0) <= address(9 downto 0) & "1111";
      instruction <= data_out_a(17 downto 0);
      data_in_a(17 downto 0) <= "0000000000000000" & address(11 downto 10);
      jtag_dout <= data_out_b(17 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b(17 downto 0) <= data_out_b(17 downto 0);
        address_b(13 downto 0) <= "11111111111111";
        we_b(3 downto 0) <= "0000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b(17 downto 0) <= jtag_din(17 downto 0);
        address_b(13 downto 0) <= jtag_addr(9 downto 0) & "1111";
        we_b(3 downto 0) <= jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      -- 
      kcpsm6_rom: RAMB18E1
      generic map ( READ_WIDTH_A => 18,
                    WRITE_WIDTH_A => 18,
                    DOA_REG => 0,
                    INIT_A => "000000000000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 18,
                    WRITE_WIDTH_B => 18,
                    DOB_REG => 0,
                    INIT_B => X"000000000000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    SIM_DEVICE => "VIRTEX6",
                    INIT_00 => X"90005000D008900020089000D008900020041000D00490002637014D006F00C5",
                    INIT_01 => X"003100205000D00290005000D01090005000D00490005000D02090005000D001",
                    INIT_02 => X"400E100050000030400E10010300E02E0031001043064306430643060300E02E",
                    INIT_03 => X"1000A042D010100AA03F902AA042D010100AA03F9011A042D00AA03F90305000",
                    INIT_04 => X"1137310F01009207204DE04DD2411237420E420E420E420E020050005000400E",
                    INIT_05 => X"0004110AD1010004110D5000D1010004D20100040043500091072054E054D141",
                    INIT_06 => X"1F01500020663B001A01D1010004206ED1004BA05000D101113E00045000D101",
                    INIT_07 => X"500000A700B5009E00B400A45000009A00B500A400B4009E00A75000DF045F02",
                    INIT_08 => X"00A45000608B9D0100AA1D08208190004D0E009000A7208600A46085CED01D80",
                    INIT_09 => X"DF045F01500000B4DF043FFE5000DE0100AA209000A75000009A00B5009E00B4",
                    INIT_0A => X"DC029C0200B7009E00B400A75000DF045F025000DF043FFD500020A0DC019C02",
                    INIT_0B => X"114C1143500060BB9C011C01500000BA00BA00BA00BA00BA5000009A00B74E00",
                    INIT_0C => X"0004D20100040043100100661ABE1B00B001B03100D41100113A115611201149",
                    INIT_0D => X"D0051000E0E2D404B42C210BD300B3235000F023F020100050000062005BD101",
                    INIT_0E => X"4E061E280073006F20E89401450620ECD40015109404B42CD005100120E6B42C",
                    INIT_0F => X"03E0008A009700804E071E280073006F022F022F007A009700800E5000970080",
                    INIT_10 => X"00D8F62C1600F62316015000005B0055004000550030007A009504E0008A008F",
                    INIT_11 => X"1174112011641165116C11691161116611201143113211495000610ED6081601",
                    INIT_12 => X"00661A141B01005B006F110011211164116E116F11701173116511721120116F",
                    INIT_13 => X"007A01411E21160101411E23160101411E27162CD00510025000D009B02C205B",
                    INIT_14 => X"1E27D0051002500000970080AE60009700801E09009700804E060073006F5000",
                    INIT_15 => X"1E00009700801E00009700804E060073006F5000007A01571E2101571E230157",
                    INIT_16 => X"4206410042064100420641004206A1001001A2001030D0051002500000970080",
                    INIT_17 => X"0E20009700800E10009700804E60B62C1E30009700804E061E730073006F4100",
                    INIT_18 => X"21863B001A01D10100042194D1FF2190D1004BA01AC31B045000007A00970080",
                    INIT_19 => X"0080BE34009700804E06BE300073006FD005B02C5000005B21863B001A03005B",
                    INIT_1A => X"04E0008A008F03E0008A009700804E07BE300073006FD005B02C5000007A0097",
                    INIT_1B => X"B1285000005B005590065000D006B02C5000005B0055004000550030007A0095",
                    INIT_1C => X"ED101101EC101101EB101141AE009001AD009001AC009001AB001003102CF140",
                    INIT_1D => X"102CAE001001AD001001AC001001AB001041625AC050B528B0405000EE101101",
                    INIT_1E => X"0210020712001100022102210221021BA9009001A8009001A7009001A6001003",
                    INIT_1F => X"112070010221021B021002070221021B021002070221021B021002070221021B",
                    INIT_20 => X"5000022744204410320402A0310101F014005000005B61EE95017000D1010004",
                    INIT_21 => X"4F004E084D084C084B0E50007000D0011030221810316217D001900600047001",
                    INIT_22 => X"900110195000022E340DD4065402022ED40650004A00490848084708460E5000",
                    INIT_23 => X"1164116E116111201153114D11541120113A1152114F1152115211455000622F",
                    INIT_24 => X"1120116F116411201173116811741167116E1165116C1120114F114411541120",
                    INIT_25 => X"B42C5000005B00661A321B0211001168116311741161116D11201174116F116E",
                    INIT_26 => X"4406A440140142004306420043064200430642004306A3401200143002841545",
                    INIT_27 => X"0043A05015010055A05002841545B42C5000E3501501E2504240440644064406",
                    INIT_28 => X"1504190618261E001D03500022849401150115011000D4005000005BD2010004",
                    INIT_29 => X"4708460E4708460E4708460E4708460EA7401401A640696068601600144502BD",
                    INIT_2A => X"4708460F4708460FA7401401A6406292D4611401700002BD150370016E706D60",
                    INIT_2B => X"02210221021B500002BD150617FF18F819000E700D601CFF4708460F4708460F",
                    INIT_2C => X"95010221021B02070221021B02070221021B02070221021B0207120011000221",
                    INIT_2D => X"0980031403140314031419001800164502BD1504190618261E001D03500062C3",
                    INIT_2E => X"62D9D6631601005BE9601601E860031403140314031403140314031403141800",
                    INIT_2F => X"0314031403140314190018001C0602BD1504190618261E401D0122921445005B",
                    INIT_30 => X"00550090D2010004004300800314031403140314031403140314031418000980",
                    INIT_31 => X"500002BD150219FF18FF1E0050004808450E950602271400231A62FA9C01005B",
                    INIT_32 => X"18261E201D015000005B0055A07007501763B52C5000E67007501763B630B52C",
                    INIT_33 => X"70016DD06EE0ADF09F01AEF09F010227A4F01F0A1F631200130202BD15041906",
                    INIT_34 => X"9F014EA04A064A064A06AAF09F01AEF09F01700002BD15041600170018001900",
                    INIT_35 => X"4A08490EA9F09F014DA04A064A06AAF09F010D904EA04A0049064A004906A9F0",
                    INIT_36 => X"6DD06EE04BA04A06AAF09F010B904CA049004A06AAF09F010C904DA04A08490E",
                    INIT_37 => X"9301700002BD150270012384D2016EE0AEF09F01700002BD150770016BB06CC0",
                    INIT_38 => X"022702BD1504190618261E201D01500002BD150418FF1980233512016335D300",
                    INIT_39 => X"E890990103A780C0100803BB03AC18001609E89003A710070314190A19631800",
                    INIT_3A => X"10009C01031403BB23A79001480E1000D00050002335130212006398D6FF9601",
                    INIT_3B => X"4BA03B000A601AB11B031C081C081C031C031C041C041C031C081C031C0823AD",
                    INIT_3C => X"0043A030D00110200004D001103A0004D1010004D20100040043003013005000",
                    INIT_3D => X"04215000005B23C2005B63CED00330031301003023DDD3FFD1010004D2010004",
                    INIT_3E => X"5000D00310005000D00310FF50000421060B05BC0210B12BB227A3E9D004B023",
                    INIT_3F => X"116F115711001120113A117211651166116611751142500000C55000D00AB02C",
                   INITP_00 => X"AAAAAAA8296B6A2A8A2AAA7D41F5552935DD7776484785538820820820B0B0AA",
                   INITP_01 => X"2A4AAA8A4A9744888D34A8AAAA20AAAAAB4AAAA90AAA28B08A88AAAAAD8B6AB0",
                   INITP_02 => X"28A029295554422A28A6AA2222A28A6AA18608A282AAAAAAAAAAAAB5A22A228A",
                   INITP_03 => X"3AAAAAAAA0AA111104443429998111122A28A88A28A92A2A8A4A8A9696B760AA",
                   INITP_04 => X"8620A615455554082A0AAAAAAAAAAAAAAAAAAAAB4A22A556556E234BA0002B7A",
                   INITP_05 => X"AA020022D69AAAA82A80800B6AAAAA82AA80005555135E355555114200295DAA",
                   INITP_06 => X"78F51E35511051055114415445447800D446102002A10A40A00948B68A8AAAA0",
                   INITP_07 => X"AAAAAAA8A28AA434AAB44DAA88A2AA82942AAAAADA97683599282890A002808D")
      port map(   ADDRARDADDR => address_a(13 downto 0),
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a(15 downto 0),
                      DOPADOP => data_out_a(17 downto 16), 
                        DIADI => data_in_a(15 downto 0),
                      DIPADIP => data_in_a(17 downto 16), 
                          WEA => "00",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b(13 downto 0),
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b(15 downto 0),
                      DOPBDOP => data_out_b(17 downto 16), 
                        DIBDI => data_in_b(15 downto 0),
                      DIPBDIP => data_in_b(17 downto 16), 
                        WEBWE => we_b(3 downto 0),
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0');
      --
    end generate v6;
    --
    --
    akv7 : if (C_FAMILY = "7S") generate
      --
      address_a(13 downto 0) <= address(9 downto 0) & "1111";
      instruction <= data_out_a(17 downto 0);
      data_in_a(17 downto 0) <= "0000000000000000" & address(11 downto 10);
      jtag_dout <= data_out_b(17 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b(17 downto 0) <= data_out_b(17 downto 0);
        address_b(13 downto 0) <= "11111111111111";
        we_b(3 downto 0) <= "0000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b(17 downto 0) <= jtag_din(17 downto 0);
        address_b(13 downto 0) <= jtag_addr(9 downto 0) & "1111";
        we_b(3 downto 0) <= jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      -- 
      kcpsm6_rom: RAMB18E1
      generic map ( READ_WIDTH_A => 18,
                    WRITE_WIDTH_A => 18,
                    DOA_REG => 0,
                    INIT_A => "000000000000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 18,
                    WRITE_WIDTH_B => 18,
                    DOB_REG => 0,
                    INIT_B => X"000000000000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    SIM_DEVICE => "7SERIES",
                    INIT_00 => X"90005000D008900020089000D008900020041000D00490002637014D006F00C5",
                    INIT_01 => X"003100205000D00290005000D01090005000D00490005000D02090005000D001",
                    INIT_02 => X"400E100050000030400E10010300E02E0031001043064306430643060300E02E",
                    INIT_03 => X"1000A042D010100AA03F902AA042D010100AA03F9011A042D00AA03F90305000",
                    INIT_04 => X"1137310F01009207204DE04DD2411237420E420E420E420E020050005000400E",
                    INIT_05 => X"0004110AD1010004110D5000D1010004D20100040043500091072054E054D141",
                    INIT_06 => X"1F01500020663B001A01D1010004206ED1004BA05000D101113E00045000D101",
                    INIT_07 => X"500000A700B5009E00B400A45000009A00B500A400B4009E00A75000DF045F02",
                    INIT_08 => X"00A45000608B9D0100AA1D08208190004D0E009000A7208600A46085CED01D80",
                    INIT_09 => X"DF045F01500000B4DF043FFE5000DE0100AA209000A75000009A00B5009E00B4",
                    INIT_0A => X"DC029C0200B7009E00B400A75000DF045F025000DF043FFD500020A0DC019C02",
                    INIT_0B => X"114C1143500060BB9C011C01500000BA00BA00BA00BA00BA5000009A00B74E00",
                    INIT_0C => X"0004D20100040043100100661ABE1B00B001B03100D41100113A115611201149",
                    INIT_0D => X"D0051000E0E2D404B42C210BD300B3235000F023F020100050000062005BD101",
                    INIT_0E => X"4E061E280073006F20E89401450620ECD40015109404B42CD005100120E6B42C",
                    INIT_0F => X"03E0008A009700804E071E280073006F022F022F007A009700800E5000970080",
                    INIT_10 => X"00D8F62C1600F62316015000005B0055004000550030007A009504E0008A008F",
                    INIT_11 => X"1174112011641165116C11691161116611201143113211495000610ED6081601",
                    INIT_12 => X"00661A141B01005B006F110011211164116E116F11701173116511721120116F",
                    INIT_13 => X"007A01411E21160101411E23160101411E27162CD00510025000D009B02C205B",
                    INIT_14 => X"1E27D0051002500000970080AE60009700801E09009700804E060073006F5000",
                    INIT_15 => X"1E00009700801E00009700804E060073006F5000007A01571E2101571E230157",
                    INIT_16 => X"4206410042064100420641004206A1001001A2001030D0051002500000970080",
                    INIT_17 => X"0E20009700800E10009700804E60B62C1E30009700804E061E730073006F4100",
                    INIT_18 => X"21863B001A01D10100042194D1FF2190D1004BA01AC31B045000007A00970080",
                    INIT_19 => X"0080BE34009700804E06BE300073006FD005B02C5000005B21863B001A03005B",
                    INIT_1A => X"04E0008A008F03E0008A009700804E07BE300073006FD005B02C5000007A0097",
                    INIT_1B => X"B1285000005B005590065000D006B02C5000005B0055004000550030007A0095",
                    INIT_1C => X"ED101101EC101101EB101141AE009001AD009001AC009001AB001003102CF140",
                    INIT_1D => X"102CAE001001AD001001AC001001AB001041625AC050B528B0405000EE101101",
                    INIT_1E => X"0210020712001100022102210221021BA9009001A8009001A7009001A6001003",
                    INIT_1F => X"112070010221021B021002070221021B021002070221021B021002070221021B",
                    INIT_20 => X"5000022744204410320402A0310101F014005000005B61EE95017000D1010004",
                    INIT_21 => X"4F004E084D084C084B0E50007000D0011030221810316217D001900600047001",
                    INIT_22 => X"900110195000022E340DD4065402022ED40650004A00490848084708460E5000",
                    INIT_23 => X"1164116E116111201153114D11541120113A1152114F1152115211455000622F",
                    INIT_24 => X"1120116F116411201173116811741167116E1165116C1120114F114411541120",
                    INIT_25 => X"B42C5000005B00661A321B0211001168116311741161116D11201174116F116E",
                    INIT_26 => X"4406A440140142004306420043064200430642004306A3401200143002841545",
                    INIT_27 => X"0043A05015010055A05002841545B42C5000E3501501E2504240440644064406",
                    INIT_28 => X"1504190618261E001D03500022849401150115011000D4005000005BD2010004",
                    INIT_29 => X"4708460E4708460E4708460E4708460EA7401401A640696068601600144502BD",
                    INIT_2A => X"4708460F4708460FA7401401A6406292D4611401700002BD150370016E706D60",
                    INIT_2B => X"02210221021B500002BD150617FF18F819000E700D601CFF4708460F4708460F",
                    INIT_2C => X"95010221021B02070221021B02070221021B02070221021B0207120011000221",
                    INIT_2D => X"0980031403140314031419001800164502BD1504190618261E001D03500062C3",
                    INIT_2E => X"62D9D6631601005BE9601601E860031403140314031403140314031403141800",
                    INIT_2F => X"0314031403140314190018001C0602BD1504190618261E401D0122921445005B",
                    INIT_30 => X"00550090D2010004004300800314031403140314031403140314031418000980",
                    INIT_31 => X"500002BD150219FF18FF1E0050004808450E950602271400231A62FA9C01005B",
                    INIT_32 => X"18261E201D015000005B0055A07007501763B52C5000E67007501763B630B52C",
                    INIT_33 => X"70016DD06EE0ADF09F01AEF09F010227A4F01F0A1F631200130202BD15041906",
                    INIT_34 => X"9F014EA04A064A064A06AAF09F01AEF09F01700002BD15041600170018001900",
                    INIT_35 => X"4A08490EA9F09F014DA04A064A06AAF09F010D904EA04A0049064A004906A9F0",
                    INIT_36 => X"6DD06EE04BA04A06AAF09F010B904CA049004A06AAF09F010C904DA04A08490E",
                    INIT_37 => X"9301700002BD150270012384D2016EE0AEF09F01700002BD150770016BB06CC0",
                    INIT_38 => X"022702BD1504190618261E201D01500002BD150418FF1980233512016335D300",
                    INIT_39 => X"E890990103A780C0100803BB03AC18001609E89003A710070314190A19631800",
                    INIT_3A => X"10009C01031403BB23A79001480E1000D00050002335130212006398D6FF9601",
                    INIT_3B => X"4BA03B000A601AB11B031C081C081C031C031C041C041C031C081C031C0823AD",
                    INIT_3C => X"0043A030D00110200004D001103A0004D1010004D20100040043003013005000",
                    INIT_3D => X"04215000005B23C2005B63CED00330031301003023DDD3FFD1010004D2010004",
                    INIT_3E => X"5000D00310005000D00310FF50000421060B05BC0210B12BB227A3E9D004B023",
                    INIT_3F => X"116F115711001120113A117211651166116611751142500000C55000D00AB02C",
                   INITP_00 => X"AAAAAAA8296B6A2A8A2AAA7D41F5552935DD7776484785538820820820B0B0AA",
                   INITP_01 => X"2A4AAA8A4A9744888D34A8AAAA20AAAAAB4AAAA90AAA28B08A88AAAAAD8B6AB0",
                   INITP_02 => X"28A029295554422A28A6AA2222A28A6AA18608A282AAAAAAAAAAAAB5A22A228A",
                   INITP_03 => X"3AAAAAAAA0AA111104443429998111122A28A88A28A92A2A8A4A8A9696B760AA",
                   INITP_04 => X"8620A615455554082A0AAAAAAAAAAAAAAAAAAAAB4A22A556556E234BA0002B7A",
                   INITP_05 => X"AA020022D69AAAA82A80800B6AAAAA82AA80005555135E355555114200295DAA",
                   INITP_06 => X"78F51E35511051055114415445447800D446102002A10A40A00948B68A8AAAA0",
                   INITP_07 => X"AAAAAAA8A28AA434AAB44DAA88A2AA82942AAAAADA97683599282890A002808D")
      port map(   ADDRARDADDR => address_a(13 downto 0),
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a(15 downto 0),
                      DOPADOP => data_out_a(17 downto 16), 
                        DIADI => data_in_a(15 downto 0),
                      DIPADIP => data_in_a(17 downto 16), 
                          WEA => "00",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b(13 downto 0),
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b(15 downto 0),
                      DOPBDOP => data_out_b(17 downto 16), 
                        DIBDI => data_in_b(15 downto 0),
                      DIPBDIP => data_in_b(17 downto 16), 
                        WEBWE => we_b(3 downto 0),
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0');
      --
    end generate akv7;
    --
  end generate ram_1k_generate;
  --
  --
  --
  ram_2k_generate : if (C_RAM_SIZE_KWORDS = 2) generate
    --
    --
    s6: if (C_FAMILY = "S6") generate
      --
      address_a(13 downto 0) <= address(10 downto 0) & "000";
      instruction <= data_out_a_h(32) & data_out_a_h(7 downto 0) & data_out_a_l(32) & data_out_a_l(7 downto 0);
      data_in_a <= "00000000000000000000000000000000000" & address(11);
      jtag_dout <= data_out_b_h(32) & data_out_b_h(7 downto 0) & data_out_b_l(32) & data_out_b_l(7 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b_l <= "000" & data_out_b_l(32) & "000000000000000000000000" & data_out_b_l(7 downto 0);
        data_in_b_h <= "000" & data_out_b_h(32) & "000000000000000000000000" & data_out_b_h(7 downto 0);
        address_b(13 downto 0) <= "00000000000000";
        we_b(3 downto 0) <= "0000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b_h <= "000" & jtag_din(17) & "000000000000000000000000" & jtag_din(16 downto 9);
        data_in_b_l <= "000" & jtag_din(8) & "000000000000000000000000" & jtag_din(7 downto 0);
        address_b(13 downto 0) <= jtag_addr(10 downto 0) & "000";
        we_b(3 downto 0) <= jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom_l: RAMB16BWER
      generic map ( DATA_WIDTH_A => 9,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 9,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"31200002000010000004000020000001000008000800080004000400374D6FC5",
                    INIT_01 => X"0042100A3F2A42100A3F11420A3F30000E0000300E01002E311006060606002E",
                    INIT_02 => X"040A01040D0001040104430007545441370F00074D4D41370E0E0E0E0000000E",
                    INIT_03 => X"00A7B59EB4A4009AB5A4B49EA7000402010066000101046E00A000013E040001",
                    INIT_04 => X"040100B404FE0001AA90A7009AB59EB4A4008B01AA0881000E90A786A485D080",
                    INIT_05 => X"4C4300BB010100BABABABABA009AB7000202B79EB4A70004020004FD00A00102",
                    INIT_06 => X"0500E2042C0B00230023200000625B01040104430166BE000131D4003A562049",
                    INIT_07 => X"E08A97800728736F2F2F7A97805097800628736FE80106EC0010042C0501E62C",
                    INIT_08 => X"742064656C69616620433249000E0801D82C002301005B554055307A95E08A8F",
                    INIT_09 => X"7A41210141230141272C050200092C5B6614015B6F0021646E6F70736572206F",
                    INIT_0A => X"00978000978006736F007A572157235727050200978060978009978006736F00",
                    INIT_0B => X"209780109780602C3097800673736F0006000600060006000100300502009780",
                    INIT_0C => X"803497800630736F052C005B8600035B860001010494FF9000A0C304007A9780",
                    INIT_0D => X"28005B550600062C005B554055307A95E08A8FE08A97800730736F052C007A97",
                    INIT_0E => X"2C00010001000100415A50284000100110011001104100010001000100032C40",
                    INIT_0F => X"2001211B1007211B1007211B1007211B100700002121211B0001000100010003",
                    INIT_10 => X"000808080E00000130183117010604010027201004A001F000005BEE01000104",
                    INIT_11 => X"646E6120534D54203A524F525245002F0119002E0D06022E0600000808080E00",
                    INIT_12 => X"2C005B66320200686374616D20746F6E206F6420736874676E656C204F445420",
                    INIT_13 => X"435001555084452C005001504006060606400100060006000600064000308445",
                    INIT_14 => X"080E080E080E080E40014060600045BD040626000300840101010000005B0104",
                    INIT_15 => X"21211B00BD06FFF8007060FF080F080F080F080F40014092610100BD03017060",
                    INIT_16 => X"8014141414000045BD040626000300C301211B07211B07211B07211B07000021",
                    INIT_17 => X"14141414000006BD040626400192455BD963015B600160141414141414141400",
                    INIT_18 => X"00BD02FFFF0000080E0627001AFA015B55900104438014141414141414140080",
                    INIT_19 => X"01D0E0F001F00127F00A630002BD0406262001005B557050632C00705063302C",
                    INIT_1A => X"080EF001A00606F00190A000060006F001A0060606F001F00100BD0400000000",
                    INIT_1B => X"0100BD02018401E0F00100BD0701B0C0D0E0A006F00190A00006F00190A0080E",
                    INIT_1C => X"9001A7C008BBAC000990A707140A630027BD040626200100BD04FF8035013500",
                    INIT_1D => X"A00060B10308080303040403080308AD000114BBA7010E00000035020098FF01",
                    INIT_1E => X"21005BC25BCE03030130DDFF010401044330012004013A040104010443300000",
                    INIT_1F => X"6F5700203A72656666754200C5000A2C0003000003FF00210BBC102B27E90423",
                    INIT_20 => X"2064726F5700202020203A73657A69732064726F5700203A746E756F63206472",
                    INIT_21 => X"66FE035B01290401040104432001280401200426010110042D20200066F50300",
                    INIT_22 => X"23660B045B490101040104431030240140040120045B40002301040104432304",
                    INIT_23 => X"04010401044330661B045B934000235B61010104010443103028012004704000",
                    INIT_24 => X"5B5505000800070007102C005B8901010401044360735003502C060601300120",
                    INIT_25 => X"040104430166AE0400203A6E6F6973726556A15B550755075507550700010500",
                    INIT_26 => X"F303007465736572C10300706D75646D656DDF030067726169746C756D005B01",
                    INIT_27 => X"006E6F5F7265776F70840100706C6568210400737973B804006E6F6973726576",
                    INIT_28 => X"01007769BB0100726AB80100776AD8000061ED030066666F5F7265776F70EA03",
                    INIT_29 => X"0075746A78020072746A5F020077746AD301006D6ABF0100646AA30100726996",
                    INIT_2A => X"0072749B04007A749D040066749504006374F3020073746AD2020067746A8B02",
                    INIT_2B => X"70310100707389030067616A2D030075616A26030072616A20030077616AA104",
                    INIT_2C => X"A0900001019F10209F0020B8FFAB00A000C304FF6301006434010070F0030063",
                    INIT_2D => X"102023000062F3D40062D410A0000110A000010BBC900000039F0001A700B8FF",
                    INIT_2E => X"1001242320D401DB3120DB2010D41020082010002323E605012301BE310120E6",
                    INIT_2F => X"00203A726F727245005B66E70500646E616D6D6F632064614200BE0001282300",
                    INIT_30 => X"064050104028004024360023000E200110002C0438005B01040104432066F805",
                    INIT_31 => X"20200120100020010800147031601450012301701E016001602F501402012C06",
                    INIT_32 => X"2073086C0A6C0D0001203762D45B6644065B0021776F6C667265764F378D564E",
                    INIT_33 => X"20010804012004010804820220000C012001205B000C000104000C0020012067",
                    INIT_34 => X"000000000000000000000000000000000000000000000000000C002001202001",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"800002400701011FC00001B0CC001481000394D96A09E0000000023E00000004",
                   INITP_01 => X"800010881111DC8980001000000CD7D00001550000150000490027FFFFF40000",
                   INITP_02 => X"F8C809FEFC64800206AAA809AA90C8C022600AB107FFFFFFFFFC0014A800031A",
                   INITP_03 => X"FFE0005414B80082C8013834662E325B944AA69578CB82955A6B21CD30C803FD",
                   INITP_04 => X"FFFFFFFFFFFFFFF901FFC0060001007C404C60C31306034021000853FFFFFFFF",
                   INITP_05 => X"FF0FFFB17D3FDA11420CCD6FE49F3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_06 => X"000000000000000000000000000000006D800100AB00BFF4F6002203CE032101",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a_l(31 downto 0),
                  DOPA => data_out_a_l(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b_l(31 downto 0),
                  DOPB => data_out_b_l(35 downto 32), 
                   DIB => data_in_b_l(31 downto 0),
                  DIPB => data_in_b_l(35 downto 32), 
                   WEB => we_b(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
      -- 
      kcpsm6_rom_h: RAMB16BWER
      generic map ( DATA_WIDTH_A => 9,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 9,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"000028684828684828684828684828684828684810C868481088684813000000",
                    INIT_01 => X"08D0E888D0C8D0E888D0C8D0E8D0C828A0082800A00881F00000A1A1A1A101F0",
                    INIT_02 => X"000868000828680069000028C890F0E8881800C990F0E989A1A1A1A1012828A0",
                    INIT_03 => X"28000000000028000000000000286F2F0F28109D8D680090E825286808002868",
                    INIT_04 => X"6F2F28006F1F286F00100028000000000028B0CE000E10C8A600001000B0670E",
                    INIT_05 => X"080828B0CE0E280000000000280000A76E4E00000000286F2F286F1F28906E4E",
                    INIT_06 => X"6808F0EA5A90E95928787808280000680069000008000D0D5858000808080808",
                    INIT_07 => X"01000000A70F00000101000000070000A70F000010CAA290EA0ACA5A6808105A",
                    INIT_08 => X"08080808080808080808080828B0EB8B007B0B7B0B2800000000000000020000",
                    INIT_09 => X"00000F8B000F8B000F0B680828685810000D0D00000808080808080808080808",
                    INIT_0A => X"0F00000F0000A700002800000F000F000F68082800005700000F0000A7000028",
                    INIT_0B => X"070000070000275B0F0000A70F0000A0A1A0A1A0A1A0A1508851086808280000",
                    INIT_0C => X"005F0000A75F000068582800109D8D00109D8D680090E890E8250D0D28000000",
                    INIT_0D => X"5828000048286858280000000000000002000001000000A75F00006858280000",
                    INIT_0E => X"085788568856885508B1E05A5828778876887688750857C856C856C855880878",
                    INIT_0F => X"08B80101010101010101010101010101010109080101010154C854C853C85388",
                    INIT_10 => X"A7A7A6A6A528B868081108B1E84800B828012222190118000A2800B0CAB86800",
                    INIT_11 => X"080808080808080808080808080828B1C80828011A6A2A016A28A5A4A4A3A328",
                    INIT_12 => X"5A2800000D0D0808080808080808080808080808080808080808080808080808",
                    INIT_13 => X"00508A0050010A5A28718A7121A2A2A2A2528AA1A1A1A1A1A1A1A151090A010A",
                    INIT_14 => X"A3A3A3A3A3A3A3A3538A53B4B40B0A010A0C0C0F0E2811CA8A8A88EA28006900",
                    INIT_15 => X"01010128010A0B0C0C07060EA3A3A3A3A3A3A3A3538A53B1EA8AB8010AB8B7B6",
                    INIT_16 => X"04010101010C0C0B010A0C0C0F0E28B1CA010101010101010101010101090801",
                    INIT_17 => X"010101010C0C0E010A0C0C0F0E110A00B1EB8B00748B7401010101010101010C",
                    INIT_18 => X"28010A0C0C0F28A4A24A010A11B1CE0000006900000001010101010101010C04",
                    INIT_19 => X"B8B6B756CF57CF01528F0F0909010A0C0C0F0E28000050830B5A2873830B5B5A",
                    INIT_1A => X"A5A454CF26A5A555CF0627A5A4A5A454CF27A5A5A555CF57CFB8010A0B0B0C0C",
                    INIT_1B => X"C9B8010AB891E9B757CFB8010AB8B5B6B6B725A555CF0526A4A555CF0626A5A4",
                    INIT_1C => X"74CC01C00801010C0B740108018C0C0C01010A0C0C0F0E28010A0C0C1109B1E9",
                    INIT_1D => X"259D850D0D0E0E0E0E0E0E0E0E0E0E1188CE010111C8A488E828110909B1EBCB",
                    INIT_1E => X"0228001100B1E818890091E96800690000506808006808006800690000000928",
                    INIT_1F => X"0808080808080808080808280028685828680828680828020302815859D1E858",
                    INIT_20 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_21 => X"000D0D006808006800690000006808006808001288685000F2E05908000D0D08",
                    INIT_22 => X"5A000D0D0012896800690000508008680800680800F2E1095A68006900005800",
                    INIT_23 => X"00680069000000000D0D00F2E1095A0012896800690000508008680800F2E109",
                    INIT_24 => X"0000482868286808682858280012CB680069000050D2E38B038AA2A289026808",
                    INIT_25 => X"0069000008000D0D080808080808080808081200004800480048004888EA4A28",
                    INIT_26 => X"0808080808080808080808080808080808080808080808080808080808280068",
                    INIT_27 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_28 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_29 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2A => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2B => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2C => X"25129D8D89B2E050F2E15892E892E825090D0D08080808080808080808080808",
                    INIT_2D => X"E15878082800020028000021259D8D01259D8D030212099D8D129D8D92E892E8",
                    INIT_2E => X"50C88858011289F2005092E101D2E15889017180087892E88858C9F2008950F2",
                    INIT_2F => X"08080808080808082800000D0D080808080808080808080808281271C88858C1",
                    INIT_30 => X"A30383538008528008F3E2580AD3E08870080889092800680069000000000D0D",
                    INIT_31 => X"E878885870885848002813700050B3E38B138B7000CB508B51D3E3D3CB8A8BA3",
                    INIT_32 => X"E893E893E893E850C85813000000000D0D000808080808080808080813C203F3",
                    INIT_33 => X"58680800680800680800D3C85828A00878C8580028A008680028A00878C858F3",
                    INIT_34 => X"00000000000000000000000000000000000000000000000028A00878C85878C8",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"73FB390AA4EFF4FFF3FE3F6CBAFFEB7CFFFE6777B7F60C064A552181A4924CCF",
                   INITP_01 => X"7FFFCF000046A80176EB6E77B3B99D4F6C6600176DF55DB7C92D9FFFFFFCD75B",
                   INITP_02 => X"F1059BFE78837FF9F80001340001062F94D0000273FFFFFFFFFF35C10753C077",
                   INITP_03 => X"FFFEDBC4FC2FADF987FFB964A668C18A6C3400000000006081041C30C22DBBFC",
                   INITP_04 => X"FFFFFFFFFFFFFFFFF4FFFAA9DE9DF402FD31BE2C4DF16C7D9BF5B589FFFFFFFF",
                   INITP_05 => X"FFE7FFF005A426192FF89C4AC4951FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_06 => X"000000000000000000000000000000925B6499C9543E7FFF48FA5850004487F4",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a_h(31 downto 0),
                  DOPA => data_out_a_h(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b_h(31 downto 0),
                  DOPB => data_out_b_h(35 downto 32), 
                   DIB => data_in_b_h(31 downto 0),
                  DIPB => data_in_b_h(35 downto 32), 
                   WEB => we_b(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
    --
    end generate s6;
    --
    --
    v6 : if (C_FAMILY = "V6") generate
      --
      address_a <= '1' & address(10 downto 0) & "1111";
      instruction <= data_out_a(33 downto 32) & data_out_a(15 downto 0);
      data_in_a <= "00000000000000000000000000000000000" & address(11);
      jtag_dout <= data_out_b(33 downto 32) & data_out_b(15 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b <= "00" & data_out_b(33 downto 32) & "0000000000000000" & data_out_b(15 downto 0);
        address_b <= "1111111111111111";
        we_b <= "00000000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b <= "00" & jtag_din(17 downto 16) & "0000000000000000" & jtag_din(15 downto 0);
        address_b <= '1' & jtag_addr(10 downto 0) & "1111";
        we_b <= jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom: RAMB36E1
      generic map ( READ_WIDTH_A => 18,
                    WRITE_WIDTH_A => 18,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 18,
                    WRITE_WIDTH_B => 18,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "VIRTEX6",
                    INIT_00 => X"90005000D008900020089000D008900020041000D00490002637014D006F00C5",
                    INIT_01 => X"003100205000D00290005000D01090005000D00490005000D02090005000D001",
                    INIT_02 => X"400E100050000030400E10010300E02E0031001043064306430643060300E02E",
                    INIT_03 => X"1000A042D010100AA03F902AA042D010100AA03F9011A042D00AA03F90305000",
                    INIT_04 => X"1137310F01009207204DE04DD2411237420E420E420E420E020050005000400E",
                    INIT_05 => X"0004110AD1010004110D5000D1010004D20100040043500091072054E054D141",
                    INIT_06 => X"1F01500020663B001A01D1010004206ED1004BA05000D101113E00045000D101",
                    INIT_07 => X"500000A700B5009E00B400A45000009A00B500A400B4009E00A75000DF045F02",
                    INIT_08 => X"00A45000608B9D0100AA1D08208190004D0E009000A7208600A46085CED01D80",
                    INIT_09 => X"DF045F01500000B4DF043FFE5000DE0100AA209000A75000009A00B5009E00B4",
                    INIT_0A => X"DC029C0200B7009E00B400A75000DF045F025000DF043FFD500020A0DC019C02",
                    INIT_0B => X"114C1143500060BB9C011C01500000BA00BA00BA00BA00BA5000009A00B74E00",
                    INIT_0C => X"0004D20100040043100100661ABE1B00B001B03100D41100113A115611201149",
                    INIT_0D => X"D0051000E0E2D404B42C210BD300B3235000F023F020100050000062005BD101",
                    INIT_0E => X"4E061E280073006F20E89401450620ECD40015109404B42CD005100120E6B42C",
                    INIT_0F => X"03E0008A009700804E071E280073006F022F022F007A009700800E5000970080",
                    INIT_10 => X"00D8F62C1600F62316015000005B0055004000550030007A009504E0008A008F",
                    INIT_11 => X"1174112011641165116C11691161116611201143113211495000610ED6081601",
                    INIT_12 => X"00661A141B01005B006F110011211164116E116F11701173116511721120116F",
                    INIT_13 => X"007A01411E21160101411E23160101411E27162CD00510025000D009B02C205B",
                    INIT_14 => X"1E27D0051002500000970080AE60009700801E09009700804E060073006F5000",
                    INIT_15 => X"1E00009700801E00009700804E060073006F5000007A01571E2101571E230157",
                    INIT_16 => X"4206410042064100420641004206A1001001A2001030D0051002500000970080",
                    INIT_17 => X"0E20009700800E10009700804E60B62C1E30009700804E061E730073006F4100",
                    INIT_18 => X"21863B001A01D10100042194D1FF2190D1004BA01AC31B045000007A00970080",
                    INIT_19 => X"0080BE34009700804E06BE300073006FD005B02C5000005B21863B001A03005B",
                    INIT_1A => X"04E0008A008F03E0008A009700804E07BE300073006FD005B02C5000007A0097",
                    INIT_1B => X"B1285000005B005590065000D006B02C5000005B0055004000550030007A0095",
                    INIT_1C => X"ED101101EC101101EB101141AE009001AD009001AC009001AB001003102CF140",
                    INIT_1D => X"102CAE001001AD001001AC001001AB001041625AC050B528B0405000EE101101",
                    INIT_1E => X"0210020712001100022102210221021BA9009001A8009001A7009001A6001003",
                    INIT_1F => X"112070010221021B021002070221021B021002070221021B021002070221021B",
                    INIT_20 => X"5000022744204410320402A0310101F014005000005B61EE95017000D1010004",
                    INIT_21 => X"4F004E084D084C084B0E50007000D0011030221810316217D001900600047001",
                    INIT_22 => X"900110195000022E340DD4065402022ED40650004A00490848084708460E5000",
                    INIT_23 => X"1164116E116111201153114D11541120113A1152114F1152115211455000622F",
                    INIT_24 => X"1120116F116411201173116811741167116E1165116C1120114F114411541120",
                    INIT_25 => X"B42C5000005B00661A321B0211001168116311741161116D11201174116F116E",
                    INIT_26 => X"4406A440140142004306420043064200430642004306A3401200143002841545",
                    INIT_27 => X"0043A05015010055A05002841545B42C5000E3501501E2504240440644064406",
                    INIT_28 => X"1504190618261E001D03500022849401150115011000D4005000005BD2010004",
                    INIT_29 => X"4708460E4708460E4708460E4708460EA7401401A640696068601600144502BD",
                    INIT_2A => X"4708460F4708460FA7401401A6406292D4611401700002BD150370016E706D60",
                    INIT_2B => X"02210221021B500002BD150617FF18F819000E700D601CFF4708460F4708460F",
                    INIT_2C => X"95010221021B02070221021B02070221021B02070221021B0207120011000221",
                    INIT_2D => X"0980031403140314031419001800164502BD1504190618261E001D03500062C3",
                    INIT_2E => X"62D9D6631601005BE9601601E860031403140314031403140314031403141800",
                    INIT_2F => X"0314031403140314190018001C0602BD1504190618261E401D0122921445005B",
                    INIT_30 => X"00550090D2010004004300800314031403140314031403140314031418000980",
                    INIT_31 => X"500002BD150219FF18FF1E0050004808450E950602271400231A62FA9C01005B",
                    INIT_32 => X"18261E201D015000005B0055A07007501763B52C5000E67007501763B630B52C",
                    INIT_33 => X"70016DD06EE0ADF09F01AEF09F010227A4F01F0A1F631200130202BD15041906",
                    INIT_34 => X"9F014EA04A064A064A06AAF09F01AEF09F01700002BD15041600170018001900",
                    INIT_35 => X"4A08490EA9F09F014DA04A064A06AAF09F010D904EA04A0049064A004906A9F0",
                    INIT_36 => X"6DD06EE04BA04A06AAF09F010B904CA049004A06AAF09F010C904DA04A08490E",
                    INIT_37 => X"9301700002BD150270012384D2016EE0AEF09F01700002BD150770016BB06CC0",
                    INIT_38 => X"022702BD1504190618261E201D01500002BD150418FF1980233512016335D300",
                    INIT_39 => X"E890990103A780C0100803BB03AC18001609E89003A710070314190A19631800",
                    INIT_3A => X"10009C01031403BB23A79001480E1000D00050002335130212006398D6FF9601",
                    INIT_3B => X"4BA03B000A601AB11B031C081C081C031C031C041C041C031C081C031C0823AD",
                    INIT_3C => X"0043A030D00110200004D001103A0004D1010004D20100040043003013005000",
                    INIT_3D => X"04215000005B23C2005B63CED00330031301003023DDD3FFD1010004D2010004",
                    INIT_3E => X"5000D00310005000D00310FF50000421060B05BC0210B12BB227A3E9D004B023",
                    INIT_3F => X"116F115711001120113A117211651166116611751142500000C55000D00AB02C",
                    INIT_40 => X"112011641172116F115711001120113A1174116E1175116F1163112011641172",
                    INIT_41 => X"112011641172116F115711001120112011201120113A11731165117A11691173",
                    INIT_42 => X"D0011020000424261101D001A0100004E42DC120B220110000661AF51B031100",
                    INIT_43 => X"00661AFE1B03005BD00110290004D1010004D201000400430020D00110280004",
                    INIT_44 => X"10400004D00110200004E45BC3401300B423D1010004D20100040043B0230004",
                    INIT_45 => X"B42300661A0B1B04005B24491301D1010004D20100040043A01001301124D001",
                    INIT_46 => X"24611301D1010004D20100040043A01001301128D00110200004E470C3401300",
                    INIT_47 => X"0004D1010004D20100040043003000661A1B1B04005BE493C3401300B423005B",
                    INIT_48 => X"0004D20100040043A060A473C65016030650152C4506450613010530D0011020",
                    INIT_49 => X"005B005590055000D0085000D0071000D0075010B02C5000005B24899601D101",
                    INIT_4A => X"1165115624A1005B005590070055900700559007005590071000D50195055000",
                    INIT_4B => X"0004D20100040043100100661AAE1B0411001120113A116E116F116911731172",
                    INIT_4C => X"1165116D11DF1103110011671172116111691174116C1175116D5000005BD101",
                    INIT_4D => X"11F3110311001174116511731165117211C1110311001170116D11751164116D",
                    INIT_4E => X"11211104110011731179117311B811041100116E116F11691173117211651176",
                    INIT_4F => X"1100116E116F115F117211651177116F11701184110111001170116C11651168",
                    INIT_50 => X"1100116111ED1103110011661166116F115F117211651177116F117011EA1103",
                    INIT_51 => X"110111001177116911BB110111001172116A11B8110111001177116A11D81100",
                    INIT_52 => X"11D311011100116D116A11BF110111001164116A11A311011100117211691196",
                    INIT_53 => X"110011751174116A11781102110011721174116A115F1102110011771174116A",
                    INIT_54 => X"1163117411F31102110011731174116A11D21102110011671174116A118B1102",
                    INIT_55 => X"110011721174119B11041100117A1174119D1104110011661174119511041100",
                    INIT_56 => X"1161116A11261103110011721161116A11201103110011771161116A11A11104",
                    INIT_57 => X"11701131110111001170117311891103110011671161116A112D110311001175",
                    INIT_58 => X"12001AC31B0411FF1163110111001164113411011100117011F0110311001163",
                    INIT_59 => X"4BA025903B001A011201659FC010A020E59FC200B02025B8D1FF25ABD1004BA0",
                    INIT_5A => X"4BA03B001A01060B05BC259012003B001A03259F3B001A0125A7D10025B8D1FF",
                    INIT_5B => X"C210B120F02310005000006205F300D45000006200D442104BA03B001A010210",
                    INIT_5C => X"13080320E21001001123F02325E6D0051001B0239201E5BE00311201A020E5E6",
                    INIT_5D => X"A01091011124B123032025D41201E5DB0031A02025DBC3200310A5D4C310B120",
                    INIT_5E => X"1161116D116D116F11631120116411611142500025BEE30090011028B0238300",
                    INIT_5F => X"11001120113A1172116F1172117211455000005B00661AE71B0511001164116E",
                    INIT_60 => X"E0101000112C120412385000005BD1010004D20100040043002000661AF81B05",
                    INIT_61 => X"470607400650A61001401128A50000401024E636C400B0231400A60EC1201101",
                    INIT_62 => X"160126231701E070001E9601A1601601A260A62FC650A61496021401172C4706",
                    INIT_63 => X"D120F1201101B120E0101100B1209001000850002614E0700031A0606614C650",
                    INIT_64 => X"1B06005B110011211177116F116C1166117211651176114F2637858D0656E64E",
                    INIT_65 => X"D1202673D108266CD10A266CD10DA1009001B0202637006200D4005B00661A44",
                    INIT_66 => X"F0209001B020005B5000400C1000D10100045000400C1000F0209001B020E667",
                    INIT_67 => X"B020D10111080004D10111200004D10111080004A6829002B0205000400C1001",
                    INIT_68 => X"000000000000000000000000000000005000400C1000F0209001B020F0209001",
                    INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"AAAAAAA8296B6A2A8A2AAA7D41F5552935DD7776484785538820820820B0B0AA",
                   INITP_01 => X"2A4AAA8A4A9744888D34A8AAAA20AAAAAB4AAAA90AAA28B08A88AAAAAD8B6AB0",
                   INITP_02 => X"28A029295554422A28A6AA2222A28A6AA18608A282AAAAAAAAAAAAB5A22A228A",
                   INITP_03 => X"3AAAAAAAA0AA111104443429998111122A28A88A28A92A2A8A4A8A9696B760AA",
                   INITP_04 => X"8620A615455554082A0AAAAAAAAAAAAAAAAAAAAB4A22A556556E234BA0002B7A",
                   INITP_05 => X"AA020022D69AAAA82A80800B6AAAAA82AA80005555135E355555114200295DAA",
                   INITP_06 => X"78F51E35511051055114415445447800D446102002A10A40A00948B68A8AAAA0",
                   INITP_07 => X"AAAAAAA8A28AA434AAB44DAA88A2AA82942AAAAADA97683599282890A002808D",
                   INITP_08 => X"AAA20B429AA848B420A6AA1228B42AA2828AAA228A62D082AAAAAAAAAAAAAAAA",
                   INITP_09 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA20AAAAAA8888D2A2A882A6AA351548",
                   INITP_0A => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_0B => X"AAAAA82AAAAAAA5114278D34492D479348AAAA9496A165DDA574D37602AAAAAA",
                   INITP_0C => X"228A2D249292A49377744AA82AAAAABB6490AA8D6691375544413435812AAA20",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000009249",
                   INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a(31 downto 0),
                      DOPADOP => data_out_a(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b(31 downto 0),
                      DOPBDOP => data_out_b(35 downto 32), 
                        DIBDI => data_in_b(31 downto 0),
                      DIPBDIP => data_in_b(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
    end generate v6;
    --
    --
    akv7 : if (C_FAMILY = "7S") generate
      --
      address_a <= '1' & address(10 downto 0) & "1111";
      instruction <= data_out_a(33 downto 32) & data_out_a(15 downto 0);
      data_in_a <= "00000000000000000000000000000000000" & address(11);
      jtag_dout <= data_out_b(33 downto 32) & data_out_b(15 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b <= "00" & data_out_b(33 downto 32) & "0000000000000000" & data_out_b(15 downto 0);
        address_b <= "1111111111111111";
        we_b <= "00000000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b <= "00" & jtag_din(17 downto 16) & "0000000000000000" & jtag_din(15 downto 0);
        address_b <= '1' & jtag_addr(10 downto 0) & "1111";
        we_b <= jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom: RAMB36E1
      generic map ( READ_WIDTH_A => 18,
                    WRITE_WIDTH_A => 18,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 18,
                    WRITE_WIDTH_B => 18,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "7SERIES",
                    INIT_00 => X"90005000D008900020089000D008900020041000D00490002637014D006F00C5",
                    INIT_01 => X"003100205000D00290005000D01090005000D00490005000D02090005000D001",
                    INIT_02 => X"400E100050000030400E10010300E02E0031001043064306430643060300E02E",
                    INIT_03 => X"1000A042D010100AA03F902AA042D010100AA03F9011A042D00AA03F90305000",
                    INIT_04 => X"1137310F01009207204DE04DD2411237420E420E420E420E020050005000400E",
                    INIT_05 => X"0004110AD1010004110D5000D1010004D20100040043500091072054E054D141",
                    INIT_06 => X"1F01500020663B001A01D1010004206ED1004BA05000D101113E00045000D101",
                    INIT_07 => X"500000A700B5009E00B400A45000009A00B500A400B4009E00A75000DF045F02",
                    INIT_08 => X"00A45000608B9D0100AA1D08208190004D0E009000A7208600A46085CED01D80",
                    INIT_09 => X"DF045F01500000B4DF043FFE5000DE0100AA209000A75000009A00B5009E00B4",
                    INIT_0A => X"DC029C0200B7009E00B400A75000DF045F025000DF043FFD500020A0DC019C02",
                    INIT_0B => X"114C1143500060BB9C011C01500000BA00BA00BA00BA00BA5000009A00B74E00",
                    INIT_0C => X"0004D20100040043100100661ABE1B00B001B03100D41100113A115611201149",
                    INIT_0D => X"D0051000E0E2D404B42C210BD300B3235000F023F020100050000062005BD101",
                    INIT_0E => X"4E061E280073006F20E89401450620ECD40015109404B42CD005100120E6B42C",
                    INIT_0F => X"03E0008A009700804E071E280073006F022F022F007A009700800E5000970080",
                    INIT_10 => X"00D8F62C1600F62316015000005B0055004000550030007A009504E0008A008F",
                    INIT_11 => X"1174112011641165116C11691161116611201143113211495000610ED6081601",
                    INIT_12 => X"00661A141B01005B006F110011211164116E116F11701173116511721120116F",
                    INIT_13 => X"007A01411E21160101411E23160101411E27162CD00510025000D009B02C205B",
                    INIT_14 => X"1E27D0051002500000970080AE60009700801E09009700804E060073006F5000",
                    INIT_15 => X"1E00009700801E00009700804E060073006F5000007A01571E2101571E230157",
                    INIT_16 => X"4206410042064100420641004206A1001001A2001030D0051002500000970080",
                    INIT_17 => X"0E20009700800E10009700804E60B62C1E30009700804E061E730073006F4100",
                    INIT_18 => X"21863B001A01D10100042194D1FF2190D1004BA01AC31B045000007A00970080",
                    INIT_19 => X"0080BE34009700804E06BE300073006FD005B02C5000005B21863B001A03005B",
                    INIT_1A => X"04E0008A008F03E0008A009700804E07BE300073006FD005B02C5000007A0097",
                    INIT_1B => X"B1285000005B005590065000D006B02C5000005B0055004000550030007A0095",
                    INIT_1C => X"ED101101EC101101EB101141AE009001AD009001AC009001AB001003102CF140",
                    INIT_1D => X"102CAE001001AD001001AC001001AB001041625AC050B528B0405000EE101101",
                    INIT_1E => X"0210020712001100022102210221021BA9009001A8009001A7009001A6001003",
                    INIT_1F => X"112070010221021B021002070221021B021002070221021B021002070221021B",
                    INIT_20 => X"5000022744204410320402A0310101F014005000005B61EE95017000D1010004",
                    INIT_21 => X"4F004E084D084C084B0E50007000D0011030221810316217D001900600047001",
                    INIT_22 => X"900110195000022E340DD4065402022ED40650004A00490848084708460E5000",
                    INIT_23 => X"1164116E116111201153114D11541120113A1152114F1152115211455000622F",
                    INIT_24 => X"1120116F116411201173116811741167116E1165116C1120114F114411541120",
                    INIT_25 => X"B42C5000005B00661A321B0211001168116311741161116D11201174116F116E",
                    INIT_26 => X"4406A440140142004306420043064200430642004306A3401200143002841545",
                    INIT_27 => X"0043A05015010055A05002841545B42C5000E3501501E2504240440644064406",
                    INIT_28 => X"1504190618261E001D03500022849401150115011000D4005000005BD2010004",
                    INIT_29 => X"4708460E4708460E4708460E4708460EA7401401A640696068601600144502BD",
                    INIT_2A => X"4708460F4708460FA7401401A6406292D4611401700002BD150370016E706D60",
                    INIT_2B => X"02210221021B500002BD150617FF18F819000E700D601CFF4708460F4708460F",
                    INIT_2C => X"95010221021B02070221021B02070221021B02070221021B0207120011000221",
                    INIT_2D => X"0980031403140314031419001800164502BD1504190618261E001D03500062C3",
                    INIT_2E => X"62D9D6631601005BE9601601E860031403140314031403140314031403141800",
                    INIT_2F => X"0314031403140314190018001C0602BD1504190618261E401D0122921445005B",
                    INIT_30 => X"00550090D2010004004300800314031403140314031403140314031418000980",
                    INIT_31 => X"500002BD150219FF18FF1E0050004808450E950602271400231A62FA9C01005B",
                    INIT_32 => X"18261E201D015000005B0055A07007501763B52C5000E67007501763B630B52C",
                    INIT_33 => X"70016DD06EE0ADF09F01AEF09F010227A4F01F0A1F631200130202BD15041906",
                    INIT_34 => X"9F014EA04A064A064A06AAF09F01AEF09F01700002BD15041600170018001900",
                    INIT_35 => X"4A08490EA9F09F014DA04A064A06AAF09F010D904EA04A0049064A004906A9F0",
                    INIT_36 => X"6DD06EE04BA04A06AAF09F010B904CA049004A06AAF09F010C904DA04A08490E",
                    INIT_37 => X"9301700002BD150270012384D2016EE0AEF09F01700002BD150770016BB06CC0",
                    INIT_38 => X"022702BD1504190618261E201D01500002BD150418FF1980233512016335D300",
                    INIT_39 => X"E890990103A780C0100803BB03AC18001609E89003A710070314190A19631800",
                    INIT_3A => X"10009C01031403BB23A79001480E1000D00050002335130212006398D6FF9601",
                    INIT_3B => X"4BA03B000A601AB11B031C081C081C031C031C041C041C031C081C031C0823AD",
                    INIT_3C => X"0043A030D00110200004D001103A0004D1010004D20100040043003013005000",
                    INIT_3D => X"04215000005B23C2005B63CED00330031301003023DDD3FFD1010004D2010004",
                    INIT_3E => X"5000D00310005000D00310FF50000421060B05BC0210B12BB227A3E9D004B023",
                    INIT_3F => X"116F115711001120113A117211651166116611751142500000C55000D00AB02C",
                    INIT_40 => X"112011641172116F115711001120113A1174116E1175116F1163112011641172",
                    INIT_41 => X"112011641172116F115711001120112011201120113A11731165117A11691173",
                    INIT_42 => X"D0011020000424261101D001A0100004E42DC120B220110000661AF51B031100",
                    INIT_43 => X"00661AFE1B03005BD00110290004D1010004D201000400430020D00110280004",
                    INIT_44 => X"10400004D00110200004E45BC3401300B423D1010004D20100040043B0230004",
                    INIT_45 => X"B42300661A0B1B04005B24491301D1010004D20100040043A01001301124D001",
                    INIT_46 => X"24611301D1010004D20100040043A01001301128D00110200004E470C3401300",
                    INIT_47 => X"0004D1010004D20100040043003000661A1B1B04005BE493C3401300B423005B",
                    INIT_48 => X"0004D20100040043A060A473C65016030650152C4506450613010530D0011020",
                    INIT_49 => X"005B005590055000D0085000D0071000D0075010B02C5000005B24899601D101",
                    INIT_4A => X"1165115624A1005B005590070055900700559007005590071000D50195055000",
                    INIT_4B => X"0004D20100040043100100661AAE1B0411001120113A116E116F116911731172",
                    INIT_4C => X"1165116D11DF1103110011671172116111691174116C1175116D5000005BD101",
                    INIT_4D => X"11F3110311001174116511731165117211C1110311001170116D11751164116D",
                    INIT_4E => X"11211104110011731179117311B811041100116E116F11691173117211651176",
                    INIT_4F => X"1100116E116F115F117211651177116F11701184110111001170116C11651168",
                    INIT_50 => X"1100116111ED1103110011661166116F115F117211651177116F117011EA1103",
                    INIT_51 => X"110111001177116911BB110111001172116A11B8110111001177116A11D81100",
                    INIT_52 => X"11D311011100116D116A11BF110111001164116A11A311011100117211691196",
                    INIT_53 => X"110011751174116A11781102110011721174116A115F1102110011771174116A",
                    INIT_54 => X"1163117411F31102110011731174116A11D21102110011671174116A118B1102",
                    INIT_55 => X"110011721174119B11041100117A1174119D1104110011661174119511041100",
                    INIT_56 => X"1161116A11261103110011721161116A11201103110011771161116A11A11104",
                    INIT_57 => X"11701131110111001170117311891103110011671161116A112D110311001175",
                    INIT_58 => X"12001AC31B0411FF1163110111001164113411011100117011F0110311001163",
                    INIT_59 => X"4BA025903B001A011201659FC010A020E59FC200B02025B8D1FF25ABD1004BA0",
                    INIT_5A => X"4BA03B001A01060B05BC259012003B001A03259F3B001A0125A7D10025B8D1FF",
                    INIT_5B => X"C210B120F02310005000006205F300D45000006200D442104BA03B001A010210",
                    INIT_5C => X"13080320E21001001123F02325E6D0051001B0239201E5BE00311201A020E5E6",
                    INIT_5D => X"A01091011124B123032025D41201E5DB0031A02025DBC3200310A5D4C310B120",
                    INIT_5E => X"1161116D116D116F11631120116411611142500025BEE30090011028B0238300",
                    INIT_5F => X"11001120113A1172116F1172117211455000005B00661AE71B0511001164116E",
                    INIT_60 => X"E0101000112C120412385000005BD1010004D20100040043002000661AF81B05",
                    INIT_61 => X"470607400650A61001401128A50000401024E636C400B0231400A60EC1201101",
                    INIT_62 => X"160126231701E070001E9601A1601601A260A62FC650A61496021401172C4706",
                    INIT_63 => X"D120F1201101B120E0101100B1209001000850002614E0700031A0606614C650",
                    INIT_64 => X"1B06005B110011211177116F116C1166117211651176114F2637858D0656E64E",
                    INIT_65 => X"D1202673D108266CD10A266CD10DA1009001B0202637006200D4005B00661A44",
                    INIT_66 => X"F0209001B020005B5000400C1000D10100045000400C1000F0209001B020E667",
                    INIT_67 => X"B020D10111080004D10111200004D10111080004A6829002B0205000400C1001",
                    INIT_68 => X"000000000000000000000000000000005000400C1000F0209001B020F0209001",
                    INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"AAAAAAA8296B6A2A8A2AAA7D41F5552935DD7776484785538820820820B0B0AA",
                   INITP_01 => X"2A4AAA8A4A9744888D34A8AAAA20AAAAAB4AAAA90AAA28B08A88AAAAAD8B6AB0",
                   INITP_02 => X"28A029295554422A28A6AA2222A28A6AA18608A282AAAAAAAAAAAAB5A22A228A",
                   INITP_03 => X"3AAAAAAAA0AA111104443429998111122A28A88A28A92A2A8A4A8A9696B760AA",
                   INITP_04 => X"8620A615455554082A0AAAAAAAAAAAAAAAAAAAAB4A22A556556E234BA0002B7A",
                   INITP_05 => X"AA020022D69AAAA82A80800B6AAAAA82AA80005555135E355555114200295DAA",
                   INITP_06 => X"78F51E35511051055114415445447800D446102002A10A40A00948B68A8AAAA0",
                   INITP_07 => X"AAAAAAA8A28AA434AAB44DAA88A2AA82942AAAAADA97683599282890A002808D",
                   INITP_08 => X"AAA20B429AA848B420A6AA1228B42AA2828AAA228A62D082AAAAAAAAAAAAAAAA",
                   INITP_09 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA20AAAAAA8888D2A2A882A6AA351548",
                   INITP_0A => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_0B => X"AAAAA82AAAAAAA5114278D34492D479348AAAA9496A165DDA574D37602AAAAAA",
                   INITP_0C => X"228A2D249292A49377744AA82AAAAABB6490AA8D6691375544413435812AAA20",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000009249",
                   INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a(31 downto 0),
                      DOPADOP => data_out_a(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b(31 downto 0),
                      DOPBDOP => data_out_b(35 downto 32), 
                        DIBDI => data_in_b(31 downto 0),
                      DIPBDIP => data_in_b(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
    end generate akv7;
    --
  end generate ram_2k_generate;
  --
  --	
  ram_4k_generate : if (C_RAM_SIZE_KWORDS = 4) generate
    s6: if (C_FAMILY = "S6") generate
      --
      address_a(13 downto 0) <= address(10 downto 0) & "000";
      data_in_a <= "000000000000000000000000000000000000";
      --
      s6_a11_flop: FD
      port map (  D => address(11),
                  Q => pipe_a11,
                  C => clk);
      --
      s6_4k_mux0_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_ll(0),
                I1 => data_out_a_hl(0),
                I2 => data_out_a_ll(1),
                I3 => data_out_a_hl(1),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(0),
                O6 => instruction(1));
      --
      s6_4k_mux2_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_ll(2),
                I1 => data_out_a_hl(2),
                I2 => data_out_a_ll(3),
                I3 => data_out_a_hl(3),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(2),
                O6 => instruction(3));
      --
      s6_4k_mux4_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_ll(4),
                I1 => data_out_a_hl(4),
                I2 => data_out_a_ll(5),
                I3 => data_out_a_hl(5),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(4),
                O6 => instruction(5));
      --
      s6_4k_mux6_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_ll(6),
                I1 => data_out_a_hl(6),
                I2 => data_out_a_ll(7),
                I3 => data_out_a_hl(7),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(6),
                O6 => instruction(7));
      --
      s6_4k_mux8_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_ll(32),
                I1 => data_out_a_hl(32),
                I2 => data_out_a_lh(0),
                I3 => data_out_a_hh(0),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(8),
                O6 => instruction(9));
      --
      s6_4k_mux10_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_lh(1),
                I1 => data_out_a_hh(1),
                I2 => data_out_a_lh(2),
                I3 => data_out_a_hh(2),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(10),
                O6 => instruction(11));
      --
      s6_4k_mux12_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_lh(3),
                I1 => data_out_a_hh(3),
                I2 => data_out_a_lh(4),
                I3 => data_out_a_hh(4),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(12),
                O6 => instruction(13));
      --
      s6_4k_mux14_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_lh(5),
                I1 => data_out_a_hh(5),
                I2 => data_out_a_lh(6),
                I3 => data_out_a_hh(6),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(14),
                O6 => instruction(15));
      --
      s6_4k_mux16_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_lh(7),
                I1 => data_out_a_hh(7),
                I2 => data_out_a_lh(32),
                I3 => data_out_a_hh(32),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(16),
                O6 => instruction(17));
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b_ll <= "000" & data_out_b_ll(32) & "000000000000000000000000" & data_out_b_ll(7 downto 0);
        data_in_b_lh <= "000" & data_out_b_lh(32) & "000000000000000000000000" & data_out_b_lh(7 downto 0);
        data_in_b_hl <= "000" & data_out_b_hl(32) & "000000000000000000000000" & data_out_b_hl(7 downto 0);
        data_in_b_hh <= "000" & data_out_b_hh(32) & "000000000000000000000000" & data_out_b_hh(7 downto 0);
        address_b(13 downto 0) <= "00000000000000";
        we_b_l(3 downto 0) <= "0000";
        we_b_h(3 downto 0) <= "0000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
        jtag_dout <= data_out_b_lh(32) & data_out_b_lh(7 downto 0) & data_out_b_ll(32) & data_out_b_ll(7 downto 0);
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b_lh <= "000" & jtag_din(17) & "000000000000000000000000" & jtag_din(16 downto 9);
        data_in_b_ll <= "000" & jtag_din(8) & "000000000000000000000000" & jtag_din(7 downto 0);
        data_in_b_hh <= "000" & jtag_din(17) & "000000000000000000000000" & jtag_din(16 downto 9);
        data_in_b_hl <= "000" & jtag_din(8) & "000000000000000000000000" & jtag_din(7 downto 0);
        address_b(13 downto 0) <= jtag_addr(10 downto 0) & "000";
        --
        s6_4k_jtag_we_lut: LUT6_2
        generic map (INIT => X"8000000020000000")
        port map( I0 => jtag_we,
                  I1 => jtag_addr(11),
                  I2 => '1',
                  I3 => '1',
                  I4 => '1',
                  I5 => '1',
                  O5 => jtag_we_l,
                  O6 => jtag_we_h);
        --
        we_b_l(3 downto 0) <= jtag_we_l & jtag_we_l & jtag_we_l & jtag_we_l;
        we_b_h(3 downto 0) <= jtag_we_h & jtag_we_h & jtag_we_h & jtag_we_h;
        --
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
        --
        s6_4k_jtag_mux0_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_ll(0),
                  I1 => data_out_b_hl(0),
                  I2 => data_out_b_ll(1),
                  I3 => data_out_b_hl(1),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(0),
                  O6 => jtag_dout(1));
        --
        s6_4k_jtag_mux2_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_ll(2),
                  I1 => data_out_b_hl(2),
                  I2 => data_out_b_ll(3),
                  I3 => data_out_b_hl(3),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(2),
                  O6 => jtag_dout(3));
        --
        s6_4k_jtag_mux4_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_ll(4),
                  I1 => data_out_b_hl(4),
                  I2 => data_out_b_ll(5),
                  I3 => data_out_b_hl(5),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(4),
                  O6 => jtag_dout(5));
        --
        s6_4k_jtag_mux6_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_ll(6),
                  I1 => data_out_b_hl(6),
                  I2 => data_out_b_ll(7),
                  I3 => data_out_b_hl(7),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(6),
                  O6 => jtag_dout(7));
        --
        s6_4k_jtag_mux8_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_ll(32),
                  I1 => data_out_b_hl(32),
                  I2 => data_out_b_lh(0),
                  I3 => data_out_b_hh(0),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(8),
                  O6 => jtag_dout(9));
        --
        s6_4k_jtag_mux10_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_lh(1),
                  I1 => data_out_b_hh(1),
                  I2 => data_out_b_lh(2),
                  I3 => data_out_b_hh(2),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(10),
                  O6 => jtag_dout(11));
        --
        s6_4k_jtag_mux12_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_lh(3),
                  I1 => data_out_b_hh(3),
                  I2 => data_out_b_lh(4),
                  I3 => data_out_b_hh(4),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(12),
                  O6 => jtag_dout(13));
        --
        s6_4k_jtag_mux14_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_lh(5),
                  I1 => data_out_b_hh(5),
                  I2 => data_out_b_lh(6),
                  I3 => data_out_b_hh(6),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(14),
                  O6 => jtag_dout(15));
        --
        s6_4k_jtag_mux16_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_lh(7),
                  I1 => data_out_b_hh(7),
                  I2 => data_out_b_lh(32),
                  I3 => data_out_b_hh(32),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(16),
                  O6 => jtag_dout(17));
      --
      end generate loader;
      --
      kcpsm6_rom_ll: RAMB16BWER
      generic map ( DATA_WIDTH_A => 9,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 9,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"31200002000010000004000020000001000008000800080004000400374D6FC5",
                    INIT_01 => X"0042100A3F2A42100A3F11420A3F30000E0000300E01002E311006060606002E",
                    INIT_02 => X"040A01040D0001040104430007545441370F00074D4D41370E0E0E0E0000000E",
                    INIT_03 => X"00A7B59EB4A4009AB5A4B49EA7000402010066000101046E00A000013E040001",
                    INIT_04 => X"040100B404FE0001AA90A7009AB59EB4A4008B01AA0881000E90A786A485D080",
                    INIT_05 => X"4C4300BB010100BABABABABA009AB7000202B79EB4A70004020004FD00A00102",
                    INIT_06 => X"0500E2042C0B00230023200000625B01040104430166BE000131D4003A562049",
                    INIT_07 => X"E08A97800728736F2F2F7A97805097800628736FE80106EC0010042C0501E62C",
                    INIT_08 => X"742064656C69616620433249000E0801D82C002301005B554055307A95E08A8F",
                    INIT_09 => X"7A41210141230141272C050200092C5B6614015B6F0021646E6F70736572206F",
                    INIT_0A => X"00978000978006736F007A572157235727050200978060978009978006736F00",
                    INIT_0B => X"209780109780602C3097800673736F0006000600060006000100300502009780",
                    INIT_0C => X"803497800630736F052C005B8600035B860001010494FF9000A0C304007A9780",
                    INIT_0D => X"28005B550600062C005B554055307A95E08A8FE08A97800730736F052C007A97",
                    INIT_0E => X"2C00010001000100415A50284000100110011001104100010001000100032C40",
                    INIT_0F => X"2001211B1007211B1007211B1007211B100700002121211B0001000100010003",
                    INIT_10 => X"000808080E00000130183117010604010027201004A001F000005BEE01000104",
                    INIT_11 => X"646E6120534D54203A524F525245002F0119002E0D06022E0600000808080E00",
                    INIT_12 => X"2C005B66320200686374616D20746F6E206F6420736874676E656C204F445420",
                    INIT_13 => X"435001555084452C005001504006060606400100060006000600064000308445",
                    INIT_14 => X"080E080E080E080E40014060600045BD040626000300840101010000005B0104",
                    INIT_15 => X"21211B00BD06FFF8007060FF080F080F080F080F40014092610100BD03017060",
                    INIT_16 => X"8014141414000045BD040626000300C301211B07211B07211B07211B07000021",
                    INIT_17 => X"14141414000006BD040626400192455BD963015B600160141414141414141400",
                    INIT_18 => X"00BD02FFFF0000080E0627001AFA015B55900104438014141414141414140080",
                    INIT_19 => X"01D0E0F001F00127F00A630002BD0406262001005B557050632C00705063302C",
                    INIT_1A => X"080EF001A00606F00190A000060006F001A0060606F001F00100BD0400000000",
                    INIT_1B => X"0100BD02018401E0F00100BD0701B0C0D0E0A006F00190A00006F00190A0080E",
                    INIT_1C => X"9001A7C008BBAC000990A707140A630027BD040626200100BD04FF8035013500",
                    INIT_1D => X"A00060B10308080303040403080308AD000114BBA7010E00000035020098FF01",
                    INIT_1E => X"21005BC25BCE03030130DDFF010401044330012004013A040104010443300000",
                    INIT_1F => X"6F5700203A72656666754200C5000A2C0003000003FF00210BBC102B27E90423",
                    INIT_20 => X"2064726F5700202020203A73657A69732064726F5700203A746E756F63206472",
                    INIT_21 => X"66FE035B01290401040104432001280401200426010110042D20200066F50300",
                    INIT_22 => X"23660B045B490101040104431030240140040120045B40002301040104432304",
                    INIT_23 => X"04010401044330661B045B934000235B61010104010443103028012004704000",
                    INIT_24 => X"5B5505000800070007102C005B8901010401044360735003502C060601300120",
                    INIT_25 => X"040104430166AE0400203A6E6F6973726556A15B550755075507550700010500",
                    INIT_26 => X"F303007465736572C10300706D75646D656DDF030067726169746C756D005B01",
                    INIT_27 => X"006E6F5F7265776F70840100706C6568210400737973B804006E6F6973726576",
                    INIT_28 => X"01007769BB0100726AB80100776AD8000061ED030066666F5F7265776F70EA03",
                    INIT_29 => X"0075746A78020072746A5F020077746AD301006D6ABF0100646AA30100726996",
                    INIT_2A => X"0072749B04007A749D040066749504006374F3020073746AD2020067746A8B02",
                    INIT_2B => X"70310100707389030067616A2D030075616A26030072616A20030077616AA104",
                    INIT_2C => X"A0900001019F10209F0020B8FFAB00A000C304FF6301006434010070F0030063",
                    INIT_2D => X"102023000062F3D40062D410A0000110A000010BBC900000039F0001A700B8FF",
                    INIT_2E => X"1001242320D401DB3120DB2010D41020082010002323E605012301BE310120E6",
                    INIT_2F => X"00203A726F727245005B66E70500646E616D6D6F632064614200BE0001282300",
                    INIT_30 => X"064050104028004024360023000E200110002C0438005B01040104432066F805",
                    INIT_31 => X"20200120100020010800147031601450012301701E016001602F501402012C06",
                    INIT_32 => X"2073086C0A6C0D0001203762D45B6644065B0021776F6C667265764F378D564E",
                    INIT_33 => X"20010804012004010804820220000C012001205B000C000104000C0020012067",
                    INIT_34 => X"000000000000000000000000000000000000000000000000000C002001202001",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"800002400701011FC00001B0CC001481000394D96A09E0000000023E00000004",
                   INITP_01 => X"800010881111DC8980001000000CD7D00001550000150000490027FFFFF40000",
                   INITP_02 => X"F8C809FEFC64800206AAA809AA90C8C022600AB107FFFFFFFFFC0014A800031A",
                   INITP_03 => X"FFE0005414B80082C8013834662E325B944AA69578CB82955A6B21CD30C803FD",
                   INITP_04 => X"FFFFFFFFFFFFFFF901FFC0060001007C404C60C31306034021000853FFFFFFFF",
                   INITP_05 => X"FF0FFFB17D3FDA11420CCD6FE49F3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_06 => X"000000000000000000000000000000006D800100AB00BFF4F6002203CE032101",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a_ll(31 downto 0),
                  DOPA => data_out_a_ll(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b_ll(31 downto 0),
                  DOPB => data_out_b_ll(35 downto 32), 
                   DIB => data_in_b_ll(31 downto 0),
                  DIPB => data_in_b_ll(35 downto 32), 
                   WEB => we_b_l(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
      -- 
      kcpsm6_rom_lh: RAMB16BWER
      generic map ( DATA_WIDTH_A => 9,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 9,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"000028684828684828684828684828684828684810C868481088684813000000",
                    INIT_01 => X"08D0E888D0C8D0E888D0C8D0E8D0C828A0082800A00881F00000A1A1A1A101F0",
                    INIT_02 => X"000868000828680069000028C890F0E8881800C990F0E989A1A1A1A1012828A0",
                    INIT_03 => X"28000000000028000000000000286F2F0F28109D8D680090E825286808002868",
                    INIT_04 => X"6F2F28006F1F286F00100028000000000028B0CE000E10C8A600001000B0670E",
                    INIT_05 => X"080828B0CE0E280000000000280000A76E4E00000000286F2F286F1F28906E4E",
                    INIT_06 => X"6808F0EA5A90E95928787808280000680069000008000D0D5858000808080808",
                    INIT_07 => X"01000000A70F00000101000000070000A70F000010CAA290EA0ACA5A6808105A",
                    INIT_08 => X"08080808080808080808080828B0EB8B007B0B7B0B2800000000000000020000",
                    INIT_09 => X"00000F8B000F8B000F0B680828685810000D0D00000808080808080808080808",
                    INIT_0A => X"0F00000F0000A700002800000F000F000F68082800005700000F0000A7000028",
                    INIT_0B => X"070000070000275B0F0000A70F0000A0A1A0A1A0A1A0A1508851086808280000",
                    INIT_0C => X"005F0000A75F000068582800109D8D00109D8D680090E890E8250D0D28000000",
                    INIT_0D => X"5828000048286858280000000000000002000001000000A75F00006858280000",
                    INIT_0E => X"085788568856885508B1E05A5828778876887688750857C856C856C855880878",
                    INIT_0F => X"08B80101010101010101010101010101010109080101010154C854C853C85388",
                    INIT_10 => X"A7A7A6A6A528B868081108B1E84800B828012222190118000A2800B0CAB86800",
                    INIT_11 => X"080808080808080808080808080828B1C80828011A6A2A016A28A5A4A4A3A328",
                    INIT_12 => X"5A2800000D0D0808080808080808080808080808080808080808080808080808",
                    INIT_13 => X"00508A0050010A5A28718A7121A2A2A2A2528AA1A1A1A1A1A1A1A151090A010A",
                    INIT_14 => X"A3A3A3A3A3A3A3A3538A53B4B40B0A010A0C0C0F0E2811CA8A8A88EA28006900",
                    INIT_15 => X"01010128010A0B0C0C07060EA3A3A3A3A3A3A3A3538A53B1EA8AB8010AB8B7B6",
                    INIT_16 => X"04010101010C0C0B010A0C0C0F0E28B1CA010101010101010101010101090801",
                    INIT_17 => X"010101010C0C0E010A0C0C0F0E110A00B1EB8B00748B7401010101010101010C",
                    INIT_18 => X"28010A0C0C0F28A4A24A010A11B1CE0000006900000001010101010101010C04",
                    INIT_19 => X"B8B6B756CF57CF01528F0F0909010A0C0C0F0E28000050830B5A2873830B5B5A",
                    INIT_1A => X"A5A454CF26A5A555CF0627A5A4A5A454CF27A5A5A555CF57CFB8010A0B0B0C0C",
                    INIT_1B => X"C9B8010AB891E9B757CFB8010AB8B5B6B6B725A555CF0526A4A555CF0626A5A4",
                    INIT_1C => X"74CC01C00801010C0B740108018C0C0C01010A0C0C0F0E28010A0C0C1109B1E9",
                    INIT_1D => X"259D850D0D0E0E0E0E0E0E0E0E0E0E1188CE010111C8A488E828110909B1EBCB",
                    INIT_1E => X"0228001100B1E818890091E96800690000506808006808006800690000000928",
                    INIT_1F => X"0808080808080808080808280028685828680828680828020302815859D1E858",
                    INIT_20 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_21 => X"000D0D006808006800690000006808006808001288685000F2E05908000D0D08",
                    INIT_22 => X"5A000D0D0012896800690000508008680800680800F2E1095A68006900005800",
                    INIT_23 => X"00680069000000000D0D00F2E1095A0012896800690000508008680800F2E109",
                    INIT_24 => X"0000482868286808682858280012CB680069000050D2E38B038AA2A289026808",
                    INIT_25 => X"0069000008000D0D080808080808080808081200004800480048004888EA4A28",
                    INIT_26 => X"0808080808080808080808080808080808080808080808080808080808280068",
                    INIT_27 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_28 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_29 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2A => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2B => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2C => X"25129D8D89B2E050F2E15892E892E825090D0D08080808080808080808080808",
                    INIT_2D => X"E15878082800020028000021259D8D01259D8D030212099D8D129D8D92E892E8",
                    INIT_2E => X"50C88858011289F2005092E101D2E15889017180087892E88858C9F2008950F2",
                    INIT_2F => X"08080808080808082800000D0D080808080808080808080808281271C88858C1",
                    INIT_30 => X"A30383538008528008F3E2580AD3E08870080889092800680069000000000D0D",
                    INIT_31 => X"E878885870885848002813700050B3E38B138B7000CB508B51D3E3D3CB8A8BA3",
                    INIT_32 => X"E893E893E893E850C85813000000000D0D000808080808080808080813C203F3",
                    INIT_33 => X"58680800680800680800D3C85828A00878C8580028A008680028A00878C858F3",
                    INIT_34 => X"00000000000000000000000000000000000000000000000028A00878C85878C8",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"73FB390AA4EFF4FFF3FE3F6CBAFFEB7CFFFE6777B7F60C064A552181A4924CCF",
                   INITP_01 => X"7FFFCF000046A80176EB6E77B3B99D4F6C6600176DF55DB7C92D9FFFFFFCD75B",
                   INITP_02 => X"F1059BFE78837FF9F80001340001062F94D0000273FFFFFFFFFF35C10753C077",
                   INITP_03 => X"FFFEDBC4FC2FADF987FFB964A668C18A6C3400000000006081041C30C22DBBFC",
                   INITP_04 => X"FFFFFFFFFFFFFFFFF4FFFAA9DE9DF402FD31BE2C4DF16C7D9BF5B589FFFFFFFF",
                   INITP_05 => X"FFE7FFF005A426192FF89C4AC4951FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_06 => X"000000000000000000000000000000925B6499C9543E7FFF48FA5850004487F4",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a_lh(31 downto 0),
                  DOPA => data_out_a_lh(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b_lh(31 downto 0),
                  DOPB => data_out_b_lh(35 downto 32), 
                   DIB => data_in_b_lh(31 downto 0),
                  DIPB => data_in_b_lh(35 downto 32), 
                   WEB => we_b_l(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
      --
      kcpsm6_rom_hl: RAMB16BWER
      generic map ( DATA_WIDTH_A => 9,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 9,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_10 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_11 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_12 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_13 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_14 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_15 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_16 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_17 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_18 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_19 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a_hl(31 downto 0),
                  DOPA => data_out_a_hl(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b_hl(31 downto 0),
                  DOPB => data_out_b_hl(35 downto 32), 
                   DIB => data_in_b_hl(31 downto 0),
                  DIPB => data_in_b_hl(35 downto 32), 
                   WEB => we_b_h(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
      -- 
      kcpsm6_rom_hh: RAMB16BWER
      generic map ( DATA_WIDTH_A => 9,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 9,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_10 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_11 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_12 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_13 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_14 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_15 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_16 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_17 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_18 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_19 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a_hh(31 downto 0),
                  DOPA => data_out_a_hh(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b_hh(31 downto 0),
                  DOPB => data_out_b_hh(35 downto 32), 
                   DIB => data_in_b_hh(31 downto 0),
                  DIPB => data_in_b_hh(35 downto 32), 
                   WEB => we_b_h(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
    --
    end generate s6;
    --
    --
    v6 : if (C_FAMILY = "V6") generate
      --
      address_a <= '1' & address(11 downto 0) & "111";
      instruction <= data_out_a_h(32) & data_out_a_h(7 downto 0) & data_out_a_l(32) & data_out_a_l(7 downto 0);
      data_in_a <= "000000000000000000000000000000000000";
      jtag_dout <= data_out_b_h(32) & data_out_b_h(7 downto 0) & data_out_b_l(32) & data_out_b_l(7 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b_l <= "000" & data_out_b_l(32) & "000000000000000000000000" & data_out_b_l(7 downto 0);
        data_in_b_h <= "000" & data_out_b_h(32) & "000000000000000000000000" & data_out_b_h(7 downto 0);
        address_b <= "1111111111111111";
        we_b <= "00000000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b_h <= "000" & jtag_din(17) & "000000000000000000000000" & jtag_din(16 downto 9);
        data_in_b_l <= "000" & jtag_din(8) & "000000000000000000000000" & jtag_din(7 downto 0);
        address_b <= '1' & jtag_addr(11 downto 0) & "111";
        we_b <= jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom_l: RAMB36E1
      generic map ( READ_WIDTH_A => 9,
                    WRITE_WIDTH_A => 9,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 9,
                    WRITE_WIDTH_B => 9,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "VIRTEX6",
                    INIT_00 => X"31200002000010000004000020000001000008000800080004000400374D6FC5",
                    INIT_01 => X"0042100A3F2A42100A3F11420A3F30000E0000300E01002E311006060606002E",
                    INIT_02 => X"040A01040D0001040104430007545441370F00074D4D41370E0E0E0E0000000E",
                    INIT_03 => X"00A7B59EB4A4009AB5A4B49EA7000402010066000101046E00A000013E040001",
                    INIT_04 => X"040100B404FE0001AA90A7009AB59EB4A4008B01AA0881000E90A786A485D080",
                    INIT_05 => X"4C4300BB010100BABABABABA009AB7000202B79EB4A70004020004FD00A00102",
                    INIT_06 => X"0500E2042C0B00230023200000625B01040104430166BE000131D4003A562049",
                    INIT_07 => X"E08A97800728736F2F2F7A97805097800628736FE80106EC0010042C0501E62C",
                    INIT_08 => X"742064656C69616620433249000E0801D82C002301005B554055307A95E08A8F",
                    INIT_09 => X"7A41210141230141272C050200092C5B6614015B6F0021646E6F70736572206F",
                    INIT_0A => X"00978000978006736F007A572157235727050200978060978009978006736F00",
                    INIT_0B => X"209780109780602C3097800673736F0006000600060006000100300502009780",
                    INIT_0C => X"803497800630736F052C005B8600035B860001010494FF9000A0C304007A9780",
                    INIT_0D => X"28005B550600062C005B554055307A95E08A8FE08A97800730736F052C007A97",
                    INIT_0E => X"2C00010001000100415A50284000100110011001104100010001000100032C40",
                    INIT_0F => X"2001211B1007211B1007211B1007211B100700002121211B0001000100010003",
                    INIT_10 => X"000808080E00000130183117010604010027201004A001F000005BEE01000104",
                    INIT_11 => X"646E6120534D54203A524F525245002F0119002E0D06022E0600000808080E00",
                    INIT_12 => X"2C005B66320200686374616D20746F6E206F6420736874676E656C204F445420",
                    INIT_13 => X"435001555084452C005001504006060606400100060006000600064000308445",
                    INIT_14 => X"080E080E080E080E40014060600045BD040626000300840101010000005B0104",
                    INIT_15 => X"21211B00BD06FFF8007060FF080F080F080F080F40014092610100BD03017060",
                    INIT_16 => X"8014141414000045BD040626000300C301211B07211B07211B07211B07000021",
                    INIT_17 => X"14141414000006BD040626400192455BD963015B600160141414141414141400",
                    INIT_18 => X"00BD02FFFF0000080E0627001AFA015B55900104438014141414141414140080",
                    INIT_19 => X"01D0E0F001F00127F00A630002BD0406262001005B557050632C00705063302C",
                    INIT_1A => X"080EF001A00606F00190A000060006F001A0060606F001F00100BD0400000000",
                    INIT_1B => X"0100BD02018401E0F00100BD0701B0C0D0E0A006F00190A00006F00190A0080E",
                    INIT_1C => X"9001A7C008BBAC000990A707140A630027BD040626200100BD04FF8035013500",
                    INIT_1D => X"A00060B10308080303040403080308AD000114BBA7010E00000035020098FF01",
                    INIT_1E => X"21005BC25BCE03030130DDFF010401044330012004013A040104010443300000",
                    INIT_1F => X"6F5700203A72656666754200C5000A2C0003000003FF00210BBC102B27E90423",
                    INIT_20 => X"2064726F5700202020203A73657A69732064726F5700203A746E756F63206472",
                    INIT_21 => X"66FE035B01290401040104432001280401200426010110042D20200066F50300",
                    INIT_22 => X"23660B045B490101040104431030240140040120045B40002301040104432304",
                    INIT_23 => X"04010401044330661B045B934000235B61010104010443103028012004704000",
                    INIT_24 => X"5B5505000800070007102C005B8901010401044360735003502C060601300120",
                    INIT_25 => X"040104430166AE0400203A6E6F6973726556A15B550755075507550700010500",
                    INIT_26 => X"F303007465736572C10300706D75646D656DDF030067726169746C756D005B01",
                    INIT_27 => X"006E6F5F7265776F70840100706C6568210400737973B804006E6F6973726576",
                    INIT_28 => X"01007769BB0100726AB80100776AD8000061ED030066666F5F7265776F70EA03",
                    INIT_29 => X"0075746A78020072746A5F020077746AD301006D6ABF0100646AA30100726996",
                    INIT_2A => X"0072749B04007A749D040066749504006374F3020073746AD2020067746A8B02",
                    INIT_2B => X"70310100707389030067616A2D030075616A26030072616A20030077616AA104",
                    INIT_2C => X"A0900001019F10209F0020B8FFAB00A000C304FF6301006434010070F0030063",
                    INIT_2D => X"102023000062F3D40062D410A0000110A000010BBC900000039F0001A700B8FF",
                    INIT_2E => X"1001242320D401DB3120DB2010D41020082010002323E605012301BE310120E6",
                    INIT_2F => X"00203A726F727245005B66E70500646E616D6D6F632064614200BE0001282300",
                    INIT_30 => X"064050104028004024360023000E200110002C0438005B01040104432066F805",
                    INIT_31 => X"20200120100020010800147031601450012301701E016001602F501402012C06",
                    INIT_32 => X"2073086C0A6C0D0001203762D45B6644065B0021776F6C667265764F378D564E",
                    INIT_33 => X"20010804012004010804820220000C012001205B000C000104000C0020012067",
                    INIT_34 => X"000000000000000000000000000000000000000000000000000C002001202001",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_40 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_41 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_42 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"800002400701011FC00001B0CC001481000394D96A09E0000000023E00000004",
                   INITP_01 => X"800010881111DC8980001000000CD7D00001550000150000490027FFFFF40000",
                   INITP_02 => X"F8C809FEFC64800206AAA809AA90C8C022600AB107FFFFFFFFFC0014A800031A",
                   INITP_03 => X"FFE0005414B80082C8013834662E325B944AA69578CB82955A6B21CD30C803FD",
                   INITP_04 => X"FFFFFFFFFFFFFFF901FFC0060001007C404C60C31306034021000853FFFFFFFF",
                   INITP_05 => X"FF0FFFB17D3FDA11420CCD6FE49F3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_06 => X"000000000000000000000000000000006D800100AB00BFF4F6002203CE032101",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a_l(31 downto 0),
                      DOPADOP => data_out_a_l(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b_l(31 downto 0),
                      DOPBDOP => data_out_b_l(35 downto 32), 
                        DIBDI => data_in_b_l(31 downto 0),
                      DIPBDIP => data_in_b_l(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
      kcpsm6_rom_h: RAMB36E1
      generic map ( READ_WIDTH_A => 9,
                    WRITE_WIDTH_A => 9,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 9,
                    WRITE_WIDTH_B => 9,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "VIRTEX6",
                    INIT_00 => X"000028684828684828684828684828684828684810C868481088684813000000",
                    INIT_01 => X"08D0E888D0C8D0E888D0C8D0E8D0C828A0082800A00881F00000A1A1A1A101F0",
                    INIT_02 => X"000868000828680069000028C890F0E8881800C990F0E989A1A1A1A1012828A0",
                    INIT_03 => X"28000000000028000000000000286F2F0F28109D8D680090E825286808002868",
                    INIT_04 => X"6F2F28006F1F286F00100028000000000028B0CE000E10C8A600001000B0670E",
                    INIT_05 => X"080828B0CE0E280000000000280000A76E4E00000000286F2F286F1F28906E4E",
                    INIT_06 => X"6808F0EA5A90E95928787808280000680069000008000D0D5858000808080808",
                    INIT_07 => X"01000000A70F00000101000000070000A70F000010CAA290EA0ACA5A6808105A",
                    INIT_08 => X"08080808080808080808080828B0EB8B007B0B7B0B2800000000000000020000",
                    INIT_09 => X"00000F8B000F8B000F0B680828685810000D0D00000808080808080808080808",
                    INIT_0A => X"0F00000F0000A700002800000F000F000F68082800005700000F0000A7000028",
                    INIT_0B => X"070000070000275B0F0000A70F0000A0A1A0A1A0A1A0A1508851086808280000",
                    INIT_0C => X"005F0000A75F000068582800109D8D00109D8D680090E890E8250D0D28000000",
                    INIT_0D => X"5828000048286858280000000000000002000001000000A75F00006858280000",
                    INIT_0E => X"085788568856885508B1E05A5828778876887688750857C856C856C855880878",
                    INIT_0F => X"08B80101010101010101010101010101010109080101010154C854C853C85388",
                    INIT_10 => X"A7A7A6A6A528B868081108B1E84800B828012222190118000A2800B0CAB86800",
                    INIT_11 => X"080808080808080808080808080828B1C80828011A6A2A016A28A5A4A4A3A328",
                    INIT_12 => X"5A2800000D0D0808080808080808080808080808080808080808080808080808",
                    INIT_13 => X"00508A0050010A5A28718A7121A2A2A2A2528AA1A1A1A1A1A1A1A151090A010A",
                    INIT_14 => X"A3A3A3A3A3A3A3A3538A53B4B40B0A010A0C0C0F0E2811CA8A8A88EA28006900",
                    INIT_15 => X"01010128010A0B0C0C07060EA3A3A3A3A3A3A3A3538A53B1EA8AB8010AB8B7B6",
                    INIT_16 => X"04010101010C0C0B010A0C0C0F0E28B1CA010101010101010101010101090801",
                    INIT_17 => X"010101010C0C0E010A0C0C0F0E110A00B1EB8B00748B7401010101010101010C",
                    INIT_18 => X"28010A0C0C0F28A4A24A010A11B1CE0000006900000001010101010101010C04",
                    INIT_19 => X"B8B6B756CF57CF01528F0F0909010A0C0C0F0E28000050830B5A2873830B5B5A",
                    INIT_1A => X"A5A454CF26A5A555CF0627A5A4A5A454CF27A5A5A555CF57CFB8010A0B0B0C0C",
                    INIT_1B => X"C9B8010AB891E9B757CFB8010AB8B5B6B6B725A555CF0526A4A555CF0626A5A4",
                    INIT_1C => X"74CC01C00801010C0B740108018C0C0C01010A0C0C0F0E28010A0C0C1109B1E9",
                    INIT_1D => X"259D850D0D0E0E0E0E0E0E0E0E0E0E1188CE010111C8A488E828110909B1EBCB",
                    INIT_1E => X"0228001100B1E818890091E96800690000506808006808006800690000000928",
                    INIT_1F => X"0808080808080808080808280028685828680828680828020302815859D1E858",
                    INIT_20 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_21 => X"000D0D006808006800690000006808006808001288685000F2E05908000D0D08",
                    INIT_22 => X"5A000D0D0012896800690000508008680800680800F2E1095A68006900005800",
                    INIT_23 => X"00680069000000000D0D00F2E1095A0012896800690000508008680800F2E109",
                    INIT_24 => X"0000482868286808682858280012CB680069000050D2E38B038AA2A289026808",
                    INIT_25 => X"0069000008000D0D080808080808080808081200004800480048004888EA4A28",
                    INIT_26 => X"0808080808080808080808080808080808080808080808080808080808280068",
                    INIT_27 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_28 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_29 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2A => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2B => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2C => X"25129D8D89B2E050F2E15892E892E825090D0D08080808080808080808080808",
                    INIT_2D => X"E15878082800020028000021259D8D01259D8D030212099D8D129D8D92E892E8",
                    INIT_2E => X"50C88858011289F2005092E101D2E15889017180087892E88858C9F2008950F2",
                    INIT_2F => X"08080808080808082800000D0D080808080808080808080808281271C88858C1",
                    INIT_30 => X"A30383538008528008F3E2580AD3E08870080889092800680069000000000D0D",
                    INIT_31 => X"E878885870885848002813700050B3E38B138B7000CB508B51D3E3D3CB8A8BA3",
                    INIT_32 => X"E893E893E893E850C85813000000000D0D000808080808080808080813C203F3",
                    INIT_33 => X"58680800680800680800D3C85828A00878C8580028A008680028A00878C858F3",
                    INIT_34 => X"00000000000000000000000000000000000000000000000028A00878C85878C8",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_40 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_41 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_42 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"73FB390AA4EFF4FFF3FE3F6CBAFFEB7CFFFE6777B7F60C064A552181A4924CCF",
                   INITP_01 => X"7FFFCF000046A80176EB6E77B3B99D4F6C6600176DF55DB7C92D9FFFFFFCD75B",
                   INITP_02 => X"F1059BFE78837FF9F80001340001062F94D0000273FFFFFFFFFF35C10753C077",
                   INITP_03 => X"FFFEDBC4FC2FADF987FFB964A668C18A6C3400000000006081041C30C22DBBFC",
                   INITP_04 => X"FFFFFFFFFFFFFFFFF4FFFAA9DE9DF402FD31BE2C4DF16C7D9BF5B589FFFFFFFF",
                   INITP_05 => X"FFE7FFF005A426192FF89C4AC4951FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_06 => X"000000000000000000000000000000925B6499C9543E7FFF48FA5850004487F4",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a_h(31 downto 0),
                      DOPADOP => data_out_a_h(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b_h(31 downto 0),
                      DOPBDOP => data_out_b_h(35 downto 32), 
                        DIBDI => data_in_b_h(31 downto 0),
                      DIPBDIP => data_in_b_h(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
    end generate v6;
    --
    --
    akv7 : if (C_FAMILY = "7S") generate
      --
      address_a <= '1' & address(11 downto 0) & "111";
      instruction <= data_out_a_h(32) & data_out_a_h(7 downto 0) & data_out_a_l(32) & data_out_a_l(7 downto 0);
      data_in_a <= "000000000000000000000000000000000000";
      jtag_dout <= data_out_b_h(32) & data_out_b_h(7 downto 0) & data_out_b_l(32) & data_out_b_l(7 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b_l <= "000" & data_out_b_l(32) & "000000000000000000000000" & data_out_b_l(7 downto 0);
        data_in_b_h <= "000" & data_out_b_h(32) & "000000000000000000000000" & data_out_b_h(7 downto 0);
        address_b <= "1111111111111111";
        we_b <= "00000000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b_h <= "000" & jtag_din(17) & "000000000000000000000000" & jtag_din(16 downto 9);
        data_in_b_l <= "000" & jtag_din(8) & "000000000000000000000000" & jtag_din(7 downto 0);
        address_b <= '1' & jtag_addr(11 downto 0) & "111";
        we_b <= jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom_l: RAMB36E1
      generic map ( READ_WIDTH_A => 9,
                    WRITE_WIDTH_A => 9,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 9,
                    WRITE_WIDTH_B => 9,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "7SERIES",
                    INIT_00 => X"31200002000010000004000020000001000008000800080004000400374D6FC5",
                    INIT_01 => X"0042100A3F2A42100A3F11420A3F30000E0000300E01002E311006060606002E",
                    INIT_02 => X"040A01040D0001040104430007545441370F00074D4D41370E0E0E0E0000000E",
                    INIT_03 => X"00A7B59EB4A4009AB5A4B49EA7000402010066000101046E00A000013E040001",
                    INIT_04 => X"040100B404FE0001AA90A7009AB59EB4A4008B01AA0881000E90A786A485D080",
                    INIT_05 => X"4C4300BB010100BABABABABA009AB7000202B79EB4A70004020004FD00A00102",
                    INIT_06 => X"0500E2042C0B00230023200000625B01040104430166BE000131D4003A562049",
                    INIT_07 => X"E08A97800728736F2F2F7A97805097800628736FE80106EC0010042C0501E62C",
                    INIT_08 => X"742064656C69616620433249000E0801D82C002301005B554055307A95E08A8F",
                    INIT_09 => X"7A41210141230141272C050200092C5B6614015B6F0021646E6F70736572206F",
                    INIT_0A => X"00978000978006736F007A572157235727050200978060978009978006736F00",
                    INIT_0B => X"209780109780602C3097800673736F0006000600060006000100300502009780",
                    INIT_0C => X"803497800630736F052C005B8600035B860001010494FF9000A0C304007A9780",
                    INIT_0D => X"28005B550600062C005B554055307A95E08A8FE08A97800730736F052C007A97",
                    INIT_0E => X"2C00010001000100415A50284000100110011001104100010001000100032C40",
                    INIT_0F => X"2001211B1007211B1007211B1007211B100700002121211B0001000100010003",
                    INIT_10 => X"000808080E00000130183117010604010027201004A001F000005BEE01000104",
                    INIT_11 => X"646E6120534D54203A524F525245002F0119002E0D06022E0600000808080E00",
                    INIT_12 => X"2C005B66320200686374616D20746F6E206F6420736874676E656C204F445420",
                    INIT_13 => X"435001555084452C005001504006060606400100060006000600064000308445",
                    INIT_14 => X"080E080E080E080E40014060600045BD040626000300840101010000005B0104",
                    INIT_15 => X"21211B00BD06FFF8007060FF080F080F080F080F40014092610100BD03017060",
                    INIT_16 => X"8014141414000045BD040626000300C301211B07211B07211B07211B07000021",
                    INIT_17 => X"14141414000006BD040626400192455BD963015B600160141414141414141400",
                    INIT_18 => X"00BD02FFFF0000080E0627001AFA015B55900104438014141414141414140080",
                    INIT_19 => X"01D0E0F001F00127F00A630002BD0406262001005B557050632C00705063302C",
                    INIT_1A => X"080EF001A00606F00190A000060006F001A0060606F001F00100BD0400000000",
                    INIT_1B => X"0100BD02018401E0F00100BD0701B0C0D0E0A006F00190A00006F00190A0080E",
                    INIT_1C => X"9001A7C008BBAC000990A707140A630027BD040626200100BD04FF8035013500",
                    INIT_1D => X"A00060B10308080303040403080308AD000114BBA7010E00000035020098FF01",
                    INIT_1E => X"21005BC25BCE03030130DDFF010401044330012004013A040104010443300000",
                    INIT_1F => X"6F5700203A72656666754200C5000A2C0003000003FF00210BBC102B27E90423",
                    INIT_20 => X"2064726F5700202020203A73657A69732064726F5700203A746E756F63206472",
                    INIT_21 => X"66FE035B01290401040104432001280401200426010110042D20200066F50300",
                    INIT_22 => X"23660B045B490101040104431030240140040120045B40002301040104432304",
                    INIT_23 => X"04010401044330661B045B934000235B61010104010443103028012004704000",
                    INIT_24 => X"5B5505000800070007102C005B8901010401044360735003502C060601300120",
                    INIT_25 => X"040104430166AE0400203A6E6F6973726556A15B550755075507550700010500",
                    INIT_26 => X"F303007465736572C10300706D75646D656DDF030067726169746C756D005B01",
                    INIT_27 => X"006E6F5F7265776F70840100706C6568210400737973B804006E6F6973726576",
                    INIT_28 => X"01007769BB0100726AB80100776AD8000061ED030066666F5F7265776F70EA03",
                    INIT_29 => X"0075746A78020072746A5F020077746AD301006D6ABF0100646AA30100726996",
                    INIT_2A => X"0072749B04007A749D040066749504006374F3020073746AD2020067746A8B02",
                    INIT_2B => X"70310100707389030067616A2D030075616A26030072616A20030077616AA104",
                    INIT_2C => X"A0900001019F10209F0020B8FFAB00A000C304FF6301006434010070F0030063",
                    INIT_2D => X"102023000062F3D40062D410A0000110A000010BBC900000039F0001A700B8FF",
                    INIT_2E => X"1001242320D401DB3120DB2010D41020082010002323E605012301BE310120E6",
                    INIT_2F => X"00203A726F727245005B66E70500646E616D6D6F632064614200BE0001282300",
                    INIT_30 => X"064050104028004024360023000E200110002C0438005B01040104432066F805",
                    INIT_31 => X"20200120100020010800147031601450012301701E016001602F501402012C06",
                    INIT_32 => X"2073086C0A6C0D0001203762D45B6644065B0021776F6C667265764F378D564E",
                    INIT_33 => X"20010804012004010804820220000C012001205B000C000104000C0020012067",
                    INIT_34 => X"000000000000000000000000000000000000000000000000000C002001202001",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_40 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_41 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_42 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"800002400701011FC00001B0CC001481000394D96A09E0000000023E00000004",
                   INITP_01 => X"800010881111DC8980001000000CD7D00001550000150000490027FFFFF40000",
                   INITP_02 => X"F8C809FEFC64800206AAA809AA90C8C022600AB107FFFFFFFFFC0014A800031A",
                   INITP_03 => X"FFE0005414B80082C8013834662E325B944AA69578CB82955A6B21CD30C803FD",
                   INITP_04 => X"FFFFFFFFFFFFFFF901FFC0060001007C404C60C31306034021000853FFFFFFFF",
                   INITP_05 => X"FF0FFFB17D3FDA11420CCD6FE49F3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_06 => X"000000000000000000000000000000006D800100AB00BFF4F6002203CE032101",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a_l(31 downto 0),
                      DOPADOP => data_out_a_l(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b_l(31 downto 0),
                      DOPBDOP => data_out_b_l(35 downto 32), 
                        DIBDI => data_in_b_l(31 downto 0),
                      DIPBDIP => data_in_b_l(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
      kcpsm6_rom_h: RAMB36E1
      generic map ( READ_WIDTH_A => 9,
                    WRITE_WIDTH_A => 9,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 9,
                    WRITE_WIDTH_B => 9,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "7SERIES",
                    INIT_00 => X"000028684828684828684828684828684828684810C868481088684813000000",
                    INIT_01 => X"08D0E888D0C8D0E888D0C8D0E8D0C828A0082800A00881F00000A1A1A1A101F0",
                    INIT_02 => X"000868000828680069000028C890F0E8881800C990F0E989A1A1A1A1012828A0",
                    INIT_03 => X"28000000000028000000000000286F2F0F28109D8D680090E825286808002868",
                    INIT_04 => X"6F2F28006F1F286F00100028000000000028B0CE000E10C8A600001000B0670E",
                    INIT_05 => X"080828B0CE0E280000000000280000A76E4E00000000286F2F286F1F28906E4E",
                    INIT_06 => X"6808F0EA5A90E95928787808280000680069000008000D0D5858000808080808",
                    INIT_07 => X"01000000A70F00000101000000070000A70F000010CAA290EA0ACA5A6808105A",
                    INIT_08 => X"08080808080808080808080828B0EB8B007B0B7B0B2800000000000000020000",
                    INIT_09 => X"00000F8B000F8B000F0B680828685810000D0D00000808080808080808080808",
                    INIT_0A => X"0F00000F0000A700002800000F000F000F68082800005700000F0000A7000028",
                    INIT_0B => X"070000070000275B0F0000A70F0000A0A1A0A1A0A1A0A1508851086808280000",
                    INIT_0C => X"005F0000A75F000068582800109D8D00109D8D680090E890E8250D0D28000000",
                    INIT_0D => X"5828000048286858280000000000000002000001000000A75F00006858280000",
                    INIT_0E => X"085788568856885508B1E05A5828778876887688750857C856C856C855880878",
                    INIT_0F => X"08B80101010101010101010101010101010109080101010154C854C853C85388",
                    INIT_10 => X"A7A7A6A6A528B868081108B1E84800B828012222190118000A2800B0CAB86800",
                    INIT_11 => X"080808080808080808080808080828B1C80828011A6A2A016A28A5A4A4A3A328",
                    INIT_12 => X"5A2800000D0D0808080808080808080808080808080808080808080808080808",
                    INIT_13 => X"00508A0050010A5A28718A7121A2A2A2A2528AA1A1A1A1A1A1A1A151090A010A",
                    INIT_14 => X"A3A3A3A3A3A3A3A3538A53B4B40B0A010A0C0C0F0E2811CA8A8A88EA28006900",
                    INIT_15 => X"01010128010A0B0C0C07060EA3A3A3A3A3A3A3A3538A53B1EA8AB8010AB8B7B6",
                    INIT_16 => X"04010101010C0C0B010A0C0C0F0E28B1CA010101010101010101010101090801",
                    INIT_17 => X"010101010C0C0E010A0C0C0F0E110A00B1EB8B00748B7401010101010101010C",
                    INIT_18 => X"28010A0C0C0F28A4A24A010A11B1CE0000006900000001010101010101010C04",
                    INIT_19 => X"B8B6B756CF57CF01528F0F0909010A0C0C0F0E28000050830B5A2873830B5B5A",
                    INIT_1A => X"A5A454CF26A5A555CF0627A5A4A5A454CF27A5A5A555CF57CFB8010A0B0B0C0C",
                    INIT_1B => X"C9B8010AB891E9B757CFB8010AB8B5B6B6B725A555CF0526A4A555CF0626A5A4",
                    INIT_1C => X"74CC01C00801010C0B740108018C0C0C01010A0C0C0F0E28010A0C0C1109B1E9",
                    INIT_1D => X"259D850D0D0E0E0E0E0E0E0E0E0E0E1188CE010111C8A488E828110909B1EBCB",
                    INIT_1E => X"0228001100B1E818890091E96800690000506808006808006800690000000928",
                    INIT_1F => X"0808080808080808080808280028685828680828680828020302815859D1E858",
                    INIT_20 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_21 => X"000D0D006808006800690000006808006808001288685000F2E05908000D0D08",
                    INIT_22 => X"5A000D0D0012896800690000508008680800680800F2E1095A68006900005800",
                    INIT_23 => X"00680069000000000D0D00F2E1095A0012896800690000508008680800F2E109",
                    INIT_24 => X"0000482868286808682858280012CB680069000050D2E38B038AA2A289026808",
                    INIT_25 => X"0069000008000D0D080808080808080808081200004800480048004888EA4A28",
                    INIT_26 => X"0808080808080808080808080808080808080808080808080808080808280068",
                    INIT_27 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_28 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_29 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2A => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2B => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2C => X"25129D8D89B2E050F2E15892E892E825090D0D08080808080808080808080808",
                    INIT_2D => X"E15878082800020028000021259D8D01259D8D030212099D8D129D8D92E892E8",
                    INIT_2E => X"50C88858011289F2005092E101D2E15889017180087892E88858C9F2008950F2",
                    INIT_2F => X"08080808080808082800000D0D080808080808080808080808281271C88858C1",
                    INIT_30 => X"A30383538008528008F3E2580AD3E08870080889092800680069000000000D0D",
                    INIT_31 => X"E878885870885848002813700050B3E38B138B7000CB508B51D3E3D3CB8A8BA3",
                    INIT_32 => X"E893E893E893E850C85813000000000D0D000808080808080808080813C203F3",
                    INIT_33 => X"58680800680800680800D3C85828A00878C8580028A008680028A00878C858F3",
                    INIT_34 => X"00000000000000000000000000000000000000000000000028A00878C85878C8",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_40 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_41 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_42 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"73FB390AA4EFF4FFF3FE3F6CBAFFEB7CFFFE6777B7F60C064A552181A4924CCF",
                   INITP_01 => X"7FFFCF000046A80176EB6E77B3B99D4F6C6600176DF55DB7C92D9FFFFFFCD75B",
                   INITP_02 => X"F1059BFE78837FF9F80001340001062F94D0000273FFFFFFFFFF35C10753C077",
                   INITP_03 => X"FFFEDBC4FC2FADF987FFB964A668C18A6C3400000000006081041C30C22DBBFC",
                   INITP_04 => X"FFFFFFFFFFFFFFFFF4FFFAA9DE9DF402FD31BE2C4DF16C7D9BF5B589FFFFFFFF",
                   INITP_05 => X"FFE7FFF005A426192FF89C4AC4951FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_06 => X"000000000000000000000000000000925B6499C9543E7FFF48FA5850004487F4",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a_h(31 downto 0),
                      DOPADOP => data_out_a_h(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b_h(31 downto 0),
                      DOPBDOP => data_out_b_h(35 downto 32), 
                        DIBDI => data_in_b_h(31 downto 0),
                      DIPBDIP => data_in_b_h(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
    end generate akv7;
    --
  end generate ram_4k_generate;	              
  --
  --
  --
  --
  -- JTAG Loader
  --
  instantiate_loader : if (C_JTAG_LOADER_ENABLE = 1) generate
  --
    jtag_loader_6_inst : jtag_loader_6
    generic map(              C_FAMILY => C_FAMILY,
                       C_NUM_PICOBLAZE => 1,
                  C_JTAG_LOADER_ENABLE => C_JTAG_LOADER_ENABLE,
                 C_BRAM_MAX_ADDR_WIDTH => BRAM_ADDRESS_WIDTH,
	                  C_ADDR_WIDTH_0 => BRAM_ADDRESS_WIDTH)
    port map( picoblaze_reset => rdl_bus,
                      jtag_en => jtag_en,
                     jtag_din => jtag_din,
                    jtag_addr => jtag_addr(BRAM_ADDRESS_WIDTH-1 downto 0),
                     jtag_clk => jtag_clk,
                      jtag_we => jtag_we,
                  jtag_dout_0 => jtag_dout,
                  jtag_dout_1 => jtag_dout, -- ports 1-7 are not used
                  jtag_dout_2 => jtag_dout, -- in a 1 device debug 
                  jtag_dout_3 => jtag_dout, -- session.  However, Synplify
                  jtag_dout_4 => jtag_dout, -- etc require all ports to
                  jtag_dout_5 => jtag_dout, -- be connected
                  jtag_dout_6 => jtag_dout,
                  jtag_dout_7 => jtag_dout);
    --  
  end generate instantiate_loader;
  --
end low_level_definition;
--
--
-------------------------------------------------------------------------------------------
--
-- JTAG Loader 
--
-------------------------------------------------------------------------------------------
--
--
-- JTAG Loader 6 - Version 6.00
-- Kris Chaplin 4 February 2010
-- Ken Chapman 15 August 2011 - Revised coding style
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--
library unisim;
use unisim.vcomponents.all;
--
entity jtag_loader_6 is
generic(              C_JTAG_LOADER_ENABLE : integer := 1;
                                  C_FAMILY : string := "V6";
                           C_NUM_PICOBLAZE : integer := 1;
                     C_BRAM_MAX_ADDR_WIDTH : integer := 10;
        C_PICOBLAZE_INSTRUCTION_DATA_WIDTH : integer := 18;
                              C_JTAG_CHAIN : integer := 2;
                            C_ADDR_WIDTH_0 : integer := 10;
                            C_ADDR_WIDTH_1 : integer := 10;
                            C_ADDR_WIDTH_2 : integer := 10;
                            C_ADDR_WIDTH_3 : integer := 10;
                            C_ADDR_WIDTH_4 : integer := 10;
                            C_ADDR_WIDTH_5 : integer := 10;
                            C_ADDR_WIDTH_6 : integer := 10;
                            C_ADDR_WIDTH_7 : integer := 10);
port(   picoblaze_reset : out std_logic_vector(C_NUM_PICOBLAZE-1 downto 0);
                jtag_en : out std_logic_vector(C_NUM_PICOBLAZE-1 downto 0) := (others => '0');
               jtag_din : out std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0) := (others => '0');
              jtag_addr : out std_logic_vector(C_BRAM_MAX_ADDR_WIDTH-1 downto 0) := (others => '0');
               jtag_clk : out std_logic := '0';
                jtag_we : out std_logic := '0';
            jtag_dout_0 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_1 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_2 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_3 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_4 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_5 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_6 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_7 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0));
end jtag_loader_6;
--
architecture Behavioral of jtag_loader_6 is
  --
  signal num_picoblaze       : std_logic_vector(2 downto 0);
  signal picoblaze_instruction_data_width : std_logic_vector(4 downto 0);
  --
  signal drck                : std_logic;
  signal shift_clk           : std_logic;
  signal shift_din           : std_logic;
  signal shift_dout          : std_logic;
  signal shift               : std_logic;
  signal capture             : std_logic;
  --
  signal control_reg_ce      : std_logic;
  signal bram_ce             : std_logic_vector(C_NUM_PICOBLAZE-1 downto 0);
  signal bus_zero            : std_logic_vector(C_NUM_PICOBLAZE-1 downto 0) := (others => '0');
  signal jtag_en_int         : std_logic_vector(C_NUM_PICOBLAZE-1 downto 0);
  signal jtag_en_expanded    : std_logic_vector(7 downto 0) := (others => '0');
  signal jtag_addr_int       : std_logic_vector(C_BRAM_MAX_ADDR_WIDTH-1 downto 0);
  signal jtag_din_int        : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal control_din         : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0):= (others => '0');
  signal control_dout        : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0):= (others => '0');
  signal control_dout_int    : std_logic_vector(7 downto 0):= (others => '0');
  signal bram_dout_int       : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0) := (others => '0');
  signal jtag_we_int         : std_logic;
  signal jtag_clk_int        : std_logic;
  signal bram_ce_valid       : std_logic;
  signal din_load            : std_logic;
  --
  signal jtag_dout_0_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_1_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_2_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_3_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_4_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_5_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_6_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_7_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal picoblaze_reset_int : std_logic_vector(C_NUM_PICOBLAZE-1 downto 0) := (others => '0');
  --        
begin
  bus_zero <= (others => '0');
  --
  jtag_loader_gen: if (C_JTAG_LOADER_ENABLE = 1) generate
    --
    -- Insert BSCAN primitive for target device architecture.
    --
    BSCAN_SPARTAN6_gen: if (C_FAMILY="S6") generate
    begin
      BSCAN_BLOCK_inst : BSCAN_SPARTAN6
      generic map ( JTAG_CHAIN => C_JTAG_CHAIN)
      port map( CAPTURE => capture,
                   DRCK => drck,
                  RESET => open,
                RUNTEST => open,
                    SEL => bram_ce_valid,
                  SHIFT => shift,
                    TCK => open,
                    TDI => shift_din,
                    TMS => open,
                 UPDATE => jtag_clk_int,
                    TDO => shift_dout);
    end generate BSCAN_SPARTAN6_gen;   
    --
    BSCAN_VIRTEX6_gen: if (C_FAMILY="V6") generate
    begin
      BSCAN_BLOCK_inst: BSCAN_VIRTEX6
      generic map(    JTAG_CHAIN => C_JTAG_CHAIN,
                    DISABLE_JTAG => FALSE)
      port map( CAPTURE => capture,
                   DRCK => drck,
                  RESET => open,
                RUNTEST => open,
                    SEL => bram_ce_valid,
                  SHIFT => shift,
                    TCK => open,
                    TDI => shift_din,
                    TMS => open,
                 UPDATE => jtag_clk_int,
                    TDO => shift_dout);
    end generate BSCAN_VIRTEX6_gen;   
    --
    BSCAN_7SERIES_gen: if (C_FAMILY="7S") generate
    begin
      BSCAN_BLOCK_inst: BSCANE2
      generic map(    JTAG_CHAIN => C_JTAG_CHAIN,
                    DISABLE_JTAG => "FALSE")
      port map( CAPTURE => capture,
                   DRCK => drck,
                  RESET => open,
                RUNTEST => open,
                    SEL => bram_ce_valid,
                  SHIFT => shift,
                    TCK => open,
                    TDI => shift_din,
                    TMS => open,
                 UPDATE => jtag_clk_int,
                    TDO => shift_dout);
    end generate BSCAN_7SERIES_gen;   
    --
    --
    -- Insert clock buffer to ensure reliable shift operations.
    --
    upload_clock: BUFG
    port map( I => drck,
              O => shift_clk);
    --        
    --        
    --  Shift Register      
    --        
    --
    control_reg_ce_shift: process (shift_clk)
    begin
      if shift_clk'event and shift_clk = '1' then
        if (shift = '1') then
          control_reg_ce <= shift_din;
        end if;
      end if;
    end process control_reg_ce_shift;
    --        
    bram_ce_shift: process (shift_clk)
    begin
      if shift_clk'event and shift_clk='1' then  
        if (shift = '1') then
          if(C_NUM_PICOBLAZE > 1) then
            for i in 0 to C_NUM_PICOBLAZE-2 loop
              bram_ce(i+1) <= bram_ce(i);
            end loop;
          end if;
          bram_ce(0) <= control_reg_ce;
        end if;
      end if;
    end process bram_ce_shift;
    --        
    bram_we_shift: process (shift_clk)
    begin
      if shift_clk'event and shift_clk='1' then  
        if (shift = '1') then
          jtag_we_int <= bram_ce(C_NUM_PICOBLAZE-1);
        end if;
      end if;
    end process bram_we_shift;
    --        
    bram_a_shift: process (shift_clk)
    begin
      if shift_clk'event and shift_clk='1' then  
        if (shift = '1') then
          for i in 0 to C_BRAM_MAX_ADDR_WIDTH-2 loop
            jtag_addr_int(i+1) <= jtag_addr_int(i);
          end loop;
          jtag_addr_int(0) <= jtag_we_int;
        end if;
      end if;
    end process bram_a_shift;
    --        
    bram_d_shift: process (shift_clk)
    begin
      if shift_clk'event and shift_clk='1' then  
        if (din_load = '1') then
          jtag_din_int <= bram_dout_int;
         elsif (shift = '1') then
          for i in 0 to C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-2 loop
            jtag_din_int(i+1) <= jtag_din_int(i);
          end loop;
          jtag_din_int(0) <= jtag_addr_int(C_BRAM_MAX_ADDR_WIDTH-1);
        end if;
      end if;
    end process bram_d_shift;
    --
    shift_dout <= jtag_din_int(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1);
    --
    --
    din_load_select:process (bram_ce, din_load, capture, bus_zero, control_reg_ce) 
    begin
      if ( bram_ce = bus_zero ) then
        din_load <= capture and control_reg_ce;
       else
        din_load <= capture;
      end if;
    end process din_load_select;
    --
    --
    -- Control Registers 
    --
    num_picoblaze <= conv_std_logic_vector(C_NUM_PICOBLAZE-1,3);
    picoblaze_instruction_data_width <= conv_std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1,5);
    --	
    control_registers: process(jtag_clk_int) 
    begin
      if (jtag_clk_int'event and jtag_clk_int = '1') then
        if (bram_ce_valid = '1') and (jtag_we_int = '0') and (control_reg_ce = '1') then
          case (jtag_addr_int(3 downto 0)) is 
            when "0000" => -- 0 = version - returns (7 downto 4) illustrating number of PB
                           --               and (3 downto 0) picoblaze instruction data width
                           control_dout_int <= num_picoblaze & picoblaze_instruction_data_width;
            when "0001" => -- 1 = PicoBlaze 0 reset / status
                           if (C_NUM_PICOBLAZE >= 1) then 
                            control_dout_int <= picoblaze_reset_int(0) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_0-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "0010" => -- 2 = PicoBlaze 1 reset / status
                           if (C_NUM_PICOBLAZE >= 2) then 
                             control_dout_int <= picoblaze_reset_int(1) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_1-1,5) );
                            else 
                             control_dout_int <= (others => '0');
                           end if;
            when "0011" => -- 3 = PicoBlaze 2 reset / status
                           if (C_NUM_PICOBLAZE >= 3) then 
                            control_dout_int <= picoblaze_reset_int(2) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_2-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "0100" => -- 4 = PicoBlaze 3 reset / status
                           if (C_NUM_PICOBLAZE >= 4) then 
                            control_dout_int <= picoblaze_reset_int(3) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_3-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "0101" => -- 5 = PicoBlaze 4 reset / status
                           if (C_NUM_PICOBLAZE >= 5) then 
                            control_dout_int <= picoblaze_reset_int(4) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_4-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "0110" => -- 6 = PicoBlaze 5 reset / status
                           if (C_NUM_PICOBLAZE >= 6) then 
                            control_dout_int <= picoblaze_reset_int(5) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_5-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "0111" => -- 7 = PicoBlaze 6 reset / status
                           if (C_NUM_PICOBLAZE >= 7) then 
                            control_dout_int <= picoblaze_reset_int(6) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_6-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "1000" => -- 8 = PicoBlaze 7 reset / status
                           if (C_NUM_PICOBLAZE >= 8) then 
                            control_dout_int <= picoblaze_reset_int(7) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_7-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "1111" => control_dout_int <= conv_std_logic_vector(C_BRAM_MAX_ADDR_WIDTH -1,8);
            when others => control_dout_int <= (others => '1');
          end case;
        else 
          control_dout_int <= (others => '0');
        end if;
      end if;
    end process control_registers;
    -- 
    control_dout(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-8) <= control_dout_int;
    --
    pb_reset: process(jtag_clk_int) 
    begin
      if (jtag_clk_int'event and jtag_clk_int = '1') then
        if (bram_ce_valid = '1') and (jtag_we_int = '1') and (control_reg_ce = '1') then
          picoblaze_reset_int(C_NUM_PICOBLAZE-1 downto 0) <= control_din(C_NUM_PICOBLAZE-1 downto 0);
        end if;
      end if;
    end process pb_reset;    
    --
    --
    -- Assignments 
    --
    control_dout (C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-9 downto 0) <= (others => '0') when (C_PICOBLAZE_INSTRUCTION_DATA_WIDTH > 8);
    --
    -- Qualify the blockram CS signal with bscan select output
    jtag_en_int <= bram_ce when bram_ce_valid = '1' else (others => '0');
    --      
    jtag_en_expanded(C_NUM_PICOBLAZE-1 downto 0) <= jtag_en_int;
    jtag_en_expanded(7 downto C_NUM_PICOBLAZE) <= (others => '0') when (C_NUM_PICOBLAZE < 8);
    --        
    bram_dout_int <= control_dout or jtag_dout_0_masked or jtag_dout_1_masked or jtag_dout_2_masked or jtag_dout_3_masked or jtag_dout_4_masked or jtag_dout_5_masked or jtag_dout_6_masked or jtag_dout_7_masked;
    --
    control_din <= jtag_din_int;
    --        
    jtag_dout_0_masked <= jtag_dout_0 when jtag_en_expanded(0) = '1' else (others => '0');
    jtag_dout_1_masked <= jtag_dout_1 when jtag_en_expanded(1) = '1' else (others => '0');
    jtag_dout_2_masked <= jtag_dout_2 when jtag_en_expanded(2) = '1' else (others => '0');
    jtag_dout_3_masked <= jtag_dout_3 when jtag_en_expanded(3) = '1' else (others => '0');
    jtag_dout_4_masked <= jtag_dout_4 when jtag_en_expanded(4) = '1' else (others => '0');
    jtag_dout_5_masked <= jtag_dout_5 when jtag_en_expanded(5) = '1' else (others => '0');
    jtag_dout_6_masked <= jtag_dout_6 when jtag_en_expanded(6) = '1' else (others => '0');
    jtag_dout_7_masked <= jtag_dout_7 when jtag_en_expanded(7) = '1' else (others => '0');
    --
    jtag_en <= jtag_en_int;
    jtag_din <= jtag_din_int;
    jtag_addr <= jtag_addr_int;
    jtag_clk <= jtag_clk_int;
    jtag_we <= jtag_we_int;
    picoblaze_reset <= picoblaze_reset_int;
    --        
  end generate jtag_loader_gen;
--
end Behavioral;
--
--
------------------------------------------------------------------------------------
--
-- END OF FILE cli.vhd
--
------------------------------------------------------------------------------------
