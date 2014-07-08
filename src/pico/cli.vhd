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
-- Generated by KCPSM6 Assembler: 08 Jul 2014 - 12:46:59. 
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
                    INIT_00 => X"D0089000200A9000D008900020061000D00490002653D00B109B014F007100C7",
                    INIT_01 => X"5000D00290005000D01090005000D00490005000D02090005000D00190005000",
                    INIT_02 => X"50000030400E10010300E0300033001043064306430643060300E03000330020",
                    INIT_03 => X"D010100AA041902AA044D010100AA0419011A044D00AA04190305000400E1000",
                    INIT_04 => X"01009207204FE04FD2411237420E420E420E420E020050005000400E1000A044",
                    INIT_05 => X"D1010006110D5000D1010006D20100060045500091072056E056D1411137310F",
                    INIT_06 => X"20683B001A01D10100062070D1004BA05000D101113E00065000D1010006110A",
                    INIT_07 => X"00B700A000B600A65000009C00B700A600B600A000A95000DF045F021F015000",
                    INIT_08 => X"608D9D0100AC1D08208390004D0E009200A9208800A66087CED01D80500000A9",
                    INIT_09 => X"500000B6DF043FFE5000DE0100AC209200A95000009C00B700A000B600A65000",
                    INIT_0A => X"00B900A000B600A95000DF045F025000DF043FFD500020A2DC019C02DF045F01",
                    INIT_0B => X"500060BD9C011C01500000BC00BC00BC00BC00BC5000009C00B94E00DC029C02",
                    INIT_0C => X"00060045100100681AC01B00B001B03100D61100113A115611201149114C1143",
                    INIT_0D => X"E0E4D404B42C210DD300B3235000F023F020100050000064005DD1010006D201",
                    INIT_0E => X"0075007120EA9401450620EED40015109404B42CD005100120E8B42CD0051000",
                    INIT_0F => X"009900824E071E280075007102310231007C009900820E50009900824E061E28",
                    INIT_10 => X"1600F62316015000005D0057004000570030007C009704E0008C009103E0008C",
                    INIT_11 => X"11641165116C116911611166112011431132114950006110D608160100DAF62C",
                    INIT_12 => X"1B01005D0071110011211164116E116F11701173116511721120116F11741120",
                    INIT_13 => X"1E27160101431E23160101431E21162CD00510025000D009B02C205D00681A16",
                    INIT_14 => X"1002500000990082AE60009900821E09009900824E06007500715000007C0143",
                    INIT_15 => X"00821E00009900824E06007500715000007C01591E2101591E2301591E27D005",
                    INIT_16 => X"42064100420641004206A1001001A2001030D00510025000009900821E000099",
                    INIT_17 => X"00820E10009900824E60B62C1E30009900824E061E7300750071410042064100",
                    INIT_18 => X"1A01D10100062196D1FF2192D1004BA01AD81B045000007C009900820E200099",
                    INIT_19 => X"009900824E06BE3000750071D005B02C5000005D21883B001A03005D21883B00",
                    INIT_1A => X"009103E0008C009900824E07BE3000750071D005B02C5000007C00990082BE34",
                    INIT_1B => X"005D005790065000D006B02C5000005D0057004000570030007C009704E0008C",
                    INIT_1C => X"EC101101EB101141AE009001AD009001AC009001AB001003102CF140B1285000",
                    INIT_1D => X"1001AD001001AC001001AB001041625CC050B528B0405000EE101101ED101101",
                    INIT_1E => X"12001100022302230223021DA9009001A8009001A7009001A6001003102CAE00",
                    INIT_1F => X"0223021D021202090223021D021202090223021D021202090223021D02120209",
                    INIT_20 => X"44204410320402A0310101F014005000005D61F095017000D101000611207001",
                    INIT_21 => X"4D084C084B0E50007000D0011030221A10316219D00190060006700150000229",
                    INIT_22 => X"50000230340DD40654020230D40650004A00490848084708460E50004F004E08",
                    INIT_23 => X"116111201153114D11541120113A1152114F1152115211455000623190011019",
                    INIT_24 => X"116411201173116811741167116E1165116C1120114F1144115411201164116E",
                    INIT_25 => X"005D00681A341B0211001168116311741161116D11201174116F116E1120116F",
                    INIT_26 => X"140142004306420043064200430642004306A3401200143002861545B42C5000",
                    INIT_27 => X"15010057A05002861545B42C5000E3501501E25042404406440644064406A440",
                    INIT_28 => X"18261E001D03500022869401150115011000D4005000005DD20100060045A050",
                    INIT_29 => X"4708460E4708460E4708460EA7401401A640696068601600144502BF15041906",
                    INIT_2A => X"4708460FA7401401A6406294D4611401700002BF150370016E706D604708460E",
                    INIT_2B => X"021D500002BF150617FF18F819000E700D601CFF4708460F4708460F4708460F",
                    INIT_2C => X"021D02090223021D02090223021D02090223021D020912001100022302230223",
                    INIT_2D => X"03140314031419001800164502BF1504190618261E001D03500062C595010223",
                    INIT_2E => X"D6631601E9601601E86003140314031403140314031403140314180009800314",
                    INIT_2F => X"0314031403140314190018001C0602BF1504190618261E401D012294144562DB",
                    INIT_30 => X"00570090D2010006004500800314031403140314031403140314031418000980",
                    INIT_31 => X"500002BF150219FF18FF1E0050004808450E950602291400231A62FA9C01005D",
                    INIT_32 => X"18261E201D015000005D0057A07007501763B52C5000E67007501763B630B52C",
                    INIT_33 => X"70016DD06EE0ADF09F01AEF09F010229A4F01F0A1F631200130202BF15041906",
                    INIT_34 => X"9F014EA04A064A064A06AAF09F01AEF09F01700002BF15041600170018001900",
                    INIT_35 => X"1A00A9F09F014DA04A064A06AAF09F010D904EA04A08490E4A08490E1A00A9F0",
                    INIT_36 => X"4A06AAF09F010B904CA049004A061900AAF09F010C904DA04A08490E4A08490E",
                    INIT_37 => X"150270012387D2016EE0AEF09F01700002BF150770016BB06CC06DD06EE04BA0",
                    INIT_38 => X"190618261E201D01500002BF150418FF1980233512016335D3009301700002BF",
                    INIT_39 => X"80C0100803BE03AF18001609E89003AA10070314190A19631800022902BF1504",
                    INIT_3A => X"03BE23AA9001480E1000D0005000233513021200639BD6FF9601E890990103AA",
                    INIT_3B => X"1AB41B031C081C081C031C031C041C041C031C081C031C0823B010009C010314",
                    INIT_3C => X"10200006D001103A0006D1010006D201000600450030130050004BA03B000A60",
                    INIT_3D => X"23C5005D63D1D00330031301003023E0D3FFD1010006D20100060045A030D001",
                    INIT_3E => X"5000D00310FF50000424062705D80210B12BB227A3ECD004B02304245000005D",
                    INIT_3F => X"1120113A117211651166116611751142500000C75000D00BB02C5000D0031000",
                   INITP_00 => X"AAAAAA8296B6A2A8A2AAA7D41F5552935DD7776484785538820820820B0B0A2A",
                   INITP_01 => X"A4AAA8A4A9744888D34A8AAAA20AAAAAB4AAAA90AAA28B08A88AAAAAD8B6AB0A",
                   INITP_02 => X"8A029295554422A28A6AA2222A28A6AA18608A282AAAAAAAAAAAAB5A22A228A2",
                   INITP_03 => X"AAAAAAAA0AA111104443429998111122A28A88A28A92A2A8A4A8A9696B760AA2",
                   INITP_04 => X"620A615455554082A0AAAAAAAAAAAAAAAAAAAAB4A22A556556E234BA0002B7A3",
                   INITP_05 => X"AA02002359AAAA82A80800B6AAAAA82AA80005555135E355555114200295DAA8",
                   INITP_06 => X"3D478D54441410550451055045447800D446102002A10A40A00948B68A8AAAA0",
                   INITP_07 => X"AAAAAA28A2A90D2AAD136AA228AAA0A50AAAAAB6A5DA0D664A0A242800A0235E")
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
                    INIT_00 => X"D0089000200A9000D008900020061000D00490002653D00B109B014F007100C7",
                    INIT_01 => X"5000D00290005000D01090005000D00490005000D02090005000D00190005000",
                    INIT_02 => X"50000030400E10010300E0300033001043064306430643060300E03000330020",
                    INIT_03 => X"D010100AA041902AA044D010100AA0419011A044D00AA04190305000400E1000",
                    INIT_04 => X"01009207204FE04FD2411237420E420E420E420E020050005000400E1000A044",
                    INIT_05 => X"D1010006110D5000D1010006D20100060045500091072056E056D1411137310F",
                    INIT_06 => X"20683B001A01D10100062070D1004BA05000D101113E00065000D1010006110A",
                    INIT_07 => X"00B700A000B600A65000009C00B700A600B600A000A95000DF045F021F015000",
                    INIT_08 => X"608D9D0100AC1D08208390004D0E009200A9208800A66087CED01D80500000A9",
                    INIT_09 => X"500000B6DF043FFE5000DE0100AC209200A95000009C00B700A000B600A65000",
                    INIT_0A => X"00B900A000B600A95000DF045F025000DF043FFD500020A2DC019C02DF045F01",
                    INIT_0B => X"500060BD9C011C01500000BC00BC00BC00BC00BC5000009C00B94E00DC029C02",
                    INIT_0C => X"00060045100100681AC01B00B001B03100D61100113A115611201149114C1143",
                    INIT_0D => X"E0E4D404B42C210DD300B3235000F023F020100050000064005DD1010006D201",
                    INIT_0E => X"0075007120EA9401450620EED40015109404B42CD005100120E8B42CD0051000",
                    INIT_0F => X"009900824E071E280075007102310231007C009900820E50009900824E061E28",
                    INIT_10 => X"1600F62316015000005D0057004000570030007C009704E0008C009103E0008C",
                    INIT_11 => X"11641165116C116911611166112011431132114950006110D608160100DAF62C",
                    INIT_12 => X"1B01005D0071110011211164116E116F11701173116511721120116F11741120",
                    INIT_13 => X"1E27160101431E23160101431E21162CD00510025000D009B02C205D00681A16",
                    INIT_14 => X"1002500000990082AE60009900821E09009900824E06007500715000007C0143",
                    INIT_15 => X"00821E00009900824E06007500715000007C01591E2101591E2301591E27D005",
                    INIT_16 => X"42064100420641004206A1001001A2001030D00510025000009900821E000099",
                    INIT_17 => X"00820E10009900824E60B62C1E30009900824E061E7300750071410042064100",
                    INIT_18 => X"1A01D10100062196D1FF2192D1004BA01AD81B045000007C009900820E200099",
                    INIT_19 => X"009900824E06BE3000750071D005B02C5000005D21883B001A03005D21883B00",
                    INIT_1A => X"009103E0008C009900824E07BE3000750071D005B02C5000007C00990082BE34",
                    INIT_1B => X"005D005790065000D006B02C5000005D0057004000570030007C009704E0008C",
                    INIT_1C => X"EC101101EB101141AE009001AD009001AC009001AB001003102CF140B1285000",
                    INIT_1D => X"1001AD001001AC001001AB001041625CC050B528B0405000EE101101ED101101",
                    INIT_1E => X"12001100022302230223021DA9009001A8009001A7009001A6001003102CAE00",
                    INIT_1F => X"0223021D021202090223021D021202090223021D021202090223021D02120209",
                    INIT_20 => X"44204410320402A0310101F014005000005D61F095017000D101000611207001",
                    INIT_21 => X"4D084C084B0E50007000D0011030221A10316219D00190060006700150000229",
                    INIT_22 => X"50000230340DD40654020230D40650004A00490848084708460E50004F004E08",
                    INIT_23 => X"116111201153114D11541120113A1152114F1152115211455000623190011019",
                    INIT_24 => X"116411201173116811741167116E1165116C1120114F1144115411201164116E",
                    INIT_25 => X"005D00681A341B0211001168116311741161116D11201174116F116E1120116F",
                    INIT_26 => X"140142004306420043064200430642004306A3401200143002861545B42C5000",
                    INIT_27 => X"15010057A05002861545B42C5000E3501501E25042404406440644064406A440",
                    INIT_28 => X"18261E001D03500022869401150115011000D4005000005DD20100060045A050",
                    INIT_29 => X"4708460E4708460E4708460EA7401401A640696068601600144502BF15041906",
                    INIT_2A => X"4708460FA7401401A6406294D4611401700002BF150370016E706D604708460E",
                    INIT_2B => X"021D500002BF150617FF18F819000E700D601CFF4708460F4708460F4708460F",
                    INIT_2C => X"021D02090223021D02090223021D02090223021D020912001100022302230223",
                    INIT_2D => X"03140314031419001800164502BF1504190618261E001D03500062C595010223",
                    INIT_2E => X"D6631601E9601601E86003140314031403140314031403140314180009800314",
                    INIT_2F => X"0314031403140314190018001C0602BF1504190618261E401D012294144562DB",
                    INIT_30 => X"00570090D2010006004500800314031403140314031403140314031418000980",
                    INIT_31 => X"500002BF150219FF18FF1E0050004808450E950602291400231A62FA9C01005D",
                    INIT_32 => X"18261E201D015000005D0057A07007501763B52C5000E67007501763B630B52C",
                    INIT_33 => X"70016DD06EE0ADF09F01AEF09F010229A4F01F0A1F631200130202BF15041906",
                    INIT_34 => X"9F014EA04A064A064A06AAF09F01AEF09F01700002BF15041600170018001900",
                    INIT_35 => X"1A00A9F09F014DA04A064A06AAF09F010D904EA04A08490E4A08490E1A00A9F0",
                    INIT_36 => X"4A06AAF09F010B904CA049004A061900AAF09F010C904DA04A08490E4A08490E",
                    INIT_37 => X"150270012387D2016EE0AEF09F01700002BF150770016BB06CC06DD06EE04BA0",
                    INIT_38 => X"190618261E201D01500002BF150418FF1980233512016335D3009301700002BF",
                    INIT_39 => X"80C0100803BE03AF18001609E89003AA10070314190A19631800022902BF1504",
                    INIT_3A => X"03BE23AA9001480E1000D0005000233513021200639BD6FF9601E890990103AA",
                    INIT_3B => X"1AB41B031C081C081C031C031C041C041C031C081C031C0823B010009C010314",
                    INIT_3C => X"10200006D001103A0006D1010006D201000600450030130050004BA03B000A60",
                    INIT_3D => X"23C5005D63D1D00330031301003023E0D3FFD1010006D20100060045A030D001",
                    INIT_3E => X"5000D00310FF50000424062705D80210B12BB227A3ECD004B02304245000005D",
                    INIT_3F => X"1120113A117211651166116611751142500000C75000D00BB02C5000D0031000",
                   INITP_00 => X"AAAAAA8296B6A2A8A2AAA7D41F5552935DD7776484785538820820820B0B0A2A",
                   INITP_01 => X"A4AAA8A4A9744888D34A8AAAA20AAAAAB4AAAA90AAA28B08A88AAAAAD8B6AB0A",
                   INITP_02 => X"8A029295554422A28A6AA2222A28A6AA18608A282AAAAAAAAAAAAB5A22A228A2",
                   INITP_03 => X"AAAAAAAA0AA111104443429998111122A28A88A28A92A2A8A4A8A9696B760AA2",
                   INITP_04 => X"620A615455554082A0AAAAAAAAAAAAAAAAAAAAB4A22A556556E234BA0002B7A3",
                   INITP_05 => X"AA02002359AAAA82A80800B6AAAAA82AA80005555135E355555114200295DAA8",
                   INITP_06 => X"3D478D54441410550451055045447800D446102002A10A40A00948B68A8AAAA0",
                   INITP_07 => X"AAAAAA28A2A90D2AAD136AA228AAA0A50AAAAAB6A5DA0D664A0A242800A0235E")
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
                    INIT_00 => X"D0089000200A9000D008900020061000D00490002653D00B109B014F007100C7",
                    INIT_01 => X"5000D00290005000D01090005000D00490005000D02090005000D00190005000",
                    INIT_02 => X"50000030400E10010300E0300033001043064306430643060300E03000330020",
                    INIT_03 => X"D010100AA041902AA044D010100AA0419011A044D00AA04190305000400E1000",
                    INIT_04 => X"01009207204FE04FD2411237420E420E420E420E020050005000400E1000A044",
                    INIT_05 => X"D1010006110D5000D1010006D20100060045500091072056E056D1411137310F",
                    INIT_06 => X"20683B001A01D10100062070D1004BA05000D101113E00065000D1010006110A",
                    INIT_07 => X"00B700A000B600A65000009C00B700A600B600A000A95000DF045F021F015000",
                    INIT_08 => X"608D9D0100AC1D08208390004D0E009200A9208800A66087CED01D80500000A9",
                    INIT_09 => X"500000B6DF043FFE5000DE0100AC209200A95000009C00B700A000B600A65000",
                    INIT_0A => X"00B900A000B600A95000DF045F025000DF043FFD500020A2DC019C02DF045F01",
                    INIT_0B => X"500060BD9C011C01500000BC00BC00BC00BC00BC5000009C00B94E00DC029C02",
                    INIT_0C => X"00060045100100681AC01B00B001B03100D61100113A115611201149114C1143",
                    INIT_0D => X"E0E4D404B42C210DD300B3235000F023F020100050000064005DD1010006D201",
                    INIT_0E => X"0075007120EA9401450620EED40015109404B42CD005100120E8B42CD0051000",
                    INIT_0F => X"009900824E071E280075007102310231007C009900820E50009900824E061E28",
                    INIT_10 => X"1600F62316015000005D0057004000570030007C009704E0008C009103E0008C",
                    INIT_11 => X"11641165116C116911611166112011431132114950006110D608160100DAF62C",
                    INIT_12 => X"1B01005D0071110011211164116E116F11701173116511721120116F11741120",
                    INIT_13 => X"1E27160101431E23160101431E21162CD00510025000D009B02C205D00681A16",
                    INIT_14 => X"1002500000990082AE60009900821E09009900824E06007500715000007C0143",
                    INIT_15 => X"00821E00009900824E06007500715000007C01591E2101591E2301591E27D005",
                    INIT_16 => X"42064100420641004206A1001001A2001030D00510025000009900821E000099",
                    INIT_17 => X"00820E10009900824E60B62C1E30009900824E061E7300750071410042064100",
                    INIT_18 => X"1A01D10100062196D1FF2192D1004BA01AD81B045000007C009900820E200099",
                    INIT_19 => X"009900824E06BE3000750071D005B02C5000005D21883B001A03005D21883B00",
                    INIT_1A => X"009103E0008C009900824E07BE3000750071D005B02C5000007C00990082BE34",
                    INIT_1B => X"005D005790065000D006B02C5000005D0057004000570030007C009704E0008C",
                    INIT_1C => X"EC101101EB101141AE009001AD009001AC009001AB001003102CF140B1285000",
                    INIT_1D => X"1001AD001001AC001001AB001041625CC050B528B0405000EE101101ED101101",
                    INIT_1E => X"12001100022302230223021DA9009001A8009001A7009001A6001003102CAE00",
                    INIT_1F => X"0223021D021202090223021D021202090223021D021202090223021D02120209",
                    INIT_20 => X"44204410320402A0310101F014005000005D61F095017000D101000611207001",
                    INIT_21 => X"4D084C084B0E50007000D0011030221A10316219D00190060006700150000229",
                    INIT_22 => X"50000230340DD40654020230D40650004A00490848084708460E50004F004E08",
                    INIT_23 => X"116111201153114D11541120113A1152114F1152115211455000623190011019",
                    INIT_24 => X"116411201173116811741167116E1165116C1120114F1144115411201164116E",
                    INIT_25 => X"005D00681A341B0211001168116311741161116D11201174116F116E1120116F",
                    INIT_26 => X"140142004306420043064200430642004306A3401200143002861545B42C5000",
                    INIT_27 => X"15010057A05002861545B42C5000E3501501E25042404406440644064406A440",
                    INIT_28 => X"18261E001D03500022869401150115011000D4005000005DD20100060045A050",
                    INIT_29 => X"4708460E4708460E4708460EA7401401A640696068601600144502BF15041906",
                    INIT_2A => X"4708460FA7401401A6406294D4611401700002BF150370016E706D604708460E",
                    INIT_2B => X"021D500002BF150617FF18F819000E700D601CFF4708460F4708460F4708460F",
                    INIT_2C => X"021D02090223021D02090223021D02090223021D020912001100022302230223",
                    INIT_2D => X"03140314031419001800164502BF1504190618261E001D03500062C595010223",
                    INIT_2E => X"D6631601E9601601E86003140314031403140314031403140314180009800314",
                    INIT_2F => X"0314031403140314190018001C0602BF1504190618261E401D012294144562DB",
                    INIT_30 => X"00570090D2010006004500800314031403140314031403140314031418000980",
                    INIT_31 => X"500002BF150219FF18FF1E0050004808450E950602291400231A62FA9C01005D",
                    INIT_32 => X"18261E201D015000005D0057A07007501763B52C5000E67007501763B630B52C",
                    INIT_33 => X"70016DD06EE0ADF09F01AEF09F010229A4F01F0A1F631200130202BF15041906",
                    INIT_34 => X"9F014EA04A064A064A06AAF09F01AEF09F01700002BF15041600170018001900",
                    INIT_35 => X"1A00A9F09F014DA04A064A06AAF09F010D904EA04A08490E4A08490E1A00A9F0",
                    INIT_36 => X"4A06AAF09F010B904CA049004A061900AAF09F010C904DA04A08490E4A08490E",
                    INIT_37 => X"150270012387D2016EE0AEF09F01700002BF150770016BB06CC06DD06EE04BA0",
                    INIT_38 => X"190618261E201D01500002BF150418FF1980233512016335D3009301700002BF",
                    INIT_39 => X"80C0100803BE03AF18001609E89003AA10070314190A19631800022902BF1504",
                    INIT_3A => X"03BE23AA9001480E1000D0005000233513021200639BD6FF9601E890990103AA",
                    INIT_3B => X"1AB41B031C081C081C031C031C041C041C031C081C031C0823B010009C010314",
                    INIT_3C => X"10200006D001103A0006D1010006D201000600450030130050004BA03B000A60",
                    INIT_3D => X"23C5005D63D1D00330031301003023E0D3FFD1010006D20100060045A030D001",
                    INIT_3E => X"5000D00310FF50000424062705D80210B12BB227A3ECD004B02304245000005D",
                    INIT_3F => X"1120113A117211651166116611751142500000C75000D00BB02C5000D0031000",
                   INITP_00 => X"AAAAAA8296B6A2A8A2AAA7D41F5552935DD7776484785538820820820B0B0A2A",
                   INITP_01 => X"A4AAA8A4A9744888D34A8AAAA20AAAAAB4AAAA90AAA28B08A88AAAAAD8B6AB0A",
                   INITP_02 => X"8A029295554422A28A6AA2222A28A6AA18608A282AAAAAAAAAAAAB5A22A228A2",
                   INITP_03 => X"AAAAAAAA0AA111104443429998111122A28A88A28A92A2A8A4A8A9696B760AA2",
                   INITP_04 => X"620A615455554082A0AAAAAAAAAAAAAAAAAAAAB4A22A556556E234BA0002B7A3",
                   INITP_05 => X"AA02002359AAAA82A80800B6AAAAA82AA80005555135E355555114200295DAA8",
                   INITP_06 => X"3D478D54441410550451055045447800D446102002A10A40A00948B68A8AAAA0",
                   INITP_07 => X"AAAAAA28A2A90D2AAD136AA228AAA0A50AAAAAB6A5DA0D664A0A242800A0235E")
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
                    INIT_00 => X"0002000010000004000020000001000008000A00080006000400530B9B4F71C7",
                    INIT_01 => X"100A412A44100A4111440A4130000E0000300E01003033100606060600303320",
                    INIT_02 => X"01060D0001060106450007565641370F00074F4F41370E0E0E0E0000000E0044",
                    INIT_03 => X"B7A0B6A6009CB7A6B6A0A9000402010068000101067000A000013E060001060A",
                    INIT_04 => X"00B604FE0001AC92A9009CB7A0B6A6008D01AC0883000E92A988A687D08000A9",
                    INIT_05 => X"00BD010100BCBCBCBCBC009CB9000202B9A0B6A90004020004FD00A201020401",
                    INIT_06 => X"E4042C0D00230023200000645D01060106450168C0000131D6003A5620494C43",
                    INIT_07 => X"99820728757131317C998250998206287571EA0106EE0010042C0501E82C0500",
                    INIT_08 => X"64656C6961662043324900100801DA2C002301005D574057307C97E08C91E08C",
                    INIT_09 => X"270143230143212C050200092C5D6816015D710021646E6F70736572206F7420",
                    INIT_0A => X"82009982067571007C5921592359270502009982609982099982067571007C43",
                    INIT_0B => X"82109982602C3099820673757100060006000600060001003005020099820099",
                    INIT_0C => X"998206307571052C005D8800035D880001010696FF9200A0D804007C99822099",
                    INIT_0D => X"5D570600062C005D574057307C97E08C91E08C998207307571052C007C998234",
                    INIT_0E => X"010001000100415C50284000100110011001104100010001000100032C402800",
                    INIT_0F => X"231D1209231D1209231D1209231D120900002323231D00010001000100032C00",
                    INIT_10 => X"08080E000001301A3119010606010029201004A001F000005DF0010001062001",
                    INIT_11 => X"6120534D54203A524F5252450031011900300D0602300600000808080E000008",
                    INIT_12 => X"5D68340200686374616D20746F6E206F6420736874676E656C204F445420646E",
                    INIT_13 => X"01575086452C0050015040060606064001000600060006000640003086452C00",
                    INIT_14 => X"080E080E080E40014060600045BF040626000300860101010000005D01064550",
                    INIT_15 => X"1D00BF06FFF8007060FF080F080F080F080F40014094610100BF03017060080E",
                    INIT_16 => X"141414000045BF040626000300C501231D09231D09231D09231D090000232323",
                    INIT_17 => X"14141414000006BF04062640019445DB63016001601414141414141414008014",
                    INIT_18 => X"00BF02FFFF0000080E0629001AFA015D57900106458014141414141414140080",
                    INIT_19 => X"01D0E0F001F00129F00A630002BF0406262001005D577050632C00705063302C",
                    INIT_1A => X"00F001A00606F00190A0080E080E00F001A0060606F001F00100BF0400000000",
                    INIT_1B => X"02018701E0F00100BF0701B0C0D0E0A006F00190A0000600F00190A0080E080E",
                    INIT_1C => X"C008BEAF000990AA07140A630029BF040626200100BF04FF80350135000100BF",
                    INIT_1D => X"B40308080303040403080308B0000114BEAA010E0000003502009BFF019001AA",
                    INIT_1E => X"C55DD103030130E0FF010601064530012006013A060106010645300000A00060",
                    INIT_1F => X"203A72656666754200C7000B2C0003000003FF002427D8102B27EC042324005D",
                    INIT_20 => X"6F5700202020203A73657A69732064726F5700203A746E756F632064726F5700",
                    INIT_21 => X"5D01290601060106452001280601200629010110063020200068F80300206472",
                    INIT_22 => X"045D4C0101060106451030240140060120065E40002301060106452306680104",
                    INIT_23 => X"01064530681E045D964000235D6401010601064510302801200673400023680E",
                    INIT_24 => X"505007102CA3042C005D8C01010601064560765003502C060601300120060106",
                    INIT_25 => X"0757075707570700010105005D57050008002C00A9000220040A000A01000700",
                    INIT_26 => X"67726169746C756D005D01060106450168C30400203A6E6F6973726556B55D57",
                    INIT_27 => X"73CD04006E6F6973726576F603007465736572C40300706D75646D656DE20300",
                    INIT_28 => X"66666F5F7265776F70ED03006E6F5F7265776F70860100706C65682404007379",
                    INIT_29 => X"C10100646AA5010072699801007769BD0100726ABA0100776ADA000061F00300",
                    INIT_2A => X"73746AD4020067746A8D020075746A7A020072746A61020077746AD501006D6A",
                    INIT_2B => X"72616A20030077616AB504007274AF04007A74B1040066749804006374F30200",
                    INIT_2C => X"03007074650100643601007033010070738C030067616A2D030075616A260300",
                    INIT_2D => X"C300D4FFA0AC000101BB1020BB0020D4FFC700A000D804FF4F01006F697067F3",
                    INIT_2E => X"330120021020230000640FD60064D610A0000110A0000127D8AC000003BB0001",
                    INIT_2F => X"012823001001242320F001F73320F72010F010200820100023230205012301DA",
                    INIT_30 => X"2068140600203A726F727245005D68030600646E616D6D6F632064614200DA00",
                    INIT_31 => X"02012C06064050104028004024520023002A200110002C0438005D0106010645",
                    INIT_32 => X"53A9726A20200120100020010A00307033603050013F017020016001604B5030",
                    INIT_33 => X"20012083208F08880A880D0001205364D65D6860065D0021776F6C667265764F",
                    INIT_34 => X"01202001200108060120060108069E0220000C012001205D000C000106000C00",
                    INIT_35 => X"00000000000000000000000000000000000000000000000000000000000C0020",
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
                   INITP_00 => X"000009001C04047F000006C330005204000E5365A8278000000008F800000004",
                   INITP_01 => X"00004220444772260000400000335F40000554000054000124009FFFFFD00002",
                   INITP_02 => X"F8C827FBF19200081AAAA026AA43230089802AC41FFFFFFFFFF00052A0000C6A",
                   INITP_03 => X"FF0002A0A5C004164009C1A3317192DCA2553555719582955A6B21CD30C803FD",
                   INITP_04 => X"FFFFFFFFFF203FF800E00300C00803E20263061898301A010800429FFFFFFFFF",
                   INITP_05 => X"17D3FD810400CCD6FE49F3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_06 => X"00000000000000000000000006D800100AB00BFF4F6002203CE032101FF0FFFB",
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
                    INIT_00 => X"28684828684828684828684828684828684810C8684810886848136808000000",
                    INIT_01 => X"E888D0C8D0E888D0C8D0E8D0C828A0082800A00881F00000A1A1A1A101F00000",
                    INIT_02 => X"68000828680069000028C890F0E8881800C990F0E989A1A1A1A1012828A008D0",
                    INIT_03 => X"0000000028000000000000286F2F0F28109D8D680090E8252868080028680008",
                    INIT_04 => X"28006F1F286F00100028000000000028B0CE000E10C8A600001000B0670E2800",
                    INIT_05 => X"28B0CE0E280000000000280000A76E4E00000000286F2F286F1F28906E4E6F2F",
                    INIT_06 => X"F0EA5A90E95928787808280000680069000008000D0D58580008080808080808",
                    INIT_07 => X"0000A70F00000101000000070000A70F000010CAA290EA0ACA5A6808105A6808",
                    INIT_08 => X"0808080808080808080828B0EB8B007B0B7B0B28000000000000000200000100",
                    INIT_09 => X"0F8B000F8B000F0B680828685810000D0D000008080808080808080808080808",
                    INIT_0A => X"000F0000A700002800000F000F000F68082800005700000F0000A70000280000",
                    INIT_0B => X"00070000275B0F0000A70F0000A0A1A0A1A0A1A0A15088510868082800000F00",
                    INIT_0C => X"0000A75F000068582800109D8D00109D8D680090E890E8250D0D280000000700",
                    INIT_0D => X"000048286858280000000000000002000001000000A75F00006858280000005F",
                    INIT_0E => X"88568856885508B1E05A5828778876887688750857C856C856C8558808785828",
                    INIT_0F => X"0101010101010101010101010101010109080101010154C854C853C853880857",
                    INIT_10 => X"A6A6A528B868081108B1E84800B828012222190118000A2800B0CAB8680008B8",
                    INIT_11 => X"08080808080808080808080828B1C80828011A6A2A016A28A5A4A4A3A328A7A7",
                    INIT_12 => X"00000D0D08080808080808080808080808080808080808080808080808080808",
                    INIT_13 => X"8A0050010A5A28718A7121A2A2A2A2528AA1A1A1A1A1A1A1A151090A010A5A28",
                    INIT_14 => X"A3A3A3A3A3A3538A53B4B40B0A010A0C0C0F0E2811CA8A8A88EA280069000050",
                    INIT_15 => X"0128010A0B0C0C07060EA3A3A3A3A3A3A3A3538A53B1EA8AB8010AB8B7B6A3A3",
                    INIT_16 => X"0101010C0C0B010A0C0C0F0E28B1CA0101010101010101010101010908010101",
                    INIT_17 => X"010101010C0C0E010A0C0C0F0E110AB1EB8B748B7401010101010101010C0401",
                    INIT_18 => X"28010A0C0C0F28A4A24A010A11B1CE0000006900000001010101010101010C04",
                    INIT_19 => X"B8B6B756CF57CF01528F0F0909010A0C0C0F0E28000050830B5A2873830B5B5A",
                    INIT_1A => X"0D54CF26A5A555CF0627A5A4A5A40D54CF27A5A5A555CF57CFB8010A0B0B0C0C",
                    INIT_1B => X"0AB891E9B757CFB8010AB8B5B6B6B725A555CF0526A4A50C55CF0626A5A4A5A4",
                    INIT_1C => X"C00801010C0B740108018C0C0C01010A0C0C0F0E28010A0C0C1109B1E9C9B801",
                    INIT_1D => X"0D0D0E0E0E0E0E0E0E0E0E0E1188CE010111C8A488E828110909B1EBCB74CC01",
                    INIT_1E => X"1100B1E818890091E96800690000506808006808006800690000000928259D85",
                    INIT_1F => X"0808080808080808280028685828680828680828020302815859D1E858022800",
                    INIT_20 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_21 => X"006808006800690000006808006808001288685000F2E05908000D0D08080808",
                    INIT_22 => X"0D0012896800690000508008680800680800F2E1095A68006900005800000D0D",
                    INIT_23 => X"69000000000D0D00F2E1095A0012896800690000508008680800F2E1095A000D",
                    INIT_24 => X"020268285882E858280012CB680069000050D2E38B038AA2A289026808006800",
                    INIT_25 => X"4800480048004888EA1A4A280000482868287808B2DDCD0D0D68086808286808",
                    INIT_26 => X"08080808080808082800680069000008000D0D08080808080808080808120000",
                    INIT_27 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_28 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_29 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2A => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2B => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2C => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2D => X"92E892E825129D8D89B2E050F2E15892E892E825090D0D080808080808080808",
                    INIT_2E => X"008950F3E15878082800030028000021259D8D01259D8D030212099D8D129D8D",
                    INIT_2F => X"C88858C150C88858011289F2005092E101D2E15889017180087893E88858C9F2",
                    INIT_30 => X"00000D0D08080808080808082800000D0D080808080808080808080808281271",
                    INIT_31 => X"CB8A8BA3A30383538008528008F3E2580AD3E088700808890928006800690000",
                    INIT_32 => X"13C203F3E878885870885848002813700050B3E38B138B7000CB508B51D3E3D3",
                    INIT_33 => X"78C858F3E893E893E893E850C85813000000000D0D0008080808080808080808",
                    INIT_34 => X"C85878C858680800680800680800D3C85828A00878C8580028A008680028A008",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000028A00878",
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
                   INITP_00 => X"CFECE42A93BFD3FFCFF8FDB2EBFFADF3FFF99DDEDFD830192954860692493337",
                   INITP_01 => X"FFFF3C00011AA005DBADB9DECEE6753DB198005DB7D576DF24B67FFFFFF35D6D",
                   INITP_02 => X"F1052FF9E20DFFE7E00004D0000418BE53400009CFFFFFFFFFFCD7041D4F01DD",
                   INITP_03 => X"FFF6DE27E17D6FCC3FFDCB2533460C5361A000000000006081041C30C22DBBFC",
                   INITP_04 => X"FFFFFFFFFFFE9FFF551DE85624EFA017E98DF1626F8B63ECDFADAC4FFFFFFFFF",
                   INITP_05 => X"005A426192FF89C4AC4951FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_06 => X"00000000000000000000000925B6499C9543E7FFF48FA5850004487F4FFE7FFF",
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
                    INIT_00 => X"D0089000200A9000D008900020061000D00490002653D00B109B014F007100C7",
                    INIT_01 => X"5000D00290005000D01090005000D00490005000D02090005000D00190005000",
                    INIT_02 => X"50000030400E10010300E0300033001043064306430643060300E03000330020",
                    INIT_03 => X"D010100AA041902AA044D010100AA0419011A044D00AA04190305000400E1000",
                    INIT_04 => X"01009207204FE04FD2411237420E420E420E420E020050005000400E1000A044",
                    INIT_05 => X"D1010006110D5000D1010006D20100060045500091072056E056D1411137310F",
                    INIT_06 => X"20683B001A01D10100062070D1004BA05000D101113E00065000D1010006110A",
                    INIT_07 => X"00B700A000B600A65000009C00B700A600B600A000A95000DF045F021F015000",
                    INIT_08 => X"608D9D0100AC1D08208390004D0E009200A9208800A66087CED01D80500000A9",
                    INIT_09 => X"500000B6DF043FFE5000DE0100AC209200A95000009C00B700A000B600A65000",
                    INIT_0A => X"00B900A000B600A95000DF045F025000DF043FFD500020A2DC019C02DF045F01",
                    INIT_0B => X"500060BD9C011C01500000BC00BC00BC00BC00BC5000009C00B94E00DC029C02",
                    INIT_0C => X"00060045100100681AC01B00B001B03100D61100113A115611201149114C1143",
                    INIT_0D => X"E0E4D404B42C210DD300B3235000F023F020100050000064005DD1010006D201",
                    INIT_0E => X"0075007120EA9401450620EED40015109404B42CD005100120E8B42CD0051000",
                    INIT_0F => X"009900824E071E280075007102310231007C009900820E50009900824E061E28",
                    INIT_10 => X"1600F62316015000005D0057004000570030007C009704E0008C009103E0008C",
                    INIT_11 => X"11641165116C116911611166112011431132114950006110D608160100DAF62C",
                    INIT_12 => X"1B01005D0071110011211164116E116F11701173116511721120116F11741120",
                    INIT_13 => X"1E27160101431E23160101431E21162CD00510025000D009B02C205D00681A16",
                    INIT_14 => X"1002500000990082AE60009900821E09009900824E06007500715000007C0143",
                    INIT_15 => X"00821E00009900824E06007500715000007C01591E2101591E2301591E27D005",
                    INIT_16 => X"42064100420641004206A1001001A2001030D00510025000009900821E000099",
                    INIT_17 => X"00820E10009900824E60B62C1E30009900824E061E7300750071410042064100",
                    INIT_18 => X"1A01D10100062196D1FF2192D1004BA01AD81B045000007C009900820E200099",
                    INIT_19 => X"009900824E06BE3000750071D005B02C5000005D21883B001A03005D21883B00",
                    INIT_1A => X"009103E0008C009900824E07BE3000750071D005B02C5000007C00990082BE34",
                    INIT_1B => X"005D005790065000D006B02C5000005D0057004000570030007C009704E0008C",
                    INIT_1C => X"EC101101EB101141AE009001AD009001AC009001AB001003102CF140B1285000",
                    INIT_1D => X"1001AD001001AC001001AB001041625CC050B528B0405000EE101101ED101101",
                    INIT_1E => X"12001100022302230223021DA9009001A8009001A7009001A6001003102CAE00",
                    INIT_1F => X"0223021D021202090223021D021202090223021D021202090223021D02120209",
                    INIT_20 => X"44204410320402A0310101F014005000005D61F095017000D101000611207001",
                    INIT_21 => X"4D084C084B0E50007000D0011030221A10316219D00190060006700150000229",
                    INIT_22 => X"50000230340DD40654020230D40650004A00490848084708460E50004F004E08",
                    INIT_23 => X"116111201153114D11541120113A1152114F1152115211455000623190011019",
                    INIT_24 => X"116411201173116811741167116E1165116C1120114F1144115411201164116E",
                    INIT_25 => X"005D00681A341B0211001168116311741161116D11201174116F116E1120116F",
                    INIT_26 => X"140142004306420043064200430642004306A3401200143002861545B42C5000",
                    INIT_27 => X"15010057A05002861545B42C5000E3501501E25042404406440644064406A440",
                    INIT_28 => X"18261E001D03500022869401150115011000D4005000005DD20100060045A050",
                    INIT_29 => X"4708460E4708460E4708460EA7401401A640696068601600144502BF15041906",
                    INIT_2A => X"4708460FA7401401A6406294D4611401700002BF150370016E706D604708460E",
                    INIT_2B => X"021D500002BF150617FF18F819000E700D601CFF4708460F4708460F4708460F",
                    INIT_2C => X"021D02090223021D02090223021D02090223021D020912001100022302230223",
                    INIT_2D => X"03140314031419001800164502BF1504190618261E001D03500062C595010223",
                    INIT_2E => X"D6631601E9601601E86003140314031403140314031403140314180009800314",
                    INIT_2F => X"0314031403140314190018001C0602BF1504190618261E401D012294144562DB",
                    INIT_30 => X"00570090D2010006004500800314031403140314031403140314031418000980",
                    INIT_31 => X"500002BF150219FF18FF1E0050004808450E950602291400231A62FA9C01005D",
                    INIT_32 => X"18261E201D015000005D0057A07007501763B52C5000E67007501763B630B52C",
                    INIT_33 => X"70016DD06EE0ADF09F01AEF09F010229A4F01F0A1F631200130202BF15041906",
                    INIT_34 => X"9F014EA04A064A064A06AAF09F01AEF09F01700002BF15041600170018001900",
                    INIT_35 => X"1A00A9F09F014DA04A064A06AAF09F010D904EA04A08490E4A08490E1A00A9F0",
                    INIT_36 => X"4A06AAF09F010B904CA049004A061900AAF09F010C904DA04A08490E4A08490E",
                    INIT_37 => X"150270012387D2016EE0AEF09F01700002BF150770016BB06CC06DD06EE04BA0",
                    INIT_38 => X"190618261E201D01500002BF150418FF1980233512016335D3009301700002BF",
                    INIT_39 => X"80C0100803BE03AF18001609E89003AA10070314190A19631800022902BF1504",
                    INIT_3A => X"03BE23AA9001480E1000D0005000233513021200639BD6FF9601E890990103AA",
                    INIT_3B => X"1AB41B031C081C081C031C031C041C041C031C081C031C0823B010009C010314",
                    INIT_3C => X"10200006D001103A0006D1010006D201000600450030130050004BA03B000A60",
                    INIT_3D => X"23C5005D63D1D00330031301003023E0D3FFD1010006D20100060045A030D001",
                    INIT_3E => X"5000D00310FF50000424062705D80210B12BB227A3ECD004B02304245000005D",
                    INIT_3F => X"1120113A117211651166116611751142500000C75000D00BB02C5000D0031000",
                    INIT_40 => X"116F115711001120113A1174116E1175116F1163112011641172116F11571100",
                    INIT_41 => X"116F115711001120112011201120113A11731165117A11691173112011641172",
                    INIT_42 => X"24291101D001A0100006E430C120B220110000681AF81B031100112011641172",
                    INIT_43 => X"005DD00110290006D1010006D201000600450020D00110280006D00110200006",
                    INIT_44 => X"10200006E45EC3401300B423D1010006D20100060045B023000600681A011B04",
                    INIT_45 => X"1B04005D244C1301D1010006D20100060045A01001301124D00110400006D001",
                    INIT_46 => X"0006D20100060045A01001301128D00110200006E473C3401300B42300681A0E",
                    INIT_47 => X"D20100060045003000681A1E1B04005DE496C3401300B423005D24641301D101",
                    INIT_48 => X"0045A060A476C65016030650152C4506450613010530D00110200006D1010006",
                    INIT_49 => X"05500550D0075010B02C04A3D004B02C5000005D248C9601D1010006D2010006",
                    INIT_4A => X"D0085000F02C100064A9BA009B021B201A04D00A1000D00A10015000D0071000",
                    INIT_4B => X"90070057900700579007005790071000D501350195055000005D005790055000",
                    INIT_4C => X"00681AC31B0411001120113A116E116F1169117311721165115624B5005D0057",
                    INIT_4D => X"11671172116111691174116C1175116D5000005DD1010006D201000600451001",
                    INIT_4E => X"11731165117211C4110311001170116D11751164116D1165116D11E211031100",
                    INIT_4F => X"117311CD11041100116E116F1169117311721165117611F61103110011741165",
                    INIT_50 => X"11651177116F11701186110111001170116C1165116811241104110011731179",
                    INIT_51 => X"11661166116F115F117211651177116F117011ED11031100116E116F115F1172",
                    INIT_52 => X"110111001172116A11BA110111001177116A11DA11001100116111F011031100",
                    INIT_53 => X"11C1110111001164116A11A511011100117211691198110111001177116911BD",
                    INIT_54 => X"1102110011721174116A11611102110011771174116A11D511011100116D116A",
                    INIT_55 => X"11731174116A11D41102110011671174116A118D1102110011751174116A117A",
                    INIT_56 => X"1100117A117411B111041100116611741198110411001163117411F311021100",
                    INIT_57 => X"11721161116A11201103110011771161116A11B5110411001172117411AF1104",
                    INIT_58 => X"1173118C1103110011671161116A112D1103110011751161116A112611031100",
                    INIT_59 => X"1103110011701174116511011100116411361101110011701133110111001170",
                    INIT_5A => X"D1FF25C7D1004BA012001AD81B0411FF114F11011100116F11691170116711F3",
                    INIT_5B => X"25C3D10025D4D1FF4BA025AC3B001A01120165BBC010A020E5BBC200B02025D4",
                    INIT_5C => X"4BA03B001A0102104BA03B001A01062705D825AC12003B001A0325BB3B001A01",
                    INIT_5D => X"00331201A020E602C210B120F023100050000064060F00D65000006400D64210",
                    INIT_5E => X"0310A5F0C310B12013080320E21001001123F0232602D0051001B0239201E5DA",
                    INIT_5F => X"90011028B0238300A01091011124B123032025F01201E5F70033A02025F7C320",
                    INIT_60 => X"1B0611001164116E1161116D116D116F11631120116411611142500025DAE300",
                    INIT_61 => X"002000681A141B0611001120113A1172116F1172117211455000005D00681A03",
                    INIT_62 => X"1400A62AC1201101E0101000112C120412385000005DD1010006D20100060045",
                    INIT_63 => X"96021401172C4706470607400650A61001401128A50000401024E652C400B023",
                    INIT_64 => X"0033A0606630C6501601263F1701E07000209601A1601601A260A64BC650A630",
                    INIT_65 => X"265385A90672E66AD120F1201101B120E0101100B1209001000A50002630E070",
                    INIT_66 => X"00D6005D00681A601B06005D110011211177116F116C1166117211651176114F",
                    INIT_67 => X"F0209001B020E683D120268FD1082688D10A2688D10DA1009001B02026530064",
                    INIT_68 => X"B0205000400C1001F0209001B020005D5000400C1000D10100065000400C1000",
                    INIT_69 => X"9001B020F0209001B020D10111080006D10111200006D10111080006A69E9002",
                    INIT_6A => X"0000000000000000000000000000000000000000000000005000400C1000F020",
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
                   INITP_00 => X"AAAAAA8296B6A2A8A2AAA7D41F5552935DD7776484785538820820820B0B0A2A",
                   INITP_01 => X"A4AAA8A4A9744888D34A8AAAA20AAAAAB4AAAA90AAA28B08A88AAAAAD8B6AB0A",
                   INITP_02 => X"8A029295554422A28A6AA2222A28A6AA18608A282AAAAAAAAAAAAB5A22A228A2",
                   INITP_03 => X"AAAAAAAA0AA111104443429998111122A28A88A28A92A2A8A4A8A9696B760AA2",
                   INITP_04 => X"620A615455554082A0AAAAAAAAAAAAAAAAAAAAB4A22A556556E234BA0002B7A3",
                   INITP_05 => X"AA02002359AAAA82A80800B6AAAAA82AA80005555135E355555114200295DAA8",
                   INITP_06 => X"3D478D54441410550451055045447800D446102002A10A40A00948B68A8AAAA0",
                   INITP_07 => X"AAAAAA28A2A90D2AAD136AA228AAA0A50AAAAAB6A5DA0D664A0A242800A0235E",
                   INITP_08 => X"A882D0A6AA122D0829AA848A2D0AA8A0A2AA88A298B420AAAAAAAAAAAAAAAAAA",
                   INITP_09 => X"AAAAAAAAAAAAAAAAAAAAAAA882AAAAAA222342A2A8D422280834A9AA8D45522A",
                   INITP_0A => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_0B => X"5114278D34492D479348AAAA9496A165DDA574D37602AAAAAAAAAAAAAAAAAAAA",
                   INITP_0C => X"9377744AA82AAAAABB6490AA8D6691375544413435812AAA20AAAAA82AAAAAAA",
                   INITP_0D => X"00000000000000000000000000000000000000000000009249228A2D249292A4",
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
                    INIT_00 => X"D0089000200A9000D008900020061000D00490002653D00B109B014F007100C7",
                    INIT_01 => X"5000D00290005000D01090005000D00490005000D02090005000D00190005000",
                    INIT_02 => X"50000030400E10010300E0300033001043064306430643060300E03000330020",
                    INIT_03 => X"D010100AA041902AA044D010100AA0419011A044D00AA04190305000400E1000",
                    INIT_04 => X"01009207204FE04FD2411237420E420E420E420E020050005000400E1000A044",
                    INIT_05 => X"D1010006110D5000D1010006D20100060045500091072056E056D1411137310F",
                    INIT_06 => X"20683B001A01D10100062070D1004BA05000D101113E00065000D1010006110A",
                    INIT_07 => X"00B700A000B600A65000009C00B700A600B600A000A95000DF045F021F015000",
                    INIT_08 => X"608D9D0100AC1D08208390004D0E009200A9208800A66087CED01D80500000A9",
                    INIT_09 => X"500000B6DF043FFE5000DE0100AC209200A95000009C00B700A000B600A65000",
                    INIT_0A => X"00B900A000B600A95000DF045F025000DF043FFD500020A2DC019C02DF045F01",
                    INIT_0B => X"500060BD9C011C01500000BC00BC00BC00BC00BC5000009C00B94E00DC029C02",
                    INIT_0C => X"00060045100100681AC01B00B001B03100D61100113A115611201149114C1143",
                    INIT_0D => X"E0E4D404B42C210DD300B3235000F023F020100050000064005DD1010006D201",
                    INIT_0E => X"0075007120EA9401450620EED40015109404B42CD005100120E8B42CD0051000",
                    INIT_0F => X"009900824E071E280075007102310231007C009900820E50009900824E061E28",
                    INIT_10 => X"1600F62316015000005D0057004000570030007C009704E0008C009103E0008C",
                    INIT_11 => X"11641165116C116911611166112011431132114950006110D608160100DAF62C",
                    INIT_12 => X"1B01005D0071110011211164116E116F11701173116511721120116F11741120",
                    INIT_13 => X"1E27160101431E23160101431E21162CD00510025000D009B02C205D00681A16",
                    INIT_14 => X"1002500000990082AE60009900821E09009900824E06007500715000007C0143",
                    INIT_15 => X"00821E00009900824E06007500715000007C01591E2101591E2301591E27D005",
                    INIT_16 => X"42064100420641004206A1001001A2001030D00510025000009900821E000099",
                    INIT_17 => X"00820E10009900824E60B62C1E30009900824E061E7300750071410042064100",
                    INIT_18 => X"1A01D10100062196D1FF2192D1004BA01AD81B045000007C009900820E200099",
                    INIT_19 => X"009900824E06BE3000750071D005B02C5000005D21883B001A03005D21883B00",
                    INIT_1A => X"009103E0008C009900824E07BE3000750071D005B02C5000007C00990082BE34",
                    INIT_1B => X"005D005790065000D006B02C5000005D0057004000570030007C009704E0008C",
                    INIT_1C => X"EC101101EB101141AE009001AD009001AC009001AB001003102CF140B1285000",
                    INIT_1D => X"1001AD001001AC001001AB001041625CC050B528B0405000EE101101ED101101",
                    INIT_1E => X"12001100022302230223021DA9009001A8009001A7009001A6001003102CAE00",
                    INIT_1F => X"0223021D021202090223021D021202090223021D021202090223021D02120209",
                    INIT_20 => X"44204410320402A0310101F014005000005D61F095017000D101000611207001",
                    INIT_21 => X"4D084C084B0E50007000D0011030221A10316219D00190060006700150000229",
                    INIT_22 => X"50000230340DD40654020230D40650004A00490848084708460E50004F004E08",
                    INIT_23 => X"116111201153114D11541120113A1152114F1152115211455000623190011019",
                    INIT_24 => X"116411201173116811741167116E1165116C1120114F1144115411201164116E",
                    INIT_25 => X"005D00681A341B0211001168116311741161116D11201174116F116E1120116F",
                    INIT_26 => X"140142004306420043064200430642004306A3401200143002861545B42C5000",
                    INIT_27 => X"15010057A05002861545B42C5000E3501501E25042404406440644064406A440",
                    INIT_28 => X"18261E001D03500022869401150115011000D4005000005DD20100060045A050",
                    INIT_29 => X"4708460E4708460E4708460EA7401401A640696068601600144502BF15041906",
                    INIT_2A => X"4708460FA7401401A6406294D4611401700002BF150370016E706D604708460E",
                    INIT_2B => X"021D500002BF150617FF18F819000E700D601CFF4708460F4708460F4708460F",
                    INIT_2C => X"021D02090223021D02090223021D02090223021D020912001100022302230223",
                    INIT_2D => X"03140314031419001800164502BF1504190618261E001D03500062C595010223",
                    INIT_2E => X"D6631601E9601601E86003140314031403140314031403140314180009800314",
                    INIT_2F => X"0314031403140314190018001C0602BF1504190618261E401D012294144562DB",
                    INIT_30 => X"00570090D2010006004500800314031403140314031403140314031418000980",
                    INIT_31 => X"500002BF150219FF18FF1E0050004808450E950602291400231A62FA9C01005D",
                    INIT_32 => X"18261E201D015000005D0057A07007501763B52C5000E67007501763B630B52C",
                    INIT_33 => X"70016DD06EE0ADF09F01AEF09F010229A4F01F0A1F631200130202BF15041906",
                    INIT_34 => X"9F014EA04A064A064A06AAF09F01AEF09F01700002BF15041600170018001900",
                    INIT_35 => X"1A00A9F09F014DA04A064A06AAF09F010D904EA04A08490E4A08490E1A00A9F0",
                    INIT_36 => X"4A06AAF09F010B904CA049004A061900AAF09F010C904DA04A08490E4A08490E",
                    INIT_37 => X"150270012387D2016EE0AEF09F01700002BF150770016BB06CC06DD06EE04BA0",
                    INIT_38 => X"190618261E201D01500002BF150418FF1980233512016335D3009301700002BF",
                    INIT_39 => X"80C0100803BE03AF18001609E89003AA10070314190A19631800022902BF1504",
                    INIT_3A => X"03BE23AA9001480E1000D0005000233513021200639BD6FF9601E890990103AA",
                    INIT_3B => X"1AB41B031C081C081C031C031C041C041C031C081C031C0823B010009C010314",
                    INIT_3C => X"10200006D001103A0006D1010006D201000600450030130050004BA03B000A60",
                    INIT_3D => X"23C5005D63D1D00330031301003023E0D3FFD1010006D20100060045A030D001",
                    INIT_3E => X"5000D00310FF50000424062705D80210B12BB227A3ECD004B02304245000005D",
                    INIT_3F => X"1120113A117211651166116611751142500000C75000D00BB02C5000D0031000",
                    INIT_40 => X"116F115711001120113A1174116E1175116F1163112011641172116F11571100",
                    INIT_41 => X"116F115711001120112011201120113A11731165117A11691173112011641172",
                    INIT_42 => X"24291101D001A0100006E430C120B220110000681AF81B031100112011641172",
                    INIT_43 => X"005DD00110290006D1010006D201000600450020D00110280006D00110200006",
                    INIT_44 => X"10200006E45EC3401300B423D1010006D20100060045B023000600681A011B04",
                    INIT_45 => X"1B04005D244C1301D1010006D20100060045A01001301124D00110400006D001",
                    INIT_46 => X"0006D20100060045A01001301128D00110200006E473C3401300B42300681A0E",
                    INIT_47 => X"D20100060045003000681A1E1B04005DE496C3401300B423005D24641301D101",
                    INIT_48 => X"0045A060A476C65016030650152C4506450613010530D00110200006D1010006",
                    INIT_49 => X"05500550D0075010B02C04A3D004B02C5000005D248C9601D1010006D2010006",
                    INIT_4A => X"D0085000F02C100064A9BA009B021B201A04D00A1000D00A10015000D0071000",
                    INIT_4B => X"90070057900700579007005790071000D501350195055000005D005790055000",
                    INIT_4C => X"00681AC31B0411001120113A116E116F1169117311721165115624B5005D0057",
                    INIT_4D => X"11671172116111691174116C1175116D5000005DD1010006D201000600451001",
                    INIT_4E => X"11731165117211C4110311001170116D11751164116D1165116D11E211031100",
                    INIT_4F => X"117311CD11041100116E116F1169117311721165117611F61103110011741165",
                    INIT_50 => X"11651177116F11701186110111001170116C1165116811241104110011731179",
                    INIT_51 => X"11661166116F115F117211651177116F117011ED11031100116E116F115F1172",
                    INIT_52 => X"110111001172116A11BA110111001177116A11DA11001100116111F011031100",
                    INIT_53 => X"11C1110111001164116A11A511011100117211691198110111001177116911BD",
                    INIT_54 => X"1102110011721174116A11611102110011771174116A11D511011100116D116A",
                    INIT_55 => X"11731174116A11D41102110011671174116A118D1102110011751174116A117A",
                    INIT_56 => X"1100117A117411B111041100116611741198110411001163117411F311021100",
                    INIT_57 => X"11721161116A11201103110011771161116A11B5110411001172117411AF1104",
                    INIT_58 => X"1173118C1103110011671161116A112D1103110011751161116A112611031100",
                    INIT_59 => X"1103110011701174116511011100116411361101110011701133110111001170",
                    INIT_5A => X"D1FF25C7D1004BA012001AD81B0411FF114F11011100116F11691170116711F3",
                    INIT_5B => X"25C3D10025D4D1FF4BA025AC3B001A01120165BBC010A020E5BBC200B02025D4",
                    INIT_5C => X"4BA03B001A0102104BA03B001A01062705D825AC12003B001A0325BB3B001A01",
                    INIT_5D => X"00331201A020E602C210B120F023100050000064060F00D65000006400D64210",
                    INIT_5E => X"0310A5F0C310B12013080320E21001001123F0232602D0051001B0239201E5DA",
                    INIT_5F => X"90011028B0238300A01091011124B123032025F01201E5F70033A02025F7C320",
                    INIT_60 => X"1B0611001164116E1161116D116D116F11631120116411611142500025DAE300",
                    INIT_61 => X"002000681A141B0611001120113A1172116F1172117211455000005D00681A03",
                    INIT_62 => X"1400A62AC1201101E0101000112C120412385000005DD1010006D20100060045",
                    INIT_63 => X"96021401172C4706470607400650A61001401128A50000401024E652C400B023",
                    INIT_64 => X"0033A0606630C6501601263F1701E07000209601A1601601A260A64BC650A630",
                    INIT_65 => X"265385A90672E66AD120F1201101B120E0101100B1209001000A50002630E070",
                    INIT_66 => X"00D6005D00681A601B06005D110011211177116F116C1166117211651176114F",
                    INIT_67 => X"F0209001B020E683D120268FD1082688D10A2688D10DA1009001B02026530064",
                    INIT_68 => X"B0205000400C1001F0209001B020005D5000400C1000D10100065000400C1000",
                    INIT_69 => X"9001B020F0209001B020D10111080006D10111200006D10111080006A69E9002",
                    INIT_6A => X"0000000000000000000000000000000000000000000000005000400C1000F020",
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
                   INITP_00 => X"AAAAAA8296B6A2A8A2AAA7D41F5552935DD7776484785538820820820B0B0A2A",
                   INITP_01 => X"A4AAA8A4A9744888D34A8AAAA20AAAAAB4AAAA90AAA28B08A88AAAAAD8B6AB0A",
                   INITP_02 => X"8A029295554422A28A6AA2222A28A6AA18608A282AAAAAAAAAAAAB5A22A228A2",
                   INITP_03 => X"AAAAAAAA0AA111104443429998111122A28A88A28A92A2A8A4A8A9696B760AA2",
                   INITP_04 => X"620A615455554082A0AAAAAAAAAAAAAAAAAAAAB4A22A556556E234BA0002B7A3",
                   INITP_05 => X"AA02002359AAAA82A80800B6AAAAA82AA80005555135E355555114200295DAA8",
                   INITP_06 => X"3D478D54441410550451055045447800D446102002A10A40A00948B68A8AAAA0",
                   INITP_07 => X"AAAAAA28A2A90D2AAD136AA228AAA0A50AAAAAB6A5DA0D664A0A242800A0235E",
                   INITP_08 => X"A882D0A6AA122D0829AA848A2D0AA8A0A2AA88A298B420AAAAAAAAAAAAAAAAAA",
                   INITP_09 => X"AAAAAAAAAAAAAAAAAAAAAAA882AAAAAA222342A2A8D422280834A9AA8D45522A",
                   INITP_0A => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_0B => X"5114278D34492D479348AAAA9496A165DDA574D37602AAAAAAAAAAAAAAAAAAAA",
                   INITP_0C => X"9377744AA82AAAAABB6490AA8D6691375544413435812AAA20AAAAA82AAAAAAA",
                   INITP_0D => X"00000000000000000000000000000000000000000000009249228A2D249292A4",
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
                    INIT_00 => X"0002000010000004000020000001000008000A00080006000400530B9B4F71C7",
                    INIT_01 => X"100A412A44100A4111440A4130000E0000300E01003033100606060600303320",
                    INIT_02 => X"01060D0001060106450007565641370F00074F4F41370E0E0E0E0000000E0044",
                    INIT_03 => X"B7A0B6A6009CB7A6B6A0A9000402010068000101067000A000013E060001060A",
                    INIT_04 => X"00B604FE0001AC92A9009CB7A0B6A6008D01AC0883000E92A988A687D08000A9",
                    INIT_05 => X"00BD010100BCBCBCBCBC009CB9000202B9A0B6A90004020004FD00A201020401",
                    INIT_06 => X"E4042C0D00230023200000645D01060106450168C0000131D6003A5620494C43",
                    INIT_07 => X"99820728757131317C998250998206287571EA0106EE0010042C0501E82C0500",
                    INIT_08 => X"64656C6961662043324900100801DA2C002301005D574057307C97E08C91E08C",
                    INIT_09 => X"270143230143212C050200092C5D6816015D710021646E6F70736572206F7420",
                    INIT_0A => X"82009982067571007C5921592359270502009982609982099982067571007C43",
                    INIT_0B => X"82109982602C3099820673757100060006000600060001003005020099820099",
                    INIT_0C => X"998206307571052C005D8800035D880001010696FF9200A0D804007C99822099",
                    INIT_0D => X"5D570600062C005D574057307C97E08C91E08C998207307571052C007C998234",
                    INIT_0E => X"010001000100415C50284000100110011001104100010001000100032C402800",
                    INIT_0F => X"231D1209231D1209231D1209231D120900002323231D00010001000100032C00",
                    INIT_10 => X"08080E000001301A3119010606010029201004A001F000005DF0010001062001",
                    INIT_11 => X"6120534D54203A524F5252450031011900300D0602300600000808080E000008",
                    INIT_12 => X"5D68340200686374616D20746F6E206F6420736874676E656C204F445420646E",
                    INIT_13 => X"01575086452C0050015040060606064001000600060006000640003086452C00",
                    INIT_14 => X"080E080E080E40014060600045BF040626000300860101010000005D01064550",
                    INIT_15 => X"1D00BF06FFF8007060FF080F080F080F080F40014094610100BF03017060080E",
                    INIT_16 => X"141414000045BF040626000300C501231D09231D09231D09231D090000232323",
                    INIT_17 => X"14141414000006BF04062640019445DB63016001601414141414141414008014",
                    INIT_18 => X"00BF02FFFF0000080E0629001AFA015D57900106458014141414141414140080",
                    INIT_19 => X"01D0E0F001F00129F00A630002BF0406262001005D577050632C00705063302C",
                    INIT_1A => X"00F001A00606F00190A0080E080E00F001A0060606F001F00100BF0400000000",
                    INIT_1B => X"02018701E0F00100BF0701B0C0D0E0A006F00190A0000600F00190A0080E080E",
                    INIT_1C => X"C008BEAF000990AA07140A630029BF040626200100BF04FF80350135000100BF",
                    INIT_1D => X"B40308080303040403080308B0000114BEAA010E0000003502009BFF019001AA",
                    INIT_1E => X"C55DD103030130E0FF010601064530012006013A060106010645300000A00060",
                    INIT_1F => X"203A72656666754200C7000B2C0003000003FF002427D8102B27EC042324005D",
                    INIT_20 => X"6F5700202020203A73657A69732064726F5700203A746E756F632064726F5700",
                    INIT_21 => X"5D01290601060106452001280601200629010110063020200068F80300206472",
                    INIT_22 => X"045D4C0101060106451030240140060120065E40002301060106452306680104",
                    INIT_23 => X"01064530681E045D964000235D6401010601064510302801200673400023680E",
                    INIT_24 => X"505007102CA3042C005D8C01010601064560765003502C060601300120060106",
                    INIT_25 => X"0757075707570700010105005D57050008002C00A9000220040A000A01000700",
                    INIT_26 => X"67726169746C756D005D01060106450168C30400203A6E6F6973726556B55D57",
                    INIT_27 => X"73CD04006E6F6973726576F603007465736572C40300706D75646D656DE20300",
                    INIT_28 => X"66666F5F7265776F70ED03006E6F5F7265776F70860100706C65682404007379",
                    INIT_29 => X"C10100646AA5010072699801007769BD0100726ABA0100776ADA000061F00300",
                    INIT_2A => X"73746AD4020067746A8D020075746A7A020072746A61020077746AD501006D6A",
                    INIT_2B => X"72616A20030077616AB504007274AF04007A74B1040066749804006374F30200",
                    INIT_2C => X"03007074650100643601007033010070738C030067616A2D030075616A260300",
                    INIT_2D => X"C300D4FFA0AC000101BB1020BB0020D4FFC700A000D804FF4F01006F697067F3",
                    INIT_2E => X"330120021020230000640FD60064D610A0000110A0000127D8AC000003BB0001",
                    INIT_2F => X"012823001001242320F001F73320F72010F010200820100023230205012301DA",
                    INIT_30 => X"2068140600203A726F727245005D68030600646E616D6D6F632064614200DA00",
                    INIT_31 => X"02012C06064050104028004024520023002A200110002C0438005D0106010645",
                    INIT_32 => X"53A9726A20200120100020010A00307033603050013F017020016001604B5030",
                    INIT_33 => X"20012083208F08880A880D0001205364D65D6860065D0021776F6C667265764F",
                    INIT_34 => X"01202001200108060120060108069E0220000C012001205D000C000106000C00",
                    INIT_35 => X"00000000000000000000000000000000000000000000000000000000000C0020",
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
                   INITP_00 => X"000009001C04047F000006C330005204000E5365A8278000000008F800000004",
                   INITP_01 => X"00004220444772260000400000335F40000554000054000124009FFFFFD00002",
                   INITP_02 => X"F8C827FBF19200081AAAA026AA43230089802AC41FFFFFFFFFF00052A0000C6A",
                   INITP_03 => X"FF0002A0A5C004164009C1A3317192DCA2553555719582955A6B21CD30C803FD",
                   INITP_04 => X"FFFFFFFFFF203FF800E00300C00803E20263061898301A010800429FFFFFFFFF",
                   INITP_05 => X"17D3FD810400CCD6FE49F3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_06 => X"00000000000000000000000006D800100AB00BFF4F6002203CE032101FF0FFFB",
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
                    INIT_00 => X"28684828684828684828684828684828684810C8684810886848136808000000",
                    INIT_01 => X"E888D0C8D0E888D0C8D0E8D0C828A0082800A00881F00000A1A1A1A101F00000",
                    INIT_02 => X"68000828680069000028C890F0E8881800C990F0E989A1A1A1A1012828A008D0",
                    INIT_03 => X"0000000028000000000000286F2F0F28109D8D680090E8252868080028680008",
                    INIT_04 => X"28006F1F286F00100028000000000028B0CE000E10C8A600001000B0670E2800",
                    INIT_05 => X"28B0CE0E280000000000280000A76E4E00000000286F2F286F1F28906E4E6F2F",
                    INIT_06 => X"F0EA5A90E95928787808280000680069000008000D0D58580008080808080808",
                    INIT_07 => X"0000A70F00000101000000070000A70F000010CAA290EA0ACA5A6808105A6808",
                    INIT_08 => X"0808080808080808080828B0EB8B007B0B7B0B28000000000000000200000100",
                    INIT_09 => X"0F8B000F8B000F0B680828685810000D0D000008080808080808080808080808",
                    INIT_0A => X"000F0000A700002800000F000F000F68082800005700000F0000A70000280000",
                    INIT_0B => X"00070000275B0F0000A70F0000A0A1A0A1A0A1A0A15088510868082800000F00",
                    INIT_0C => X"0000A75F000068582800109D8D00109D8D680090E890E8250D0D280000000700",
                    INIT_0D => X"000048286858280000000000000002000001000000A75F00006858280000005F",
                    INIT_0E => X"88568856885508B1E05A5828778876887688750857C856C856C8558808785828",
                    INIT_0F => X"0101010101010101010101010101010109080101010154C854C853C853880857",
                    INIT_10 => X"A6A6A528B868081108B1E84800B828012222190118000A2800B0CAB8680008B8",
                    INIT_11 => X"08080808080808080808080828B1C80828011A6A2A016A28A5A4A4A3A328A7A7",
                    INIT_12 => X"00000D0D08080808080808080808080808080808080808080808080808080808",
                    INIT_13 => X"8A0050010A5A28718A7121A2A2A2A2528AA1A1A1A1A1A1A1A151090A010A5A28",
                    INIT_14 => X"A3A3A3A3A3A3538A53B4B40B0A010A0C0C0F0E2811CA8A8A88EA280069000050",
                    INIT_15 => X"0128010A0B0C0C07060EA3A3A3A3A3A3A3A3538A53B1EA8AB8010AB8B7B6A3A3",
                    INIT_16 => X"0101010C0C0B010A0C0C0F0E28B1CA0101010101010101010101010908010101",
                    INIT_17 => X"010101010C0C0E010A0C0C0F0E110AB1EB8B748B7401010101010101010C0401",
                    INIT_18 => X"28010A0C0C0F28A4A24A010A11B1CE0000006900000001010101010101010C04",
                    INIT_19 => X"B8B6B756CF57CF01528F0F0909010A0C0C0F0E28000050830B5A2873830B5B5A",
                    INIT_1A => X"0D54CF26A5A555CF0627A5A4A5A40D54CF27A5A5A555CF57CFB8010A0B0B0C0C",
                    INIT_1B => X"0AB891E9B757CFB8010AB8B5B6B6B725A555CF0526A4A50C55CF0626A5A4A5A4",
                    INIT_1C => X"C00801010C0B740108018C0C0C01010A0C0C0F0E28010A0C0C1109B1E9C9B801",
                    INIT_1D => X"0D0D0E0E0E0E0E0E0E0E0E0E1188CE010111C8A488E828110909B1EBCB74CC01",
                    INIT_1E => X"1100B1E818890091E96800690000506808006808006800690000000928259D85",
                    INIT_1F => X"0808080808080808280028685828680828680828020302815859D1E858022800",
                    INIT_20 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_21 => X"006808006800690000006808006808001288685000F2E05908000D0D08080808",
                    INIT_22 => X"0D0012896800690000508008680800680800F2E1095A68006900005800000D0D",
                    INIT_23 => X"69000000000D0D00F2E1095A0012896800690000508008680800F2E1095A000D",
                    INIT_24 => X"020268285882E858280012CB680069000050D2E38B038AA2A289026808006800",
                    INIT_25 => X"4800480048004888EA1A4A280000482868287808B2DDCD0D0D68086808286808",
                    INIT_26 => X"08080808080808082800680069000008000D0D08080808080808080808120000",
                    INIT_27 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_28 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_29 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2A => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2B => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2C => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2D => X"92E892E825129D8D89B2E050F2E15892E892E825090D0D080808080808080808",
                    INIT_2E => X"008950F3E15878082800030028000021259D8D01259D8D030212099D8D129D8D",
                    INIT_2F => X"C88858C150C88858011289F2005092E101D2E15889017180087893E88858C9F2",
                    INIT_30 => X"00000D0D08080808080808082800000D0D080808080808080808080808281271",
                    INIT_31 => X"CB8A8BA3A30383538008528008F3E2580AD3E088700808890928006800690000",
                    INIT_32 => X"13C203F3E878885870885848002813700050B3E38B138B7000CB508B51D3E3D3",
                    INIT_33 => X"78C858F3E893E893E893E850C85813000000000D0D0008080808080808080808",
                    INIT_34 => X"C85878C858680800680800680800D3C85828A00878C8580028A008680028A008",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000028A00878",
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
                   INITP_00 => X"CFECE42A93BFD3FFCFF8FDB2EBFFADF3FFF99DDEDFD830192954860692493337",
                   INITP_01 => X"FFFF3C00011AA005DBADB9DECEE6753DB198005DB7D576DF24B67FFFFFF35D6D",
                   INITP_02 => X"F1052FF9E20DFFE7E00004D0000418BE53400009CFFFFFFFFFFCD7041D4F01DD",
                   INITP_03 => X"FFF6DE27E17D6FCC3FFDCB2533460C5361A000000000006081041C30C22DBBFC",
                   INITP_04 => X"FFFFFFFFFFFE9FFF551DE85624EFA017E98DF1626F8B63ECDFADAC4FFFFFFFFF",
                   INITP_05 => X"005A426192FF89C4AC4951FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_06 => X"00000000000000000000000925B6499C9543E7FFF48FA5850004487F4FFE7FFF",
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
                    INIT_00 => X"0002000010000004000020000001000008000A00080006000400530B9B4F71C7",
                    INIT_01 => X"100A412A44100A4111440A4130000E0000300E01003033100606060600303320",
                    INIT_02 => X"01060D0001060106450007565641370F00074F4F41370E0E0E0E0000000E0044",
                    INIT_03 => X"B7A0B6A6009CB7A6B6A0A9000402010068000101067000A000013E060001060A",
                    INIT_04 => X"00B604FE0001AC92A9009CB7A0B6A6008D01AC0883000E92A988A687D08000A9",
                    INIT_05 => X"00BD010100BCBCBCBCBC009CB9000202B9A0B6A90004020004FD00A201020401",
                    INIT_06 => X"E4042C0D00230023200000645D01060106450168C0000131D6003A5620494C43",
                    INIT_07 => X"99820728757131317C998250998206287571EA0106EE0010042C0501E82C0500",
                    INIT_08 => X"64656C6961662043324900100801DA2C002301005D574057307C97E08C91E08C",
                    INIT_09 => X"270143230143212C050200092C5D6816015D710021646E6F70736572206F7420",
                    INIT_0A => X"82009982067571007C5921592359270502009982609982099982067571007C43",
                    INIT_0B => X"82109982602C3099820673757100060006000600060001003005020099820099",
                    INIT_0C => X"998206307571052C005D8800035D880001010696FF9200A0D804007C99822099",
                    INIT_0D => X"5D570600062C005D574057307C97E08C91E08C998207307571052C007C998234",
                    INIT_0E => X"010001000100415C50284000100110011001104100010001000100032C402800",
                    INIT_0F => X"231D1209231D1209231D1209231D120900002323231D00010001000100032C00",
                    INIT_10 => X"08080E000001301A3119010606010029201004A001F000005DF0010001062001",
                    INIT_11 => X"6120534D54203A524F5252450031011900300D0602300600000808080E000008",
                    INIT_12 => X"5D68340200686374616D20746F6E206F6420736874676E656C204F445420646E",
                    INIT_13 => X"01575086452C0050015040060606064001000600060006000640003086452C00",
                    INIT_14 => X"080E080E080E40014060600045BF040626000300860101010000005D01064550",
                    INIT_15 => X"1D00BF06FFF8007060FF080F080F080F080F40014094610100BF03017060080E",
                    INIT_16 => X"141414000045BF040626000300C501231D09231D09231D09231D090000232323",
                    INIT_17 => X"14141414000006BF04062640019445DB63016001601414141414141414008014",
                    INIT_18 => X"00BF02FFFF0000080E0629001AFA015D57900106458014141414141414140080",
                    INIT_19 => X"01D0E0F001F00129F00A630002BF0406262001005D577050632C00705063302C",
                    INIT_1A => X"00F001A00606F00190A0080E080E00F001A0060606F001F00100BF0400000000",
                    INIT_1B => X"02018701E0F00100BF0701B0C0D0E0A006F00190A0000600F00190A0080E080E",
                    INIT_1C => X"C008BEAF000990AA07140A630029BF040626200100BF04FF80350135000100BF",
                    INIT_1D => X"B40308080303040403080308B0000114BEAA010E0000003502009BFF019001AA",
                    INIT_1E => X"C55DD103030130E0FF010601064530012006013A060106010645300000A00060",
                    INIT_1F => X"203A72656666754200C7000B2C0003000003FF002427D8102B27EC042324005D",
                    INIT_20 => X"6F5700202020203A73657A69732064726F5700203A746E756F632064726F5700",
                    INIT_21 => X"5D01290601060106452001280601200629010110063020200068F80300206472",
                    INIT_22 => X"045D4C0101060106451030240140060120065E40002301060106452306680104",
                    INIT_23 => X"01064530681E045D964000235D6401010601064510302801200673400023680E",
                    INIT_24 => X"505007102CA3042C005D8C01010601064560765003502C060601300120060106",
                    INIT_25 => X"0757075707570700010105005D57050008002C00A9000220040A000A01000700",
                    INIT_26 => X"67726169746C756D005D01060106450168C30400203A6E6F6973726556B55D57",
                    INIT_27 => X"73CD04006E6F6973726576F603007465736572C40300706D75646D656DE20300",
                    INIT_28 => X"66666F5F7265776F70ED03006E6F5F7265776F70860100706C65682404007379",
                    INIT_29 => X"C10100646AA5010072699801007769BD0100726ABA0100776ADA000061F00300",
                    INIT_2A => X"73746AD4020067746A8D020075746A7A020072746A61020077746AD501006D6A",
                    INIT_2B => X"72616A20030077616AB504007274AF04007A74B1040066749804006374F30200",
                    INIT_2C => X"03007074650100643601007033010070738C030067616A2D030075616A260300",
                    INIT_2D => X"C300D4FFA0AC000101BB1020BB0020D4FFC700A000D804FF4F01006F697067F3",
                    INIT_2E => X"330120021020230000640FD60064D610A0000110A0000127D8AC000003BB0001",
                    INIT_2F => X"012823001001242320F001F73320F72010F010200820100023230205012301DA",
                    INIT_30 => X"2068140600203A726F727245005D68030600646E616D6D6F632064614200DA00",
                    INIT_31 => X"02012C06064050104028004024520023002A200110002C0438005D0106010645",
                    INIT_32 => X"53A9726A20200120100020010A00307033603050013F017020016001604B5030",
                    INIT_33 => X"20012083208F08880A880D0001205364D65D6860065D0021776F6C667265764F",
                    INIT_34 => X"01202001200108060120060108069E0220000C012001205D000C000106000C00",
                    INIT_35 => X"00000000000000000000000000000000000000000000000000000000000C0020",
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
                   INITP_00 => X"000009001C04047F000006C330005204000E5365A8278000000008F800000004",
                   INITP_01 => X"00004220444772260000400000335F40000554000054000124009FFFFFD00002",
                   INITP_02 => X"F8C827FBF19200081AAAA026AA43230089802AC41FFFFFFFFFF00052A0000C6A",
                   INITP_03 => X"FF0002A0A5C004164009C1A3317192DCA2553555719582955A6B21CD30C803FD",
                   INITP_04 => X"FFFFFFFFFF203FF800E00300C00803E20263061898301A010800429FFFFFFFFF",
                   INITP_05 => X"17D3FD810400CCD6FE49F3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_06 => X"00000000000000000000000006D800100AB00BFF4F6002203CE032101FF0FFFB",
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
                    INIT_00 => X"28684828684828684828684828684828684810C8684810886848136808000000",
                    INIT_01 => X"E888D0C8D0E888D0C8D0E8D0C828A0082800A00881F00000A1A1A1A101F00000",
                    INIT_02 => X"68000828680069000028C890F0E8881800C990F0E989A1A1A1A1012828A008D0",
                    INIT_03 => X"0000000028000000000000286F2F0F28109D8D680090E8252868080028680008",
                    INIT_04 => X"28006F1F286F00100028000000000028B0CE000E10C8A600001000B0670E2800",
                    INIT_05 => X"28B0CE0E280000000000280000A76E4E00000000286F2F286F1F28906E4E6F2F",
                    INIT_06 => X"F0EA5A90E95928787808280000680069000008000D0D58580008080808080808",
                    INIT_07 => X"0000A70F00000101000000070000A70F000010CAA290EA0ACA5A6808105A6808",
                    INIT_08 => X"0808080808080808080828B0EB8B007B0B7B0B28000000000000000200000100",
                    INIT_09 => X"0F8B000F8B000F0B680828685810000D0D000008080808080808080808080808",
                    INIT_0A => X"000F0000A700002800000F000F000F68082800005700000F0000A70000280000",
                    INIT_0B => X"00070000275B0F0000A70F0000A0A1A0A1A0A1A0A15088510868082800000F00",
                    INIT_0C => X"0000A75F000068582800109D8D00109D8D680090E890E8250D0D280000000700",
                    INIT_0D => X"000048286858280000000000000002000001000000A75F00006858280000005F",
                    INIT_0E => X"88568856885508B1E05A5828778876887688750857C856C856C8558808785828",
                    INIT_0F => X"0101010101010101010101010101010109080101010154C854C853C853880857",
                    INIT_10 => X"A6A6A528B868081108B1E84800B828012222190118000A2800B0CAB8680008B8",
                    INIT_11 => X"08080808080808080808080828B1C80828011A6A2A016A28A5A4A4A3A328A7A7",
                    INIT_12 => X"00000D0D08080808080808080808080808080808080808080808080808080808",
                    INIT_13 => X"8A0050010A5A28718A7121A2A2A2A2528AA1A1A1A1A1A1A1A151090A010A5A28",
                    INIT_14 => X"A3A3A3A3A3A3538A53B4B40B0A010A0C0C0F0E2811CA8A8A88EA280069000050",
                    INIT_15 => X"0128010A0B0C0C07060EA3A3A3A3A3A3A3A3538A53B1EA8AB8010AB8B7B6A3A3",
                    INIT_16 => X"0101010C0C0B010A0C0C0F0E28B1CA0101010101010101010101010908010101",
                    INIT_17 => X"010101010C0C0E010A0C0C0F0E110AB1EB8B748B7401010101010101010C0401",
                    INIT_18 => X"28010A0C0C0F28A4A24A010A11B1CE0000006900000001010101010101010C04",
                    INIT_19 => X"B8B6B756CF57CF01528F0F0909010A0C0C0F0E28000050830B5A2873830B5B5A",
                    INIT_1A => X"0D54CF26A5A555CF0627A5A4A5A40D54CF27A5A5A555CF57CFB8010A0B0B0C0C",
                    INIT_1B => X"0AB891E9B757CFB8010AB8B5B6B6B725A555CF0526A4A50C55CF0626A5A4A5A4",
                    INIT_1C => X"C00801010C0B740108018C0C0C01010A0C0C0F0E28010A0C0C1109B1E9C9B801",
                    INIT_1D => X"0D0D0E0E0E0E0E0E0E0E0E0E1188CE010111C8A488E828110909B1EBCB74CC01",
                    INIT_1E => X"1100B1E818890091E96800690000506808006808006800690000000928259D85",
                    INIT_1F => X"0808080808080808280028685828680828680828020302815859D1E858022800",
                    INIT_20 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_21 => X"006808006800690000006808006808001288685000F2E05908000D0D08080808",
                    INIT_22 => X"0D0012896800690000508008680800680800F2E1095A68006900005800000D0D",
                    INIT_23 => X"69000000000D0D00F2E1095A0012896800690000508008680800F2E1095A000D",
                    INIT_24 => X"020268285882E858280012CB680069000050D2E38B038AA2A289026808006800",
                    INIT_25 => X"4800480048004888EA1A4A280000482868287808B2DDCD0D0D68086808286808",
                    INIT_26 => X"08080808080808082800680069000008000D0D08080808080808080808120000",
                    INIT_27 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_28 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_29 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2A => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2B => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2C => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2D => X"92E892E825129D8D89B2E050F2E15892E892E825090D0D080808080808080808",
                    INIT_2E => X"008950F3E15878082800030028000021259D8D01259D8D030212099D8D129D8D",
                    INIT_2F => X"C88858C150C88858011289F2005092E101D2E15889017180087893E88858C9F2",
                    INIT_30 => X"00000D0D08080808080808082800000D0D080808080808080808080808281271",
                    INIT_31 => X"CB8A8BA3A30383538008528008F3E2580AD3E088700808890928006800690000",
                    INIT_32 => X"13C203F3E878885870885848002813700050B3E38B138B7000CB508B51D3E3D3",
                    INIT_33 => X"78C858F3E893E893E893E850C85813000000000D0D0008080808080808080808",
                    INIT_34 => X"C85878C858680800680800680800D3C85828A00878C8580028A008680028A008",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000028A00878",
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
                   INITP_00 => X"CFECE42A93BFD3FFCFF8FDB2EBFFADF3FFF99DDEDFD830192954860692493337",
                   INITP_01 => X"FFFF3C00011AA005DBADB9DECEE6753DB198005DB7D576DF24B67FFFFFF35D6D",
                   INITP_02 => X"F1052FF9E20DFFE7E00004D0000418BE53400009CFFFFFFFFFFCD7041D4F01DD",
                   INITP_03 => X"FFF6DE27E17D6FCC3FFDCB2533460C5361A000000000006081041C30C22DBBFC",
                   INITP_04 => X"FFFFFFFFFFFE9FFF551DE85624EFA017E98DF1626F8B63ECDFADAC4FFFFFFFFF",
                   INITP_05 => X"005A426192FF89C4AC4951FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_06 => X"00000000000000000000000925B6499C9543E7FFF48FA5850004487F4FFE7FFF",
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
                    INIT_00 => X"0002000010000004000020000001000008000A00080006000400530B9B4F71C7",
                    INIT_01 => X"100A412A44100A4111440A4130000E0000300E01003033100606060600303320",
                    INIT_02 => X"01060D0001060106450007565641370F00074F4F41370E0E0E0E0000000E0044",
                    INIT_03 => X"B7A0B6A6009CB7A6B6A0A9000402010068000101067000A000013E060001060A",
                    INIT_04 => X"00B604FE0001AC92A9009CB7A0B6A6008D01AC0883000E92A988A687D08000A9",
                    INIT_05 => X"00BD010100BCBCBCBCBC009CB9000202B9A0B6A90004020004FD00A201020401",
                    INIT_06 => X"E4042C0D00230023200000645D01060106450168C0000131D6003A5620494C43",
                    INIT_07 => X"99820728757131317C998250998206287571EA0106EE0010042C0501E82C0500",
                    INIT_08 => X"64656C6961662043324900100801DA2C002301005D574057307C97E08C91E08C",
                    INIT_09 => X"270143230143212C050200092C5D6816015D710021646E6F70736572206F7420",
                    INIT_0A => X"82009982067571007C5921592359270502009982609982099982067571007C43",
                    INIT_0B => X"82109982602C3099820673757100060006000600060001003005020099820099",
                    INIT_0C => X"998206307571052C005D8800035D880001010696FF9200A0D804007C99822099",
                    INIT_0D => X"5D570600062C005D574057307C97E08C91E08C998207307571052C007C998234",
                    INIT_0E => X"010001000100415C50284000100110011001104100010001000100032C402800",
                    INIT_0F => X"231D1209231D1209231D1209231D120900002323231D00010001000100032C00",
                    INIT_10 => X"08080E000001301A3119010606010029201004A001F000005DF0010001062001",
                    INIT_11 => X"6120534D54203A524F5252450031011900300D0602300600000808080E000008",
                    INIT_12 => X"5D68340200686374616D20746F6E206F6420736874676E656C204F445420646E",
                    INIT_13 => X"01575086452C0050015040060606064001000600060006000640003086452C00",
                    INIT_14 => X"080E080E080E40014060600045BF040626000300860101010000005D01064550",
                    INIT_15 => X"1D00BF06FFF8007060FF080F080F080F080F40014094610100BF03017060080E",
                    INIT_16 => X"141414000045BF040626000300C501231D09231D09231D09231D090000232323",
                    INIT_17 => X"14141414000006BF04062640019445DB63016001601414141414141414008014",
                    INIT_18 => X"00BF02FFFF0000080E0629001AFA015D57900106458014141414141414140080",
                    INIT_19 => X"01D0E0F001F00129F00A630002BF0406262001005D577050632C00705063302C",
                    INIT_1A => X"00F001A00606F00190A0080E080E00F001A0060606F001F00100BF0400000000",
                    INIT_1B => X"02018701E0F00100BF0701B0C0D0E0A006F00190A0000600F00190A0080E080E",
                    INIT_1C => X"C008BEAF000990AA07140A630029BF040626200100BF04FF80350135000100BF",
                    INIT_1D => X"B40308080303040403080308B0000114BEAA010E0000003502009BFF019001AA",
                    INIT_1E => X"C55DD103030130E0FF010601064530012006013A060106010645300000A00060",
                    INIT_1F => X"203A72656666754200C7000B2C0003000003FF002427D8102B27EC042324005D",
                    INIT_20 => X"6F5700202020203A73657A69732064726F5700203A746E756F632064726F5700",
                    INIT_21 => X"5D01290601060106452001280601200629010110063020200068F80300206472",
                    INIT_22 => X"045D4C0101060106451030240140060120065E40002301060106452306680104",
                    INIT_23 => X"01064530681E045D964000235D6401010601064510302801200673400023680E",
                    INIT_24 => X"505007102CA3042C005D8C01010601064560765003502C060601300120060106",
                    INIT_25 => X"0757075707570700010105005D57050008002C00A9000220040A000A01000700",
                    INIT_26 => X"67726169746C756D005D01060106450168C30400203A6E6F6973726556B55D57",
                    INIT_27 => X"73CD04006E6F6973726576F603007465736572C40300706D75646D656DE20300",
                    INIT_28 => X"66666F5F7265776F70ED03006E6F5F7265776F70860100706C65682404007379",
                    INIT_29 => X"C10100646AA5010072699801007769BD0100726ABA0100776ADA000061F00300",
                    INIT_2A => X"73746AD4020067746A8D020075746A7A020072746A61020077746AD501006D6A",
                    INIT_2B => X"72616A20030077616AB504007274AF04007A74B1040066749804006374F30200",
                    INIT_2C => X"03007074650100643601007033010070738C030067616A2D030075616A260300",
                    INIT_2D => X"C300D4FFA0AC000101BB1020BB0020D4FFC700A000D804FF4F01006F697067F3",
                    INIT_2E => X"330120021020230000640FD60064D610A0000110A0000127D8AC000003BB0001",
                    INIT_2F => X"012823001001242320F001F73320F72010F010200820100023230205012301DA",
                    INIT_30 => X"2068140600203A726F727245005D68030600646E616D6D6F632064614200DA00",
                    INIT_31 => X"02012C06064050104028004024520023002A200110002C0438005D0106010645",
                    INIT_32 => X"53A9726A20200120100020010A00307033603050013F017020016001604B5030",
                    INIT_33 => X"20012083208F08880A880D0001205364D65D6860065D0021776F6C667265764F",
                    INIT_34 => X"01202001200108060120060108069E0220000C012001205D000C000106000C00",
                    INIT_35 => X"00000000000000000000000000000000000000000000000000000000000C0020",
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
                   INITP_00 => X"000009001C04047F000006C330005204000E5365A8278000000008F800000004",
                   INITP_01 => X"00004220444772260000400000335F40000554000054000124009FFFFFD00002",
                   INITP_02 => X"F8C827FBF19200081AAAA026AA43230089802AC41FFFFFFFFFF00052A0000C6A",
                   INITP_03 => X"FF0002A0A5C004164009C1A3317192DCA2553555719582955A6B21CD30C803FD",
                   INITP_04 => X"FFFFFFFFFF203FF800E00300C00803E20263061898301A010800429FFFFFFFFF",
                   INITP_05 => X"17D3FD810400CCD6FE49F3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_06 => X"00000000000000000000000006D800100AB00BFF4F6002203CE032101FF0FFFB",
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
                    INIT_00 => X"28684828684828684828684828684828684810C8684810886848136808000000",
                    INIT_01 => X"E888D0C8D0E888D0C8D0E8D0C828A0082800A00881F00000A1A1A1A101F00000",
                    INIT_02 => X"68000828680069000028C890F0E8881800C990F0E989A1A1A1A1012828A008D0",
                    INIT_03 => X"0000000028000000000000286F2F0F28109D8D680090E8252868080028680008",
                    INIT_04 => X"28006F1F286F00100028000000000028B0CE000E10C8A600001000B0670E2800",
                    INIT_05 => X"28B0CE0E280000000000280000A76E4E00000000286F2F286F1F28906E4E6F2F",
                    INIT_06 => X"F0EA5A90E95928787808280000680069000008000D0D58580008080808080808",
                    INIT_07 => X"0000A70F00000101000000070000A70F000010CAA290EA0ACA5A6808105A6808",
                    INIT_08 => X"0808080808080808080828B0EB8B007B0B7B0B28000000000000000200000100",
                    INIT_09 => X"0F8B000F8B000F0B680828685810000D0D000008080808080808080808080808",
                    INIT_0A => X"000F0000A700002800000F000F000F68082800005700000F0000A70000280000",
                    INIT_0B => X"00070000275B0F0000A70F0000A0A1A0A1A0A1A0A15088510868082800000F00",
                    INIT_0C => X"0000A75F000068582800109D8D00109D8D680090E890E8250D0D280000000700",
                    INIT_0D => X"000048286858280000000000000002000001000000A75F00006858280000005F",
                    INIT_0E => X"88568856885508B1E05A5828778876887688750857C856C856C8558808785828",
                    INIT_0F => X"0101010101010101010101010101010109080101010154C854C853C853880857",
                    INIT_10 => X"A6A6A528B868081108B1E84800B828012222190118000A2800B0CAB8680008B8",
                    INIT_11 => X"08080808080808080808080828B1C80828011A6A2A016A28A5A4A4A3A328A7A7",
                    INIT_12 => X"00000D0D08080808080808080808080808080808080808080808080808080808",
                    INIT_13 => X"8A0050010A5A28718A7121A2A2A2A2528AA1A1A1A1A1A1A1A151090A010A5A28",
                    INIT_14 => X"A3A3A3A3A3A3538A53B4B40B0A010A0C0C0F0E2811CA8A8A88EA280069000050",
                    INIT_15 => X"0128010A0B0C0C07060EA3A3A3A3A3A3A3A3538A53B1EA8AB8010AB8B7B6A3A3",
                    INIT_16 => X"0101010C0C0B010A0C0C0F0E28B1CA0101010101010101010101010908010101",
                    INIT_17 => X"010101010C0C0E010A0C0C0F0E110AB1EB8B748B7401010101010101010C0401",
                    INIT_18 => X"28010A0C0C0F28A4A24A010A11B1CE0000006900000001010101010101010C04",
                    INIT_19 => X"B8B6B756CF57CF01528F0F0909010A0C0C0F0E28000050830B5A2873830B5B5A",
                    INIT_1A => X"0D54CF26A5A555CF0627A5A4A5A40D54CF27A5A5A555CF57CFB8010A0B0B0C0C",
                    INIT_1B => X"0AB891E9B757CFB8010AB8B5B6B6B725A555CF0526A4A50C55CF0626A5A4A5A4",
                    INIT_1C => X"C00801010C0B740108018C0C0C01010A0C0C0F0E28010A0C0C1109B1E9C9B801",
                    INIT_1D => X"0D0D0E0E0E0E0E0E0E0E0E0E1188CE010111C8A488E828110909B1EBCB74CC01",
                    INIT_1E => X"1100B1E818890091E96800690000506808006808006800690000000928259D85",
                    INIT_1F => X"0808080808080808280028685828680828680828020302815859D1E858022800",
                    INIT_20 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_21 => X"006808006800690000006808006808001288685000F2E05908000D0D08080808",
                    INIT_22 => X"0D0012896800690000508008680800680800F2E1095A68006900005800000D0D",
                    INIT_23 => X"69000000000D0D00F2E1095A0012896800690000508008680800F2E1095A000D",
                    INIT_24 => X"020268285882E858280012CB680069000050D2E38B038AA2A289026808006800",
                    INIT_25 => X"4800480048004888EA1A4A280000482868287808B2DDCD0D0D68086808286808",
                    INIT_26 => X"08080808080808082800680069000008000D0D08080808080808080808120000",
                    INIT_27 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_28 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_29 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2A => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2B => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2C => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2D => X"92E892E825129D8D89B2E050F2E15892E892E825090D0D080808080808080808",
                    INIT_2E => X"008950F3E15878082800030028000021259D8D01259D8D030212099D8D129D8D",
                    INIT_2F => X"C88858C150C88858011289F2005092E101D2E15889017180087893E88858C9F2",
                    INIT_30 => X"00000D0D08080808080808082800000D0D080808080808080808080808281271",
                    INIT_31 => X"CB8A8BA3A30383538008528008F3E2580AD3E088700808890928006800690000",
                    INIT_32 => X"13C203F3E878885870885848002813700050B3E38B138B7000CB508B51D3E3D3",
                    INIT_33 => X"78C858F3E893E893E893E850C85813000000000D0D0008080808080808080808",
                    INIT_34 => X"C85878C858680800680800680800D3C85828A00878C8580028A008680028A008",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000028A00878",
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
                   INITP_00 => X"CFECE42A93BFD3FFCFF8FDB2EBFFADF3FFF99DDEDFD830192954860692493337",
                   INITP_01 => X"FFFF3C00011AA005DBADB9DECEE6753DB198005DB7D576DF24B67FFFFFF35D6D",
                   INITP_02 => X"F1052FF9E20DFFE7E00004D0000418BE53400009CFFFFFFFFFFCD7041D4F01DD",
                   INITP_03 => X"FFF6DE27E17D6FCC3FFDCB2533460C5361A000000000006081041C30C22DBBFC",
                   INITP_04 => X"FFFFFFFFFFFE9FFF551DE85624EFA017E98DF1626F8B63ECDFADAC4FFFFFFFFF",
                   INITP_05 => X"005A426192FF89C4AC4951FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_06 => X"00000000000000000000000925B6499C9543E7FFF48FA5850004487F4FFE7FFF",
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
