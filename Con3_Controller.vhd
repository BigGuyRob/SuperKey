----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/29/2023 11:51:24 PM
-- Design Name: 
-- Module Name: Con3_Controller - Behavioral
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
use IEEE.NUMERIC_STD.ALL;


entity Con3_Controller is
    port(clk : in std_logic;
         servo_angle : integer;
         PWM_OUT1 : out std_logic;
         PWM_OUT2 : out std_logic;
         PWM_OUT3 : out std_logic;
         PWM_OUT4 : out std_logic);
end Con3_Controller;

architecture Behavioral of Con3_Controller is
    component PWM_controller is
        port (
           clk: in std_logic; 
           input_angle : integer; --0 to 7
           PWM_OUT: out std_logic -- PWM signal out with frequency of 10MHz
          );
     end component;
    
    
    signal div : std_logic;
begin

             
    pwm_port1:PWM_controller
    port map(clk => clk,
             input_angle => servo_angle,
             PWM_OUT => PWM_OUT1);
    
    pwm_port2:PWM_controller
    port map(clk => clk,
             input_angle => servo_angle,
             PWM_OUT => PWM_OUT2);
                      
    pwm_port3:PWM_controller
    port map(clk => clk,
             input_angle => servo_angle,
             PWM_OUT => PWM_OUT3);
             
    pwm_port4:PWM_controller
    port map(clk => clk,
             input_angle => 7, --locking this for testing THIS IS MY IP HAHAHAHHAHAHHAH
             PWM_OUT => PWM_OUT4);

end Behavioral;
