----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:39:33 04/16/2014 
-- Design Name: 
-- Module Name:    tdc_ser_fifo - Behavioral 
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
use IEEE.NUMERIC_STD.all;

use work.common.all;

entity tdc_ser_fifo is
  port(
    clk, rd_clk : in  std_logic;
    tdc_ser     : in  std_logic;
    fifo_reset  : in  std_logic;
    fifo_flags  : out std_logic_vector (1 downto 0);
    fifo_d_out  : out std_logic_vector(7 downto 0);
    fifo_rd_en  : in  std_logic);
end tdc_ser_fifo;

architecture Behavioral of tdc_ser_fifo is
  
  component data_fifo
    port (
      rst    : in  std_logic;
      wr_clk : in  std_logic;
      rd_clk : in  std_logic;
      din    : in  std_logic_vector(31 downto 0);
      wr_en  : in  std_logic;
      rd_en  : in  std_logic;
      dout   : out std_logic_vector(7 downto 0);
      full   : out std_logic;
      empty  : out std_logic);
  end component;

  signal read_state      : std_logic                     := '0';
  signal receive_counter : std_logic_vector(7 downto 0)  := (others => '0');
  signal temp_word       : std_logic_vector(31 downto 0) := (others => '0');

  signal wr_en                 : std_logic := '0';
  signal fifo_full, fifo_empty : std_logic;

begin

  fifo_flags <= fifo_full & fifo_empty;

  --wr_en <= read_state;

  det_proc : process(clk)
  begin
    if falling_edge(clk) then
      if read_state = '0' and tdc_ser = '1' then
        read_state <= '1';
      elsif read_state = '1' then
        receive_counter <= receive_counter + 1;

        if receive_counter = X"20" then
          wr_en           <= '1';
          read_state      <= '0';
          receive_counter <= (others => '0');
        else
          temp_word(31 downto 0) <= temp_word(30 downto 0) & tdc_ser;
        end if;
      else
        wr_en <= '0';
        temp_word <= (others => '0');
      end if;
    end if;
  end process;

  tdc_fifo : data_fifo
    port map (
      rst    => fifo_reset,
      wr_clk => clk,
      rd_clk => rd_clk,
      din    => temp_word,
      wr_en  => wr_en,
      rd_en  => fifo_rd_en,
      dout   => fifo_d_out,
      full   => fifo_full,
      empty  => fifo_empty);

end Behavioral;

