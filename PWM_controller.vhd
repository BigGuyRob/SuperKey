----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/29/2023 11:17:34 PM
-- Design Name: 
-- Module Name: PWM_controller - Behavioral
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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.round;

entity PWM_controller is
port (
   clk: in std_logic; -- 125MHz PWM frequency
   input_angle : in integer; 
   pwm_out: out std_logic -- PWM signal out 
  );
end PWM_controller;

architecture Behavioral of PWM_controller is
    --TOWER PRO SG90 Servo Specs
    constant clk_hz : real := 125.0e6; --125MHz 
    constant pulse_hz : real := 50.0; -- Tower Pro SG90 refresh rate
    constant min_pulse : real := 500.0; -- TowerPro SG90 min pulse in microseconds
    constant max_pulse : real := 2500.0; -- TowerPro SG90 max pulse in microseconds
    constant step_bits : positive := 8; -- 0 to 255
    
    
    constant max_pwm_length : integer := integer(round(clk_hz / 1.0e6 * max_pulse)); 
    constant min_pwm_length : integer := integer(round(clk_hz / 1.0e6 * min_pulse));
    constant min_max_range_us : real := max_pulse - min_pulse; 
    constant step_us : real := min_max_range_us / real(step_bits - 1); --steps is min max range over the 8 bit resolution
    constant cycles_per_step : positive := integer(round(clk_hz / 1.0e6 * step_us));
    
    constant pwm_counter_max : integer := integer(round(clk_hz/pulse_hz)) - 1;
    signal pwm_counter : integer range 0 to pwm_counter_max;

    
    signal pwm_duty_cycle : integer range 0 to max_pwm_length;
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            pwm_duty_cycle <= input_angle * cycles_per_step + min_pwm_length;
            pwm_counter <= pwm_counter + 1;
            if pwm_counter = pwm_counter_max  then
                pwm_counter <= 0;
            end if;
            --ensure that I send the minimum pulse length
            if(pwm_counter < min_pwm_length) then
                pwm_out <= '1';
            end if;
            --ensure that I do not send over the max pulse length
            if(pwm_counter > max_pwm_length) then
                pwm_out <= '0';
            end if;
            
            if(pwm_counter < pwm_duty_cycle) then
                pwm_out <= '1';
            else
                pwm_out <= '0';
            end if;
        end if;
    end process;
end Behavioral;
