----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Robert Reid 
-- 
-- Create Date: 03/06/2023 05:58:34 PM
-- Design Name: 
-- Module Name: uart_tx - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity uart_tx is
    port(clk, en, send, rst : in std_logic;
         char : in std_logic_vector(7 downto 0);
         ready, tx : out std_logic);
end uart_tx;

architecture Behavioral of uart_tx is
    type state_type is (idle, data, stop, start);
    signal state : state_type := idle;
    signal char_reg : std_logic_vector(7 downto 0);
    signal count : std_logic_vector(2 downto 0) := "000";
begin
    process(clk)
    begin
        if(rising_edge(clk)) then
                if(rst = '1') then --if rst
                   char_reg <= (others => '0'); --reset everything
                   tx <= '1';
                   ready <= '1';
                   state <= idle;
                elsif(en = '1') then
                    ready <= '0';
                    tx <= '0'; --pre assign outputs
                    case(state) is
                        when idle => --items regarding itle state 
                            tx <= '1'; --drive line high while idling
                            ready <= '1'; --when in idle state ready is 1
                            if(send = '0') then state <= idle; --if send is 0 we stay here 
                            elsif(send = '1') then 
                                state <= start; ----TRANSITION TO start
                                char_reg <= char; --store char into register
                            end if;
                        
                        when start =>
                            tx <= '0'; --indicate start bit
                            state <= data;  
                              
                        when data => --items regarding data state
                            if(unsigned(count) < 7) then
                                tx <= char_reg(0); --sample from the MSB
                                char_reg <= '0' & char_reg(7 downto 1); --slide down
                                count <= std_logic_vector(unsigned(count) + 1);
                                state <= data;
                            else
                                state <= stop;
                                count <= (others => '0');
                            end if;
                            
                       when stop =>
                            tx <= '1'; -- indicate stop bit
                            state <= idle; --return to idle
                            
                       when others => --arbitrary catch all
                            tx <= '1';
                            ready <= '0';
                            state <= idle; 
                    end case;
                end if;
        end if;
    end process;
end Behavioral;
