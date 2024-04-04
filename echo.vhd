----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Robert Reid 
-- 
-- Create Date: 03/17/2023 12:28:22 PM
-- Design Name: UART echo
-- Module Name: echo - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;


entity echo is
    port(clk, en, ready, newChar : in std_logic;
         charIn : in std_logic_vector(7 downto 0);
         send : out std_logic;
         charOut : out std_logic_vector(7 downto 0));
end echo;

architecture Behavioral of echo is
   type state_type is (idle, busyA, busyB, busyC);
   signal state : state_type := idle;
begin
    process(clk)
    begin
        if(rising_edge(clk)) then --on the rising edge of the clock when enable is 1 
            if(en = '1') then
                send <= '0'; -- preset outputs
                case state is
                    when idle => --items regarding idle state
                        if(newChar = '1') then
                            send <= '1'; --assert send = 1
                            charOut <= charIn;
                            state <= busyA; --TRANSITION TO state busy A
                        end if;
                        
                    when busyA => --items regarding busyA state
                        state <= busyB; --TRANSITION TO state to busyB;
                    
                    when busyB => 
                        send <= '0'; --change send to 0 
                        state <= busyC; --TRANSITION TO state busyC
                    
                    when busyC =>
                        if(ready = '1') then --CHECK FOR rdy = '1'
                            --Here we are waiting for the ready to come back from UART module
                            --I assume also waiting for btn to equal 0 so one cannot simply hold the button and have characters transmit
                            state <= idle; --TRANSITION back to idle
                        else
                            state <= busyC; --STAY AT BUSYC
                        end if;
                        
                    when others => --arbitrary catch all
                        state <= idle;
                        send <= '0';
                        
                end case;
            end if;
        end if;
    end process;

end Behavioral;