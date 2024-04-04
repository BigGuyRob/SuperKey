----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Robert Reid
-- 
-- Create Date: 02/09/2023 07:25:41 PM
-- Design Name: 
-- Module Name: debounce - Behavioral
-- Project Name: 
-- Target Devices: xc7z010-clg400-1
-- Tool Versions: 
-- Description: 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity debounce is
    port(
        clk : in std_logic;
        btn : in std_logic;
        dbnc : out std_logic);
end debounce;

architecture Behavioral of debounce is
    constant threshold : integer := 2500000; --20ms = 200kns /8ns per cycle = 25000
    -- signal debouncer_shift_reg : std_logic_vector(1 downto 0);
    signal counter : std_logic_vector(21 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if(rising_edge(clk)) then
            --sample
            if(btn = '1') then
                if(unsigned(counter) > threshold) then
                    dbnc <= '1';
                else
                    counter <= std_logic_vector(unsigned(counter) + 1);
                    dbnc <= '0';
                end if;
            else
                counter <= (others => '0');
                dbnc <= '0';
            end if;
        end if;
    end process;

end Behavioral;
