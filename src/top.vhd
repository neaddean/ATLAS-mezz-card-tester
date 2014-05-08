----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:39:50 01/31/2014 
-- Design Name: 
-- Module Name:    top - Behavioral 
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
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.common.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity top is
  port (uart_rx                      : in    std_logic;
        uart_tx                      : out   std_logic;
        clk100                       : in    std_logic;
        Led                          : out   std_logic_vector (7 downto 0);
        sw                           : in    std_logic_vector (7 downto 0);
        I2C_SDA1, I2C_SCL1           : inout std_logic;
        I2C_SDA2, I2C_SCL2           : inout std_logic;
        PWR_ON                       : out   std_logic;
        JTAG_TMS, JTAG_TCK, JTAG_TDO : out   std_logic;
        JTAG_TDI                     : in    std_logic;
        TDC_CLK_P, TDC_CLK_N         : out   std_logic;
        TDC_ENC_P, TDC_ENC_N         : out   std_logic;
        TDC_SER_P, TDC_SER_N         : in    std_logic;
        TDC_STROBE_P, TDC_STROBE_N   : in    std_logic;
        ASD_STROBE_P, ASD_STROBE_N   : out   std_logic);
end top;

architecture Behavioral of top is

  component uart_top is
    port (
      clk                          : in  std_logic;
      uart_tx                      : out std_logic;
      uart_rx                      : in  std_logic;
      LED                          : out std_logic_vector (7 downto 0);
      sw                           : in  std_logic_vector (7 downto 0);
      DRIVE_SCL, DRIVE_SDA         : out std_logic;
      I2C_SDA, I2C_SCL             : in  std_logic;
      I2C_mux_signal               : out std_logic_vector (2 downto 0);
      PWR_ON                       : out std_logic;
      JTAG_TMS, JTAG_TCK, JTAG_TDO : out std_logic;
      JTAG_TDI                     : in  std_logic;
      tdc_tr_strobe                : out std_logic;
      tdc_tr_mux                   : out std_logic_vector(1 downto 0);
      fifo_flags                   : in  std_logic_vector(1 downto 0);
      fifo_rd_en, fifo_reset       : out std_logic;
      fifo_d_in                    : in  std_logic_vector(7 downto 0);
      asd_strobe_period_sel        : out std_logic);
  end component;

  component clk_gen_25_40
    port
      (
        clk100 : in  std_logic;
        clk25  : out std_logic;
        clk40  : out std_logic;
        clk40n : out std_logic);
  end component;

  component tdc_trig_res
    port(
      clk           : in  std_logic;
      tdc_tr_strobe : in  std_logic;
      tdc_tr_mux    : in  std_logic_vector;
      tdc_enc       : out std_logic);
  end component;

  component tdc_ser_fifo is
    port(
      clk, rd_clk : in  std_logic;
      tdc_ser     : in  std_logic;
      fifo_reset  : in  std_logic;
      fifo_flags  : out std_logic_vector(1 downto 0);
      fifo_d_out  : out std_logic_vector(7 downto 0);
      fifo_rd_en  : in  std_logic);
  end component;

  component asd_strobe is
    port (clk               : in  std_logic;
          asd_strobe_signal : out std_logic;
          period_sel        : in  std_logic_vector(7 downto 0));
  end component;

  signal DRIVE_SDA1, DRIVE_SCL1 : std_logic;
  signal DRIVE_SDA2, DRIVE_SCL2 : std_logic;

  -- Signals used for the I2C mux

  signal I2C_mux_signal       : std_logic_vector (2 downto 0);
  signal SDA, SCL             : std_logic;
  signal DRIVE_SDA, DRIVE_SCL : std_logic;

  signal clk25        : std_logic;
  signal clk40        : std_logic;
  signal clk40n       : std_logic;
  signal clk40_diff_s : std_logic;

  signal tdc_enc       : std_logic := '0';
  signal tdc_tr_strobe : std_logic := '0';
  signal tdc_tr_mux    : std_logic_vector (1 downto 0);

  signal tdc_ser    : std_logic;
  signal tdc_strobe : std_logic;

  signal fifo_reset, fifo_rd_en : std_logic;
  signal fifo_d_out             : std_logic_vector(7 downto 0);
  signal fifo_flags             : std_logic_vector(1 downto 0);

  signal asd_strobe_period_sel : std_logic_vector(7 downto 0);
  signal asd_strobe_signal     : std_logic;
  
begin

  clk_gen : clk_gen_25_40
    port map (
      clk100 => clk100,
      clk25  => clk25,
      clk40  => clk40,
      clk40n => clk40n);

  clk40_forward : ODDR2
    generic map(
      DDR_ALIGNMENT => "NONE",  -- Sets output alignment to "NONE", "C0", "C1" 
      INIT          => '0',  -- Sets initial state of the Q output to '0' or '1'
      SRTYPE        => "SYNC")  -- Specifies "SYNC" or "ASYNC" set/reset
    port map (
      Q  => clk40_diff_s,               -- 1-bit output data
      C0 => clk40,                      -- 1-bit clock input
      C1 => clk40n,                     -- 1-bit clock input
      CE => '1',                        -- 1-bit clock enable input
      D0 => '1',             -- 1-bit data input (associated with C0)
      D1 => '0',             -- 1-bit data input (associated with C1)
      R  => '0',                        -- 1-bit reset input
      S  => '0'                         -- 1-bit set input
      );

  lvds_clk : OBUFDS
    port map (
      I  => clk40_diff_s,
      O  => TDC_CLK_P,
      OB => TDC_CLK_N);

  lvds_enc : OBUFDS
    port map (
      I  => tdc_enc,
      O  => TDC_ENC_P,
      OB => TDC_ENC_N);

  lvds_asd_strobe : OBUFDS
    port map (
      I  => asd_strobe_signal,
      O  => ASD_STROBE_P,
      OB => ASD_STROBE_N);

  lvds_ser : IBUFDS
    port map (
      O  => tdc_ser,
      I  => TDC_SER_P,
      IB => TDC_SER_N);

  lvds_strobe : IBUFGDS
    port map (
      O  => tdc_strobe,
      I  => TDC_STROBE_P,
      IB => TDC_STROBE_N);

  I2C_SDA1 <= '0' when DRIVE_SDA1 = '0' else 'Z';
  I2C_SCL1 <= '0' when DRIVE_SCL1 = '0' else 'Z';
  I2C_SDA2 <= '0' when DRIVE_SDA2 = '0' else 'Z';
  I2C_SCL2 <= '0' when DRIVE_SCL2 = '0' else 'Z';


  i2c_multiplexer : process (clk25)
  begin
    if rising_edge(clk25) then
      case I2C_mux_signal is
        when "000" => SDA <= I2C_SDA1;
                      SCL        <= I2C_SCL1;
                      DRIVE_SDA1 <= DRIVE_SDA;
                      DRIVE_SCL1 <= DRIVE_SCL;
        when "001" => SDA <= I2C_SDA2;
                      SCL        <= I2C_SCL2;
                      DRIVE_SDA2 <= DRIVE_SDA;
                      DRIVE_SCL2 <= DRIVE_SCL;
        when others => null;
      end case;
    end if;
  end process i2c_multiplexer;


  -- instance "uart_top_1"
  uart_top_1 : entity work.uart_top
    port map (
      clk                   => clk25,
      uart_tx               => uart_tx,
      uart_rx               => uart_rx,
      LED                   => Led,
      sw                    => sw,
      DRIVE_SCL             => DRIVE_SCL,
      DRIVE_SDA             => DRIVE_SDA,
      SDA                   => SDA,
      SCL                   => SCL,
      I2C_mux_signal        => I2C_mux_signal,
      PWR_ON                => PWR_ON,
      JTAG_TMS              => JTAG_TMS,
      JTAG_TCK              => JTAG_TCK,
      JTAG_TDO              => JTAG_TDO,
      JTAG_TDI              => JTAG_TDI,
      tdc_tr_strobe         => tdc_tr_strobe,
      tdc_tr_mux            => tdc_tr_mux,
      fifo_flags            => fifo_flags,
      fifo_rd_en            => fifo_rd_en,
      fifo_reset            => fifo_reset,
      fifo_d_in             => fifo_d_out,
      asd_strobe_period_sel => asd_strobe_period_sel);

  tdc_trig_res_1 : tdc_trig_res
    port map (
      clk           => clk40,
      tdc_tr_strobe => tdc_tr_strobe,
      tdc_tr_mux    => tdc_tr_mux,
      tdc_enc       => tdc_enc);

  tdc_fifo : tdc_ser_fifo
    port map (
      clk        => tdc_strobe,
      rd_clk     => clk25,
      tdc_ser    => tdc_ser,
      fifo_reset => fifo_reset,
      fifo_flags => fifo_flags,
      fifo_d_out => fifo_d_out,
      fifo_rd_en => fifo_rd_en);

  asd_strobe_1 : asd_strobe
    port map (
      clk               => clk25,
      asd_strobe_signal => asd_strobe_signal,
      period_sel        => asd_strobe_period_sel);

end Behavioral;

