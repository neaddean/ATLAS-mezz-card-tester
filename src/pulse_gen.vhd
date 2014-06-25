----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:00:49 06/03/2014 
-- Design Name: 
-- Module Name:    pulse_gen - Behavioral 
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

entity pulse_gen is
  port (clk           : in  std_logic;
        pulse_ctl     : in  std_logic;
        pulse_time    : in  std_logic_vector(7 downto 0);
        pulse_trigger : out std_logic);
end pulse_gen;

architecture Behavioral of pulse_gen is
  constant cnt_max : std_logic_vector               := X"FFF";
  signal tmr_en    : std_logic                      := '0';
  signal old_ctl   : std_logic;
  signal cnt       : std_logic_vector (11 downto 0) := (others => '0');
begin

  pulse_en_process : process(clk)
  begin
    if rising_edge(clk) then
      old_ctl <= pulse_ctl;
      if (old_ctl = '0' and pulse_ctl = '1') then
        tmr_en <= '1';
      elsif cnt = cnt_max then
        tmr_en <= '0';
      end if;
    end if;
  end process;

  tmr_process : process(clk)
  begin
    if rising_edge(clk) then
      if tmr_en = '1' then
        if cnt = cnt_max then
          cnt           <= (others => '0');
          pulse_trigger <= '0';
		  elsif cnt = "00" & pulse_time & "00" then
          pulse_trigger <= '1';
          cnt           <= cnt + 1;
        else
          cnt <= cnt + 1;
        end if;
      else
        pulse_trigger <= '0';
      end if;
    end if;
  end process;

end Behavioral;

