----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:50:07 04/14/2014 
-- Design Name: 
-- Module Name:    tdc_trig_res - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tdc_trig_res is
  port(
    clk           : in  std_logic;
    tdc_tr_strobe : in  std_logic;
    tdc_tr_mux    : in  std_logic_vector(1 downto 0);
    tdc_enc       : out std_logic);
end tdc_trig_res;

architecture Behavioral of tdc_trig_res is
  
  signal tr_en      : std_logic;
  signal en_counter : std_logic_vector (1 downto 0) := "00";
  signal old_strobe : std_logic;

begin

  tr_en_process : process (clk)
  begin
    if rising_edge(clk) then
      old_strobe <= tdc_tr_strobe;
      if (old_strobe = '0' and tdc_tr_strobe = '1') then
        tr_en <= '1';
      elsif en_counter = "11" then
        tr_en <= '0';
      end if;
    end if;
  end process;

  tr_counter_process : process(clk)
  begin
    if rising_edge(clk) then
      if tr_en = '1' then
        if en_counter = "11" then
          en_counter <= "00";
        else
          en_counter <= en_counter + 1;
        end if;
      end if;
    end if;
  end process;

  trig_res_process : process(clk)
  begin
    if rising_edge(clk) then
      case en_counter (1 downto 0) is
        when "01"   => tdc_enc <= '1';
        when "10"   => tdc_enc <= tdc_tr_mux(1);
        when "11"   => tdc_enc <= tdc_tr_mux(0);
        when "00"   => tdc_enc <= '0';
        when others => tdc_enc <= '0';
      end case;
    end if;
  end process;
  
end Behavioral;

