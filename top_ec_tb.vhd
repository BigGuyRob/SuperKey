----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/05/2023 04:13:31 PM
-- Design Name: 
-- Module Name: top_ec_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_ec_tb is
--  Port ( );
end top_ec_tb;

architecture Behavioral of top_ec_tb is
    component top_ec is
    port(TXD, clk : in std_logic;
         sw_input : in std_logic;
         charRec : out std_logic_vector (7 downto 0);
         charSend : in std_logic_vector(7 downto 0);
         CTS, RTS, RXD : out std_logic);
    end component;
    signal TXD, clk :  std_logic;
    signal sw_input :  std_logic;
    signal charRec :  std_logic_vector (7 downto 0);
    signal charSend :  std_logic_vector(7 downto 0);
    signal CTS, RTS, RXD :  std_logic;
begin
    bluetooth: top_ec
    port map(TXD => TXD,
             clk => clk,
             charSend => charSend,
             sw_input => sw_input, --select the echo_charSend
             charRec => charRec,
             CTS => CTS,
             RTS => RTS,
             RXD => RXD);

    clock_gen:process
    begin
        clk <= '1';
        wait for 4ns;
        clk <= '0';
        wait for 4ns;
    end process;
    
    
    stim:process
    begin
        sw_input <= '1'; --send echoChar
        charRec <= "11110000"; --should see TXD be charRec
        wait for 8ns;
        sw_input<= '0'; --send sendChar
        charSend <= "11001100"; --should see TXD be charSend
        wait for 8ns;
        
    end process;
end Behavioral;
