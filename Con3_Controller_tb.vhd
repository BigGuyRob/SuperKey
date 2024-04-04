----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/06/2023 04:40:04 PM
-- Design Name: 
-- Module Name: Con3_Controller_tb - Behavioral
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

entity Con3_Controller_tb is
--  Port ( );
end Con3_Controller_tb;

architecture Behavioral of Con3_Controller_tb is
    Component Con3_Controller is
    port(clk : in std_logic;
         servo_angle : integer;
         PWM_OUT1 : out std_logic;
         PWM_OUT2 : out std_logic;
         PWM_OUT3 : out std_logic;
         PWM_OUT4 : out std_logic);
    end Component;
    signal clk : std_logic;
    signal servo_angle : integer;
    signal PWM_OUT1 : std_logic;
    signal PWM_OUT2 : std_logic;
    signal PWM_OUT3 : std_logic;
    signal PWM_OUT4 : std_logic;
begin
    clock_gen:process
    begin
        clk <= '1';
        wait for 4ns;
        clk <= '0';
        wait for 4ns;
    end process;
    con:Con3_Controller
    port map(clk => clk,
             servo_angle => servo_angle,
             PWM_OUT1 => PWM_OUT1,
             PWM_OUT2 => PWM_OUT2,
             PWM_OUT3 => PWM_OUT3,
             PWM_OUT4 => PWM_OUT4);
    
    stim: process
    begin
        servo_angle <= 1;
        wait for 1ms;
        servo_angle <= 7;
        wait for 1ms;
    end process;     

end Behavioral;
