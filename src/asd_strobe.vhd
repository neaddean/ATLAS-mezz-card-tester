----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:26:29 05/08/2014 
-- Design Name: 
-- Module Name:    asd_strobe - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity asd_strobe is
  port (clk               : in  std_logic;
        asd_strobe_signal : out std_logic;
        period_sel        : in  std_logic_vector(7 downto 0));
end asd_strobe;

architecture Behavioral of asd_strobe is

  signal counter : std_logic_vector(7 downto 0) := (others => '0');
  
begin
  
  main_proc : process (clk)
  begin
    if rising_edge(clk) then
      if not (period_sel = (period_sel'range => '0')) then
        counter <= counter + 1;
        if (counter = period_sel) then
          asd_strobe_signal <= '1';
          counter           <= (others => '0');
        else
          asd_strobe_signal <= '0';
        end if;
      end if;
    end if;
  end process;

end Behavioral;

