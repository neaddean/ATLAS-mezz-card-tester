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
-- Generated by KCPSM6 Assembler: 06 May 2014 - 15:09:36. 
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
                    INIT_00 => X"D00190005000D008900020079000D008900020031000D004900025D3006E00C4",
                    INIT_01 => X"E02D003000205000D00290005000D01090005000D00490005000D02090005000",
                    INIT_02 => X"5000400E100050000030400E10010300E02D0030001043064306430643060300",
                    INIT_03 => X"400E1000A041D010100AA03E902AA041D010100AA03E9011A041D00AA03E9030",
                    INIT_04 => X"D1411137310F01009207204CE04CD2411237420E420E420E420E020050005000",
                    INIT_05 => X"D1010003110AD1010003110D5000D1010003D20100030042500091072053E053",
                    INIT_06 => X"5F021F01500020653B001A01D1010003206DD1004BA05000D101113E00035000",
                    INIT_07 => X"1D80500000A600B4009D00B300A35000009900B400A300B3009D00A65000DF04",
                    INIT_08 => X"00B300A35000608A9D0100A91D08208090004D0E008F00A6208500A36084CED0",
                    INIT_09 => X"9C02DF045F01500000B3DF043FFE5000DE0100A9208F00A65000009900B4009D",
                    INIT_0A => X"4E00DC029C0200B6009D00B300A65000DF045F025000DF043FFD5000209FDC01",
                    INIT_0B => X"1149114C1143500060BA9C011C05500000B900B900B900B900B95000009900B6",
                    INIT_0C => X"D1010003D20100030042100100651ABD1B00B001B03100D31100113A11561120",
                    INIT_0D => X"B42CD0051000E0E1D404B42C2109D300B3235000F023F020100050000061005A",
                    INIT_0E => X"007F4E061E280072006E20E79401450620EBD40015109404B42CD005100120E5",
                    INIT_0F => X"0089008E03E000890096007F4E071E280072006E01DA00790096007F0E500096",
                    INIT_10 => X"D608160100D7F62C1600F62316015000005A00540040005400300079009404E0",
                    INIT_11 => X"1120116F1174112011641165116C11691161116611201143113211495000610C",
                    INIT_12 => X"1B04205A00651A121B01005A006E110011211164116E116F1170117311651172",
                    INIT_13 => X"005A21313B001A03005A21313B001A01D1010003213FD1FF213BD1004BA01A71",
                    INIT_14 => X"D005B02C500000790096007FBE340096007F4E06BE300072006ED005B02C5000",
                    INIT_15 => X"0040005400300079009404E00089008E03E000890096007F4E07BE300072006E",
                    INIT_16 => X"9001AB001003102CF140B1285000005A005490065000D006B02C5000005A0054",
                    INIT_17 => X"B528B0405000EE101101ED101101EC101101EB101141AE009001AD009001AC00",
                    INIT_18 => X"9001A7009001A6001003102CAE001001AD001001AC001001AB0010416205C050",
                    INIT_19 => X"01C601BB01B201CC01C601BB01B21200110001CC01CC01CC01C6A9009001A800",
                    INIT_1A => X"619995017000D10100031120700101CC01C601BB01B201CC01C601BB01B201CC",
                    INIT_1B => X"61C2D001900600037001500001D244204410320402A0310101F014005000005A",
                    INIT_1C => X"490848084708460E50004F004E084D084C084B0E50007000D001103021C31031",
                    INIT_1D => X"115211521145500061DA90011019500001D9340DD406540201D9D40650004A00",
                    INIT_1E => X"1120114F1144115411201164116E116111201153114D11541120113A1152114F",
                    INIT_1F => X"116D11201174116F116E1120116F116411201173116811741167116E1165116C",
                    INIT_20 => X"A34012001430022F1545B42C5000005A00651ADD1B0111001168116311741161",
                    INIT_21 => X"E25042404406440644064406A440140142004306420043064200430642004306",
                    INIT_22 => X"D4005000005AD20100030042A05015010054A050022F1545B42C5000E3501501",
                    INIT_23 => X"696068601600144502681504190618261E001D035000222F9401150115011000",
                    INIT_24 => X"0268150370016E706D604708460E4708460E4708460E4708460EA7401401A640",
                    INIT_25 => X"1CFF4708460F4708460F4708460F4708460FA7401401A640623DD46114017000",
                    INIT_26 => X"028101B21200110001CC01CC01CC01C650000268150617FF18F819000E700D60",
                    INIT_27 => X"626E950101CC01C6028101B201CC01C6028101B201CC01C6028101B201CC01C6",
                    INIT_28 => X"098002C502C502C502C519001800164502681504190618261E001D0350005000",
                    INIT_29 => X"6289D6631601005AE9601601E86002C502C502C502C502C502C502C502C51800",
                    INIT_2A => X"02C502C502C502C5190018001C0602681504190618261E401D01223D1445005A",
                    INIT_2B => X"0090D201000300420080005A02C502C502C502C502C502C502C502C518000980",
                    INIT_2C => X"0268150219FF18FF1E0050004808450E950601D2140022CB62AA9C01005A0054",
                    INIT_2D => X"1E201D015000005A0054A07007501763B52C5000E67007501763B630B52C5000",
                    INIT_2E => X"6DD06EE0ADF09F01AEF09F0101D2A4F01F0A1F63120013020268150419061826",
                    INIT_2F => X"4EA04A064A064A06AAF09F01AEF09F0170000268150416001700180019007001",
                    INIT_30 => X"490EA9F09F014DA04A064A06AAF09F010D904EA04A0049064A004906A9F09F01",
                    INIT_31 => X"6EE04BA04A06AAF09F010B904CA049004A06AAF09F010C904DA04A08490E4A08",
                    INIT_32 => X"70000268150270012335D2016EE0AEF09F0170000268150770016BB06CC06DD0",
                    INIT_33 => X"02681504190618261E201D0150000268150418FF198022E6120162E6D3009301",
                    INIT_34 => X"9901035880C01008036C035D18001609E8900358100702C5190A1963180001D2",
                    INIT_35 => X"9C0102C5036C23589001480E1000D000500022E6130212006349D6FF9601E890",
                    INIT_36 => X"3B000A601A621B031C081C081C031C031C041C041C031C081C031C08235E1000",
                    INIT_37 => X"A030D00110200003D001103A0003D1010003D201000300420030130050004BA0",
                    INIT_38 => X"5000005A2373005A637FD003300313010030238ED3FFD1010003D20100030042",
                    INIT_39 => X"D00310005000D00310FF500003CF05A705580210B12BB227A39AD004B02303CF",
                    INIT_3A => X"11641172116F115711001120113A117211651166116611751142500000C45000",
                    INIT_3B => X"11691173112011641172116F115711001120113A1174116E1175116F11631120",
                    INIT_3C => X"1B031100112011641172116F115711001120112011201120113A11731165117A",
                    INIT_3D => X"10280003D0011020000323D41101D001A0100003E3DBC120B220110000651AA3",
                    INIT_3E => X"B023000300651AAC1B03005AD00110290003D1010003D201000300420020D001",
                    INIT_3F => X"1124D00110400003D00110200003E409C3401300B423D1010003D20100030042",
                   INITP_00 => X"2AAAAAAA0A5ADA8AA28AAA9F507D554A4D775DDD9211E154E2082082082C2C2A",
                   INITP_01 => X"A2A4AAA292A5D122234D2A2AAA882AAAAAD2AAAA42AA8A2C22A22AAAAB62DAAC",
                   INITP_02 => X"0A666044448A8A2A228A2A4A8AA292A2A5A5ADD8282AAAAAAAAAAAAB5A22A228",
                   INITP_03 => X"AAAAAAAAAAAAAAAAAAD288A955955B88D2E8000ADE8EAAAAAAA82A844441110D",
                   INITP_04 => X"DAAAAAAAA0AAA000155544D78D55554450800A576AA1882985515555020A82AA",
                   INITP_05 => X"1511E003511840800A842902802522DA2A2AAAA0AA020022D69AAAA82A80800A",
                   INITP_06 => X"228AAA0A50AAAAAB6A5DA0D664A0A242800A0235E3D478D54441441544510551",
                   INITP_07 => X"228B42AA2828AAA228A62D082AAAAAAAAAAAAAAAAAAAAAAA8A2A90D2AAD136AA")
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
                    INIT_00 => X"D00190005000D008900020079000D008900020031000D004900025D3006E00C4",
                    INIT_01 => X"E02D003000205000D00290005000D01090005000D00490005000D02090005000",
                    INIT_02 => X"5000400E100050000030400E10010300E02D0030001043064306430643060300",
                    INIT_03 => X"400E1000A041D010100AA03E902AA041D010100AA03E9011A041D00AA03E9030",
                    INIT_04 => X"D1411137310F01009207204CE04CD2411237420E420E420E420E020050005000",
                    INIT_05 => X"D1010003110AD1010003110D5000D1010003D20100030042500091072053E053",
                    INIT_06 => X"5F021F01500020653B001A01D1010003206DD1004BA05000D101113E00035000",
                    INIT_07 => X"1D80500000A600B4009D00B300A35000009900B400A300B3009D00A65000DF04",
                    INIT_08 => X"00B300A35000608A9D0100A91D08208090004D0E008F00A6208500A36084CED0",
                    INIT_09 => X"9C02DF045F01500000B3DF043FFE5000DE0100A9208F00A65000009900B4009D",
                    INIT_0A => X"4E00DC029C0200B6009D00B300A65000DF045F025000DF043FFD5000209FDC01",
                    INIT_0B => X"1149114C1143500060BA9C011C05500000B900B900B900B900B95000009900B6",
                    INIT_0C => X"D1010003D20100030042100100651ABD1B00B001B03100D31100113A11561120",
                    INIT_0D => X"B42CD0051000E0E1D404B42C2109D300B3235000F023F020100050000061005A",
                    INIT_0E => X"007F4E061E280072006E20E79401450620EBD40015109404B42CD005100120E5",
                    INIT_0F => X"0089008E03E000890096007F4E071E280072006E01DA00790096007F0E500096",
                    INIT_10 => X"D608160100D7F62C1600F62316015000005A00540040005400300079009404E0",
                    INIT_11 => X"1120116F1174112011641165116C11691161116611201143113211495000610C",
                    INIT_12 => X"1B04205A00651A121B01005A006E110011211164116E116F1170117311651172",
                    INIT_13 => X"005A21313B001A03005A21313B001A01D1010003213FD1FF213BD1004BA01A71",
                    INIT_14 => X"D005B02C500000790096007FBE340096007F4E06BE300072006ED005B02C5000",
                    INIT_15 => X"0040005400300079009404E00089008E03E000890096007F4E07BE300072006E",
                    INIT_16 => X"9001AB001003102CF140B1285000005A005490065000D006B02C5000005A0054",
                    INIT_17 => X"B528B0405000EE101101ED101101EC101101EB101141AE009001AD009001AC00",
                    INIT_18 => X"9001A7009001A6001003102CAE001001AD001001AC001001AB0010416205C050",
                    INIT_19 => X"01C601BB01B201CC01C601BB01B21200110001CC01CC01CC01C6A9009001A800",
                    INIT_1A => X"619995017000D10100031120700101CC01C601BB01B201CC01C601BB01B201CC",
                    INIT_1B => X"61C2D001900600037001500001D244204410320402A0310101F014005000005A",
                    INIT_1C => X"490848084708460E50004F004E084D084C084B0E50007000D001103021C31031",
                    INIT_1D => X"115211521145500061DA90011019500001D9340DD406540201D9D40650004A00",
                    INIT_1E => X"1120114F1144115411201164116E116111201153114D11541120113A1152114F",
                    INIT_1F => X"116D11201174116F116E1120116F116411201173116811741167116E1165116C",
                    INIT_20 => X"A34012001430022F1545B42C5000005A00651ADD1B0111001168116311741161",
                    INIT_21 => X"E25042404406440644064406A440140142004306420043064200430642004306",
                    INIT_22 => X"D4005000005AD20100030042A05015010054A050022F1545B42C5000E3501501",
                    INIT_23 => X"696068601600144502681504190618261E001D035000222F9401150115011000",
                    INIT_24 => X"0268150370016E706D604708460E4708460E4708460E4708460EA7401401A640",
                    INIT_25 => X"1CFF4708460F4708460F4708460F4708460FA7401401A640623DD46114017000",
                    INIT_26 => X"028101B21200110001CC01CC01CC01C650000268150617FF18F819000E700D60",
                    INIT_27 => X"626E950101CC01C6028101B201CC01C6028101B201CC01C6028101B201CC01C6",
                    INIT_28 => X"098002C502C502C502C519001800164502681504190618261E001D0350005000",
                    INIT_29 => X"6289D6631601005AE9601601E86002C502C502C502C502C502C502C502C51800",
                    INIT_2A => X"02C502C502C502C5190018001C0602681504190618261E401D01223D1445005A",
                    INIT_2B => X"0090D201000300420080005A02C502C502C502C502C502C502C502C518000980",
                    INIT_2C => X"0268150219FF18FF1E0050004808450E950601D2140022CB62AA9C01005A0054",
                    INIT_2D => X"1E201D015000005A0054A07007501763B52C5000E67007501763B630B52C5000",
                    INIT_2E => X"6DD06EE0ADF09F01AEF09F0101D2A4F01F0A1F63120013020268150419061826",
                    INIT_2F => X"4EA04A064A064A06AAF09F01AEF09F0170000268150416001700180019007001",
                    INIT_30 => X"490EA9F09F014DA04A064A06AAF09F010D904EA04A0049064A004906A9F09F01",
                    INIT_31 => X"6EE04BA04A06AAF09F010B904CA049004A06AAF09F010C904DA04A08490E4A08",
                    INIT_32 => X"70000268150270012335D2016EE0AEF09F0170000268150770016BB06CC06DD0",
                    INIT_33 => X"02681504190618261E201D0150000268150418FF198022E6120162E6D3009301",
                    INIT_34 => X"9901035880C01008036C035D18001609E8900358100702C5190A1963180001D2",
                    INIT_35 => X"9C0102C5036C23589001480E1000D000500022E6130212006349D6FF9601E890",
                    INIT_36 => X"3B000A601A621B031C081C081C031C031C041C041C031C081C031C08235E1000",
                    INIT_37 => X"A030D00110200003D001103A0003D1010003D201000300420030130050004BA0",
                    INIT_38 => X"5000005A2373005A637FD003300313010030238ED3FFD1010003D20100030042",
                    INIT_39 => X"D00310005000D00310FF500003CF05A705580210B12BB227A39AD004B02303CF",
                    INIT_3A => X"11641172116F115711001120113A117211651166116611751142500000C45000",
                    INIT_3B => X"11691173112011641172116F115711001120113A1174116E1175116F11631120",
                    INIT_3C => X"1B031100112011641172116F115711001120112011201120113A11731165117A",
                    INIT_3D => X"10280003D0011020000323D41101D001A0100003E3DBC120B220110000651AA3",
                    INIT_3E => X"B023000300651AAC1B03005AD00110290003D1010003D201000300420020D001",
                    INIT_3F => X"1124D00110400003D00110200003E409C3401300B423D1010003D20100030042",
                   INITP_00 => X"2AAAAAAA0A5ADA8AA28AAA9F507D554A4D775DDD9211E154E2082082082C2C2A",
                   INITP_01 => X"A2A4AAA292A5D122234D2A2AAA882AAAAAD2AAAA42AA8A2C22A22AAAAB62DAAC",
                   INITP_02 => X"0A666044448A8A2A228A2A4A8AA292A2A5A5ADD8282AAAAAAAAAAAAB5A22A228",
                   INITP_03 => X"AAAAAAAAAAAAAAAAAAD288A955955B88D2E8000ADE8EAAAAAAA82A844441110D",
                   INITP_04 => X"DAAAAAAAA0AAA000155544D78D55554450800A576AA1882985515555020A82AA",
                   INITP_05 => X"1511E003511840800A842902802522DA2A2AAAA0AA020022D69AAAA82A80800A",
                   INITP_06 => X"228AAA0A50AAAAAB6A5DA0D664A0A242800A0235E3D478D54441441544510551",
                   INITP_07 => X"228B42AA2828AAA228A62D082AAAAAAAAAAAAAAAAAAAAAAA8A2A90D2AAD136AA")
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
                    INIT_00 => X"D00190005000D008900020079000D008900020031000D004900025D3006E00C4",
                    INIT_01 => X"E02D003000205000D00290005000D01090005000D00490005000D02090005000",
                    INIT_02 => X"5000400E100050000030400E10010300E02D0030001043064306430643060300",
                    INIT_03 => X"400E1000A041D010100AA03E902AA041D010100AA03E9011A041D00AA03E9030",
                    INIT_04 => X"D1411137310F01009207204CE04CD2411237420E420E420E420E020050005000",
                    INIT_05 => X"D1010003110AD1010003110D5000D1010003D20100030042500091072053E053",
                    INIT_06 => X"5F021F01500020653B001A01D1010003206DD1004BA05000D101113E00035000",
                    INIT_07 => X"1D80500000A600B4009D00B300A35000009900B400A300B3009D00A65000DF04",
                    INIT_08 => X"00B300A35000608A9D0100A91D08208090004D0E008F00A6208500A36084CED0",
                    INIT_09 => X"9C02DF045F01500000B3DF043FFE5000DE0100A9208F00A65000009900B4009D",
                    INIT_0A => X"4E00DC029C0200B6009D00B300A65000DF045F025000DF043FFD5000209FDC01",
                    INIT_0B => X"1149114C1143500060BA9C011C05500000B900B900B900B900B95000009900B6",
                    INIT_0C => X"D1010003D20100030042100100651ABD1B00B001B03100D31100113A11561120",
                    INIT_0D => X"B42CD0051000E0E1D404B42C2109D300B3235000F023F020100050000061005A",
                    INIT_0E => X"007F4E061E280072006E20E79401450620EBD40015109404B42CD005100120E5",
                    INIT_0F => X"0089008E03E000890096007F4E071E280072006E01DA00790096007F0E500096",
                    INIT_10 => X"D608160100D7F62C1600F62316015000005A00540040005400300079009404E0",
                    INIT_11 => X"1120116F1174112011641165116C11691161116611201143113211495000610C",
                    INIT_12 => X"1B04205A00651A121B01005A006E110011211164116E116F1170117311651172",
                    INIT_13 => X"005A21313B001A03005A21313B001A01D1010003213FD1FF213BD1004BA01A71",
                    INIT_14 => X"D005B02C500000790096007FBE340096007F4E06BE300072006ED005B02C5000",
                    INIT_15 => X"0040005400300079009404E00089008E03E000890096007F4E07BE300072006E",
                    INIT_16 => X"9001AB001003102CF140B1285000005A005490065000D006B02C5000005A0054",
                    INIT_17 => X"B528B0405000EE101101ED101101EC101101EB101141AE009001AD009001AC00",
                    INIT_18 => X"9001A7009001A6001003102CAE001001AD001001AC001001AB0010416205C050",
                    INIT_19 => X"01C601BB01B201CC01C601BB01B21200110001CC01CC01CC01C6A9009001A800",
                    INIT_1A => X"619995017000D10100031120700101CC01C601BB01B201CC01C601BB01B201CC",
                    INIT_1B => X"61C2D001900600037001500001D244204410320402A0310101F014005000005A",
                    INIT_1C => X"490848084708460E50004F004E084D084C084B0E50007000D001103021C31031",
                    INIT_1D => X"115211521145500061DA90011019500001D9340DD406540201D9D40650004A00",
                    INIT_1E => X"1120114F1144115411201164116E116111201153114D11541120113A1152114F",
                    INIT_1F => X"116D11201174116F116E1120116F116411201173116811741167116E1165116C",
                    INIT_20 => X"A34012001430022F1545B42C5000005A00651ADD1B0111001168116311741161",
                    INIT_21 => X"E25042404406440644064406A440140142004306420043064200430642004306",
                    INIT_22 => X"D4005000005AD20100030042A05015010054A050022F1545B42C5000E3501501",
                    INIT_23 => X"696068601600144502681504190618261E001D035000222F9401150115011000",
                    INIT_24 => X"0268150370016E706D604708460E4708460E4708460E4708460EA7401401A640",
                    INIT_25 => X"1CFF4708460F4708460F4708460F4708460FA7401401A640623DD46114017000",
                    INIT_26 => X"028101B21200110001CC01CC01CC01C650000268150617FF18F819000E700D60",
                    INIT_27 => X"626E950101CC01C6028101B201CC01C6028101B201CC01C6028101B201CC01C6",
                    INIT_28 => X"098002C502C502C502C519001800164502681504190618261E001D0350005000",
                    INIT_29 => X"6289D6631601005AE9601601E86002C502C502C502C502C502C502C502C51800",
                    INIT_2A => X"02C502C502C502C5190018001C0602681504190618261E401D01223D1445005A",
                    INIT_2B => X"0090D201000300420080005A02C502C502C502C502C502C502C502C518000980",
                    INIT_2C => X"0268150219FF18FF1E0050004808450E950601D2140022CB62AA9C01005A0054",
                    INIT_2D => X"1E201D015000005A0054A07007501763B52C5000E67007501763B630B52C5000",
                    INIT_2E => X"6DD06EE0ADF09F01AEF09F0101D2A4F01F0A1F63120013020268150419061826",
                    INIT_2F => X"4EA04A064A064A06AAF09F01AEF09F0170000268150416001700180019007001",
                    INIT_30 => X"490EA9F09F014DA04A064A06AAF09F010D904EA04A0049064A004906A9F09F01",
                    INIT_31 => X"6EE04BA04A06AAF09F010B904CA049004A06AAF09F010C904DA04A08490E4A08",
                    INIT_32 => X"70000268150270012335D2016EE0AEF09F0170000268150770016BB06CC06DD0",
                    INIT_33 => X"02681504190618261E201D0150000268150418FF198022E6120162E6D3009301",
                    INIT_34 => X"9901035880C01008036C035D18001609E8900358100702C5190A1963180001D2",
                    INIT_35 => X"9C0102C5036C23589001480E1000D000500022E6130212006349D6FF9601E890",
                    INIT_36 => X"3B000A601A621B031C081C081C031C031C041C041C031C081C031C08235E1000",
                    INIT_37 => X"A030D00110200003D001103A0003D1010003D201000300420030130050004BA0",
                    INIT_38 => X"5000005A2373005A637FD003300313010030238ED3FFD1010003D20100030042",
                    INIT_39 => X"D00310005000D00310FF500003CF05A705580210B12BB227A39AD004B02303CF",
                    INIT_3A => X"11641172116F115711001120113A117211651166116611751142500000C45000",
                    INIT_3B => X"11691173112011641172116F115711001120113A1174116E1175116F11631120",
                    INIT_3C => X"1B031100112011641172116F115711001120112011201120113A11731165117A",
                    INIT_3D => X"10280003D0011020000323D41101D001A0100003E3DBC120B220110000651AA3",
                    INIT_3E => X"B023000300651AAC1B03005AD00110290003D1010003D201000300420020D001",
                    INIT_3F => X"1124D00110400003D00110200003E409C3401300B423D1010003D20100030042",
                   INITP_00 => X"2AAAAAAA0A5ADA8AA28AAA9F507D554A4D775DDD9211E154E2082082082C2C2A",
                   INITP_01 => X"A2A4AAA292A5D122234D2A2AAA882AAAAAD2AAAA42AA8A2C22A22AAAAB62DAAC",
                   INITP_02 => X"0A666044448A8A2A228A2A4A8AA292A2A5A5ADD8282AAAAAAAAAAAAB5A22A228",
                   INITP_03 => X"AAAAAAAAAAAAAAAAAAD288A955955B88D2E8000ADE8EAAAAAAA82A844441110D",
                   INITP_04 => X"DAAAAAAAA0AAA000155544D78D55554450800A576AA1882985515555020A82AA",
                   INITP_05 => X"1511E003511840800A842902802522DA2A2AAAA0AA020022D69AAAA82A80800A",
                   INITP_06 => X"228AAA0A50AAAAAB6A5DA0D664A0A242800A0235E3D478D54441441544510551",
                   INITP_07 => X"228B42AA2828AAA228A62D082AAAAAAAAAAAAAAAAAAAAAAA8A2A90D2AAD136AA")
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
                    INIT_00 => X"2D30200002000010000004000020000001000008000700080003000400D36EC4",
                    INIT_01 => X"0E0041100A3E2A41100A3E11410A3E30000E0000300E01002D30100606060600",
                    INIT_02 => X"01030A01030D0001030103420007535341370F00074C4C41370E0E0E0E000000",
                    INIT_03 => X"8000A6B49DB3A30099B4A3B39DA6000402010065000101036D00A000013E0300",
                    INIT_04 => X"02040100B304FE0001A98FA60099B49DB3A3008A01A90880000E8FA685A384D0",
                    INIT_05 => X"494C4300BA010500B9B9B9B9B90099B6000202B69DB3A60004020004FD009F01",
                    INIT_06 => X"2C0500E1042C0900230023200000615A01030103420165BD000131D3003A5620",
                    INIT_07 => X"898EE089967F0728726EDA79967F50967F0628726EE70106EB0010042C0501E5",
                    INIT_08 => X"206F742064656C69616620433249000C0801D72C002301005A544054307994E0",
                    INIT_09 => X"5A3100035A31000101033FFF3B00A071045A6512015A6E0021646E6F70736572",
                    INIT_0A => X"4054307994E0898EE089967F0730726E052C0079967F34967F0630726E052C00",
                    INIT_0B => X"284000100110011001104100010001000100032C4028005A540600062C005A54",
                    INIT_0C => X"C6BBB2CCC6BBB20000CCCCCCC600010001000100032C00010001000100410550",
                    INIT_0D => X"C20106030100D2201004A001F000005A99010001032001CCC6BBB2CCC6BBB2CC",
                    INIT_0E => X"52524500DA011900D90D0602D90600000808080E00000808080E00000130C331",
                    INIT_0F => X"6D20746F6E206F6420736874676E656C204F445420646E6120534D54203A524F",
                    INIT_10 => X"504006060606400100060006000600064000302F452C005A65DD010068637461",
                    INIT_11 => X"60600045680406260003002F0101010000005A010342500154502F452C005001",
                    INIT_12 => X"FF080F080F080F080F4001403D6101006803017060080E080E080E080E400140",
                    INIT_13 => X"6E01CCC681B2CCC681B2CCC681B2CCC681B20000CCCCCCC6006806FFF8007060",
                    INIT_14 => X"8963015A600160C5C5C5C5C5C5C5C50080C5C5C5C50000456804062600030000",
                    INIT_15 => X"90010342805AC5C5C5C5C5C5C5C50080C5C5C5C50000066804062640013D455A",
                    INIT_16 => X"2001005A547050632C00705063302C006802FFFF0000080E06D200CBAA015A54",
                    INIT_17 => X"A0060606F001F0010068040000000001D0E0F001F001D2F00A63000268040626",
                    INIT_18 => X"E0A006F00190A00006F00190A0080E080EF001A00606F00190A000060006F001",
                    INIT_19 => X"680406262001006804FF80E601E60001006802013501E0F00100680701B0C0D0",
                    INIT_1A => X"01C56C58010E000000E6020049FF01900158C0086C5D0009905807C50A6300D2",
                    INIT_1B => X"30012003013A030103010342300000A000606203080803030404030803085E00",
                    INIT_1C => X"03000003FF00CFA758102B279A0423CF005A735A7F030301308EFF0103010342",
                    INIT_1D => X"69732064726F5700203A746E756F632064726F5700203A72656666754200C400",
                    INIT_1E => X"2803012003D401011003DB20200065A303002064726F5700202020203A73657A",
                    INIT_1F => X"24014003012003094000230103010342230365AC035A01290301030103422001",
                    INIT_20 => X"235A0F0101030103421030280120031E40002365B9035AF70101030103421030",
                    INIT_21 => X"01010301034260215003502C0606013001200301030103423065C9035A414000",
                    INIT_22 => X"737265564F5A5407540754075407000105005A5405000800070007102C005A37",
                    INIT_23 => X"646D656D90030067726169746C756D005A010301034201655C0400203A6E6F69",
                    INIT_24 => X"6568CF03007379736604006E6F6973726576A103007465736572720300706D75",
                    INIT_25 => X"D70000619E030066666F5F7265776F709B03006E6F5F7265776F702F0100706C",
                    INIT_26 => X"746A7E01006D6A6A0100646A4E010072694101007769660100726A630100776A",
                    INIT_27 => X"04006374A3020073746A82020067746A36020075746A23020072746A0A020077",
                    INIT_28 => X"0075616AD7020072616AD1020077616A4F040072744904007A744B0400667443",
                    INIT_29 => X"430054FFA02C0001013B10203B002054FF4700A0007104FF3A030067616ADE02",
                    INIT_2A => X"300120821020230000618FD30061D310A0000110A00001A7582C0000033B0001",
                    INIT_2B => X"012823001001242320700177302077201070102008201000232382050123015A",
                    INIT_2C => X"2065940500203A726F727245005A65830500646E616D6D6F6320646142005A00",
                    INIT_2D => X"02012C06064050104028004024D2002300AA200110002C0438005A0103010342",
                    INIT_2E => X"D329F2EA20200120100020010700B0703060B05001BF01701D01600160CB50B0",
                    INIT_2F => X"20012003200F08080A080D000120D361D35A65E0055A0021776F6C667265764F",
                    INIT_30 => X"01202001200108030120030108031E0220000C012001205A000C000103000C00",
                    INIT_31 => X"00000000000000000000000000000000000000000000000000000000000C0020",
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
                   INITP_00 => X"202001200380808FE00000D866000A408001CA6CB504F0000000011F00000004",
                   INITP_01 => X"FFFFFFFFE888A5428218D5FFFEFC40888EE44C000080000066BE89FFFFFD0000",
                   INITP_02 => X"052AB6D6439A61C0000108C80800846477775F3555404D54864601130055883F",
                   INITP_03 => X"80D008400634FFFFFFFFFFF803A92970010590023028CC4D64A328954D2AF197",
                   INITP_04 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE407FF0018000401F10131830C5C1",
                   INITP_05 => X"0AB20BFFFF6226253CE472101FF0FFFB17D3FDA11420CDD6FE49F3FFFFFFFFFF",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000000000006D80010",
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
                    INIT_00 => X"F0000028684828684828684828684828684828684810C8684810886848120000",
                    INIT_01 => X"A008D0E888D0C8D0E888D0C8D0E8D0C828A0082800A00881F00000A1A1A1A101",
                    INIT_02 => X"68000868000828680069000028C890F0E8881800C990F0E989A1A1A1A1012828",
                    INIT_03 => X"0E28000000000028000000000000286F2F0F28109D8D680090E8252868080028",
                    INIT_04 => X"4E6F2F28006F1F286F00100028000000000028B0CE000E10C8A600001000B067",
                    INIT_05 => X"08080828B0CE0E280000000000280000A76E4E00000000286F2F286F1F28906E",
                    INIT_06 => X"5A6808F0EA5A90E95928787808280000680069000008000D0D58580008080808",
                    INIT_07 => X"000001000000A70F000000000000070000A70F000010CAA290EA0ACA5A680810",
                    INIT_08 => X"080808080808080808080808080828B0EB8B007B0B7B0B280000000000000002",
                    INIT_09 => X"00109D8D00109D8D680090E890E8250D0D10000D0D0000080808080808080808",
                    INIT_0A => X"000000000002000001000000A75F00006858280000005F0000A75F0000685828",
                    INIT_0B => X"5A5828778876887688750857C856C856C8558808785828000048286858280000",
                    INIT_0C => X"0000000000000009080000000054C854C853C85388085788568856885508B1E0",
                    INIT_0D => X"B0E84800B828002222190118000A2800B0CAB8680008B8000000000000000000",
                    INIT_0E => X"08080828B0C80828001A6A2A006A28A5A4A4A3A328A7A7A6A6A528B868081008",
                    INIT_0F => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_10 => X"7121A2A2A2A2528AA1A1A1A1A1A1A1A151090A010A5A2800000D0D0808080808",
                    INIT_11 => X"B4B40B0A010A0C0C0F0E2811CA8A8A88EA2800690000508A0050010A5A28718A",
                    INIT_12 => X"0EA3A3A3A3A3A3A3A3538A53B1EA8AB8010AB8B7B6A3A3A3A3A3A3A3A3538A53",
                    INIT_13 => X"B1CA0000010000000100000001000000010009080000000028010A0B0C0C0706",
                    INIT_14 => X"B1EB8B00748B7401010101010101010C04010101010C0C0B010A0C0C0F0E2828",
                    INIT_15 => X"00690000000001010101010101010C04010101010C0C0E010A0C0C0F0E110A00",
                    INIT_16 => X"0F0E28000050830B5A2873830B5B5A28010A0C0C0F28A4A24A000A11B1CE0000",
                    INIT_17 => X"27A5A5A555CF57CFB8010A0B0B0C0CB8B6B756CF57CF00528F0F0909010A0C0C",
                    INIT_18 => X"B725A555CF0526A4A555CF0626A5A4A5A454CF26A5A555CF0627A5A4A5A454CF",
                    INIT_19 => X"010A0C0C0F0E28010A0C0C1109B1E9C9B8010AB891E9B757CFB8010AB8B5B6B6",
                    INIT_1A => X"CE010111C8A488E828110909B1EBCB74CC01C00801010C0B740108018C0C0C00",
                    INIT_1B => X"506808006808006800690000000928259D850D0D0E0E0E0E0E0E0E0E0E0E1188",
                    INIT_1C => X"680828680828010202815859D1E8580128001100B1E818890091E96800690000",
                    INIT_1D => X"0808080808080808080808080808080808080808080808080808080808280028",
                    INIT_1E => X"08006808001188685000F1E05908000D0D080808080808080808080808080808",
                    INIT_1F => X"08680800680800F2E1095A68006900005800000D0D0068080068006900000068",
                    INIT_20 => X"5A0012896800690000508008680800F2E1095A000D0D00118968006900005080",
                    INIT_21 => X"CB680069000050D2E38B038AA2A28902680800680069000000000D0D00F2E109",
                    INIT_22 => X"080808081200004800480048004888EA4A280000482868286808682858280012",
                    INIT_23 => X"0808080808080808080808080808082800680069000008000D0D080808080808",
                    INIT_24 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_25 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_26 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_27 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_28 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_29 => X"92E892E825129D8D89B2E050F2E15892E892E825090D0D080808080808080808",
                    INIT_2A => X"008950F2E15878082800020028000021259D8D01259D8D020212099D8D129D8D",
                    INIT_2B => X"C88858C150C88858011289F2005092E101D2E15889017180087892E88858C9F2",
                    INIT_2C => X"00000D0D08080808080808082800000D0D080808080808080808080808281271",
                    INIT_2D => X"CB8A8BA3A30383538008528008F2E2580AD2E088700808890928006800690000",
                    INIT_2E => X"12C202F2E878885870885848002812700050B2E38B128B7000CB508B51D2E3D2",
                    INIT_2F => X"78C858F3E893E893E893E850C85812000000000D0D0008080808080808080808",
                    INIT_30 => X"C85878C858680800680800680800D3C85828A00878C8580028A008680028A008",
                    INIT_31 => X"0000000000000000000000000000000000000000000000000000000028A00878",
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
                   INITP_00 => X"DCFD9C855277FA7FF9FF1FB65D7FF5BE7FFF33BBDBFB0603252A90C0D2492667",
                   INITP_01 => X"FFFFFFFFF9AE083A9E03BBFFFE78000235400BB75B73BD9DCCEA67FFFFFF35D6",
                   INITP_02 => X"00C102083861845B77FCF1059BFE7883BFFFCFC00009A00008317CA68000139F",
                   INITP_03 => X"5B1F66FD6D627FFFFFFFFFFFB789F85F5BF30FFF72C94CD18314D86800000000",
                   INITP_04 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD3FFEAA77A77D00BF4C6F8B137C",
                   INITP_05 => X"9543E7FFF48FA5850004487F4FFE7FFF005A426192FF89C4AC4951FFFFFFFFFF",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000000000925B6499C",
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
                    INIT_00 => X"D00190005000D008900020079000D008900020031000D004900025D3006E00C4",
                    INIT_01 => X"E02D003000205000D00290005000D01090005000D00490005000D02090005000",
                    INIT_02 => X"5000400E100050000030400E10010300E02D0030001043064306430643060300",
                    INIT_03 => X"400E1000A041D010100AA03E902AA041D010100AA03E9011A041D00AA03E9030",
                    INIT_04 => X"D1411137310F01009207204CE04CD2411237420E420E420E420E020050005000",
                    INIT_05 => X"D1010003110AD1010003110D5000D1010003D20100030042500091072053E053",
                    INIT_06 => X"5F021F01500020653B001A01D1010003206DD1004BA05000D101113E00035000",
                    INIT_07 => X"1D80500000A600B4009D00B300A35000009900B400A300B3009D00A65000DF04",
                    INIT_08 => X"00B300A35000608A9D0100A91D08208090004D0E008F00A6208500A36084CED0",
                    INIT_09 => X"9C02DF045F01500000B3DF043FFE5000DE0100A9208F00A65000009900B4009D",
                    INIT_0A => X"4E00DC029C0200B6009D00B300A65000DF045F025000DF043FFD5000209FDC01",
                    INIT_0B => X"1149114C1143500060BA9C011C05500000B900B900B900B900B95000009900B6",
                    INIT_0C => X"D1010003D20100030042100100651ABD1B00B001B03100D31100113A11561120",
                    INIT_0D => X"B42CD0051000E0E1D404B42C2109D300B3235000F023F020100050000061005A",
                    INIT_0E => X"007F4E061E280072006E20E79401450620EBD40015109404B42CD005100120E5",
                    INIT_0F => X"0089008E03E000890096007F4E071E280072006E01DA00790096007F0E500096",
                    INIT_10 => X"D608160100D7F62C1600F62316015000005A00540040005400300079009404E0",
                    INIT_11 => X"1120116F1174112011641165116C11691161116611201143113211495000610C",
                    INIT_12 => X"1B04205A00651A121B01005A006E110011211164116E116F1170117311651172",
                    INIT_13 => X"005A21313B001A03005A21313B001A01D1010003213FD1FF213BD1004BA01A71",
                    INIT_14 => X"D005B02C500000790096007FBE340096007F4E06BE300072006ED005B02C5000",
                    INIT_15 => X"0040005400300079009404E00089008E03E000890096007F4E07BE300072006E",
                    INIT_16 => X"9001AB001003102CF140B1285000005A005490065000D006B02C5000005A0054",
                    INIT_17 => X"B528B0405000EE101101ED101101EC101101EB101141AE009001AD009001AC00",
                    INIT_18 => X"9001A7009001A6001003102CAE001001AD001001AC001001AB0010416205C050",
                    INIT_19 => X"01C601BB01B201CC01C601BB01B21200110001CC01CC01CC01C6A9009001A800",
                    INIT_1A => X"619995017000D10100031120700101CC01C601BB01B201CC01C601BB01B201CC",
                    INIT_1B => X"61C2D001900600037001500001D244204410320402A0310101F014005000005A",
                    INIT_1C => X"490848084708460E50004F004E084D084C084B0E50007000D001103021C31031",
                    INIT_1D => X"115211521145500061DA90011019500001D9340DD406540201D9D40650004A00",
                    INIT_1E => X"1120114F1144115411201164116E116111201153114D11541120113A1152114F",
                    INIT_1F => X"116D11201174116F116E1120116F116411201173116811741167116E1165116C",
                    INIT_20 => X"A34012001430022F1545B42C5000005A00651ADD1B0111001168116311741161",
                    INIT_21 => X"E25042404406440644064406A440140142004306420043064200430642004306",
                    INIT_22 => X"D4005000005AD20100030042A05015010054A050022F1545B42C5000E3501501",
                    INIT_23 => X"696068601600144502681504190618261E001D035000222F9401150115011000",
                    INIT_24 => X"0268150370016E706D604708460E4708460E4708460E4708460EA7401401A640",
                    INIT_25 => X"1CFF4708460F4708460F4708460F4708460FA7401401A640623DD46114017000",
                    INIT_26 => X"028101B21200110001CC01CC01CC01C650000268150617FF18F819000E700D60",
                    INIT_27 => X"626E950101CC01C6028101B201CC01C6028101B201CC01C6028101B201CC01C6",
                    INIT_28 => X"098002C502C502C502C519001800164502681504190618261E001D0350005000",
                    INIT_29 => X"6289D6631601005AE9601601E86002C502C502C502C502C502C502C502C51800",
                    INIT_2A => X"02C502C502C502C5190018001C0602681504190618261E401D01223D1445005A",
                    INIT_2B => X"0090D201000300420080005A02C502C502C502C502C502C502C502C518000980",
                    INIT_2C => X"0268150219FF18FF1E0050004808450E950601D2140022CB62AA9C01005A0054",
                    INIT_2D => X"1E201D015000005A0054A07007501763B52C5000E67007501763B630B52C5000",
                    INIT_2E => X"6DD06EE0ADF09F01AEF09F0101D2A4F01F0A1F63120013020268150419061826",
                    INIT_2F => X"4EA04A064A064A06AAF09F01AEF09F0170000268150416001700180019007001",
                    INIT_30 => X"490EA9F09F014DA04A064A06AAF09F010D904EA04A0049064A004906A9F09F01",
                    INIT_31 => X"6EE04BA04A06AAF09F010B904CA049004A06AAF09F010C904DA04A08490E4A08",
                    INIT_32 => X"70000268150270012335D2016EE0AEF09F0170000268150770016BB06CC06DD0",
                    INIT_33 => X"02681504190618261E201D0150000268150418FF198022E6120162E6D3009301",
                    INIT_34 => X"9901035880C01008036C035D18001609E8900358100702C5190A1963180001D2",
                    INIT_35 => X"9C0102C5036C23589001480E1000D000500022E6130212006349D6FF9601E890",
                    INIT_36 => X"3B000A601A621B031C081C081C031C031C041C041C031C081C031C08235E1000",
                    INIT_37 => X"A030D00110200003D001103A0003D1010003D201000300420030130050004BA0",
                    INIT_38 => X"5000005A2373005A637FD003300313010030238ED3FFD1010003D20100030042",
                    INIT_39 => X"D00310005000D00310FF500003CF05A705580210B12BB227A39AD004B02303CF",
                    INIT_3A => X"11641172116F115711001120113A117211651166116611751142500000C45000",
                    INIT_3B => X"11691173112011641172116F115711001120113A1174116E1175116F11631120",
                    INIT_3C => X"1B031100112011641172116F115711001120112011201120113A11731165117A",
                    INIT_3D => X"10280003D0011020000323D41101D001A0100003E3DBC120B220110000651AA3",
                    INIT_3E => X"B023000300651AAC1B03005AD00110290003D1010003D201000300420020D001",
                    INIT_3F => X"1124D00110400003D00110200003E409C3401300B423D1010003D20100030042",
                    INIT_40 => X"C3401300B42300651AB91B03005A23F71301D1010003D20100030042A0100130",
                    INIT_41 => X"B423005A240F1301D1010003D20100030042A01001301128D00110200003E41E",
                    INIT_42 => X"D00110200003D1010003D20100030042003000651AC91B03005AE441C3401300",
                    INIT_43 => X"9601D1010003D20100030042A060A421C65016030650152C4506450613010530",
                    INIT_44 => X"95055000005A005490055000D0085000D0071000D0075010B02C5000005A2437",
                    INIT_45 => X"1173117211651156244F005A005490070054900700549007005490071000D501",
                    INIT_46 => X"005AD1010003D20100030042100100651A5C1B0411001120113A116E116F1169",
                    INIT_47 => X"1164116D1165116D11901103110011671172116111691174116C1175116D5000",
                    INIT_48 => X"1165117611A111031100117411651173116511721172110311001170116D1175",
                    INIT_49 => X"1165116811CF11031100117311791173116611041100116E116F116911731172",
                    INIT_4A => X"119B11031100116E116F115F117211651177116F1170112F110111001170116C",
                    INIT_4B => X"11D7110011001161119E1103110011661166116F115F117211651177116F1170",
                    INIT_4C => X"1169114111011100117711691166110111001172116A1163110111001177116A",
                    INIT_4D => X"1174116A117E11011100116D116A116A110111001164116A114E110111001172",
                    INIT_4E => X"11361102110011751174116A11231102110011721174116A110A110211001177",
                    INIT_4F => X"110411001163117411A31102110011731174116A11821102110011671174116A",
                    INIT_50 => X"114F1104110011721174114911041100117A1174114B11041100116611741143",
                    INIT_51 => X"110011751161116A11D71102110011721161116A11D11102110011771161116A",
                    INIT_52 => X"D1FF2547D1004BA012001A711B0411FF113A1103110011671161116A11DE1102",
                    INIT_53 => X"2543D1002554D1FF4BA0252C3B001A011201653BC010A020E53BC200B0202554",
                    INIT_54 => X"4BA03B001A0102104BA03B001A0105A70558252C12003B001A03253B3B001A01",
                    INIT_55 => X"00301201A020E582C210B120F023100050000061058F00D35000006100D34210",
                    INIT_56 => X"0310A570C310B12013080320E21001001123F0232582D0051001B0239201E55A",
                    INIT_57 => X"90011028B0238300A01091011124B123032025701201E5770030A0202577C320",
                    INIT_58 => X"1B0511001164116E1161116D116D116F116311201164116111425000255AE300",
                    INIT_59 => X"002000651A941B0511001120113A1172116F1172117211455000005A00651A83",
                    INIT_5A => X"1400A5AAC1201101E0101000112C120412385000005AD1010003D20100030042",
                    INIT_5B => X"96021401172C4706470607400650A61001401128A50000401024E5D2C400B023",
                    INIT_5C => X"0030A06065B0C650160125BF1701E070001D9601A1601601A260A5CBC650A5B0",
                    INIT_5D => X"25D3852905F2E5EAD120F1201101B120E0101100B12090010007500025B0E070",
                    INIT_5E => X"00D3005A00651AE01B05005A110011211177116F116C1166117211651176114F",
                    INIT_5F => X"F0209001B020E603D120260FD1082608D10A2608D10DA1009001B02025D30061",
                    INIT_60 => X"B0205000400C1001F0209001B020005A5000400C1000D10100035000400C1000",
                    INIT_61 => X"9001B020F0209001B020D10111080003D10111200003D10111080003A61E9002",
                    INIT_62 => X"0000000000000000000000000000000000000000000000005000400C1000F020",
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
                   INITP_00 => X"2AAAAAAA0A5ADA8AA28AAA9F507D554A4D775DDD9211E154E2082082082C2C2A",
                   INITP_01 => X"A2A4AAA292A5D122234D2A2AAA882AAAAAD2AAAA42AA8A2C22A22AAAAB62DAAC",
                   INITP_02 => X"0A666044448A8A2A228A2A4A8AA292A2A5A5ADD8282AAAAAAAAAAAAB5A22A228",
                   INITP_03 => X"AAAAAAAAAAAAAAAAAAD288A955955B88D2E8000ADE8EAAAAAAA82A844441110D",
                   INITP_04 => X"DAAAAAAAA0AAA000155544D78D55554450800A576AA1882985515555020A82AA",
                   INITP_05 => X"1511E003511840800A842902802522DA2A2AAAA0AA020022D69AAAA82A80800A",
                   INITP_06 => X"228AAA0A50AAAAAB6A5DA0D664A0A242800A0235E3D478D54441441544510551",
                   INITP_07 => X"228B42AA2828AAA228A62D082AAAAAAAAAAAAAAAAAAAAAAA8A2A90D2AAD136AA",
                   INITP_08 => X"AAAAAAAAAAA20AAAAAA8888D2A2A882A6AA351548AAA20B429AA848B420A6AA1",
                   INITP_09 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_0A => X"5114278D34492D479348AAAA9496A165DDA574D37602AAAAAAAAAAAAAAAAAAAA",
                   INITP_0B => X"9377744AA82AAAAABB6490AA8D6691375544413435812AAA20AAAAA82AAAAAAA",
                   INITP_0C => X"00000000000000000000000000000000000000000000009249228A2D249292A4",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
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
                    INIT_00 => X"D00190005000D008900020079000D008900020031000D004900025D3006E00C4",
                    INIT_01 => X"E02D003000205000D00290005000D01090005000D00490005000D02090005000",
                    INIT_02 => X"5000400E100050000030400E10010300E02D0030001043064306430643060300",
                    INIT_03 => X"400E1000A041D010100AA03E902AA041D010100AA03E9011A041D00AA03E9030",
                    INIT_04 => X"D1411137310F01009207204CE04CD2411237420E420E420E420E020050005000",
                    INIT_05 => X"D1010003110AD1010003110D5000D1010003D20100030042500091072053E053",
                    INIT_06 => X"5F021F01500020653B001A01D1010003206DD1004BA05000D101113E00035000",
                    INIT_07 => X"1D80500000A600B4009D00B300A35000009900B400A300B3009D00A65000DF04",
                    INIT_08 => X"00B300A35000608A9D0100A91D08208090004D0E008F00A6208500A36084CED0",
                    INIT_09 => X"9C02DF045F01500000B3DF043FFE5000DE0100A9208F00A65000009900B4009D",
                    INIT_0A => X"4E00DC029C0200B6009D00B300A65000DF045F025000DF043FFD5000209FDC01",
                    INIT_0B => X"1149114C1143500060BA9C011C05500000B900B900B900B900B95000009900B6",
                    INIT_0C => X"D1010003D20100030042100100651ABD1B00B001B03100D31100113A11561120",
                    INIT_0D => X"B42CD0051000E0E1D404B42C2109D300B3235000F023F020100050000061005A",
                    INIT_0E => X"007F4E061E280072006E20E79401450620EBD40015109404B42CD005100120E5",
                    INIT_0F => X"0089008E03E000890096007F4E071E280072006E01DA00790096007F0E500096",
                    INIT_10 => X"D608160100D7F62C1600F62316015000005A00540040005400300079009404E0",
                    INIT_11 => X"1120116F1174112011641165116C11691161116611201143113211495000610C",
                    INIT_12 => X"1B04205A00651A121B01005A006E110011211164116E116F1170117311651172",
                    INIT_13 => X"005A21313B001A03005A21313B001A01D1010003213FD1FF213BD1004BA01A71",
                    INIT_14 => X"D005B02C500000790096007FBE340096007F4E06BE300072006ED005B02C5000",
                    INIT_15 => X"0040005400300079009404E00089008E03E000890096007F4E07BE300072006E",
                    INIT_16 => X"9001AB001003102CF140B1285000005A005490065000D006B02C5000005A0054",
                    INIT_17 => X"B528B0405000EE101101ED101101EC101101EB101141AE009001AD009001AC00",
                    INIT_18 => X"9001A7009001A6001003102CAE001001AD001001AC001001AB0010416205C050",
                    INIT_19 => X"01C601BB01B201CC01C601BB01B21200110001CC01CC01CC01C6A9009001A800",
                    INIT_1A => X"619995017000D10100031120700101CC01C601BB01B201CC01C601BB01B201CC",
                    INIT_1B => X"61C2D001900600037001500001D244204410320402A0310101F014005000005A",
                    INIT_1C => X"490848084708460E50004F004E084D084C084B0E50007000D001103021C31031",
                    INIT_1D => X"115211521145500061DA90011019500001D9340DD406540201D9D40650004A00",
                    INIT_1E => X"1120114F1144115411201164116E116111201153114D11541120113A1152114F",
                    INIT_1F => X"116D11201174116F116E1120116F116411201173116811741167116E1165116C",
                    INIT_20 => X"A34012001430022F1545B42C5000005A00651ADD1B0111001168116311741161",
                    INIT_21 => X"E25042404406440644064406A440140142004306420043064200430642004306",
                    INIT_22 => X"D4005000005AD20100030042A05015010054A050022F1545B42C5000E3501501",
                    INIT_23 => X"696068601600144502681504190618261E001D035000222F9401150115011000",
                    INIT_24 => X"0268150370016E706D604708460E4708460E4708460E4708460EA7401401A640",
                    INIT_25 => X"1CFF4708460F4708460F4708460F4708460FA7401401A640623DD46114017000",
                    INIT_26 => X"028101B21200110001CC01CC01CC01C650000268150617FF18F819000E700D60",
                    INIT_27 => X"626E950101CC01C6028101B201CC01C6028101B201CC01C6028101B201CC01C6",
                    INIT_28 => X"098002C502C502C502C519001800164502681504190618261E001D0350005000",
                    INIT_29 => X"6289D6631601005AE9601601E86002C502C502C502C502C502C502C502C51800",
                    INIT_2A => X"02C502C502C502C5190018001C0602681504190618261E401D01223D1445005A",
                    INIT_2B => X"0090D201000300420080005A02C502C502C502C502C502C502C502C518000980",
                    INIT_2C => X"0268150219FF18FF1E0050004808450E950601D2140022CB62AA9C01005A0054",
                    INIT_2D => X"1E201D015000005A0054A07007501763B52C5000E67007501763B630B52C5000",
                    INIT_2E => X"6DD06EE0ADF09F01AEF09F0101D2A4F01F0A1F63120013020268150419061826",
                    INIT_2F => X"4EA04A064A064A06AAF09F01AEF09F0170000268150416001700180019007001",
                    INIT_30 => X"490EA9F09F014DA04A064A06AAF09F010D904EA04A0049064A004906A9F09F01",
                    INIT_31 => X"6EE04BA04A06AAF09F010B904CA049004A06AAF09F010C904DA04A08490E4A08",
                    INIT_32 => X"70000268150270012335D2016EE0AEF09F0170000268150770016BB06CC06DD0",
                    INIT_33 => X"02681504190618261E201D0150000268150418FF198022E6120162E6D3009301",
                    INIT_34 => X"9901035880C01008036C035D18001609E8900358100702C5190A1963180001D2",
                    INIT_35 => X"9C0102C5036C23589001480E1000D000500022E6130212006349D6FF9601E890",
                    INIT_36 => X"3B000A601A621B031C081C081C031C031C041C041C031C081C031C08235E1000",
                    INIT_37 => X"A030D00110200003D001103A0003D1010003D201000300420030130050004BA0",
                    INIT_38 => X"5000005A2373005A637FD003300313010030238ED3FFD1010003D20100030042",
                    INIT_39 => X"D00310005000D00310FF500003CF05A705580210B12BB227A39AD004B02303CF",
                    INIT_3A => X"11641172116F115711001120113A117211651166116611751142500000C45000",
                    INIT_3B => X"11691173112011641172116F115711001120113A1174116E1175116F11631120",
                    INIT_3C => X"1B031100112011641172116F115711001120112011201120113A11731165117A",
                    INIT_3D => X"10280003D0011020000323D41101D001A0100003E3DBC120B220110000651AA3",
                    INIT_3E => X"B023000300651AAC1B03005AD00110290003D1010003D201000300420020D001",
                    INIT_3F => X"1124D00110400003D00110200003E409C3401300B423D1010003D20100030042",
                    INIT_40 => X"C3401300B42300651AB91B03005A23F71301D1010003D20100030042A0100130",
                    INIT_41 => X"B423005A240F1301D1010003D20100030042A01001301128D00110200003E41E",
                    INIT_42 => X"D00110200003D1010003D20100030042003000651AC91B03005AE441C3401300",
                    INIT_43 => X"9601D1010003D20100030042A060A421C65016030650152C4506450613010530",
                    INIT_44 => X"95055000005A005490055000D0085000D0071000D0075010B02C5000005A2437",
                    INIT_45 => X"1173117211651156244F005A005490070054900700549007005490071000D501",
                    INIT_46 => X"005AD1010003D20100030042100100651A5C1B0411001120113A116E116F1169",
                    INIT_47 => X"1164116D1165116D11901103110011671172116111691174116C1175116D5000",
                    INIT_48 => X"1165117611A111031100117411651173116511721172110311001170116D1175",
                    INIT_49 => X"1165116811CF11031100117311791173116611041100116E116F116911731172",
                    INIT_4A => X"119B11031100116E116F115F117211651177116F1170112F110111001170116C",
                    INIT_4B => X"11D7110011001161119E1103110011661166116F115F117211651177116F1170",
                    INIT_4C => X"1169114111011100117711691166110111001172116A1163110111001177116A",
                    INIT_4D => X"1174116A117E11011100116D116A116A110111001164116A114E110111001172",
                    INIT_4E => X"11361102110011751174116A11231102110011721174116A110A110211001177",
                    INIT_4F => X"110411001163117411A31102110011731174116A11821102110011671174116A",
                    INIT_50 => X"114F1104110011721174114911041100117A1174114B11041100116611741143",
                    INIT_51 => X"110011751161116A11D71102110011721161116A11D11102110011771161116A",
                    INIT_52 => X"D1FF2547D1004BA012001A711B0411FF113A1103110011671161116A11DE1102",
                    INIT_53 => X"2543D1002554D1FF4BA0252C3B001A011201653BC010A020E53BC200B0202554",
                    INIT_54 => X"4BA03B001A0102104BA03B001A0105A70558252C12003B001A03253B3B001A01",
                    INIT_55 => X"00301201A020E582C210B120F023100050000061058F00D35000006100D34210",
                    INIT_56 => X"0310A570C310B12013080320E21001001123F0232582D0051001B0239201E55A",
                    INIT_57 => X"90011028B0238300A01091011124B123032025701201E5770030A0202577C320",
                    INIT_58 => X"1B0511001164116E1161116D116D116F116311201164116111425000255AE300",
                    INIT_59 => X"002000651A941B0511001120113A1172116F1172117211455000005A00651A83",
                    INIT_5A => X"1400A5AAC1201101E0101000112C120412385000005AD1010003D20100030042",
                    INIT_5B => X"96021401172C4706470607400650A61001401128A50000401024E5D2C400B023",
                    INIT_5C => X"0030A06065B0C650160125BF1701E070001D9601A1601601A260A5CBC650A5B0",
                    INIT_5D => X"25D3852905F2E5EAD120F1201101B120E0101100B12090010007500025B0E070",
                    INIT_5E => X"00D3005A00651AE01B05005A110011211177116F116C1166117211651176114F",
                    INIT_5F => X"F0209001B020E603D120260FD1082608D10A2608D10DA1009001B02025D30061",
                    INIT_60 => X"B0205000400C1001F0209001B020005A5000400C1000D10100035000400C1000",
                    INIT_61 => X"9001B020F0209001B020D10111080003D10111200003D10111080003A61E9002",
                    INIT_62 => X"0000000000000000000000000000000000000000000000005000400C1000F020",
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
                   INITP_00 => X"2AAAAAAA0A5ADA8AA28AAA9F507D554A4D775DDD9211E154E2082082082C2C2A",
                   INITP_01 => X"A2A4AAA292A5D122234D2A2AAA882AAAAAD2AAAA42AA8A2C22A22AAAAB62DAAC",
                   INITP_02 => X"0A666044448A8A2A228A2A4A8AA292A2A5A5ADD8282AAAAAAAAAAAAB5A22A228",
                   INITP_03 => X"AAAAAAAAAAAAAAAAAAD288A955955B88D2E8000ADE8EAAAAAAA82A844441110D",
                   INITP_04 => X"DAAAAAAAA0AAA000155544D78D55554450800A576AA1882985515555020A82AA",
                   INITP_05 => X"1511E003511840800A842902802522DA2A2AAAA0AA020022D69AAAA82A80800A",
                   INITP_06 => X"228AAA0A50AAAAAB6A5DA0D664A0A242800A0235E3D478D54441441544510551",
                   INITP_07 => X"228B42AA2828AAA228A62D082AAAAAAAAAAAAAAAAAAAAAAA8A2A90D2AAD136AA",
                   INITP_08 => X"AAAAAAAAAAA20AAAAAA8888D2A2A882A6AA351548AAA20B429AA848B420A6AA1",
                   INITP_09 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_0A => X"5114278D34492D479348AAAA9496A165DDA574D37602AAAAAAAAAAAAAAAAAAAA",
                   INITP_0B => X"9377744AA82AAAAABB6490AA8D6691375544413435812AAA20AAAAA82AAAAAAA",
                   INITP_0C => X"00000000000000000000000000000000000000000000009249228A2D249292A4",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
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
                    INIT_00 => X"2D30200002000010000004000020000001000008000700080003000400D36EC4",
                    INIT_01 => X"0E0041100A3E2A41100A3E11410A3E30000E0000300E01002D30100606060600",
                    INIT_02 => X"01030A01030D0001030103420007535341370F00074C4C41370E0E0E0E000000",
                    INIT_03 => X"8000A6B49DB3A30099B4A3B39DA6000402010065000101036D00A000013E0300",
                    INIT_04 => X"02040100B304FE0001A98FA60099B49DB3A3008A01A90880000E8FA685A384D0",
                    INIT_05 => X"494C4300BA010500B9B9B9B9B90099B6000202B69DB3A60004020004FD009F01",
                    INIT_06 => X"2C0500E1042C0900230023200000615A01030103420165BD000131D3003A5620",
                    INIT_07 => X"898EE089967F0728726EDA79967F50967F0628726EE70106EB0010042C0501E5",
                    INIT_08 => X"206F742064656C69616620433249000C0801D72C002301005A544054307994E0",
                    INIT_09 => X"5A3100035A31000101033FFF3B00A071045A6512015A6E0021646E6F70736572",
                    INIT_0A => X"4054307994E0898EE089967F0730726E052C0079967F34967F0630726E052C00",
                    INIT_0B => X"284000100110011001104100010001000100032C4028005A540600062C005A54",
                    INIT_0C => X"C6BBB2CCC6BBB20000CCCCCCC600010001000100032C00010001000100410550",
                    INIT_0D => X"C20106030100D2201004A001F000005A99010001032001CCC6BBB2CCC6BBB2CC",
                    INIT_0E => X"52524500DA011900D90D0602D90600000808080E00000808080E00000130C331",
                    INIT_0F => X"6D20746F6E206F6420736874676E656C204F445420646E6120534D54203A524F",
                    INIT_10 => X"504006060606400100060006000600064000302F452C005A65DD010068637461",
                    INIT_11 => X"60600045680406260003002F0101010000005A010342500154502F452C005001",
                    INIT_12 => X"FF080F080F080F080F4001403D6101006803017060080E080E080E080E400140",
                    INIT_13 => X"6E01CCC681B2CCC681B2CCC681B2CCC681B20000CCCCCCC6006806FFF8007060",
                    INIT_14 => X"8963015A600160C5C5C5C5C5C5C5C50080C5C5C5C50000456804062600030000",
                    INIT_15 => X"90010342805AC5C5C5C5C5C5C5C50080C5C5C5C50000066804062640013D455A",
                    INIT_16 => X"2001005A547050632C00705063302C006802FFFF0000080E06D200CBAA015A54",
                    INIT_17 => X"A0060606F001F0010068040000000001D0E0F001F001D2F00A63000268040626",
                    INIT_18 => X"E0A006F00190A00006F00190A0080E080EF001A00606F00190A000060006F001",
                    INIT_19 => X"680406262001006804FF80E601E60001006802013501E0F00100680701B0C0D0",
                    INIT_1A => X"01C56C58010E000000E6020049FF01900158C0086C5D0009905807C50A6300D2",
                    INIT_1B => X"30012003013A030103010342300000A000606203080803030404030803085E00",
                    INIT_1C => X"03000003FF00CFA758102B279A0423CF005A735A7F030301308EFF0103010342",
                    INIT_1D => X"69732064726F5700203A746E756F632064726F5700203A72656666754200C400",
                    INIT_1E => X"2803012003D401011003DB20200065A303002064726F5700202020203A73657A",
                    INIT_1F => X"24014003012003094000230103010342230365AC035A01290301030103422001",
                    INIT_20 => X"235A0F0101030103421030280120031E40002365B9035AF70101030103421030",
                    INIT_21 => X"01010301034260215003502C0606013001200301030103423065C9035A414000",
                    INIT_22 => X"737265564F5A5407540754075407000105005A5405000800070007102C005A37",
                    INIT_23 => X"646D656D90030067726169746C756D005A010301034201655C0400203A6E6F69",
                    INIT_24 => X"6568CF03007379736604006E6F6973726576A103007465736572720300706D75",
                    INIT_25 => X"D70000619E030066666F5F7265776F709B03006E6F5F7265776F702F0100706C",
                    INIT_26 => X"746A7E01006D6A6A0100646A4E010072694101007769660100726A630100776A",
                    INIT_27 => X"04006374A3020073746A82020067746A36020075746A23020072746A0A020077",
                    INIT_28 => X"0075616AD7020072616AD1020077616A4F040072744904007A744B0400667443",
                    INIT_29 => X"430054FFA02C0001013B10203B002054FF4700A0007104FF3A030067616ADE02",
                    INIT_2A => X"300120821020230000618FD30061D310A0000110A00001A7582C0000033B0001",
                    INIT_2B => X"012823001001242320700177302077201070102008201000232382050123015A",
                    INIT_2C => X"2065940500203A726F727245005A65830500646E616D6D6F6320646142005A00",
                    INIT_2D => X"02012C06064050104028004024D2002300AA200110002C0438005A0103010342",
                    INIT_2E => X"D329F2EA20200120100020010700B0703060B05001BF01701D01600160CB50B0",
                    INIT_2F => X"20012003200F08080A080D000120D361D35A65E0055A0021776F6C667265764F",
                    INIT_30 => X"01202001200108030120030108031E0220000C012001205A000C000103000C00",
                    INIT_31 => X"00000000000000000000000000000000000000000000000000000000000C0020",
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
                   INITP_00 => X"202001200380808FE00000D866000A408001CA6CB504F0000000011F00000004",
                   INITP_01 => X"FFFFFFFFE888A5428218D5FFFEFC40888EE44C000080000066BE89FFFFFD0000",
                   INITP_02 => X"052AB6D6439A61C0000108C80800846477775F3555404D54864601130055883F",
                   INITP_03 => X"80D008400634FFFFFFFFFFF803A92970010590023028CC4D64A328954D2AF197",
                   INITP_04 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE407FF0018000401F10131830C5C1",
                   INITP_05 => X"0AB20BFFFF6226253CE472101FF0FFFB17D3FDA11420CDD6FE49F3FFFFFFFFFF",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000000000006D80010",
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
                    INIT_00 => X"F0000028684828684828684828684828684828684810C8684810886848120000",
                    INIT_01 => X"A008D0E888D0C8D0E888D0C8D0E8D0C828A0082800A00881F00000A1A1A1A101",
                    INIT_02 => X"68000868000828680069000028C890F0E8881800C990F0E989A1A1A1A1012828",
                    INIT_03 => X"0E28000000000028000000000000286F2F0F28109D8D680090E8252868080028",
                    INIT_04 => X"4E6F2F28006F1F286F00100028000000000028B0CE000E10C8A600001000B067",
                    INIT_05 => X"08080828B0CE0E280000000000280000A76E4E00000000286F2F286F1F28906E",
                    INIT_06 => X"5A6808F0EA5A90E95928787808280000680069000008000D0D58580008080808",
                    INIT_07 => X"000001000000A70F000000000000070000A70F000010CAA290EA0ACA5A680810",
                    INIT_08 => X"080808080808080808080808080828B0EB8B007B0B7B0B280000000000000002",
                    INIT_09 => X"00109D8D00109D8D680090E890E8250D0D10000D0D0000080808080808080808",
                    INIT_0A => X"000000000002000001000000A75F00006858280000005F0000A75F0000685828",
                    INIT_0B => X"5A5828778876887688750857C856C856C8558808785828000048286858280000",
                    INIT_0C => X"0000000000000009080000000054C854C853C85388085788568856885508B1E0",
                    INIT_0D => X"B0E84800B828002222190118000A2800B0CAB8680008B8000000000000000000",
                    INIT_0E => X"08080828B0C80828001A6A2A006A28A5A4A4A3A328A7A7A6A6A528B868081008",
                    INIT_0F => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_10 => X"7121A2A2A2A2528AA1A1A1A1A1A1A1A151090A010A5A2800000D0D0808080808",
                    INIT_11 => X"B4B40B0A010A0C0C0F0E2811CA8A8A88EA2800690000508A0050010A5A28718A",
                    INIT_12 => X"0EA3A3A3A3A3A3A3A3538A53B1EA8AB8010AB8B7B6A3A3A3A3A3A3A3A3538A53",
                    INIT_13 => X"B1CA0000010000000100000001000000010009080000000028010A0B0C0C0706",
                    INIT_14 => X"B1EB8B00748B7401010101010101010C04010101010C0C0B010A0C0C0F0E2828",
                    INIT_15 => X"00690000000001010101010101010C04010101010C0C0E010A0C0C0F0E110A00",
                    INIT_16 => X"0F0E28000050830B5A2873830B5B5A28010A0C0C0F28A4A24A000A11B1CE0000",
                    INIT_17 => X"27A5A5A555CF57CFB8010A0B0B0C0CB8B6B756CF57CF00528F0F0909010A0C0C",
                    INIT_18 => X"B725A555CF0526A4A555CF0626A5A4A5A454CF26A5A555CF0627A5A4A5A454CF",
                    INIT_19 => X"010A0C0C0F0E28010A0C0C1109B1E9C9B8010AB891E9B757CFB8010AB8B5B6B6",
                    INIT_1A => X"CE010111C8A488E828110909B1EBCB74CC01C00801010C0B740108018C0C0C00",
                    INIT_1B => X"506808006808006800690000000928259D850D0D0E0E0E0E0E0E0E0E0E0E1188",
                    INIT_1C => X"680828680828010202815859D1E8580128001100B1E818890091E96800690000",
                    INIT_1D => X"0808080808080808080808080808080808080808080808080808080808280028",
                    INIT_1E => X"08006808001188685000F1E05908000D0D080808080808080808080808080808",
                    INIT_1F => X"08680800680800F2E1095A68006900005800000D0D0068080068006900000068",
                    INIT_20 => X"5A0012896800690000508008680800F2E1095A000D0D00118968006900005080",
                    INIT_21 => X"CB680069000050D2E38B038AA2A28902680800680069000000000D0D00F2E109",
                    INIT_22 => X"080808081200004800480048004888EA4A280000482868286808682858280012",
                    INIT_23 => X"0808080808080808080808080808082800680069000008000D0D080808080808",
                    INIT_24 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_25 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_26 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_27 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_28 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_29 => X"92E892E825129D8D89B2E050F2E15892E892E825090D0D080808080808080808",
                    INIT_2A => X"008950F2E15878082800020028000021259D8D01259D8D020212099D8D129D8D",
                    INIT_2B => X"C88858C150C88858011289F2005092E101D2E15889017180087892E88858C9F2",
                    INIT_2C => X"00000D0D08080808080808082800000D0D080808080808080808080808281271",
                    INIT_2D => X"CB8A8BA3A30383538008528008F2E2580AD2E088700808890928006800690000",
                    INIT_2E => X"12C202F2E878885870885848002812700050B2E38B128B7000CB508B51D2E3D2",
                    INIT_2F => X"78C858F3E893E893E893E850C85812000000000D0D0008080808080808080808",
                    INIT_30 => X"C85878C858680800680800680800D3C85828A00878C8580028A008680028A008",
                    INIT_31 => X"0000000000000000000000000000000000000000000000000000000028A00878",
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
                   INITP_00 => X"DCFD9C855277FA7FF9FF1FB65D7FF5BE7FFF33BBDBFB0603252A90C0D2492667",
                   INITP_01 => X"FFFFFFFFF9AE083A9E03BBFFFE78000235400BB75B73BD9DCCEA67FFFFFF35D6",
                   INITP_02 => X"00C102083861845B77FCF1059BFE7883BFFFCFC00009A00008317CA68000139F",
                   INITP_03 => X"5B1F66FD6D627FFFFFFFFFFFB789F85F5BF30FFF72C94CD18314D86800000000",
                   INITP_04 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD3FFEAA77A77D00BF4C6F8B137C",
                   INITP_05 => X"9543E7FFF48FA5850004487F4FFE7FFF005A426192FF89C4AC4951FFFFFFFFFF",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000000000925B6499C",
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
                    INIT_00 => X"2D30200002000010000004000020000001000008000700080003000400D36EC4",
                    INIT_01 => X"0E0041100A3E2A41100A3E11410A3E30000E0000300E01002D30100606060600",
                    INIT_02 => X"01030A01030D0001030103420007535341370F00074C4C41370E0E0E0E000000",
                    INIT_03 => X"8000A6B49DB3A30099B4A3B39DA6000402010065000101036D00A000013E0300",
                    INIT_04 => X"02040100B304FE0001A98FA60099B49DB3A3008A01A90880000E8FA685A384D0",
                    INIT_05 => X"494C4300BA010500B9B9B9B9B90099B6000202B69DB3A60004020004FD009F01",
                    INIT_06 => X"2C0500E1042C0900230023200000615A01030103420165BD000131D3003A5620",
                    INIT_07 => X"898EE089967F0728726EDA79967F50967F0628726EE70106EB0010042C0501E5",
                    INIT_08 => X"206F742064656C69616620433249000C0801D72C002301005A544054307994E0",
                    INIT_09 => X"5A3100035A31000101033FFF3B00A071045A6512015A6E0021646E6F70736572",
                    INIT_0A => X"4054307994E0898EE089967F0730726E052C0079967F34967F0630726E052C00",
                    INIT_0B => X"284000100110011001104100010001000100032C4028005A540600062C005A54",
                    INIT_0C => X"C6BBB2CCC6BBB20000CCCCCCC600010001000100032C00010001000100410550",
                    INIT_0D => X"C20106030100D2201004A001F000005A99010001032001CCC6BBB2CCC6BBB2CC",
                    INIT_0E => X"52524500DA011900D90D0602D90600000808080E00000808080E00000130C331",
                    INIT_0F => X"6D20746F6E206F6420736874676E656C204F445420646E6120534D54203A524F",
                    INIT_10 => X"504006060606400100060006000600064000302F452C005A65DD010068637461",
                    INIT_11 => X"60600045680406260003002F0101010000005A010342500154502F452C005001",
                    INIT_12 => X"FF080F080F080F080F4001403D6101006803017060080E080E080E080E400140",
                    INIT_13 => X"6E01CCC681B2CCC681B2CCC681B2CCC681B20000CCCCCCC6006806FFF8007060",
                    INIT_14 => X"8963015A600160C5C5C5C5C5C5C5C50080C5C5C5C50000456804062600030000",
                    INIT_15 => X"90010342805AC5C5C5C5C5C5C5C50080C5C5C5C50000066804062640013D455A",
                    INIT_16 => X"2001005A547050632C00705063302C006802FFFF0000080E06D200CBAA015A54",
                    INIT_17 => X"A0060606F001F0010068040000000001D0E0F001F001D2F00A63000268040626",
                    INIT_18 => X"E0A006F00190A00006F00190A0080E080EF001A00606F00190A000060006F001",
                    INIT_19 => X"680406262001006804FF80E601E60001006802013501E0F00100680701B0C0D0",
                    INIT_1A => X"01C56C58010E000000E6020049FF01900158C0086C5D0009905807C50A6300D2",
                    INIT_1B => X"30012003013A030103010342300000A000606203080803030404030803085E00",
                    INIT_1C => X"03000003FF00CFA758102B279A0423CF005A735A7F030301308EFF0103010342",
                    INIT_1D => X"69732064726F5700203A746E756F632064726F5700203A72656666754200C400",
                    INIT_1E => X"2803012003D401011003DB20200065A303002064726F5700202020203A73657A",
                    INIT_1F => X"24014003012003094000230103010342230365AC035A01290301030103422001",
                    INIT_20 => X"235A0F0101030103421030280120031E40002365B9035AF70101030103421030",
                    INIT_21 => X"01010301034260215003502C0606013001200301030103423065C9035A414000",
                    INIT_22 => X"737265564F5A5407540754075407000105005A5405000800070007102C005A37",
                    INIT_23 => X"646D656D90030067726169746C756D005A010301034201655C0400203A6E6F69",
                    INIT_24 => X"6568CF03007379736604006E6F6973726576A103007465736572720300706D75",
                    INIT_25 => X"D70000619E030066666F5F7265776F709B03006E6F5F7265776F702F0100706C",
                    INIT_26 => X"746A7E01006D6A6A0100646A4E010072694101007769660100726A630100776A",
                    INIT_27 => X"04006374A3020073746A82020067746A36020075746A23020072746A0A020077",
                    INIT_28 => X"0075616AD7020072616AD1020077616A4F040072744904007A744B0400667443",
                    INIT_29 => X"430054FFA02C0001013B10203B002054FF4700A0007104FF3A030067616ADE02",
                    INIT_2A => X"300120821020230000618FD30061D310A0000110A00001A7582C0000033B0001",
                    INIT_2B => X"012823001001242320700177302077201070102008201000232382050123015A",
                    INIT_2C => X"2065940500203A726F727245005A65830500646E616D6D6F6320646142005A00",
                    INIT_2D => X"02012C06064050104028004024D2002300AA200110002C0438005A0103010342",
                    INIT_2E => X"D329F2EA20200120100020010700B0703060B05001BF01701D01600160CB50B0",
                    INIT_2F => X"20012003200F08080A080D000120D361D35A65E0055A0021776F6C667265764F",
                    INIT_30 => X"01202001200108030120030108031E0220000C012001205A000C000103000C00",
                    INIT_31 => X"00000000000000000000000000000000000000000000000000000000000C0020",
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
                   INITP_00 => X"202001200380808FE00000D866000A408001CA6CB504F0000000011F00000004",
                   INITP_01 => X"FFFFFFFFE888A5428218D5FFFEFC40888EE44C000080000066BE89FFFFFD0000",
                   INITP_02 => X"052AB6D6439A61C0000108C80800846477775F3555404D54864601130055883F",
                   INITP_03 => X"80D008400634FFFFFFFFFFF803A92970010590023028CC4D64A328954D2AF197",
                   INITP_04 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE407FF0018000401F10131830C5C1",
                   INITP_05 => X"0AB20BFFFF6226253CE472101FF0FFFB17D3FDA11420CDD6FE49F3FFFFFFFFFF",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000000000006D80010",
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
                    INIT_00 => X"F0000028684828684828684828684828684828684810C8684810886848120000",
                    INIT_01 => X"A008D0E888D0C8D0E888D0C8D0E8D0C828A0082800A00881F00000A1A1A1A101",
                    INIT_02 => X"68000868000828680069000028C890F0E8881800C990F0E989A1A1A1A1012828",
                    INIT_03 => X"0E28000000000028000000000000286F2F0F28109D8D680090E8252868080028",
                    INIT_04 => X"4E6F2F28006F1F286F00100028000000000028B0CE000E10C8A600001000B067",
                    INIT_05 => X"08080828B0CE0E280000000000280000A76E4E00000000286F2F286F1F28906E",
                    INIT_06 => X"5A6808F0EA5A90E95928787808280000680069000008000D0D58580008080808",
                    INIT_07 => X"000001000000A70F000000000000070000A70F000010CAA290EA0ACA5A680810",
                    INIT_08 => X"080808080808080808080808080828B0EB8B007B0B7B0B280000000000000002",
                    INIT_09 => X"00109D8D00109D8D680090E890E8250D0D10000D0D0000080808080808080808",
                    INIT_0A => X"000000000002000001000000A75F00006858280000005F0000A75F0000685828",
                    INIT_0B => X"5A5828778876887688750857C856C856C8558808785828000048286858280000",
                    INIT_0C => X"0000000000000009080000000054C854C853C85388085788568856885508B1E0",
                    INIT_0D => X"B0E84800B828002222190118000A2800B0CAB8680008B8000000000000000000",
                    INIT_0E => X"08080828B0C80828001A6A2A006A28A5A4A4A3A328A7A7A6A6A528B868081008",
                    INIT_0F => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_10 => X"7121A2A2A2A2528AA1A1A1A1A1A1A1A151090A010A5A2800000D0D0808080808",
                    INIT_11 => X"B4B40B0A010A0C0C0F0E2811CA8A8A88EA2800690000508A0050010A5A28718A",
                    INIT_12 => X"0EA3A3A3A3A3A3A3A3538A53B1EA8AB8010AB8B7B6A3A3A3A3A3A3A3A3538A53",
                    INIT_13 => X"B1CA0000010000000100000001000000010009080000000028010A0B0C0C0706",
                    INIT_14 => X"B1EB8B00748B7401010101010101010C04010101010C0C0B010A0C0C0F0E2828",
                    INIT_15 => X"00690000000001010101010101010C04010101010C0C0E010A0C0C0F0E110A00",
                    INIT_16 => X"0F0E28000050830B5A2873830B5B5A28010A0C0C0F28A4A24A000A11B1CE0000",
                    INIT_17 => X"27A5A5A555CF57CFB8010A0B0B0C0CB8B6B756CF57CF00528F0F0909010A0C0C",
                    INIT_18 => X"B725A555CF0526A4A555CF0626A5A4A5A454CF26A5A555CF0627A5A4A5A454CF",
                    INIT_19 => X"010A0C0C0F0E28010A0C0C1109B1E9C9B8010AB891E9B757CFB8010AB8B5B6B6",
                    INIT_1A => X"CE010111C8A488E828110909B1EBCB74CC01C00801010C0B740108018C0C0C00",
                    INIT_1B => X"506808006808006800690000000928259D850D0D0E0E0E0E0E0E0E0E0E0E1188",
                    INIT_1C => X"680828680828010202815859D1E8580128001100B1E818890091E96800690000",
                    INIT_1D => X"0808080808080808080808080808080808080808080808080808080808280028",
                    INIT_1E => X"08006808001188685000F1E05908000D0D080808080808080808080808080808",
                    INIT_1F => X"08680800680800F2E1095A68006900005800000D0D0068080068006900000068",
                    INIT_20 => X"5A0012896800690000508008680800F2E1095A000D0D00118968006900005080",
                    INIT_21 => X"CB680069000050D2E38B038AA2A28902680800680069000000000D0D00F2E109",
                    INIT_22 => X"080808081200004800480048004888EA4A280000482868286808682858280012",
                    INIT_23 => X"0808080808080808080808080808082800680069000008000D0D080808080808",
                    INIT_24 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_25 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_26 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_27 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_28 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_29 => X"92E892E825129D8D89B2E050F2E15892E892E825090D0D080808080808080808",
                    INIT_2A => X"008950F2E15878082800020028000021259D8D01259D8D020212099D8D129D8D",
                    INIT_2B => X"C88858C150C88858011289F2005092E101D2E15889017180087892E88858C9F2",
                    INIT_2C => X"00000D0D08080808080808082800000D0D080808080808080808080808281271",
                    INIT_2D => X"CB8A8BA3A30383538008528008F2E2580AD2E088700808890928006800690000",
                    INIT_2E => X"12C202F2E878885870885848002812700050B2E38B128B7000CB508B51D2E3D2",
                    INIT_2F => X"78C858F3E893E893E893E850C85812000000000D0D0008080808080808080808",
                    INIT_30 => X"C85878C858680800680800680800D3C85828A00878C8580028A008680028A008",
                    INIT_31 => X"0000000000000000000000000000000000000000000000000000000028A00878",
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
                   INITP_00 => X"DCFD9C855277FA7FF9FF1FB65D7FF5BE7FFF33BBDBFB0603252A90C0D2492667",
                   INITP_01 => X"FFFFFFFFF9AE083A9E03BBFFFE78000235400BB75B73BD9DCCEA67FFFFFF35D6",
                   INITP_02 => X"00C102083861845B77FCF1059BFE7883BFFFCFC00009A00008317CA68000139F",
                   INITP_03 => X"5B1F66FD6D627FFFFFFFFFFFB789F85F5BF30FFF72C94CD18314D86800000000",
                   INITP_04 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD3FFEAA77A77D00BF4C6F8B137C",
                   INITP_05 => X"9543E7FFF48FA5850004487F4FFE7FFF005A426192FF89C4AC4951FFFFFFFFFF",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000000000925B6499C",
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
                    INIT_00 => X"2D30200002000010000004000020000001000008000700080003000400D36EC4",
                    INIT_01 => X"0E0041100A3E2A41100A3E11410A3E30000E0000300E01002D30100606060600",
                    INIT_02 => X"01030A01030D0001030103420007535341370F00074C4C41370E0E0E0E000000",
                    INIT_03 => X"8000A6B49DB3A30099B4A3B39DA6000402010065000101036D00A000013E0300",
                    INIT_04 => X"02040100B304FE0001A98FA60099B49DB3A3008A01A90880000E8FA685A384D0",
                    INIT_05 => X"494C4300BA010500B9B9B9B9B90099B6000202B69DB3A60004020004FD009F01",
                    INIT_06 => X"2C0500E1042C0900230023200000615A01030103420165BD000131D3003A5620",
                    INIT_07 => X"898EE089967F0728726EDA79967F50967F0628726EE70106EB0010042C0501E5",
                    INIT_08 => X"206F742064656C69616620433249000C0801D72C002301005A544054307994E0",
                    INIT_09 => X"5A3100035A31000101033FFF3B00A071045A6512015A6E0021646E6F70736572",
                    INIT_0A => X"4054307994E0898EE089967F0730726E052C0079967F34967F0630726E052C00",
                    INIT_0B => X"284000100110011001104100010001000100032C4028005A540600062C005A54",
                    INIT_0C => X"C6BBB2CCC6BBB20000CCCCCCC600010001000100032C00010001000100410550",
                    INIT_0D => X"C20106030100D2201004A001F000005A99010001032001CCC6BBB2CCC6BBB2CC",
                    INIT_0E => X"52524500DA011900D90D0602D90600000808080E00000808080E00000130C331",
                    INIT_0F => X"6D20746F6E206F6420736874676E656C204F445420646E6120534D54203A524F",
                    INIT_10 => X"504006060606400100060006000600064000302F452C005A65DD010068637461",
                    INIT_11 => X"60600045680406260003002F0101010000005A010342500154502F452C005001",
                    INIT_12 => X"FF080F080F080F080F4001403D6101006803017060080E080E080E080E400140",
                    INIT_13 => X"6E01CCC681B2CCC681B2CCC681B2CCC681B20000CCCCCCC6006806FFF8007060",
                    INIT_14 => X"8963015A600160C5C5C5C5C5C5C5C50080C5C5C5C50000456804062600030000",
                    INIT_15 => X"90010342805AC5C5C5C5C5C5C5C50080C5C5C5C50000066804062640013D455A",
                    INIT_16 => X"2001005A547050632C00705063302C006802FFFF0000080E06D200CBAA015A54",
                    INIT_17 => X"A0060606F001F0010068040000000001D0E0F001F001D2F00A63000268040626",
                    INIT_18 => X"E0A006F00190A00006F00190A0080E080EF001A00606F00190A000060006F001",
                    INIT_19 => X"680406262001006804FF80E601E60001006802013501E0F00100680701B0C0D0",
                    INIT_1A => X"01C56C58010E000000E6020049FF01900158C0086C5D0009905807C50A6300D2",
                    INIT_1B => X"30012003013A030103010342300000A000606203080803030404030803085E00",
                    INIT_1C => X"03000003FF00CFA758102B279A0423CF005A735A7F030301308EFF0103010342",
                    INIT_1D => X"69732064726F5700203A746E756F632064726F5700203A72656666754200C400",
                    INIT_1E => X"2803012003D401011003DB20200065A303002064726F5700202020203A73657A",
                    INIT_1F => X"24014003012003094000230103010342230365AC035A01290301030103422001",
                    INIT_20 => X"235A0F0101030103421030280120031E40002365B9035AF70101030103421030",
                    INIT_21 => X"01010301034260215003502C0606013001200301030103423065C9035A414000",
                    INIT_22 => X"737265564F5A5407540754075407000105005A5405000800070007102C005A37",
                    INIT_23 => X"646D656D90030067726169746C756D005A010301034201655C0400203A6E6F69",
                    INIT_24 => X"6568CF03007379736604006E6F6973726576A103007465736572720300706D75",
                    INIT_25 => X"D70000619E030066666F5F7265776F709B03006E6F5F7265776F702F0100706C",
                    INIT_26 => X"746A7E01006D6A6A0100646A4E010072694101007769660100726A630100776A",
                    INIT_27 => X"04006374A3020073746A82020067746A36020075746A23020072746A0A020077",
                    INIT_28 => X"0075616AD7020072616AD1020077616A4F040072744904007A744B0400667443",
                    INIT_29 => X"430054FFA02C0001013B10203B002054FF4700A0007104FF3A030067616ADE02",
                    INIT_2A => X"300120821020230000618FD30061D310A0000110A00001A7582C0000033B0001",
                    INIT_2B => X"012823001001242320700177302077201070102008201000232382050123015A",
                    INIT_2C => X"2065940500203A726F727245005A65830500646E616D6D6F6320646142005A00",
                    INIT_2D => X"02012C06064050104028004024D2002300AA200110002C0438005A0103010342",
                    INIT_2E => X"D329F2EA20200120100020010700B0703060B05001BF01701D01600160CB50B0",
                    INIT_2F => X"20012003200F08080A080D000120D361D35A65E0055A0021776F6C667265764F",
                    INIT_30 => X"01202001200108030120030108031E0220000C012001205A000C000103000C00",
                    INIT_31 => X"00000000000000000000000000000000000000000000000000000000000C0020",
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
                   INITP_00 => X"202001200380808FE00000D866000A408001CA6CB504F0000000011F00000004",
                   INITP_01 => X"FFFFFFFFE888A5428218D5FFFEFC40888EE44C000080000066BE89FFFFFD0000",
                   INITP_02 => X"052AB6D6439A61C0000108C80800846477775F3555404D54864601130055883F",
                   INITP_03 => X"80D008400634FFFFFFFFFFF803A92970010590023028CC4D64A328954D2AF197",
                   INITP_04 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE407FF0018000401F10131830C5C1",
                   INITP_05 => X"0AB20BFFFF6226253CE472101FF0FFFB17D3FDA11420CDD6FE49F3FFFFFFFFFF",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000000000006D80010",
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
                    INIT_00 => X"F0000028684828684828684828684828684828684810C8684810886848120000",
                    INIT_01 => X"A008D0E888D0C8D0E888D0C8D0E8D0C828A0082800A00881F00000A1A1A1A101",
                    INIT_02 => X"68000868000828680069000028C890F0E8881800C990F0E989A1A1A1A1012828",
                    INIT_03 => X"0E28000000000028000000000000286F2F0F28109D8D680090E8252868080028",
                    INIT_04 => X"4E6F2F28006F1F286F00100028000000000028B0CE000E10C8A600001000B067",
                    INIT_05 => X"08080828B0CE0E280000000000280000A76E4E00000000286F2F286F1F28906E",
                    INIT_06 => X"5A6808F0EA5A90E95928787808280000680069000008000D0D58580008080808",
                    INIT_07 => X"000001000000A70F000000000000070000A70F000010CAA290EA0ACA5A680810",
                    INIT_08 => X"080808080808080808080808080828B0EB8B007B0B7B0B280000000000000002",
                    INIT_09 => X"00109D8D00109D8D680090E890E8250D0D10000D0D0000080808080808080808",
                    INIT_0A => X"000000000002000001000000A75F00006858280000005F0000A75F0000685828",
                    INIT_0B => X"5A5828778876887688750857C856C856C8558808785828000048286858280000",
                    INIT_0C => X"0000000000000009080000000054C854C853C85388085788568856885508B1E0",
                    INIT_0D => X"B0E84800B828002222190118000A2800B0CAB8680008B8000000000000000000",
                    INIT_0E => X"08080828B0C80828001A6A2A006A28A5A4A4A3A328A7A7A6A6A528B868081008",
                    INIT_0F => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_10 => X"7121A2A2A2A2528AA1A1A1A1A1A1A1A151090A010A5A2800000D0D0808080808",
                    INIT_11 => X"B4B40B0A010A0C0C0F0E2811CA8A8A88EA2800690000508A0050010A5A28718A",
                    INIT_12 => X"0EA3A3A3A3A3A3A3A3538A53B1EA8AB8010AB8B7B6A3A3A3A3A3A3A3A3538A53",
                    INIT_13 => X"B1CA0000010000000100000001000000010009080000000028010A0B0C0C0706",
                    INIT_14 => X"B1EB8B00748B7401010101010101010C04010101010C0C0B010A0C0C0F0E2828",
                    INIT_15 => X"00690000000001010101010101010C04010101010C0C0E010A0C0C0F0E110A00",
                    INIT_16 => X"0F0E28000050830B5A2873830B5B5A28010A0C0C0F28A4A24A000A11B1CE0000",
                    INIT_17 => X"27A5A5A555CF57CFB8010A0B0B0C0CB8B6B756CF57CF00528F0F0909010A0C0C",
                    INIT_18 => X"B725A555CF0526A4A555CF0626A5A4A5A454CF26A5A555CF0627A5A4A5A454CF",
                    INIT_19 => X"010A0C0C0F0E28010A0C0C1109B1E9C9B8010AB891E9B757CFB8010AB8B5B6B6",
                    INIT_1A => X"CE010111C8A488E828110909B1EBCB74CC01C00801010C0B740108018C0C0C00",
                    INIT_1B => X"506808006808006800690000000928259D850D0D0E0E0E0E0E0E0E0E0E0E1188",
                    INIT_1C => X"680828680828010202815859D1E8580128001100B1E818890091E96800690000",
                    INIT_1D => X"0808080808080808080808080808080808080808080808080808080808280028",
                    INIT_1E => X"08006808001188685000F1E05908000D0D080808080808080808080808080808",
                    INIT_1F => X"08680800680800F2E1095A68006900005800000D0D0068080068006900000068",
                    INIT_20 => X"5A0012896800690000508008680800F2E1095A000D0D00118968006900005080",
                    INIT_21 => X"CB680069000050D2E38B038AA2A28902680800680069000000000D0D00F2E109",
                    INIT_22 => X"080808081200004800480048004888EA4A280000482868286808682858280012",
                    INIT_23 => X"0808080808080808080808080808082800680069000008000D0D080808080808",
                    INIT_24 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_25 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_26 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_27 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_28 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_29 => X"92E892E825129D8D89B2E050F2E15892E892E825090D0D080808080808080808",
                    INIT_2A => X"008950F2E15878082800020028000021259D8D01259D8D020212099D8D129D8D",
                    INIT_2B => X"C88858C150C88858011289F2005092E101D2E15889017180087892E88858C9F2",
                    INIT_2C => X"00000D0D08080808080808082800000D0D080808080808080808080808281271",
                    INIT_2D => X"CB8A8BA3A30383538008528008F2E2580AD2E088700808890928006800690000",
                    INIT_2E => X"12C202F2E878885870885848002812700050B2E38B128B7000CB508B51D2E3D2",
                    INIT_2F => X"78C858F3E893E893E893E850C85812000000000D0D0008080808080808080808",
                    INIT_30 => X"C85878C858680800680800680800D3C85828A00878C8580028A008680028A008",
                    INIT_31 => X"0000000000000000000000000000000000000000000000000000000028A00878",
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
                   INITP_00 => X"DCFD9C855277FA7FF9FF1FB65D7FF5BE7FFF33BBDBFB0603252A90C0D2492667",
                   INITP_01 => X"FFFFFFFFF9AE083A9E03BBFFFE78000235400BB75B73BD9DCCEA67FFFFFF35D6",
                   INITP_02 => X"00C102083861845B77FCF1059BFE7883BFFFCFC00009A00008317CA68000139F",
                   INITP_03 => X"5B1F66FD6D627FFFFFFFFFFFB789F85F5BF30FFF72C94CD18314D86800000000",
                   INITP_04 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD3FFEAA77A77D00BF4C6F8B137C",
                   INITP_05 => X"9543E7FFF48FA5850004487F4FFE7FFF005A426192FF89C4AC4951FFFFFFFFFF",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000000000925B6499C",
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
