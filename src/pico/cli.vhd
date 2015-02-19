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
-- Program defined by 'Z:\home\dean\public_html\Xilinx\mezz_tester\src\pico\cli.psm'.
--
-- Generated by KCPSM6 Assembler: 19 Feb 2015 - 12:03:06. 
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
                    INIT_00 => X"9000200B9000D008900020071000D00490002715D00B109B0158007200C800D7",
                    INIT_01 => X"D00290005000D01090005000D00490005000D02090005000D00190005000D008",
                    INIT_02 => X"0030400E10010300E0310034001043064306430643060300E031003400205000",
                    INIT_03 => X"100AA042902AA045D010100AA0429011A045D00AA04290305000400E10005000",
                    INIT_04 => X"92072050E050D2411237420E420E420E420E020050005000400E1000A045D010",
                    INIT_05 => X"0007110D5000D1010007D20100070046500091072057E057D1411137310F0100",
                    INIT_06 => X"3B001A01D10100072071D1004BA05000D101113E00075000D1010007110AD101",
                    INIT_07 => X"00A100B700A75000009D00B800A700B700A100AA5000DF045F021F0150002069",
                    INIT_08 => X"9D0100AD1D08208490004D0E009300AA208900A76088CED01D80500000AA00B8",
                    INIT_09 => X"00B7DF043FFE5000DE0100AD209300AA5000009D00B800A100B700A75000608E",
                    INIT_0A => X"00A100B700AA5000DF045F025000DF043FFD500020A3DC019C02DF045F015000",
                    INIT_0B => X"60BE9C011C01500000BD00BD00BD00BD00BD5000009D00BA4E00DC029C0200BA",
                    INIT_0C => X"0046100100691AC11B00B001B03100DD1100113A115611201149114C11435000",
                    INIT_0D => X"F023F0201000500060D9B100900111FF10FF50000065005ED1010007D2010007",
                    INIT_0E => X"B42C1729D005100220F1B42C1728D0051002E0ECD404B42C2116D300B3235000",
                    INIT_0F => X"009A00830E50009A00834E060E700076007220F39401450620F7D40015109404",
                    INIT_10 => X"007D009804E0008D009203E0008D009A00834E070E700076007202540254007D",
                    INIT_11 => X"114950006119D608160100E1F62C1600F62316015000005E0058004000580030",
                    INIT_12 => X"1173116511721120116F1174112011641165116C116911611166112011431132",
                    INIT_13 => X"10015000D009B02C205E00691A1F1B01005E0072110011211164116E116F1170",
                    INIT_14 => X"00834E06007600725000007D014C1E241601014C1E251601014C1E27162CD005",
                    INIT_15 => X"01631E2401631E2501631E27D00510015000009A0083AE60009A00831E09009A",
                    INIT_16 => X"00725000009A00831E00009A00831E00009A00834E06007600725000016F007D",
                    INIT_17 => X"009A00831E01009A00831E00009A00831E78009A00834E061E1AD00510010076",
                    INIT_18 => X"41004206410042064100420641004206A1001001A2001030D00510015000007D",
                    INIT_19 => X"00830E20009A00830E10009A00834E60B62C1E58009A00834E061E1A00760072",
                    INIT_1A => X"21B9D1FF21B5D1004BA01A761B055000D00DB02C5000D00CB02C5000007D009A",
                    INIT_1B => X"BE3000760072D005B02C5000005E21AB3B001A03005E21AB3B001A01D1010007",
                    INIT_1C => X"009A00834E07BE3000760072D005B02C5000007D009A0083BE34009A00834E06",
                    INIT_1D => X"5000D006B02C5000005E0058004000580030007D009804E0008D009203E0008D",
                    INIT_1E => X"1141AE009001AD009001AC009001AB001003102CF140B1285000005E00589006",
                    INIT_1F => X"AC001001AB001041627FC050B528B0405000EE101101ED101101EC101101EB10",
                    INIT_20 => X"024602460240A9009001A8009001A7009001A6001003102CAE001001AD001001",
                    INIT_21 => X"022C024602400235022C024602400235022C024602400235022C120011000246",
                    INIT_22 => X"02A0310101F014005000005E621395017000D101000711207001024602400235",
                    INIT_23 => X"50007000D0011030223D1031623CD0019006000770015000024C442044103204",
                    INIT_24 => X"D40654020253D40650004A00490848084708460E50004F004E084D084C084B0E",
                    INIT_25 => X"114D11541120113A1152114F11521152114550006254900110FF50000253340D",
                    INIT_26 => X"116811741167116E1165116C1120114F1144115411201164116E116111201153",
                    INIT_27 => X"1B0211001168116311741161116D11201174116F116E1120116F116411201173",
                    INIT_28 => X"420043064200430642004306A3401200143002A91545B42C5000005E00691A57",
                    INIT_29 => X"02A91545B42C5000E3501501E25042404406440644064406A440140142004306",
                    INIT_2A => X"500022A99401150115011000D4005000005ED20100070046A05015010058A050",
                    INIT_2B => X"460E4708460EA7401401A640696068601600144502E21504190618261E001D03",
                    INIT_2C => X"1401A64062B7D4611401700002E2150370016E706D604708460E4708460E4708",
                    INIT_2D => X"150617FF18F819000E700D601CFF4708460F4708460F4708460F4708460FA740",
                    INIT_2E => X"0240022C02460240022C02460240022C120011000246024602460240500002E2",
                    INIT_2F => X"19001800164502E21504190618261E001D03500062E8950102460240022C0246",
                    INIT_30 => X"1601E86003370337033703370337033703370337180009800337033703370337",
                    INIT_31 => X"0337190018001C0602E21504190618261E401D0122B7144562FED6631601E960",
                    INIT_32 => X"0007004600800337033703370337033703370337033718000980033703370337",
                    INIT_33 => X"19FF18FF1E0050004808450E9506024C1400233D631D9C01005E00580090D201",
                    INIT_34 => X"5000005E0058A07007501763B52C5000E67007501763B630B52C500002E21502",
                    INIT_35 => X"ADF09F01AEF09F01024CA4F01F0A1F631200130202E21504190618261E201D01",
                    INIT_36 => X"4A064A06AAF09F01AEF09F01700002E21504160017001800190070016DD06EE0",
                    INIT_37 => X"4DA04A064A06AAF09F010D904EA04A08490E4A08490E1A00A9F09F014EA04A06",
                    INIT_38 => X"0B904CA049004A061900AAF09F010C904DA04A08490E4A08490E1A00A9F09F01",
                    INIT_39 => X"D2016EE0AEF09F01700002E2150770016BB06CC06DD06EE04BA04A06AAF09F01",
                    INIT_3A => X"1D01500002E2150418FF1980235812016358D3009301700002E21502700123AA",
                    INIT_3B => X"03D218001609E89003CD10070337190A19631800024C02E21504190618261E20",
                    INIT_3C => X"480E1000D000500023581302120063BED6FF9601E890990103CD80C0100803E1",
                    INIT_3D => X"1C081C031C031C041C041C031C081C031C0823D310009C01033703E123CD9001",
                    INIT_3E => X"103A0007D1010007D201000700460030130050004BA03B000A601AD71B031C08",
                    INIT_3F => X"D0033003130100302403D3FFD1010007D20100070046A030D00110200007D001",
                   INITP_00 => X"AAAAAA0A5ADA8AA28AAA9F507D554A4D775DDD9211E154E2082082082C2C28AA",
                   INITP_01 => X"A292A5D1088234D2A2D42AAA882AAAAAD2AAAA42AA8A2C22A22AAAAB62DAAC2A",
                   INITP_02 => X"A28A2922AA28A6AA8888A8A29AA8618228A0AAAAAAAAAAAAAD688A88A28A92AA",
                   INITP_03 => X"10D0A666044448A8A2A228A2A4A8AA292A2A5A5ADD828A2A8A280A4A5555108A",
                   INITP_04 => X"2AAAAAAAAAAAAAAAAAAAAD288A955955B88D2E8000ADE8EAAAAAAA82A8444411",
                   INITP_05 => X"02002DAAAAAA0AAA000155544D78D55554450800A576AA1882985515555020A8",
                   INITP_06 => X"14415411511E003511840800A842902802522DA2A2AAA82A808008D66AAAA0AA",
                   INITP_07 => X"44DAA88A2AA82942AAAAADA97683599282890A002808D78F51E3551105041541")
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
                    INIT_00 => X"9000200B9000D008900020071000D00490002715D00B109B0158007200C800D7",
                    INIT_01 => X"D00290005000D01090005000D00490005000D02090005000D00190005000D008",
                    INIT_02 => X"0030400E10010300E0310034001043064306430643060300E031003400205000",
                    INIT_03 => X"100AA042902AA045D010100AA0429011A045D00AA04290305000400E10005000",
                    INIT_04 => X"92072050E050D2411237420E420E420E420E020050005000400E1000A045D010",
                    INIT_05 => X"0007110D5000D1010007D20100070046500091072057E057D1411137310F0100",
                    INIT_06 => X"3B001A01D10100072071D1004BA05000D101113E00075000D1010007110AD101",
                    INIT_07 => X"00A100B700A75000009D00B800A700B700A100AA5000DF045F021F0150002069",
                    INIT_08 => X"9D0100AD1D08208490004D0E009300AA208900A76088CED01D80500000AA00B8",
                    INIT_09 => X"00B7DF043FFE5000DE0100AD209300AA5000009D00B800A100B700A75000608E",
                    INIT_0A => X"00A100B700AA5000DF045F025000DF043FFD500020A3DC019C02DF045F015000",
                    INIT_0B => X"60BE9C011C01500000BD00BD00BD00BD00BD5000009D00BA4E00DC029C0200BA",
                    INIT_0C => X"0046100100691AC11B00B001B03100DD1100113A115611201149114C11435000",
                    INIT_0D => X"F023F0201000500060D9B100900111FF10FF50000065005ED1010007D2010007",
                    INIT_0E => X"B42C1729D005100220F1B42C1728D0051002E0ECD404B42C2116D300B3235000",
                    INIT_0F => X"009A00830E50009A00834E060E700076007220F39401450620F7D40015109404",
                    INIT_10 => X"007D009804E0008D009203E0008D009A00834E070E700076007202540254007D",
                    INIT_11 => X"114950006119D608160100E1F62C1600F62316015000005E0058004000580030",
                    INIT_12 => X"1173116511721120116F1174112011641165116C116911611166112011431132",
                    INIT_13 => X"10015000D009B02C205E00691A1F1B01005E0072110011211164116E116F1170",
                    INIT_14 => X"00834E06007600725000007D014C1E241601014C1E251601014C1E27162CD005",
                    INIT_15 => X"01631E2401631E2501631E27D00510015000009A0083AE60009A00831E09009A",
                    INIT_16 => X"00725000009A00831E00009A00831E00009A00834E06007600725000016F007D",
                    INIT_17 => X"009A00831E01009A00831E00009A00831E78009A00834E061E1AD00510010076",
                    INIT_18 => X"41004206410042064100420641004206A1001001A2001030D00510015000007D",
                    INIT_19 => X"00830E20009A00830E10009A00834E60B62C1E58009A00834E061E1A00760072",
                    INIT_1A => X"21B9D1FF21B5D1004BA01A761B055000D00DB02C5000D00CB02C5000007D009A",
                    INIT_1B => X"BE3000760072D005B02C5000005E21AB3B001A03005E21AB3B001A01D1010007",
                    INIT_1C => X"009A00834E07BE3000760072D005B02C5000007D009A0083BE34009A00834E06",
                    INIT_1D => X"5000D006B02C5000005E0058004000580030007D009804E0008D009203E0008D",
                    INIT_1E => X"1141AE009001AD009001AC009001AB001003102CF140B1285000005E00589006",
                    INIT_1F => X"AC001001AB001041627FC050B528B0405000EE101101ED101101EC101101EB10",
                    INIT_20 => X"024602460240A9009001A8009001A7009001A6001003102CAE001001AD001001",
                    INIT_21 => X"022C024602400235022C024602400235022C024602400235022C120011000246",
                    INIT_22 => X"02A0310101F014005000005E621395017000D101000711207001024602400235",
                    INIT_23 => X"50007000D0011030223D1031623CD0019006000770015000024C442044103204",
                    INIT_24 => X"D40654020253D40650004A00490848084708460E50004F004E084D084C084B0E",
                    INIT_25 => X"114D11541120113A1152114F11521152114550006254900110FF50000253340D",
                    INIT_26 => X"116811741167116E1165116C1120114F1144115411201164116E116111201153",
                    INIT_27 => X"1B0211001168116311741161116D11201174116F116E1120116F116411201173",
                    INIT_28 => X"420043064200430642004306A3401200143002A91545B42C5000005E00691A57",
                    INIT_29 => X"02A91545B42C5000E3501501E25042404406440644064406A440140142004306",
                    INIT_2A => X"500022A99401150115011000D4005000005ED20100070046A05015010058A050",
                    INIT_2B => X"460E4708460EA7401401A640696068601600144502E21504190618261E001D03",
                    INIT_2C => X"1401A64062B7D4611401700002E2150370016E706D604708460E4708460E4708",
                    INIT_2D => X"150617FF18F819000E700D601CFF4708460F4708460F4708460F4708460FA740",
                    INIT_2E => X"0240022C02460240022C02460240022C120011000246024602460240500002E2",
                    INIT_2F => X"19001800164502E21504190618261E001D03500062E8950102460240022C0246",
                    INIT_30 => X"1601E86003370337033703370337033703370337180009800337033703370337",
                    INIT_31 => X"0337190018001C0602E21504190618261E401D0122B7144562FED6631601E960",
                    INIT_32 => X"0007004600800337033703370337033703370337033718000980033703370337",
                    INIT_33 => X"19FF18FF1E0050004808450E9506024C1400233D631D9C01005E00580090D201",
                    INIT_34 => X"5000005E0058A07007501763B52C5000E67007501763B630B52C500002E21502",
                    INIT_35 => X"ADF09F01AEF09F01024CA4F01F0A1F631200130202E21504190618261E201D01",
                    INIT_36 => X"4A064A06AAF09F01AEF09F01700002E21504160017001800190070016DD06EE0",
                    INIT_37 => X"4DA04A064A06AAF09F010D904EA04A08490E4A08490E1A00A9F09F014EA04A06",
                    INIT_38 => X"0B904CA049004A061900AAF09F010C904DA04A08490E4A08490E1A00A9F09F01",
                    INIT_39 => X"D2016EE0AEF09F01700002E2150770016BB06CC06DD06EE04BA04A06AAF09F01",
                    INIT_3A => X"1D01500002E2150418FF1980235812016358D3009301700002E21502700123AA",
                    INIT_3B => X"03D218001609E89003CD10070337190A19631800024C02E21504190618261E20",
                    INIT_3C => X"480E1000D000500023581302120063BED6FF9601E890990103CD80C0100803E1",
                    INIT_3D => X"1C081C031C031C041C041C031C081C031C0823D310009C01033703E123CD9001",
                    INIT_3E => X"103A0007D1010007D201000700460030130050004BA03B000A601AD71B031C08",
                    INIT_3F => X"D0033003130100302403D3FFD1010007D20100070046A030D00110200007D001",
                   INITP_00 => X"AAAAAA0A5ADA8AA28AAA9F507D554A4D775DDD9211E154E2082082082C2C28AA",
                   INITP_01 => X"A292A5D1088234D2A2D42AAA882AAAAAD2AAAA42AA8A2C22A22AAAAB62DAAC2A",
                   INITP_02 => X"A28A2922AA28A6AA8888A8A29AA8618228A0AAAAAAAAAAAAAD688A88A28A92AA",
                   INITP_03 => X"10D0A666044448A8A2A228A2A4A8AA292A2A5A5ADD828A2A8A280A4A5555108A",
                   INITP_04 => X"2AAAAAAAAAAAAAAAAAAAAD288A955955B88D2E8000ADE8EAAAAAAA82A8444411",
                   INITP_05 => X"02002DAAAAAA0AAA000155544D78D55554450800A576AA1882985515555020A8",
                   INITP_06 => X"14415411511E003511840800A842902802522DA2A2AAA82A808008D66AAAA0AA",
                   INITP_07 => X"44DAA88A2AA82942AAAAADA97683599282890A002808D78F51E3551105041541")
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
                    INIT_00 => X"9000200B9000D008900020071000D00490002715D00B109B0158007200C800D7",
                    INIT_01 => X"D00290005000D01090005000D00490005000D02090005000D00190005000D008",
                    INIT_02 => X"0030400E10010300E0310034001043064306430643060300E031003400205000",
                    INIT_03 => X"100AA042902AA045D010100AA0429011A045D00AA04290305000400E10005000",
                    INIT_04 => X"92072050E050D2411237420E420E420E420E020050005000400E1000A045D010",
                    INIT_05 => X"0007110D5000D1010007D20100070046500091072057E057D1411137310F0100",
                    INIT_06 => X"3B001A01D10100072071D1004BA05000D101113E00075000D1010007110AD101",
                    INIT_07 => X"00A100B700A75000009D00B800A700B700A100AA5000DF045F021F0150002069",
                    INIT_08 => X"9D0100AD1D08208490004D0E009300AA208900A76088CED01D80500000AA00B8",
                    INIT_09 => X"00B7DF043FFE5000DE0100AD209300AA5000009D00B800A100B700A75000608E",
                    INIT_0A => X"00A100B700AA5000DF045F025000DF043FFD500020A3DC019C02DF045F015000",
                    INIT_0B => X"60BE9C011C01500000BD00BD00BD00BD00BD5000009D00BA4E00DC029C0200BA",
                    INIT_0C => X"0046100100691AC11B00B001B03100DD1100113A115611201149114C11435000",
                    INIT_0D => X"F023F0201000500060D9B100900111FF10FF50000065005ED1010007D2010007",
                    INIT_0E => X"B42C1729D005100220F1B42C1728D0051002E0ECD404B42C2116D300B3235000",
                    INIT_0F => X"009A00830E50009A00834E060E700076007220F39401450620F7D40015109404",
                    INIT_10 => X"007D009804E0008D009203E0008D009A00834E070E700076007202540254007D",
                    INIT_11 => X"114950006119D608160100E1F62C1600F62316015000005E0058004000580030",
                    INIT_12 => X"1173116511721120116F1174112011641165116C116911611166112011431132",
                    INIT_13 => X"10015000D009B02C205E00691A1F1B01005E0072110011211164116E116F1170",
                    INIT_14 => X"00834E06007600725000007D014C1E241601014C1E251601014C1E27162CD005",
                    INIT_15 => X"01631E2401631E2501631E27D00510015000009A0083AE60009A00831E09009A",
                    INIT_16 => X"00725000009A00831E00009A00831E00009A00834E06007600725000016F007D",
                    INIT_17 => X"009A00831E01009A00831E00009A00831E78009A00834E061E1AD00510010076",
                    INIT_18 => X"41004206410042064100420641004206A1001001A2001030D00510015000007D",
                    INIT_19 => X"00830E20009A00830E10009A00834E60B62C1E58009A00834E061E1A00760072",
                    INIT_1A => X"21B9D1FF21B5D1004BA01A761B055000D00DB02C5000D00CB02C5000007D009A",
                    INIT_1B => X"BE3000760072D005B02C5000005E21AB3B001A03005E21AB3B001A01D1010007",
                    INIT_1C => X"009A00834E07BE3000760072D005B02C5000007D009A0083BE34009A00834E06",
                    INIT_1D => X"5000D006B02C5000005E0058004000580030007D009804E0008D009203E0008D",
                    INIT_1E => X"1141AE009001AD009001AC009001AB001003102CF140B1285000005E00589006",
                    INIT_1F => X"AC001001AB001041627FC050B528B0405000EE101101ED101101EC101101EB10",
                    INIT_20 => X"024602460240A9009001A8009001A7009001A6001003102CAE001001AD001001",
                    INIT_21 => X"022C024602400235022C024602400235022C024602400235022C120011000246",
                    INIT_22 => X"02A0310101F014005000005E621395017000D101000711207001024602400235",
                    INIT_23 => X"50007000D0011030223D1031623CD0019006000770015000024C442044103204",
                    INIT_24 => X"D40654020253D40650004A00490848084708460E50004F004E084D084C084B0E",
                    INIT_25 => X"114D11541120113A1152114F11521152114550006254900110FF50000253340D",
                    INIT_26 => X"116811741167116E1165116C1120114F1144115411201164116E116111201153",
                    INIT_27 => X"1B0211001168116311741161116D11201174116F116E1120116F116411201173",
                    INIT_28 => X"420043064200430642004306A3401200143002A91545B42C5000005E00691A57",
                    INIT_29 => X"02A91545B42C5000E3501501E25042404406440644064406A440140142004306",
                    INIT_2A => X"500022A99401150115011000D4005000005ED20100070046A05015010058A050",
                    INIT_2B => X"460E4708460EA7401401A640696068601600144502E21504190618261E001D03",
                    INIT_2C => X"1401A64062B7D4611401700002E2150370016E706D604708460E4708460E4708",
                    INIT_2D => X"150617FF18F819000E700D601CFF4708460F4708460F4708460F4708460FA740",
                    INIT_2E => X"0240022C02460240022C02460240022C120011000246024602460240500002E2",
                    INIT_2F => X"19001800164502E21504190618261E001D03500062E8950102460240022C0246",
                    INIT_30 => X"1601E86003370337033703370337033703370337180009800337033703370337",
                    INIT_31 => X"0337190018001C0602E21504190618261E401D0122B7144562FED6631601E960",
                    INIT_32 => X"0007004600800337033703370337033703370337033718000980033703370337",
                    INIT_33 => X"19FF18FF1E0050004808450E9506024C1400233D631D9C01005E00580090D201",
                    INIT_34 => X"5000005E0058A07007501763B52C5000E67007501763B630B52C500002E21502",
                    INIT_35 => X"ADF09F01AEF09F01024CA4F01F0A1F631200130202E21504190618261E201D01",
                    INIT_36 => X"4A064A06AAF09F01AEF09F01700002E21504160017001800190070016DD06EE0",
                    INIT_37 => X"4DA04A064A06AAF09F010D904EA04A08490E4A08490E1A00A9F09F014EA04A06",
                    INIT_38 => X"0B904CA049004A061900AAF09F010C904DA04A08490E4A08490E1A00A9F09F01",
                    INIT_39 => X"D2016EE0AEF09F01700002E2150770016BB06CC06DD06EE04BA04A06AAF09F01",
                    INIT_3A => X"1D01500002E2150418FF1980235812016358D3009301700002E21502700123AA",
                    INIT_3B => X"03D218001609E89003CD10070337190A19631800024C02E21504190618261E20",
                    INIT_3C => X"480E1000D000500023581302120063BED6FF9601E890990103CD80C0100803E1",
                    INIT_3D => X"1C081C031C031C041C041C031C081C031C0823D310009C01033703E123CD9001",
                    INIT_3E => X"103A0007D1010007D201000700460030130050004BA03B000A601AD71B031C08",
                    INIT_3F => X"D0033003130100302403D3FFD1010007D20100070046A030D00110200007D001",
                   INITP_00 => X"AAAAAA0A5ADA8AA28AAA9F507D554A4D775DDD9211E154E2082082082C2C28AA",
                   INITP_01 => X"A292A5D1088234D2A2D42AAA882AAAAAD2AAAA42AA8A2C22A22AAAAB62DAAC2A",
                   INITP_02 => X"A28A2922AA28A6AA8888A8A29AA8618228A0AAAAAAAAAAAAAD688A88A28A92AA",
                   INITP_03 => X"10D0A666044448A8A2A228A2A4A8AA292A2A5A5ADD828A2A8A280A4A5555108A",
                   INITP_04 => X"2AAAAAAAAAAAAAAAAAAAAD288A955955B88D2E8000ADE8EAAAAAAA82A8444411",
                   INITP_05 => X"02002DAAAAAA0AAA000155544D78D55554450800A576AA1882985515555020A8",
                   INITP_06 => X"14415411511E003511840800A842902802522DA2A2AAA82A808008D66AAAA0AA",
                   INITP_07 => X"44DAA88A2AA82942AAAAADA97683599282890A002808D78F51E3551105041541")
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
                    INIT_00 => X"02000010000004000020000001000008000B00080007000400150B9B5872C8D7",
                    INIT_01 => X"0A422A45100A4211450A4230000E0000300E0100313410060606060031342000",
                    INIT_02 => X"070D0001070107460007575741370F0007505041370E0E0E0E0000000E004510",
                    INIT_03 => X"A1B7A7009DB8A7B7A1AA000402010069000101077100A000013E070001070A01",
                    INIT_04 => X"B704FE0001AD93AA009DB8A1B7A7008E01AD0884000E93AA89A788D08000AAB8",
                    INIT_05 => X"BE010100BDBDBDBDBD009DBA000202BAA1B7AA0004020004FD00A30102040100",
                    INIT_06 => X"23200000D90001FFFF00655E01070107460169C1000131DD003A5620494C4300",
                    INIT_07 => X"9A83509A8306707672F30106F70010042C290502F12C280502EC042C16002300",
                    INIT_08 => X"4900190801E12C002301005E584058307D98E08D92E08D9A830770767254547D",
                    INIT_09 => X"0100092C5E691F015E720021646E6F70736572206F742064656C696166204332",
                    INIT_0A => X"6324632563270501009A83609A83099A83067672007D4C24014C25014C272C05",
                    INIT_0B => X"9A83019A83009A83789A83061A05017672009A83009A83009A83067672006F7D",
                    INIT_0C => X"83209A83109A83602C589A83061A76720006000600060006000100300501007D",
                    INIT_0D => X"307672052C005EAB00035EAB00010107B9FFB500A07605000D2C000C2C007D9A",
                    INIT_0E => X"00062C005E584058307D98E08D92E08D9A8307307672052C007D9A83349A8306",
                    INIT_0F => X"000100417F50284000100110011001104100010001000100032C4028005E5806",
                    INIT_10 => X"2C4640352C4640352C4640352C00004646464000010001000100032C00010001",
                    INIT_11 => X"000001303D313C01060701004C201004A001F000005E13010001072001464035",
                    INIT_12 => X"4D54203A524F525245005401FF00530D0602530600000808080E00000808080E",
                    INIT_13 => X"0200686374616D20746F6E206F6420736874676E656C204F445420646E612053",
                    INIT_14 => X"A9452C00500150400606060640010006000600060006400030A9452C005E6957",
                    INIT_15 => X"0E080E40014060600045E2040626000300A90101010000005E01074650015850",
                    INIT_16 => X"06FFF8007060FF080F080F080F080F400140B7610100E203017060080E080E08",
                    INIT_17 => X"000045E2040626000300E80146402C46402C46402C46402C00004646464000E2",
                    INIT_18 => X"37000006E20406264001B745FE63016001603737373737373737008037373737",
                    INIT_19 => X"FFFF0000080E064C003D1D015E58900107468037373737373737370080373737",
                    INIT_1A => X"F001F0014CF00A630002E20406262001005E587050632C00705063302C00E202",
                    INIT_1B => X"A00606F00190A0080E080E00F001A0060606F001F00100E2040000000001D0E0",
                    INIT_1C => X"01E0F00100E20701B0C0D0E0A006F00190A0000600F00190A0080E080E00F001",
                    INIT_1D => X"D2000990CD07370A63004CE2040626200100E204FF80580158000100E20201AA",
                    INIT_1E => X"080303040403080308D3000137E1CD010E000000580200BEFF019001CDC008E1",
                    INIT_1F => X"0303013003FF010701074630012007013A070107010746300000A00060D70308",
                    INIT_20 => X"656666754200C8000B2C0003000003FF0047E99A102B270F042347005EE85EF4",
                    INIT_21 => X"202020203A73657A69732064726F5700203A746E756F632064726F5700203A72",
                    INIT_22 => X"070107010746200128070120074C0101100753202000691B04002064726F5700",
                    INIT_23 => X"01010701074610302401400701200781400023010701074623076924045E0129",
                    INIT_24 => X"306941045EB94000235E87010107010746103028012007964000236931045E6F",
                    INIT_25 => X"102CC6042C005EAF01010701074660995003502C060601300120070107010746",
                    INIT_26 => X"0758075807000105005E58050008002C00CC000220040A000A01000700000007",
                    INIT_27 => X"560430BB2C300100000000002C3001F42C0001F102230001002CD2D85E580758",
                    INIT_28 => X"07011FFF1FFF000001073F07000701070007000728A0126030C0F00701010500",
                    INIT_29 => X"010010000002070F4D60F01007000007010700F007000007005E587058800145",
                    INIT_2A => X"5E58110300580001AA29005E58705860014907005E58F058E058D0014E07F900",
                    INIT_2B => X"040067726169746C756D005E01070107460169610500203A6E6F697372655600",
                    INIT_2C => X"7379736B05006E6F69737265761904007465736572E70300706D75646D656D05",
                    INIT_2D => X"040066666F5F7265776F701004006E6F5F7265776F70A90100706C6568470400",
                    INIT_2E => X"6D6AE40100646AC801007269BB01007769E00100726ADD0100776AE100006113",
                    INIT_2F => X"030073746AF7020067746AB0020075746A9D020072746A84020077746AF80100",
                    INIT_30 => X"030072616A43030077616AD804007274D204007A74D404006674BB0400637416",
                    INIT_31 => X"671604007074820100643F0100703C01007073AF030067616A50030075616A49",
                    INIT_32 => X"7465735F6E6961675C0500746C7561665F74736574E5040073745801006F6970",
                    INIT_33 => X"96FFA06E0001017D10207D002096FF8900A0007605FFA601006F697067A30100",
                    INIT_34 => X"20C4102023000065D1DD0065DD10A0000110A00001E99A6E0000037D00018500",
                    INIT_35 => X"23001001242320B201B93420B92010B21020082010002323C4050123019C3401",
                    INIT_36 => X"D60600203A726F727245005E69C50600646E616D6D6F6320646142009C000128",
                    INIT_37 => X"2C0606405010402800402414002300EC200110002C0438005E01070107462069",
                    INIT_38 => X"342C20200120100020010B00F2703460F2500101017021016001600D50F20201",
                    INIT_39 => X"20452051084A0A4A0D0001201565DD5E6922075E0021776F6C667265764F156B",
                    INIT_3A => X"200120010807012007010807600220000C012001205E000C000107000C002001",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000C00200120",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"0012420E050808FE00000D866000A408001CA6CB504F0000000011F000000048",
                   INITP_01 => X"223B913000020000019AFA000000AA8000000002A8000248013FFFFFA0000400",
                   INITP_02 => X"8C900040D5550135521918044C015620FFFFFFFFFF8002950000615000021102",
                   INITP_03 => X"260020B2004E0D198B8C96E512A9AAAB8CAC14AAD3590E6986601FEFC6413FDF",
                   INITP_04 => X"80A000800300180000401F10131830C4C180D008400214FFFFFFFFFFF8000405",
                   INITP_05 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC80FFE05800000D9F880006EC20A88",
                   INITP_06 => X"F390C8407FC3FFE45E06F600100330496802CFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_07 => X"00000000000000000000000000000000000000001B6800407FC82FFEFD801890")
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
                    INIT_00 => X"684828684828684828684828684828684810C868481088684813680800000000",
                    INIT_01 => X"88D0C8D0E888D0C8D0E8D0C828A0082800A00881F00000A1A1A1A101F0000028",
                    INIT_02 => X"000828680069000028C890F0E8881800C990F0E989A1A1A1A1012828A008D0E8",
                    INIT_03 => X"00000028000000000000286F2F0F28109D8D680090E825286808002868000868",
                    INIT_04 => X"006F1F286F00100028000000000028B0CE000E10C8A600001000B0670E280000",
                    INIT_05 => X"B0CE0E280000000000280000A76E4E00000000286F2F286F1F28906E4E6F2F28",
                    INIT_06 => X"78780828B0D8C80808280000680069000008000D0D5858000808080808080828",
                    INIT_07 => X"0000070000A707000010CAA290EA0ACA5A0B6808105A0B6808F0EA5A90E95928",
                    INIT_08 => X"0828B0EB8B007B0B7B0B280000000000000002000001000000A7070000010100",
                    INIT_09 => X"0828685810000D0D000008080808080808080808080808080808080808080808",
                    INIT_0A => X"000F000F000F68082800005700000F0000A700002800000F8B000F8B000F0B68",
                    INIT_0B => X"00000F00000F00000F0000A70F680800002800000F00000F0000A70000280000",
                    INIT_0C => X"00070000070000275B0F0000A70F0000A0A1A0A1A0A1A0A15088510868082800",
                    INIT_0D => X"5F000068582800109D8D00109D8D680090E890E8250D0D286858286858280000",
                    INIT_0E => X"286858280000000000000002000001000000A75F00006858280000005F0000A7",
                    INIT_0F => X"56885508B1E05A5828778876887688750857C856C856C8558808785828000048",
                    INIT_10 => X"0101010101010101010101010109080101010154C854C853C853880857885688",
                    INIT_11 => X"28B868081108B1E84800B828012222190118000A2800B1CAB8680008B8010101",
                    INIT_12 => X"08080808080808080828B1C80828011A6A2A016A28A5A4A4A3A328A7A7A6A6A5",
                    INIT_13 => X"0D08080808080808080808080808080808080808080808080808080808080808",
                    INIT_14 => X"010A5A28718A7121A2A2A2A2528AA1A1A1A1A1A1A1A151090A010A5A2800000D",
                    INIT_15 => X"A3A3A3538A53B4B40B0A010A0C0C0F0E2811CA8A8A88EA2800690000508A0050",
                    INIT_16 => X"0A0B0C0C07060EA3A3A3A3A3A3A3A3538A53B1EA8AB8010AB8B7B6A3A3A3A3A3",
                    INIT_17 => X"0C0C0B010A0C0C0F0E28B1CA0101010101010101010101010908010101012801",
                    INIT_18 => X"010C0C0E010A0C0C0F0E110AB1EB8B748B7401010101010101010C0401010101",
                    INIT_19 => X"0C0C0F28A4A24A010A11B1CE0000006900000001010101010101010C04010101",
                    INIT_1A => X"56CF57CF01528F0F0909010A0C0C0F0E28000050830B5A2873830B5B5A28010A",
                    INIT_1B => X"26A5A555CF0627A5A4A5A40D54CF27A5A5A555CF57CFB8010A0B0B0C0CB8B6B7",
                    INIT_1C => X"E9B757CFB8010AB8B5B6B6B725A555CF0526A4A50C55CF0626A5A4A5A40D54CF",
                    INIT_1D => X"010C0B740108018C0C0C01010A0C0C0F0E28010A0C0C1109B1E9C9B8010AB891",
                    INIT_1E => X"0E0E0E0E0E0E0E0E0E1188CE010111C8A488E828110909B1EBCB74CC01C00801",
                    INIT_1F => X"E818890092E96800690000506808006808006800690000000928259D850D0D0E",
                    INIT_20 => X"0808080808280028685828680828680828020303815859D2E8580228001100B1",
                    INIT_21 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_22 => X"006800690000006808006808001288685000F2E05908000D0D08080808080808",
                    INIT_23 => X"896800690000508008680800680800F2E1095A68006900005800000D0D006808",
                    INIT_24 => X"00000D0D00F2E1095A0012896800690000508008680800F2E1095A000D0D0012",
                    INIT_25 => X"285882E858280012CB680069000050D2E38B038AA2A289026808006800690000",
                    INIT_26 => X"4800480048A81A4A280000482868287808B2DDCD0D0D68086808286808000068",
                    INIT_27 => X"82E858027858B80B0F0F0EB87858B8127808B892E85852885208021200004800",
                    INIT_28 => X"0012B26CB26BDEDFCF4B1C4C004812480848084892E892E892E81848B21848B8",
                    INIT_29 => X"CA9E9787D8C84818B2E31B03480000481248001B4B0000482800000000006808",
                    INIT_2A => X"0000284828B2DDCD0D0D2800000000006808002800000000000000680800B2DA",
                    INIT_2B => X"080808080808080808082800680069000008000D0D0808080808080808080828",
                    INIT_2C => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2D => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2E => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2F => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_30 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_31 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_32 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_33 => X"93E825139D8D89B3E050F3E15893E893E825090D0D0808080808080808080808",
                    INIT_34 => X"50F3E15878082800030028000021259D8D01259D8D030313099D8D139D8D93E8",
                    INIT_35 => X"58C150C88858011389F3005093E101D3E15889017180087893E88858C9F30089",
                    INIT_36 => X"0D0D08080808080808082800000D0D080808080808080808080808281371C888",
                    INIT_37 => X"8BA3A30383538008528008F3E2580AD3E0887008088909280068006900000000",
                    INIT_38 => X"03F3E878885870885848002813700050B3E38B138B7000CB508B51D3E3D3CB8A",
                    INIT_39 => X"58F3E893E893E893E850C85813000000000D0D000808080808080808080813C3",
                    INIT_3A => X"78C858680800680800680800D3C85828A00878C8580028A008680028A00878C8",
                    INIT_3B => X"000000000000000000000000000000000000000000000000000028A00878C858",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"D9C82949D87FA7FF9FF1FB65D7FF5BE7FFF33BBDBFB0603252A90C0D2492666F",
                   INITP_01 => X"08D5002EDD6DCEF67733A9B7B633000BDB65F6DFAAEDBE496CFFFFFFE6BADB9F",
                   INITP_02 => X"106FFF3F000026800020C5F29A00004E7FFFFFFFFFE6B820EA780EEFFFF9E000",
                   INITP_03 => X"0BEB7E61FFEE59299A30629B0D000000000003040820E186116DDFE788297FCF",
                   INITP_04 => X"9A1BB03D54EF42B1277D00BF4C6F8B137C5B1F66FD6D627FFFFFFFFFFFB6F13F",
                   INITP_05 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFA7FFCC3ABD56008080EAE8020A89",
                   INITP_06 => X"001121FD3FF9FFFC016909864BFE2712B12547FFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_07 => X"000000000000000000000000000000000000002496D92672550F9FFFD23E9614")
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
                    INIT_00 => X"9000200B9000D008900020071000D00490002715D00B109B0158007200C800D7",
                    INIT_01 => X"D00290005000D01090005000D00490005000D02090005000D00190005000D008",
                    INIT_02 => X"0030400E10010300E0310034001043064306430643060300E031003400205000",
                    INIT_03 => X"100AA042902AA045D010100AA0429011A045D00AA04290305000400E10005000",
                    INIT_04 => X"92072050E050D2411237420E420E420E420E020050005000400E1000A045D010",
                    INIT_05 => X"0007110D5000D1010007D20100070046500091072057E057D1411137310F0100",
                    INIT_06 => X"3B001A01D10100072071D1004BA05000D101113E00075000D1010007110AD101",
                    INIT_07 => X"00A100B700A75000009D00B800A700B700A100AA5000DF045F021F0150002069",
                    INIT_08 => X"9D0100AD1D08208490004D0E009300AA208900A76088CED01D80500000AA00B8",
                    INIT_09 => X"00B7DF043FFE5000DE0100AD209300AA5000009D00B800A100B700A75000608E",
                    INIT_0A => X"00A100B700AA5000DF045F025000DF043FFD500020A3DC019C02DF045F015000",
                    INIT_0B => X"60BE9C011C01500000BD00BD00BD00BD00BD5000009D00BA4E00DC029C0200BA",
                    INIT_0C => X"0046100100691AC11B00B001B03100DD1100113A115611201149114C11435000",
                    INIT_0D => X"F023F0201000500060D9B100900111FF10FF50000065005ED1010007D2010007",
                    INIT_0E => X"B42C1729D005100220F1B42C1728D0051002E0ECD404B42C2116D300B3235000",
                    INIT_0F => X"009A00830E50009A00834E060E700076007220F39401450620F7D40015109404",
                    INIT_10 => X"007D009804E0008D009203E0008D009A00834E070E700076007202540254007D",
                    INIT_11 => X"114950006119D608160100E1F62C1600F62316015000005E0058004000580030",
                    INIT_12 => X"1173116511721120116F1174112011641165116C116911611166112011431132",
                    INIT_13 => X"10015000D009B02C205E00691A1F1B01005E0072110011211164116E116F1170",
                    INIT_14 => X"00834E06007600725000007D014C1E241601014C1E251601014C1E27162CD005",
                    INIT_15 => X"01631E2401631E2501631E27D00510015000009A0083AE60009A00831E09009A",
                    INIT_16 => X"00725000009A00831E00009A00831E00009A00834E06007600725000016F007D",
                    INIT_17 => X"009A00831E01009A00831E00009A00831E78009A00834E061E1AD00510010076",
                    INIT_18 => X"41004206410042064100420641004206A1001001A2001030D00510015000007D",
                    INIT_19 => X"00830E20009A00830E10009A00834E60B62C1E58009A00834E061E1A00760072",
                    INIT_1A => X"21B9D1FF21B5D1004BA01A761B055000D00DB02C5000D00CB02C5000007D009A",
                    INIT_1B => X"BE3000760072D005B02C5000005E21AB3B001A03005E21AB3B001A01D1010007",
                    INIT_1C => X"009A00834E07BE3000760072D005B02C5000007D009A0083BE34009A00834E06",
                    INIT_1D => X"5000D006B02C5000005E0058004000580030007D009804E0008D009203E0008D",
                    INIT_1E => X"1141AE009001AD009001AC009001AB001003102CF140B1285000005E00589006",
                    INIT_1F => X"AC001001AB001041627FC050B528B0405000EE101101ED101101EC101101EB10",
                    INIT_20 => X"024602460240A9009001A8009001A7009001A6001003102CAE001001AD001001",
                    INIT_21 => X"022C024602400235022C024602400235022C024602400235022C120011000246",
                    INIT_22 => X"02A0310101F014005000005E621395017000D101000711207001024602400235",
                    INIT_23 => X"50007000D0011030223D1031623CD0019006000770015000024C442044103204",
                    INIT_24 => X"D40654020253D40650004A00490848084708460E50004F004E084D084C084B0E",
                    INIT_25 => X"114D11541120113A1152114F11521152114550006254900110FF50000253340D",
                    INIT_26 => X"116811741167116E1165116C1120114F1144115411201164116E116111201153",
                    INIT_27 => X"1B0211001168116311741161116D11201174116F116E1120116F116411201173",
                    INIT_28 => X"420043064200430642004306A3401200143002A91545B42C5000005E00691A57",
                    INIT_29 => X"02A91545B42C5000E3501501E25042404406440644064406A440140142004306",
                    INIT_2A => X"500022A99401150115011000D4005000005ED20100070046A05015010058A050",
                    INIT_2B => X"460E4708460EA7401401A640696068601600144502E21504190618261E001D03",
                    INIT_2C => X"1401A64062B7D4611401700002E2150370016E706D604708460E4708460E4708",
                    INIT_2D => X"150617FF18F819000E700D601CFF4708460F4708460F4708460F4708460FA740",
                    INIT_2E => X"0240022C02460240022C02460240022C120011000246024602460240500002E2",
                    INIT_2F => X"19001800164502E21504190618261E001D03500062E8950102460240022C0246",
                    INIT_30 => X"1601E86003370337033703370337033703370337180009800337033703370337",
                    INIT_31 => X"0337190018001C0602E21504190618261E401D0122B7144562FED6631601E960",
                    INIT_32 => X"0007004600800337033703370337033703370337033718000980033703370337",
                    INIT_33 => X"19FF18FF1E0050004808450E9506024C1400233D631D9C01005E00580090D201",
                    INIT_34 => X"5000005E0058A07007501763B52C5000E67007501763B630B52C500002E21502",
                    INIT_35 => X"ADF09F01AEF09F01024CA4F01F0A1F631200130202E21504190618261E201D01",
                    INIT_36 => X"4A064A06AAF09F01AEF09F01700002E21504160017001800190070016DD06EE0",
                    INIT_37 => X"4DA04A064A06AAF09F010D904EA04A08490E4A08490E1A00A9F09F014EA04A06",
                    INIT_38 => X"0B904CA049004A061900AAF09F010C904DA04A08490E4A08490E1A00A9F09F01",
                    INIT_39 => X"D2016EE0AEF09F01700002E2150770016BB06CC06DD06EE04BA04A06AAF09F01",
                    INIT_3A => X"1D01500002E2150418FF1980235812016358D3009301700002E21502700123AA",
                    INIT_3B => X"03D218001609E89003CD10070337190A19631800024C02E21504190618261E20",
                    INIT_3C => X"480E1000D000500023581302120063BED6FF9601E890990103CD80C0100803E1",
                    INIT_3D => X"1C081C031C031C041C041C031C081C031C0823D310009C01033703E123CD9001",
                    INIT_3E => X"103A0007D1010007D201000700460030130050004BA03B000A601AD71B031C08",
                    INIT_3F => X"D0033003130100302403D3FFD1010007D20100070046A030D00110200007D001",
                    INIT_40 => X"5000044706E9069A0210B12BB227A40FD004B02304475000005E23E8005E63F4",
                    INIT_41 => X"11651166116611751142500000C85000D00BB02C5000D00310005000D00310FF",
                    INIT_42 => X"1120113A1174116E1175116F1163112011641172116F115711001120113A1172",
                    INIT_43 => X"1120112011201120113A11731165117A11691173112011641172116F11571100",
                    INIT_44 => X"A0100007E453C120B220110000691A1B1B041100112011641172116F11571100",
                    INIT_45 => X"0007D1010007D201000700460020D00110280007D00110200007244C1101D001",
                    INIT_46 => X"C3401300B423D1010007D20100070046B023000700691A241B04005ED0011029",
                    INIT_47 => X"1301D1010007D20100070046A01001301124D00110400007D00110200007E481",
                    INIT_48 => X"0046A01001301128D00110200007E496C3401300B42300691A311B04005E246F",
                    INIT_49 => X"003000691A411B04005EE4B9C3401300B423005E24871301D1010007D2010007",
                    INIT_4A => X"C65016030650152C4506450613010530D00110200007D1010007D20100070046",
                    INIT_4B => X"5010B02C04C6D004B02C5000005E24AF9601D1010007D20100070046A060A499",
                    INIT_4C => X"100064CCBA009B021B201A04D00A1000D00A10015000D007100000000000D007",
                    INIT_4D => X"900700589007005890075000350195055000005E005890055000D0085000F02C",
                    INIT_4E => X"F02C1000700124F1D002B023A4001001A500102C04D224D8005E005890070058",
                    INIT_4F => X"0556D004B03004BBF02CB030700116001F001E001D007000F02CB030700124F4",
                    INIT_50 => X"10009007100090072528D0A02512D0602530D0C030F090076501300190057000",
                    INIT_51 => X"00072501651FD8FF651FD7FFBD00BE009F019707383F98070000900725019007",
                    INIT_52 => X"25019007000036F096070000000090075000005E0058007000580080D0011045",
                    INIT_53 => X"95013D002E100F00B10090029007310F654DC76037F007109107000000009007",
                    INIT_54 => X"D001104900075000005E005800F0005800E0005800D0D001104E000764F9B400",
                    INIT_55 => X"005E00585011900350006558BA009B011BAA1A295000005E0058007000580060",
                    INIT_56 => X"0046100100691A611B0511001120113A116E116F116911731172116511565000",
                    INIT_57 => X"1104110011671172116111691174116C1175116D5000005ED1010007D2010007",
                    INIT_58 => X"1174116511731165117211E7110311001170116D11751164116D1165116D1105",
                    INIT_59 => X"117311791173116B11051100116E116F11691173117211651176111911041100",
                    INIT_5A => X"115F117211651177116F117011A9110111001170116C11651168114711041100",
                    INIT_5B => X"1104110011661166116F115F117211651177116F1170111011041100116E116F",
                    INIT_5C => X"116911E0110111001172116A11DD110111001177116A11E11100110011611113",
                    INIT_5D => X"116D116A11E4110111001164116A11C8110111001172116911BB110111001177",
                    INIT_5E => X"116A119D1102110011721174116A11841102110011771174116A11F811011100",
                    INIT_5F => X"1103110011731174116A11F71102110011671174116A11B01102110011751174",
                    INIT_60 => X"11D211041100117A117411D4110411001166117411BB11041100116311741116",
                    INIT_61 => X"1103110011721161116A11431103110011771161116A11D81104110011721174",
                    INIT_62 => X"11001170117311AF1103110011671161116A11501103110011751161116A1149",
                    INIT_63 => X"1167111611041100117011741182110111001164113F110111001170113C1101",
                    INIT_64 => X"115F117411731165117411E51104110011731174115811011100116F11691170",
                    INIT_65 => X"117411651173115F116E116911611167115C110511001174116C117511611166",
                    INIT_66 => X"D1004BA012001A761B0511FF11A611011100116F11691170116711A311011100",
                    INIT_67 => X"2696D1FF4BA0266E3B001A011201667DC010A020E67DC200B0202696D1FF2689",
                    INIT_68 => X"1A0102104BA03B001A0106E9069A266E12003B001A03267D3B001A012685D100",
                    INIT_69 => X"A020E6C4C210B120F02310005000006506D100DD5000006500DD42104BA03B00",
                    INIT_6A => X"C310B12013080320E21001001123F02326C4D0051001B0239201E69C00341201",
                    INIT_6B => X"B0238300A01091011124B123032026B21201E6B90034A02026B9C3200310A6B2",
                    INIT_6C => X"1164116E1161116D116D116F116311201164116111425000269CE30090011028",
                    INIT_6D => X"1AD61B0611001120113A1172116F1172117211455000005E00691AC51B061100",
                    INIT_6E => X"C1201101E0101000112C120412385000005ED1010007D2010007004600200069",
                    INIT_6F => X"172C4706470607400650A61001401128A50000401024E714C400B0231400A6EC",
                    INIT_70 => X"66F2C650160127011701E07000219601A1601601A260A70DC650A6F296021401",
                    INIT_71 => X"0734E72CD120F1201101B120E0101100B1209001000B500026F2E0700034A060",
                    INIT_72 => X"00691A221B07005E110011211177116F116C1166117211651176114F2715866B",
                    INIT_73 => X"B020E745D1202751D108274AD10A274AD10DA1009001B0202715006500DD005E",
                    INIT_74 => X"400C1001F0209001B020005E5000400C1000D10100075000400C1000F0209001",
                    INIT_75 => X"F0209001B020D10111080007D10111200007D10111080007A7609002B0205000",
                    INIT_76 => X"00000000000000000000000000000000000000005000400C1000F0209001B020",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"AAAAAA0A5ADA8AA28AAA9F507D554A4D775DDD9211E154E2082082082C2C28AA",
                   INITP_01 => X"A292A5D1088234D2A2D42AAA882AAAAAD2AAAA42AA8A2C22A22AAAAB62DAAC2A",
                   INITP_02 => X"A28A2922AA28A6AA8888A8A29AA8618228A0AAAAAAAAAAAAAD688A88A28A92AA",
                   INITP_03 => X"10D0A666044448A8A2A228A2A4A8AA292A2A5A5ADD828A2A8A280A4A5555108A",
                   INITP_04 => X"2AAAAAAAAAAAAAAAAAAAAD288A955955B88D2E8000ADE8EAAAAAAA82A8444411",
                   INITP_05 => X"02002DAAAAAA0AAA000155544D78D55554450800A576AA1882985515555020A8",
                   INITP_06 => X"14415411511E003511840800A842902802522DA2A2AAA82A808008D66AAAA0AA",
                   INITP_07 => X"44DAA88A2AA82942AAAAADA97683599282890A002808D78F51E3551105041541",
                   INITP_08 => X"6AA1228B42AA2828AAA228A62D082AAAAAAAAAAAAAAAAAAAAAAA8A28AA434AAB",
                   INITP_09 => X"D28C038E8F410AA22230A8AA35088A020D2A6AA351548AAA20B429AA848B420A",
                   INITP_0A => X"AAAAAAAA882AAAAAA0B50A888AA2222D5550D0008000A888ACC5400800DDD0C3",
                   INITP_0B => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_0C => X"DA574D37602AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_0D => X"544413435812AAA20AAAAA82AAAAAAA5114278D34492D479348AAAA9496A165D",
                   INITP_0E => X"00000000000009249228A2D249292A49377744AA82AAAAABB6490AA8D6691375",
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
                    INIT_00 => X"9000200B9000D008900020071000D00490002715D00B109B0158007200C800D7",
                    INIT_01 => X"D00290005000D01090005000D00490005000D02090005000D00190005000D008",
                    INIT_02 => X"0030400E10010300E0310034001043064306430643060300E031003400205000",
                    INIT_03 => X"100AA042902AA045D010100AA0429011A045D00AA04290305000400E10005000",
                    INIT_04 => X"92072050E050D2411237420E420E420E420E020050005000400E1000A045D010",
                    INIT_05 => X"0007110D5000D1010007D20100070046500091072057E057D1411137310F0100",
                    INIT_06 => X"3B001A01D10100072071D1004BA05000D101113E00075000D1010007110AD101",
                    INIT_07 => X"00A100B700A75000009D00B800A700B700A100AA5000DF045F021F0150002069",
                    INIT_08 => X"9D0100AD1D08208490004D0E009300AA208900A76088CED01D80500000AA00B8",
                    INIT_09 => X"00B7DF043FFE5000DE0100AD209300AA5000009D00B800A100B700A75000608E",
                    INIT_0A => X"00A100B700AA5000DF045F025000DF043FFD500020A3DC019C02DF045F015000",
                    INIT_0B => X"60BE9C011C01500000BD00BD00BD00BD00BD5000009D00BA4E00DC029C0200BA",
                    INIT_0C => X"0046100100691AC11B00B001B03100DD1100113A115611201149114C11435000",
                    INIT_0D => X"F023F0201000500060D9B100900111FF10FF50000065005ED1010007D2010007",
                    INIT_0E => X"B42C1729D005100220F1B42C1728D0051002E0ECD404B42C2116D300B3235000",
                    INIT_0F => X"009A00830E50009A00834E060E700076007220F39401450620F7D40015109404",
                    INIT_10 => X"007D009804E0008D009203E0008D009A00834E070E700076007202540254007D",
                    INIT_11 => X"114950006119D608160100E1F62C1600F62316015000005E0058004000580030",
                    INIT_12 => X"1173116511721120116F1174112011641165116C116911611166112011431132",
                    INIT_13 => X"10015000D009B02C205E00691A1F1B01005E0072110011211164116E116F1170",
                    INIT_14 => X"00834E06007600725000007D014C1E241601014C1E251601014C1E27162CD005",
                    INIT_15 => X"01631E2401631E2501631E27D00510015000009A0083AE60009A00831E09009A",
                    INIT_16 => X"00725000009A00831E00009A00831E00009A00834E06007600725000016F007D",
                    INIT_17 => X"009A00831E01009A00831E00009A00831E78009A00834E061E1AD00510010076",
                    INIT_18 => X"41004206410042064100420641004206A1001001A2001030D00510015000007D",
                    INIT_19 => X"00830E20009A00830E10009A00834E60B62C1E58009A00834E061E1A00760072",
                    INIT_1A => X"21B9D1FF21B5D1004BA01A761B055000D00DB02C5000D00CB02C5000007D009A",
                    INIT_1B => X"BE3000760072D005B02C5000005E21AB3B001A03005E21AB3B001A01D1010007",
                    INIT_1C => X"009A00834E07BE3000760072D005B02C5000007D009A0083BE34009A00834E06",
                    INIT_1D => X"5000D006B02C5000005E0058004000580030007D009804E0008D009203E0008D",
                    INIT_1E => X"1141AE009001AD009001AC009001AB001003102CF140B1285000005E00589006",
                    INIT_1F => X"AC001001AB001041627FC050B528B0405000EE101101ED101101EC101101EB10",
                    INIT_20 => X"024602460240A9009001A8009001A7009001A6001003102CAE001001AD001001",
                    INIT_21 => X"022C024602400235022C024602400235022C024602400235022C120011000246",
                    INIT_22 => X"02A0310101F014005000005E621395017000D101000711207001024602400235",
                    INIT_23 => X"50007000D0011030223D1031623CD0019006000770015000024C442044103204",
                    INIT_24 => X"D40654020253D40650004A00490848084708460E50004F004E084D084C084B0E",
                    INIT_25 => X"114D11541120113A1152114F11521152114550006254900110FF50000253340D",
                    INIT_26 => X"116811741167116E1165116C1120114F1144115411201164116E116111201153",
                    INIT_27 => X"1B0211001168116311741161116D11201174116F116E1120116F116411201173",
                    INIT_28 => X"420043064200430642004306A3401200143002A91545B42C5000005E00691A57",
                    INIT_29 => X"02A91545B42C5000E3501501E25042404406440644064406A440140142004306",
                    INIT_2A => X"500022A99401150115011000D4005000005ED20100070046A05015010058A050",
                    INIT_2B => X"460E4708460EA7401401A640696068601600144502E21504190618261E001D03",
                    INIT_2C => X"1401A64062B7D4611401700002E2150370016E706D604708460E4708460E4708",
                    INIT_2D => X"150617FF18F819000E700D601CFF4708460F4708460F4708460F4708460FA740",
                    INIT_2E => X"0240022C02460240022C02460240022C120011000246024602460240500002E2",
                    INIT_2F => X"19001800164502E21504190618261E001D03500062E8950102460240022C0246",
                    INIT_30 => X"1601E86003370337033703370337033703370337180009800337033703370337",
                    INIT_31 => X"0337190018001C0602E21504190618261E401D0122B7144562FED6631601E960",
                    INIT_32 => X"0007004600800337033703370337033703370337033718000980033703370337",
                    INIT_33 => X"19FF18FF1E0050004808450E9506024C1400233D631D9C01005E00580090D201",
                    INIT_34 => X"5000005E0058A07007501763B52C5000E67007501763B630B52C500002E21502",
                    INIT_35 => X"ADF09F01AEF09F01024CA4F01F0A1F631200130202E21504190618261E201D01",
                    INIT_36 => X"4A064A06AAF09F01AEF09F01700002E21504160017001800190070016DD06EE0",
                    INIT_37 => X"4DA04A064A06AAF09F010D904EA04A08490E4A08490E1A00A9F09F014EA04A06",
                    INIT_38 => X"0B904CA049004A061900AAF09F010C904DA04A08490E4A08490E1A00A9F09F01",
                    INIT_39 => X"D2016EE0AEF09F01700002E2150770016BB06CC06DD06EE04BA04A06AAF09F01",
                    INIT_3A => X"1D01500002E2150418FF1980235812016358D3009301700002E21502700123AA",
                    INIT_3B => X"03D218001609E89003CD10070337190A19631800024C02E21504190618261E20",
                    INIT_3C => X"480E1000D000500023581302120063BED6FF9601E890990103CD80C0100803E1",
                    INIT_3D => X"1C081C031C031C041C041C031C081C031C0823D310009C01033703E123CD9001",
                    INIT_3E => X"103A0007D1010007D201000700460030130050004BA03B000A601AD71B031C08",
                    INIT_3F => X"D0033003130100302403D3FFD1010007D20100070046A030D00110200007D001",
                    INIT_40 => X"5000044706E9069A0210B12BB227A40FD004B02304475000005E23E8005E63F4",
                    INIT_41 => X"11651166116611751142500000C85000D00BB02C5000D00310005000D00310FF",
                    INIT_42 => X"1120113A1174116E1175116F1163112011641172116F115711001120113A1172",
                    INIT_43 => X"1120112011201120113A11731165117A11691173112011641172116F11571100",
                    INIT_44 => X"A0100007E453C120B220110000691A1B1B041100112011641172116F11571100",
                    INIT_45 => X"0007D1010007D201000700460020D00110280007D00110200007244C1101D001",
                    INIT_46 => X"C3401300B423D1010007D20100070046B023000700691A241B04005ED0011029",
                    INIT_47 => X"1301D1010007D20100070046A01001301124D00110400007D00110200007E481",
                    INIT_48 => X"0046A01001301128D00110200007E496C3401300B42300691A311B04005E246F",
                    INIT_49 => X"003000691A411B04005EE4B9C3401300B423005E24871301D1010007D2010007",
                    INIT_4A => X"C65016030650152C4506450613010530D00110200007D1010007D20100070046",
                    INIT_4B => X"5010B02C04C6D004B02C5000005E24AF9601D1010007D20100070046A060A499",
                    INIT_4C => X"100064CCBA009B021B201A04D00A1000D00A10015000D007100000000000D007",
                    INIT_4D => X"900700589007005890075000350195055000005E005890055000D0085000F02C",
                    INIT_4E => X"F02C1000700124F1D002B023A4001001A500102C04D224D8005E005890070058",
                    INIT_4F => X"0556D004B03004BBF02CB030700116001F001E001D007000F02CB030700124F4",
                    INIT_50 => X"10009007100090072528D0A02512D0602530D0C030F090076501300190057000",
                    INIT_51 => X"00072501651FD8FF651FD7FFBD00BE009F019707383F98070000900725019007",
                    INIT_52 => X"25019007000036F096070000000090075000005E0058007000580080D0011045",
                    INIT_53 => X"95013D002E100F00B10090029007310F654DC76037F007109107000000009007",
                    INIT_54 => X"D001104900075000005E005800F0005800E0005800D0D001104E000764F9B400",
                    INIT_55 => X"005E00585011900350006558BA009B011BAA1A295000005E0058007000580060",
                    INIT_56 => X"0046100100691A611B0511001120113A116E116F116911731172116511565000",
                    INIT_57 => X"1104110011671172116111691174116C1175116D5000005ED1010007D2010007",
                    INIT_58 => X"1174116511731165117211E7110311001170116D11751164116D1165116D1105",
                    INIT_59 => X"117311791173116B11051100116E116F11691173117211651176111911041100",
                    INIT_5A => X"115F117211651177116F117011A9110111001170116C11651168114711041100",
                    INIT_5B => X"1104110011661166116F115F117211651177116F1170111011041100116E116F",
                    INIT_5C => X"116911E0110111001172116A11DD110111001177116A11E11100110011611113",
                    INIT_5D => X"116D116A11E4110111001164116A11C8110111001172116911BB110111001177",
                    INIT_5E => X"116A119D1102110011721174116A11841102110011771174116A11F811011100",
                    INIT_5F => X"1103110011731174116A11F71102110011671174116A11B01102110011751174",
                    INIT_60 => X"11D211041100117A117411D4110411001166117411BB11041100116311741116",
                    INIT_61 => X"1103110011721161116A11431103110011771161116A11D81104110011721174",
                    INIT_62 => X"11001170117311AF1103110011671161116A11501103110011751161116A1149",
                    INIT_63 => X"1167111611041100117011741182110111001164113F110111001170113C1101",
                    INIT_64 => X"115F117411731165117411E51104110011731174115811011100116F11691170",
                    INIT_65 => X"117411651173115F116E116911611167115C110511001174116C117511611166",
                    INIT_66 => X"D1004BA012001A761B0511FF11A611011100116F11691170116711A311011100",
                    INIT_67 => X"2696D1FF4BA0266E3B001A011201667DC010A020E67DC200B0202696D1FF2689",
                    INIT_68 => X"1A0102104BA03B001A0106E9069A266E12003B001A03267D3B001A012685D100",
                    INIT_69 => X"A020E6C4C210B120F02310005000006506D100DD5000006500DD42104BA03B00",
                    INIT_6A => X"C310B12013080320E21001001123F02326C4D0051001B0239201E69C00341201",
                    INIT_6B => X"B0238300A01091011124B123032026B21201E6B90034A02026B9C3200310A6B2",
                    INIT_6C => X"1164116E1161116D116D116F116311201164116111425000269CE30090011028",
                    INIT_6D => X"1AD61B0611001120113A1172116F1172117211455000005E00691AC51B061100",
                    INIT_6E => X"C1201101E0101000112C120412385000005ED1010007D2010007004600200069",
                    INIT_6F => X"172C4706470607400650A61001401128A50000401024E714C400B0231400A6EC",
                    INIT_70 => X"66F2C650160127011701E07000219601A1601601A260A70DC650A6F296021401",
                    INIT_71 => X"0734E72CD120F1201101B120E0101100B1209001000B500026F2E0700034A060",
                    INIT_72 => X"00691A221B07005E110011211177116F116C1166117211651176114F2715866B",
                    INIT_73 => X"B020E745D1202751D108274AD10A274AD10DA1009001B0202715006500DD005E",
                    INIT_74 => X"400C1001F0209001B020005E5000400C1000D10100075000400C1000F0209001",
                    INIT_75 => X"F0209001B020D10111080007D10111200007D10111080007A7609002B0205000",
                    INIT_76 => X"00000000000000000000000000000000000000005000400C1000F0209001B020",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"AAAAAA0A5ADA8AA28AAA9F507D554A4D775DDD9211E154E2082082082C2C28AA",
                   INITP_01 => X"A292A5D1088234D2A2D42AAA882AAAAAD2AAAA42AA8A2C22A22AAAAB62DAAC2A",
                   INITP_02 => X"A28A2922AA28A6AA8888A8A29AA8618228A0AAAAAAAAAAAAAD688A88A28A92AA",
                   INITP_03 => X"10D0A666044448A8A2A228A2A4A8AA292A2A5A5ADD828A2A8A280A4A5555108A",
                   INITP_04 => X"2AAAAAAAAAAAAAAAAAAAAD288A955955B88D2E8000ADE8EAAAAAAA82A8444411",
                   INITP_05 => X"02002DAAAAAA0AAA000155544D78D55554450800A576AA1882985515555020A8",
                   INITP_06 => X"14415411511E003511840800A842902802522DA2A2AAA82A808008D66AAAA0AA",
                   INITP_07 => X"44DAA88A2AA82942AAAAADA97683599282890A002808D78F51E3551105041541",
                   INITP_08 => X"6AA1228B42AA2828AAA228A62D082AAAAAAAAAAAAAAAAAAAAAAA8A28AA434AAB",
                   INITP_09 => X"D28C038E8F410AA22230A8AA35088A020D2A6AA351548AAA20B429AA848B420A",
                   INITP_0A => X"AAAAAAAA882AAAAAA0B50A888AA2222D5550D0008000A888ACC5400800DDD0C3",
                   INITP_0B => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_0C => X"DA574D37602AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_0D => X"544413435812AAA20AAAAA82AAAAAAA5114278D34492D479348AAAA9496A165D",
                   INITP_0E => X"00000000000009249228A2D249292A49377744AA82AAAAABB6490AA8D6691375",
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
                    INIT_00 => X"02000010000004000020000001000008000B00080007000400150B9B5872C8D7",
                    INIT_01 => X"0A422A45100A4211450A4230000E0000300E0100313410060606060031342000",
                    INIT_02 => X"070D0001070107460007575741370F0007505041370E0E0E0E0000000E004510",
                    INIT_03 => X"A1B7A7009DB8A7B7A1AA000402010069000101077100A000013E070001070A01",
                    INIT_04 => X"B704FE0001AD93AA009DB8A1B7A7008E01AD0884000E93AA89A788D08000AAB8",
                    INIT_05 => X"BE010100BDBDBDBDBD009DBA000202BAA1B7AA0004020004FD00A30102040100",
                    INIT_06 => X"23200000D90001FFFF00655E01070107460169C1000131DD003A5620494C4300",
                    INIT_07 => X"9A83509A8306707672F30106F70010042C290502F12C280502EC042C16002300",
                    INIT_08 => X"4900190801E12C002301005E584058307D98E08D92E08D9A830770767254547D",
                    INIT_09 => X"0100092C5E691F015E720021646E6F70736572206F742064656C696166204332",
                    INIT_0A => X"6324632563270501009A83609A83099A83067672007D4C24014C25014C272C05",
                    INIT_0B => X"9A83019A83009A83789A83061A05017672009A83009A83009A83067672006F7D",
                    INIT_0C => X"83209A83109A83602C589A83061A76720006000600060006000100300501007D",
                    INIT_0D => X"307672052C005EAB00035EAB00010107B9FFB500A07605000D2C000C2C007D9A",
                    INIT_0E => X"00062C005E584058307D98E08D92E08D9A8307307672052C007D9A83349A8306",
                    INIT_0F => X"000100417F50284000100110011001104100010001000100032C4028005E5806",
                    INIT_10 => X"2C4640352C4640352C4640352C00004646464000010001000100032C00010001",
                    INIT_11 => X"000001303D313C01060701004C201004A001F000005E13010001072001464035",
                    INIT_12 => X"4D54203A524F525245005401FF00530D0602530600000808080E00000808080E",
                    INIT_13 => X"0200686374616D20746F6E206F6420736874676E656C204F445420646E612053",
                    INIT_14 => X"A9452C00500150400606060640010006000600060006400030A9452C005E6957",
                    INIT_15 => X"0E080E40014060600045E2040626000300A90101010000005E01074650015850",
                    INIT_16 => X"06FFF8007060FF080F080F080F080F400140B7610100E203017060080E080E08",
                    INIT_17 => X"000045E2040626000300E80146402C46402C46402C46402C00004646464000E2",
                    INIT_18 => X"37000006E20406264001B745FE63016001603737373737373737008037373737",
                    INIT_19 => X"FFFF0000080E064C003D1D015E58900107468037373737373737370080373737",
                    INIT_1A => X"F001F0014CF00A630002E20406262001005E587050632C00705063302C00E202",
                    INIT_1B => X"A00606F00190A0080E080E00F001A0060606F001F00100E2040000000001D0E0",
                    INIT_1C => X"01E0F00100E20701B0C0D0E0A006F00190A0000600F00190A0080E080E00F001",
                    INIT_1D => X"D2000990CD07370A63004CE2040626200100E204FF80580158000100E20201AA",
                    INIT_1E => X"080303040403080308D3000137E1CD010E000000580200BEFF019001CDC008E1",
                    INIT_1F => X"0303013003FF010701074630012007013A070107010746300000A00060D70308",
                    INIT_20 => X"656666754200C8000B2C0003000003FF0047E99A102B270F042347005EE85EF4",
                    INIT_21 => X"202020203A73657A69732064726F5700203A746E756F632064726F5700203A72",
                    INIT_22 => X"070107010746200128070120074C0101100753202000691B04002064726F5700",
                    INIT_23 => X"01010701074610302401400701200781400023010701074623076924045E0129",
                    INIT_24 => X"306941045EB94000235E87010107010746103028012007964000236931045E6F",
                    INIT_25 => X"102CC6042C005EAF01010701074660995003502C060601300120070107010746",
                    INIT_26 => X"0758075807000105005E58050008002C00CC000220040A000A01000700000007",
                    INIT_27 => X"560430BB2C300100000000002C3001F42C0001F102230001002CD2D85E580758",
                    INIT_28 => X"07011FFF1FFF000001073F07000701070007000728A0126030C0F00701010500",
                    INIT_29 => X"010010000002070F4D60F01007000007010700F007000007005E587058800145",
                    INIT_2A => X"5E58110300580001AA29005E58705860014907005E58F058E058D0014E07F900",
                    INIT_2B => X"040067726169746C756D005E01070107460169610500203A6E6F697372655600",
                    INIT_2C => X"7379736B05006E6F69737265761904007465736572E70300706D75646D656D05",
                    INIT_2D => X"040066666F5F7265776F701004006E6F5F7265776F70A90100706C6568470400",
                    INIT_2E => X"6D6AE40100646AC801007269BB01007769E00100726ADD0100776AE100006113",
                    INIT_2F => X"030073746AF7020067746AB0020075746A9D020072746A84020077746AF80100",
                    INIT_30 => X"030072616A43030077616AD804007274D204007A74D404006674BB0400637416",
                    INIT_31 => X"671604007074820100643F0100703C01007073AF030067616A50030075616A49",
                    INIT_32 => X"7465735F6E6961675C0500746C7561665F74736574E5040073745801006F6970",
                    INIT_33 => X"96FFA06E0001017D10207D002096FF8900A0007605FFA601006F697067A30100",
                    INIT_34 => X"20C4102023000065D1DD0065DD10A0000110A00001E99A6E0000037D00018500",
                    INIT_35 => X"23001001242320B201B93420B92010B21020082010002323C4050123019C3401",
                    INIT_36 => X"D60600203A726F727245005E69C50600646E616D6D6F6320646142009C000128",
                    INIT_37 => X"2C0606405010402800402414002300EC200110002C0438005E01070107462069",
                    INIT_38 => X"342C20200120100020010B00F2703460F2500101017021016001600D50F20201",
                    INIT_39 => X"20452051084A0A4A0D0001201565DD5E6922075E0021776F6C667265764F156B",
                    INIT_3A => X"200120010807012007010807600220000C012001205E000C000107000C002001",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000C00200120",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"0012420E050808FE00000D866000A408001CA6CB504F0000000011F000000048",
                   INITP_01 => X"223B913000020000019AFA000000AA8000000002A8000248013FFFFFA0000400",
                   INITP_02 => X"8C900040D5550135521918044C015620FFFFFFFFFF8002950000615000021102",
                   INITP_03 => X"260020B2004E0D198B8C96E512A9AAAB8CAC14AAD3590E6986601FEFC6413FDF",
                   INITP_04 => X"80A000800300180000401F10131830C4C180D008400214FFFFFFFFFFF8000405",
                   INITP_05 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC80FFE05800000D9F880006EC20A88",
                   INITP_06 => X"F390C8407FC3FFE45E06F600100330496802CFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_07 => X"00000000000000000000000000000000000000001B6800407FC82FFEFD801890")
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
                    INIT_00 => X"684828684828684828684828684828684810C868481088684813680800000000",
                    INIT_01 => X"88D0C8D0E888D0C8D0E8D0C828A0082800A00881F00000A1A1A1A101F0000028",
                    INIT_02 => X"000828680069000028C890F0E8881800C990F0E989A1A1A1A1012828A008D0E8",
                    INIT_03 => X"00000028000000000000286F2F0F28109D8D680090E825286808002868000868",
                    INIT_04 => X"006F1F286F00100028000000000028B0CE000E10C8A600001000B0670E280000",
                    INIT_05 => X"B0CE0E280000000000280000A76E4E00000000286F2F286F1F28906E4E6F2F28",
                    INIT_06 => X"78780828B0D8C80808280000680069000008000D0D5858000808080808080828",
                    INIT_07 => X"0000070000A707000010CAA290EA0ACA5A0B6808105A0B6808F0EA5A90E95928",
                    INIT_08 => X"0828B0EB8B007B0B7B0B280000000000000002000001000000A7070000010100",
                    INIT_09 => X"0828685810000D0D000008080808080808080808080808080808080808080808",
                    INIT_0A => X"000F000F000F68082800005700000F0000A700002800000F8B000F8B000F0B68",
                    INIT_0B => X"00000F00000F00000F0000A70F680800002800000F00000F0000A70000280000",
                    INIT_0C => X"00070000070000275B0F0000A70F0000A0A1A0A1A0A1A0A15088510868082800",
                    INIT_0D => X"5F000068582800109D8D00109D8D680090E890E8250D0D286858286858280000",
                    INIT_0E => X"286858280000000000000002000001000000A75F00006858280000005F0000A7",
                    INIT_0F => X"56885508B1E05A5828778876887688750857C856C856C8558808785828000048",
                    INIT_10 => X"0101010101010101010101010109080101010154C854C853C853880857885688",
                    INIT_11 => X"28B868081108B1E84800B828012222190118000A2800B1CAB8680008B8010101",
                    INIT_12 => X"08080808080808080828B1C80828011A6A2A016A28A5A4A4A3A328A7A7A6A6A5",
                    INIT_13 => X"0D08080808080808080808080808080808080808080808080808080808080808",
                    INIT_14 => X"010A5A28718A7121A2A2A2A2528AA1A1A1A1A1A1A1A151090A010A5A2800000D",
                    INIT_15 => X"A3A3A3538A53B4B40B0A010A0C0C0F0E2811CA8A8A88EA2800690000508A0050",
                    INIT_16 => X"0A0B0C0C07060EA3A3A3A3A3A3A3A3538A53B1EA8AB8010AB8B7B6A3A3A3A3A3",
                    INIT_17 => X"0C0C0B010A0C0C0F0E28B1CA0101010101010101010101010908010101012801",
                    INIT_18 => X"010C0C0E010A0C0C0F0E110AB1EB8B748B7401010101010101010C0401010101",
                    INIT_19 => X"0C0C0F28A4A24A010A11B1CE0000006900000001010101010101010C04010101",
                    INIT_1A => X"56CF57CF01528F0F0909010A0C0C0F0E28000050830B5A2873830B5B5A28010A",
                    INIT_1B => X"26A5A555CF0627A5A4A5A40D54CF27A5A5A555CF57CFB8010A0B0B0C0CB8B6B7",
                    INIT_1C => X"E9B757CFB8010AB8B5B6B6B725A555CF0526A4A50C55CF0626A5A4A5A40D54CF",
                    INIT_1D => X"010C0B740108018C0C0C01010A0C0C0F0E28010A0C0C1109B1E9C9B8010AB891",
                    INIT_1E => X"0E0E0E0E0E0E0E0E0E1188CE010111C8A488E828110909B1EBCB74CC01C00801",
                    INIT_1F => X"E818890092E96800690000506808006808006800690000000928259D850D0D0E",
                    INIT_20 => X"0808080808280028685828680828680828020303815859D2E8580228001100B1",
                    INIT_21 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_22 => X"006800690000006808006808001288685000F2E05908000D0D08080808080808",
                    INIT_23 => X"896800690000508008680800680800F2E1095A68006900005800000D0D006808",
                    INIT_24 => X"00000D0D00F2E1095A0012896800690000508008680800F2E1095A000D0D0012",
                    INIT_25 => X"285882E858280012CB680069000050D2E38B038AA2A289026808006800690000",
                    INIT_26 => X"4800480048A81A4A280000482868287808B2DDCD0D0D68086808286808000068",
                    INIT_27 => X"82E858027858B80B0F0F0EB87858B8127808B892E85852885208021200004800",
                    INIT_28 => X"0012B26CB26BDEDFCF4B1C4C004812480848084892E892E892E81848B21848B8",
                    INIT_29 => X"CA9E9787D8C84818B2E31B03480000481248001B4B0000482800000000006808",
                    INIT_2A => X"0000284828B2DDCD0D0D2800000000006808002800000000000000680800B2DA",
                    INIT_2B => X"080808080808080808082800680069000008000D0D0808080808080808080828",
                    INIT_2C => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2D => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2E => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2F => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_30 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_31 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_32 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_33 => X"93E825139D8D89B3E050F3E15893E893E825090D0D0808080808080808080808",
                    INIT_34 => X"50F3E15878082800030028000021259D8D01259D8D030313099D8D139D8D93E8",
                    INIT_35 => X"58C150C88858011389F3005093E101D3E15889017180087893E88858C9F30089",
                    INIT_36 => X"0D0D08080808080808082800000D0D080808080808080808080808281371C888",
                    INIT_37 => X"8BA3A30383538008528008F3E2580AD3E0887008088909280068006900000000",
                    INIT_38 => X"03F3E878885870885848002813700050B3E38B138B7000CB508B51D3E3D3CB8A",
                    INIT_39 => X"58F3E893E893E893E850C85813000000000D0D000808080808080808080813C3",
                    INIT_3A => X"78C858680800680800680800D3C85828A00878C8580028A008680028A00878C8",
                    INIT_3B => X"000000000000000000000000000000000000000000000000000028A00878C858",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"D9C82949D87FA7FF9FF1FB65D7FF5BE7FFF33BBDBFB0603252A90C0D2492666F",
                   INITP_01 => X"08D5002EDD6DCEF67733A9B7B633000BDB65F6DFAAEDBE496CFFFFFFE6BADB9F",
                   INITP_02 => X"106FFF3F000026800020C5F29A00004E7FFFFFFFFFE6B820EA780EEFFFF9E000",
                   INITP_03 => X"0BEB7E61FFEE59299A30629B0D000000000003040820E186116DDFE788297FCF",
                   INITP_04 => X"9A1BB03D54EF42B1277D00BF4C6F8B137C5B1F66FD6D627FFFFFFFFFFFB6F13F",
                   INITP_05 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFA7FFCC3ABD56008080EAE8020A89",
                   INITP_06 => X"001121FD3FF9FFFC016909864BFE2712B12547FFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_07 => X"000000000000000000000000000000000000002496D92672550F9FFFD23E9614")
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
                    INIT_00 => X"02000010000004000020000001000008000B00080007000400150B9B5872C8D7",
                    INIT_01 => X"0A422A45100A4211450A4230000E0000300E0100313410060606060031342000",
                    INIT_02 => X"070D0001070107460007575741370F0007505041370E0E0E0E0000000E004510",
                    INIT_03 => X"A1B7A7009DB8A7B7A1AA000402010069000101077100A000013E070001070A01",
                    INIT_04 => X"B704FE0001AD93AA009DB8A1B7A7008E01AD0884000E93AA89A788D08000AAB8",
                    INIT_05 => X"BE010100BDBDBDBDBD009DBA000202BAA1B7AA0004020004FD00A30102040100",
                    INIT_06 => X"23200000D90001FFFF00655E01070107460169C1000131DD003A5620494C4300",
                    INIT_07 => X"9A83509A8306707672F30106F70010042C290502F12C280502EC042C16002300",
                    INIT_08 => X"4900190801E12C002301005E584058307D98E08D92E08D9A830770767254547D",
                    INIT_09 => X"0100092C5E691F015E720021646E6F70736572206F742064656C696166204332",
                    INIT_0A => X"6324632563270501009A83609A83099A83067672007D4C24014C25014C272C05",
                    INIT_0B => X"9A83019A83009A83789A83061A05017672009A83009A83009A83067672006F7D",
                    INIT_0C => X"83209A83109A83602C589A83061A76720006000600060006000100300501007D",
                    INIT_0D => X"307672052C005EAB00035EAB00010107B9FFB500A07605000D2C000C2C007D9A",
                    INIT_0E => X"00062C005E584058307D98E08D92E08D9A8307307672052C007D9A83349A8306",
                    INIT_0F => X"000100417F50284000100110011001104100010001000100032C4028005E5806",
                    INIT_10 => X"2C4640352C4640352C4640352C00004646464000010001000100032C00010001",
                    INIT_11 => X"000001303D313C01060701004C201004A001F000005E13010001072001464035",
                    INIT_12 => X"4D54203A524F525245005401FF00530D0602530600000808080E00000808080E",
                    INIT_13 => X"0200686374616D20746F6E206F6420736874676E656C204F445420646E612053",
                    INIT_14 => X"A9452C00500150400606060640010006000600060006400030A9452C005E6957",
                    INIT_15 => X"0E080E40014060600045E2040626000300A90101010000005E01074650015850",
                    INIT_16 => X"06FFF8007060FF080F080F080F080F400140B7610100E203017060080E080E08",
                    INIT_17 => X"000045E2040626000300E80146402C46402C46402C46402C00004646464000E2",
                    INIT_18 => X"37000006E20406264001B745FE63016001603737373737373737008037373737",
                    INIT_19 => X"FFFF0000080E064C003D1D015E58900107468037373737373737370080373737",
                    INIT_1A => X"F001F0014CF00A630002E20406262001005E587050632C00705063302C00E202",
                    INIT_1B => X"A00606F00190A0080E080E00F001A0060606F001F00100E2040000000001D0E0",
                    INIT_1C => X"01E0F00100E20701B0C0D0E0A006F00190A0000600F00190A0080E080E00F001",
                    INIT_1D => X"D2000990CD07370A63004CE2040626200100E204FF80580158000100E20201AA",
                    INIT_1E => X"080303040403080308D3000137E1CD010E000000580200BEFF019001CDC008E1",
                    INIT_1F => X"0303013003FF010701074630012007013A070107010746300000A00060D70308",
                    INIT_20 => X"656666754200C8000B2C0003000003FF0047E99A102B270F042347005EE85EF4",
                    INIT_21 => X"202020203A73657A69732064726F5700203A746E756F632064726F5700203A72",
                    INIT_22 => X"070107010746200128070120074C0101100753202000691B04002064726F5700",
                    INIT_23 => X"01010701074610302401400701200781400023010701074623076924045E0129",
                    INIT_24 => X"306941045EB94000235E87010107010746103028012007964000236931045E6F",
                    INIT_25 => X"102CC6042C005EAF01010701074660995003502C060601300120070107010746",
                    INIT_26 => X"0758075807000105005E58050008002C00CC000220040A000A01000700000007",
                    INIT_27 => X"560430BB2C300100000000002C3001F42C0001F102230001002CD2D85E580758",
                    INIT_28 => X"07011FFF1FFF000001073F07000701070007000728A0126030C0F00701010500",
                    INIT_29 => X"010010000002070F4D60F01007000007010700F007000007005E587058800145",
                    INIT_2A => X"5E58110300580001AA29005E58705860014907005E58F058E058D0014E07F900",
                    INIT_2B => X"040067726169746C756D005E01070107460169610500203A6E6F697372655600",
                    INIT_2C => X"7379736B05006E6F69737265761904007465736572E70300706D75646D656D05",
                    INIT_2D => X"040066666F5F7265776F701004006E6F5F7265776F70A90100706C6568470400",
                    INIT_2E => X"6D6AE40100646AC801007269BB01007769E00100726ADD0100776AE100006113",
                    INIT_2F => X"030073746AF7020067746AB0020075746A9D020072746A84020077746AF80100",
                    INIT_30 => X"030072616A43030077616AD804007274D204007A74D404006674BB0400637416",
                    INIT_31 => X"671604007074820100643F0100703C01007073AF030067616A50030075616A49",
                    INIT_32 => X"7465735F6E6961675C0500746C7561665F74736574E5040073745801006F6970",
                    INIT_33 => X"96FFA06E0001017D10207D002096FF8900A0007605FFA601006F697067A30100",
                    INIT_34 => X"20C4102023000065D1DD0065DD10A0000110A00001E99A6E0000037D00018500",
                    INIT_35 => X"23001001242320B201B93420B92010B21020082010002323C4050123019C3401",
                    INIT_36 => X"D60600203A726F727245005E69C50600646E616D6D6F6320646142009C000128",
                    INIT_37 => X"2C0606405010402800402414002300EC200110002C0438005E01070107462069",
                    INIT_38 => X"342C20200120100020010B00F2703460F2500101017021016001600D50F20201",
                    INIT_39 => X"20452051084A0A4A0D0001201565DD5E6922075E0021776F6C667265764F156B",
                    INIT_3A => X"200120010807012007010807600220000C012001205E000C000107000C002001",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000C00200120",
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
                   INITP_00 => X"0012420E050808FE00000D866000A408001CA6CB504F0000000011F000000048",
                   INITP_01 => X"223B913000020000019AFA000000AA8000000002A8000248013FFFFFA0000400",
                   INITP_02 => X"8C900040D5550135521918044C015620FFFFFFFFFF8002950000615000021102",
                   INITP_03 => X"260020B2004E0D198B8C96E512A9AAAB8CAC14AAD3590E6986601FEFC6413FDF",
                   INITP_04 => X"80A000800300180000401F10131830C4C180D008400214FFFFFFFFFFF8000405",
                   INITP_05 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC80FFE05800000D9F880006EC20A88",
                   INITP_06 => X"F390C8407FC3FFE45E06F600100330496802CFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_07 => X"00000000000000000000000000000000000000001B6800407FC82FFEFD801890",
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
                    INIT_00 => X"684828684828684828684828684828684810C868481088684813680800000000",
                    INIT_01 => X"88D0C8D0E888D0C8D0E8D0C828A0082800A00881F00000A1A1A1A101F0000028",
                    INIT_02 => X"000828680069000028C890F0E8881800C990F0E989A1A1A1A1012828A008D0E8",
                    INIT_03 => X"00000028000000000000286F2F0F28109D8D680090E825286808002868000868",
                    INIT_04 => X"006F1F286F00100028000000000028B0CE000E10C8A600001000B0670E280000",
                    INIT_05 => X"B0CE0E280000000000280000A76E4E00000000286F2F286F1F28906E4E6F2F28",
                    INIT_06 => X"78780828B0D8C80808280000680069000008000D0D5858000808080808080828",
                    INIT_07 => X"0000070000A707000010CAA290EA0ACA5A0B6808105A0B6808F0EA5A90E95928",
                    INIT_08 => X"0828B0EB8B007B0B7B0B280000000000000002000001000000A7070000010100",
                    INIT_09 => X"0828685810000D0D000008080808080808080808080808080808080808080808",
                    INIT_0A => X"000F000F000F68082800005700000F0000A700002800000F8B000F8B000F0B68",
                    INIT_0B => X"00000F00000F00000F0000A70F680800002800000F00000F0000A70000280000",
                    INIT_0C => X"00070000070000275B0F0000A70F0000A0A1A0A1A0A1A0A15088510868082800",
                    INIT_0D => X"5F000068582800109D8D00109D8D680090E890E8250D0D286858286858280000",
                    INIT_0E => X"286858280000000000000002000001000000A75F00006858280000005F0000A7",
                    INIT_0F => X"56885508B1E05A5828778876887688750857C856C856C8558808785828000048",
                    INIT_10 => X"0101010101010101010101010109080101010154C854C853C853880857885688",
                    INIT_11 => X"28B868081108B1E84800B828012222190118000A2800B1CAB8680008B8010101",
                    INIT_12 => X"08080808080808080828B1C80828011A6A2A016A28A5A4A4A3A328A7A7A6A6A5",
                    INIT_13 => X"0D08080808080808080808080808080808080808080808080808080808080808",
                    INIT_14 => X"010A5A28718A7121A2A2A2A2528AA1A1A1A1A1A1A1A151090A010A5A2800000D",
                    INIT_15 => X"A3A3A3538A53B4B40B0A010A0C0C0F0E2811CA8A8A88EA2800690000508A0050",
                    INIT_16 => X"0A0B0C0C07060EA3A3A3A3A3A3A3A3538A53B1EA8AB8010AB8B7B6A3A3A3A3A3",
                    INIT_17 => X"0C0C0B010A0C0C0F0E28B1CA0101010101010101010101010908010101012801",
                    INIT_18 => X"010C0C0E010A0C0C0F0E110AB1EB8B748B7401010101010101010C0401010101",
                    INIT_19 => X"0C0C0F28A4A24A010A11B1CE0000006900000001010101010101010C04010101",
                    INIT_1A => X"56CF57CF01528F0F0909010A0C0C0F0E28000050830B5A2873830B5B5A28010A",
                    INIT_1B => X"26A5A555CF0627A5A4A5A40D54CF27A5A5A555CF57CFB8010A0B0B0C0CB8B6B7",
                    INIT_1C => X"E9B757CFB8010AB8B5B6B6B725A555CF0526A4A50C55CF0626A5A4A5A40D54CF",
                    INIT_1D => X"010C0B740108018C0C0C01010A0C0C0F0E28010A0C0C1109B1E9C9B8010AB891",
                    INIT_1E => X"0E0E0E0E0E0E0E0E0E1188CE010111C8A488E828110909B1EBCB74CC01C00801",
                    INIT_1F => X"E818890092E96800690000506808006808006800690000000928259D850D0D0E",
                    INIT_20 => X"0808080808280028685828680828680828020303815859D2E8580228001100B1",
                    INIT_21 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_22 => X"006800690000006808006808001288685000F2E05908000D0D08080808080808",
                    INIT_23 => X"896800690000508008680800680800F2E1095A68006900005800000D0D006808",
                    INIT_24 => X"00000D0D00F2E1095A0012896800690000508008680800F2E1095A000D0D0012",
                    INIT_25 => X"285882E858280012CB680069000050D2E38B038AA2A289026808006800690000",
                    INIT_26 => X"4800480048A81A4A280000482868287808B2DDCD0D0D68086808286808000068",
                    INIT_27 => X"82E858027858B80B0F0F0EB87858B8127808B892E85852885208021200004800",
                    INIT_28 => X"0012B26CB26BDEDFCF4B1C4C004812480848084892E892E892E81848B21848B8",
                    INIT_29 => X"CA9E9787D8C84818B2E31B03480000481248001B4B0000482800000000006808",
                    INIT_2A => X"0000284828B2DDCD0D0D2800000000006808002800000000000000680800B2DA",
                    INIT_2B => X"080808080808080808082800680069000008000D0D0808080808080808080828",
                    INIT_2C => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2D => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2E => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2F => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_30 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_31 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_32 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_33 => X"93E825139D8D89B3E050F3E15893E893E825090D0D0808080808080808080808",
                    INIT_34 => X"50F3E15878082800030028000021259D8D01259D8D030313099D8D139D8D93E8",
                    INIT_35 => X"58C150C88858011389F3005093E101D3E15889017180087893E88858C9F30089",
                    INIT_36 => X"0D0D08080808080808082800000D0D080808080808080808080808281371C888",
                    INIT_37 => X"8BA3A30383538008528008F3E2580AD3E0887008088909280068006900000000",
                    INIT_38 => X"03F3E878885870885848002813700050B3E38B138B7000CB508B51D3E3D3CB8A",
                    INIT_39 => X"58F3E893E893E893E850C85813000000000D0D000808080808080808080813C3",
                    INIT_3A => X"78C858680800680800680800D3C85828A00878C8580028A008680028A00878C8",
                    INIT_3B => X"000000000000000000000000000000000000000000000000000028A00878C858",
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
                   INITP_00 => X"D9C82949D87FA7FF9FF1FB65D7FF5BE7FFF33BBDBFB0603252A90C0D2492666F",
                   INITP_01 => X"08D5002EDD6DCEF67733A9B7B633000BDB65F6DFAAEDBE496CFFFFFFE6BADB9F",
                   INITP_02 => X"106FFF3F000026800020C5F29A00004E7FFFFFFFFFE6B820EA780EEFFFF9E000",
                   INITP_03 => X"0BEB7E61FFEE59299A30629B0D000000000003040820E186116DDFE788297FCF",
                   INITP_04 => X"9A1BB03D54EF42B1277D00BF4C6F8B137C5B1F66FD6D627FFFFFFFFFFFB6F13F",
                   INITP_05 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFA7FFCC3ABD56008080EAE8020A89",
                   INITP_06 => X"001121FD3FF9FFFC016909864BFE2712B12547FFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_07 => X"000000000000000000000000000000000000002496D92672550F9FFFD23E9614",
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
                    INIT_00 => X"02000010000004000020000001000008000B00080007000400150B9B5872C8D7",
                    INIT_01 => X"0A422A45100A4211450A4230000E0000300E0100313410060606060031342000",
                    INIT_02 => X"070D0001070107460007575741370F0007505041370E0E0E0E0000000E004510",
                    INIT_03 => X"A1B7A7009DB8A7B7A1AA000402010069000101077100A000013E070001070A01",
                    INIT_04 => X"B704FE0001AD93AA009DB8A1B7A7008E01AD0884000E93AA89A788D08000AAB8",
                    INIT_05 => X"BE010100BDBDBDBDBD009DBA000202BAA1B7AA0004020004FD00A30102040100",
                    INIT_06 => X"23200000D90001FFFF00655E01070107460169C1000131DD003A5620494C4300",
                    INIT_07 => X"9A83509A8306707672F30106F70010042C290502F12C280502EC042C16002300",
                    INIT_08 => X"4900190801E12C002301005E584058307D98E08D92E08D9A830770767254547D",
                    INIT_09 => X"0100092C5E691F015E720021646E6F70736572206F742064656C696166204332",
                    INIT_0A => X"6324632563270501009A83609A83099A83067672007D4C24014C25014C272C05",
                    INIT_0B => X"9A83019A83009A83789A83061A05017672009A83009A83009A83067672006F7D",
                    INIT_0C => X"83209A83109A83602C589A83061A76720006000600060006000100300501007D",
                    INIT_0D => X"307672052C005EAB00035EAB00010107B9FFB500A07605000D2C000C2C007D9A",
                    INIT_0E => X"00062C005E584058307D98E08D92E08D9A8307307672052C007D9A83349A8306",
                    INIT_0F => X"000100417F50284000100110011001104100010001000100032C4028005E5806",
                    INIT_10 => X"2C4640352C4640352C4640352C00004646464000010001000100032C00010001",
                    INIT_11 => X"000001303D313C01060701004C201004A001F000005E13010001072001464035",
                    INIT_12 => X"4D54203A524F525245005401FF00530D0602530600000808080E00000808080E",
                    INIT_13 => X"0200686374616D20746F6E206F6420736874676E656C204F445420646E612053",
                    INIT_14 => X"A9452C00500150400606060640010006000600060006400030A9452C005E6957",
                    INIT_15 => X"0E080E40014060600045E2040626000300A90101010000005E01074650015850",
                    INIT_16 => X"06FFF8007060FF080F080F080F080F400140B7610100E203017060080E080E08",
                    INIT_17 => X"000045E2040626000300E80146402C46402C46402C46402C00004646464000E2",
                    INIT_18 => X"37000006E20406264001B745FE63016001603737373737373737008037373737",
                    INIT_19 => X"FFFF0000080E064C003D1D015E58900107468037373737373737370080373737",
                    INIT_1A => X"F001F0014CF00A630002E20406262001005E587050632C00705063302C00E202",
                    INIT_1B => X"A00606F00190A0080E080E00F001A0060606F001F00100E2040000000001D0E0",
                    INIT_1C => X"01E0F00100E20701B0C0D0E0A006F00190A0000600F00190A0080E080E00F001",
                    INIT_1D => X"D2000990CD07370A63004CE2040626200100E204FF80580158000100E20201AA",
                    INIT_1E => X"080303040403080308D3000137E1CD010E000000580200BEFF019001CDC008E1",
                    INIT_1F => X"0303013003FF010701074630012007013A070107010746300000A00060D70308",
                    INIT_20 => X"656666754200C8000B2C0003000003FF0047E99A102B270F042347005EE85EF4",
                    INIT_21 => X"202020203A73657A69732064726F5700203A746E756F632064726F5700203A72",
                    INIT_22 => X"070107010746200128070120074C0101100753202000691B04002064726F5700",
                    INIT_23 => X"01010701074610302401400701200781400023010701074623076924045E0129",
                    INIT_24 => X"306941045EB94000235E87010107010746103028012007964000236931045E6F",
                    INIT_25 => X"102CC6042C005EAF01010701074660995003502C060601300120070107010746",
                    INIT_26 => X"0758075807000105005E58050008002C00CC000220040A000A01000700000007",
                    INIT_27 => X"560430BB2C300100000000002C3001F42C0001F102230001002CD2D85E580758",
                    INIT_28 => X"07011FFF1FFF000001073F07000701070007000728A0126030C0F00701010500",
                    INIT_29 => X"010010000002070F4D60F01007000007010700F007000007005E587058800145",
                    INIT_2A => X"5E58110300580001AA29005E58705860014907005E58F058E058D0014E07F900",
                    INIT_2B => X"040067726169746C756D005E01070107460169610500203A6E6F697372655600",
                    INIT_2C => X"7379736B05006E6F69737265761904007465736572E70300706D75646D656D05",
                    INIT_2D => X"040066666F5F7265776F701004006E6F5F7265776F70A90100706C6568470400",
                    INIT_2E => X"6D6AE40100646AC801007269BB01007769E00100726ADD0100776AE100006113",
                    INIT_2F => X"030073746AF7020067746AB0020075746A9D020072746A84020077746AF80100",
                    INIT_30 => X"030072616A43030077616AD804007274D204007A74D404006674BB0400637416",
                    INIT_31 => X"671604007074820100643F0100703C01007073AF030067616A50030075616A49",
                    INIT_32 => X"7465735F6E6961675C0500746C7561665F74736574E5040073745801006F6970",
                    INIT_33 => X"96FFA06E0001017D10207D002096FF8900A0007605FFA601006F697067A30100",
                    INIT_34 => X"20C4102023000065D1DD0065DD10A0000110A00001E99A6E0000037D00018500",
                    INIT_35 => X"23001001242320B201B93420B92010B21020082010002323C4050123019C3401",
                    INIT_36 => X"D60600203A726F727245005E69C50600646E616D6D6F6320646142009C000128",
                    INIT_37 => X"2C0606405010402800402414002300EC200110002C0438005E01070107462069",
                    INIT_38 => X"342C20200120100020010B00F2703460F2500101017021016001600D50F20201",
                    INIT_39 => X"20452051084A0A4A0D0001201565DD5E6922075E0021776F6C667265764F156B",
                    INIT_3A => X"200120010807012007010807600220000C012001205E000C000107000C002001",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000C00200120",
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
                   INITP_00 => X"0012420E050808FE00000D866000A408001CA6CB504F0000000011F000000048",
                   INITP_01 => X"223B913000020000019AFA000000AA8000000002A8000248013FFFFFA0000400",
                   INITP_02 => X"8C900040D5550135521918044C015620FFFFFFFFFF8002950000615000021102",
                   INITP_03 => X"260020B2004E0D198B8C96E512A9AAAB8CAC14AAD3590E6986601FEFC6413FDF",
                   INITP_04 => X"80A000800300180000401F10131830C4C180D008400214FFFFFFFFFFF8000405",
                   INITP_05 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC80FFE05800000D9F880006EC20A88",
                   INITP_06 => X"F390C8407FC3FFE45E06F600100330496802CFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_07 => X"00000000000000000000000000000000000000001B6800407FC82FFEFD801890",
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
                    INIT_00 => X"684828684828684828684828684828684810C868481088684813680800000000",
                    INIT_01 => X"88D0C8D0E888D0C8D0E8D0C828A0082800A00881F00000A1A1A1A101F0000028",
                    INIT_02 => X"000828680069000028C890F0E8881800C990F0E989A1A1A1A1012828A008D0E8",
                    INIT_03 => X"00000028000000000000286F2F0F28109D8D680090E825286808002868000868",
                    INIT_04 => X"006F1F286F00100028000000000028B0CE000E10C8A600001000B0670E280000",
                    INIT_05 => X"B0CE0E280000000000280000A76E4E00000000286F2F286F1F28906E4E6F2F28",
                    INIT_06 => X"78780828B0D8C80808280000680069000008000D0D5858000808080808080828",
                    INIT_07 => X"0000070000A707000010CAA290EA0ACA5A0B6808105A0B6808F0EA5A90E95928",
                    INIT_08 => X"0828B0EB8B007B0B7B0B280000000000000002000001000000A7070000010100",
                    INIT_09 => X"0828685810000D0D000008080808080808080808080808080808080808080808",
                    INIT_0A => X"000F000F000F68082800005700000F0000A700002800000F8B000F8B000F0B68",
                    INIT_0B => X"00000F00000F00000F0000A70F680800002800000F00000F0000A70000280000",
                    INIT_0C => X"00070000070000275B0F0000A70F0000A0A1A0A1A0A1A0A15088510868082800",
                    INIT_0D => X"5F000068582800109D8D00109D8D680090E890E8250D0D286858286858280000",
                    INIT_0E => X"286858280000000000000002000001000000A75F00006858280000005F0000A7",
                    INIT_0F => X"56885508B1E05A5828778876887688750857C856C856C8558808785828000048",
                    INIT_10 => X"0101010101010101010101010109080101010154C854C853C853880857885688",
                    INIT_11 => X"28B868081108B1E84800B828012222190118000A2800B1CAB8680008B8010101",
                    INIT_12 => X"08080808080808080828B1C80828011A6A2A016A28A5A4A4A3A328A7A7A6A6A5",
                    INIT_13 => X"0D08080808080808080808080808080808080808080808080808080808080808",
                    INIT_14 => X"010A5A28718A7121A2A2A2A2528AA1A1A1A1A1A1A1A151090A010A5A2800000D",
                    INIT_15 => X"A3A3A3538A53B4B40B0A010A0C0C0F0E2811CA8A8A88EA2800690000508A0050",
                    INIT_16 => X"0A0B0C0C07060EA3A3A3A3A3A3A3A3538A53B1EA8AB8010AB8B7B6A3A3A3A3A3",
                    INIT_17 => X"0C0C0B010A0C0C0F0E28B1CA0101010101010101010101010908010101012801",
                    INIT_18 => X"010C0C0E010A0C0C0F0E110AB1EB8B748B7401010101010101010C0401010101",
                    INIT_19 => X"0C0C0F28A4A24A010A11B1CE0000006900000001010101010101010C04010101",
                    INIT_1A => X"56CF57CF01528F0F0909010A0C0C0F0E28000050830B5A2873830B5B5A28010A",
                    INIT_1B => X"26A5A555CF0627A5A4A5A40D54CF27A5A5A555CF57CFB8010A0B0B0C0CB8B6B7",
                    INIT_1C => X"E9B757CFB8010AB8B5B6B6B725A555CF0526A4A50C55CF0626A5A4A5A40D54CF",
                    INIT_1D => X"010C0B740108018C0C0C01010A0C0C0F0E28010A0C0C1109B1E9C9B8010AB891",
                    INIT_1E => X"0E0E0E0E0E0E0E0E0E1188CE010111C8A488E828110909B1EBCB74CC01C00801",
                    INIT_1F => X"E818890092E96800690000506808006808006800690000000928259D850D0D0E",
                    INIT_20 => X"0808080808280028685828680828680828020303815859D2E8580228001100B1",
                    INIT_21 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_22 => X"006800690000006808006808001288685000F2E05908000D0D08080808080808",
                    INIT_23 => X"896800690000508008680800680800F2E1095A68006900005800000D0D006808",
                    INIT_24 => X"00000D0D00F2E1095A0012896800690000508008680800F2E1095A000D0D0012",
                    INIT_25 => X"285882E858280012CB680069000050D2E38B038AA2A289026808006800690000",
                    INIT_26 => X"4800480048A81A4A280000482868287808B2DDCD0D0D68086808286808000068",
                    INIT_27 => X"82E858027858B80B0F0F0EB87858B8127808B892E85852885208021200004800",
                    INIT_28 => X"0012B26CB26BDEDFCF4B1C4C004812480848084892E892E892E81848B21848B8",
                    INIT_29 => X"CA9E9787D8C84818B2E31B03480000481248001B4B0000482800000000006808",
                    INIT_2A => X"0000284828B2DDCD0D0D2800000000006808002800000000000000680800B2DA",
                    INIT_2B => X"080808080808080808082800680069000008000D0D0808080808080808080828",
                    INIT_2C => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2D => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2E => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_2F => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_30 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_31 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_32 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_33 => X"93E825139D8D89B3E050F3E15893E893E825090D0D0808080808080808080808",
                    INIT_34 => X"50F3E15878082800030028000021259D8D01259D8D030313099D8D139D8D93E8",
                    INIT_35 => X"58C150C88858011389F3005093E101D3E15889017180087893E88858C9F30089",
                    INIT_36 => X"0D0D08080808080808082800000D0D080808080808080808080808281371C888",
                    INIT_37 => X"8BA3A30383538008528008F3E2580AD3E0887008088909280068006900000000",
                    INIT_38 => X"03F3E878885870885848002813700050B3E38B138B7000CB508B51D3E3D3CB8A",
                    INIT_39 => X"58F3E893E893E893E850C85813000000000D0D000808080808080808080813C3",
                    INIT_3A => X"78C858680800680800680800D3C85828A00878C8580028A008680028A00878C8",
                    INIT_3B => X"000000000000000000000000000000000000000000000000000028A00878C858",
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
                   INITP_00 => X"D9C82949D87FA7FF9FF1FB65D7FF5BE7FFF33BBDBFB0603252A90C0D2492666F",
                   INITP_01 => X"08D5002EDD6DCEF67733A9B7B633000BDB65F6DFAAEDBE496CFFFFFFE6BADB9F",
                   INITP_02 => X"106FFF3F000026800020C5F29A00004E7FFFFFFFFFE6B820EA780EEFFFF9E000",
                   INITP_03 => X"0BEB7E61FFEE59299A30629B0D000000000003040820E186116DDFE788297FCF",
                   INITP_04 => X"9A1BB03D54EF42B1277D00BF4C6F8B137C5B1F66FD6D627FFFFFFFFFFFB6F13F",
                   INITP_05 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFA7FFCC3ABD56008080EAE8020A89",
                   INITP_06 => X"001121FD3FF9FFFC016909864BFE2712B12547FFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_07 => X"000000000000000000000000000000000000002496D92672550F9FFFD23E9614",
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
