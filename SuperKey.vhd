----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2023 11:44:11 PM
-- Design Name: 
-- Module Name: SuperKey - Behavioral
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


entity SuperKey is
    port(clk, btn : in std_logic;
         led : out std_logic_vector(3 downto 0);
         PWM_OUT1,PWM_OUT2,PWM_OUT3,PWM_OUT4 : out std_logic; --PMOD_CON3 OUT Signals
         COLUMN : out std_logic_vector(3 downto 0); --PMOD_KEYPAD OUT
         ROW : in std_logic_vector(3 downto 0); --PMOD_KEYPAD IN
         CTS, RTS, RXD : out std_logic; --PMOD BT2 OUT
         TXD : in std_logic); --PMOD BT2
end SuperKey;

architecture Behavioral of SuperKey is
    component Con3_Controller is
    port(clk : in std_logic;
         servo_angle : integer;
         PWM_OUT1 : out std_logic;
         PWM_OUT2 : out std_logic;
         PWM_OUT3 : out std_logic;
         PWM_OUT4 : out std_logic);
    end component;
    
    component pmod_keypad is
    port(COLUMN : out std_logic_vector (3 downto 0);
         clk : in std_logic;
         ROW : in std_logic_vector(3 downto 0);
         key_out : out std_logic_vector(3 downto 0));
    end component;
    
    component top_ec is
    port(TXD, clk : in std_logic;
         sw_input : in std_logic;
         charRec : out std_logic_vector (7 downto 0);
         charSend : in std_logic_vector(7 downto 0);
         CTS, RTS, RXD : out std_logic);
    end component;
    
    component binary_decoder is
    port (
        encoded_binary : in std_logic_vector(3 downto 0);
        decoded_ascii: out std_logic_vector(7 downto 0)
    );
    end component;
    
    component debounce is
    port(
        clk : in std_logic;
        btn : in std_logic;
        dbnc : out std_logic);
    end component;
    
    component clock_divider is
    generic(
        clock_frequency : INTEGER;
        division_integer : INTEGER);
    port(
        clk  : in std_logic;        
        div : out std_logic);     
    end component;
    
    

    
    signal charRec : std_logic_vector(7 downto 0);
    signal char : character; --for char buffer
    signal char2 : character; --for char buffer
    signal timedOutWaiting : std_logic := '0';
    signal charBufferCount : std_logic_vector(26 downto 0):= (others => '0'); --125MHz timer 125*10^6 clock cycles is 27 bits
    signal rst : std_logic;
    signal input_angle : integer := 1;
    type lock_state_type is (locked, unlocked);
    signal lock_state : lock_state_type := locked;
    type key_state_type is (idle, waiting_for_user_input, ack_user_input, sending_code, num1, num2, num3, num4, check, correct, incorrect);
    signal key_state : key_state_type := idle;
    --KEYPAD INPUT--
    signal code_num1 : std_logic_vector(3 downto 0);
    signal code_num2 : std_logic_vector(3 downto 0);
    signal code_num3 : std_logic_vector(3 downto 0);
    signal code_num4 : std_logic_vector(3 downto 0);
    signal kpd_pressed : std_logic;
    signal key : std_logic_vector(3 downto 0);
    --KEYPAD INPUT--
    --CODE--
    signal c_1 : std_logic_vector(3 downto 0) := "0110"; --6
    signal c_2 : std_logic_vector(3 downto 0) := "0001"; --1
    signal c_3 : std_logic_vector(3 downto 0) := "0101"; --5
    signal c_4 : std_logic_vector(3 downto 0) := "0001"; --1
    
    signal code_received_counter : std_logic_vector(3 downto 0) := (others => '0'); 
    signal decoded_char : std_logic_vector(3 downto 0);
    --CODE--
    signal led_div : std_logic;
    signal led_out : std_logic_vector(3 downto 0);
    signal led_counter : std_logic := '0';
    signal ack : std_logic := '0';
    signal sw_input : std_logic := '1'; --echo_charSend
    signal charSend : std_logic_vector(7 downto 0) := ("00100100");
    signal received : std_logic := '0';
    signal encoded_binary : std_logic_vector(3 downto 0); 
    signal decoded_ascii : std_logic_vector(7 downto 0);
    signal watchdog_div : std_logic;
    signal watchdog_timer_counter: std_logic_vector(3 downto 0) := "0000";
    signal watchdog_timer_threshold : std_logic_vector(3 downto 0) := "0101"; --idk how long I want this threshold
    --char buffer--
    signal charBuff1 : character;
    signal charBuff2 : character;
    --char buffer--
    signal timeout : std_logic;
begin
    
    binary_decode: binary_decoder
    port map(encoded_binary => encoded_binary,
             decoded_ascii => decoded_ascii);
    dbnc_rst:debounce
    port map(clk => clk,
             btn => btn,
             dbnc => rst);
             
    bluetooth: top_ec
    port map(TXD => TXD,
             clk => clk,
             charSend => charSend,
             sw_input => sw_input, --select the echo_charSend
             charRec => charRec,
             CTS => CTS,
             RTS => RTS,
             RXD => RXD);
             
    lock:Con3_controller
    port map(clk => clk,
         servo_angle => input_angle,
         PWM_OUT1 => PWM_OUT1,
         PWM_OUT2 => PWM_OUT2,
         PWM_OUT3 => PWM_OUT3,
         PWM_OUT4 => PWM_OUT4);
    
    keypad: pmod_keypad
    port map(COLUMN => COLUMN,
             clk => clk,
             ROW => ROW,
             key_out => key);
             
    led_clk_div: clock_divider
    generic map(clock_frequency => 125000000, division_integer => 3) --I want a .33s period 
    port map(clk => clk,
             div => led_div);
             
    watchdog_clk_div: clock_divider
    generic map(clock_frequency => 125000000, division_integer => 1) --I want a 1s period 
    port map(clk => clk,
             div => watchdog_div);                   
                 
    
    process(clk)
        
    begin
        if(rising_edge(clk)) then
            if (rst = '1') then
                key_state <= idle;
                led_out <= "0000"; 
                lock_state <= locked;
            else
                lock_state <= locked;   
                --SuperKey--
                case key_state is
                    
                    when idle =>
                        led_out <= "0000";
                        char <= character'val(to_integer(unsigned(charRec)));
                        if(key = "0000") then
                            kpd_pressed <= '0';
                        end if;    
                        if(char = 'c') then 
                             --heres my entrance for my app to initiate protocol
                             code_received_counter <= (others => '0');
                             key_state <= waiting_for_user_input;
                             led_out <= "1000";
                             sw_input <= '1'; --echoChar
                        elsif(char = 's') then
                            key_state <= sending_code;     
                            code_received_counter <= (others => '0');
                            received <= '0';
                            sw_input <= '0'; --sendChar 
                        elsif NOT(key = "0000") then                               
                            code_num1 <= key;
                            key_state <= num1;
                            kpd_pressed <= '1';
                        else
                            key_state <= idle;       
                        end if;    
                    
                    when num1 =>
                    led_out <= "1000"; --set the LED indicator
                        if((key = "0000")) then
                            kpd_pressed <= '0';
                        elsif (NOT(key = "0000")) and kpd_pressed = '0' then
                            --All of the keys follow hex
                            --but 0 wont make sense 
                            --safes usually dont have letter codes
                            --so 0 = F = 1111, and A B C D E are unused
                            code_num2 <= key;
                            key_state <= num2;
                            kpd_pressed <= '1';
                        else
                            key_state <= num1;
                                
                        end if; 
                        
                    when num2 =>
                        led_out <= "1100"; --set the LED indicator
                        if((key = "0000")) then
                            kpd_pressed <= '0';
                        
                        elsif NOT(key = "0000") and kpd_pressed = '0' then
                            --All of the keys follow hex
                            --but 0 wont make sense 
                            --safes usually dont have letter codes
                            --so 0 = F = 1111, and A B C D E are unused
                            code_num3 <= key;
                            key_state <= num3;
                            kpd_pressed <= '1';
                        else
                            key_state <= num2;       
                        end if;
                        
                    when num3 =>
                        led_out <= "1110"; --set the LED indicator
                        if((key = "0000")) then
                            kpd_pressed <= '0';
                        
                        elsif NOT(key = "0000") and kpd_pressed = '0' then
                            --All of the keys follow hex
                            --but 0 wont make sense 
                            --safes usually dont have letter codes
                            --so 0 = F = 1111, and A B C D E are unused
                            code_num4 <= key;
                            key_state <= check;
                            kpd_pressed <= '1';
                        else
                            key_state <= num3;       
                        end if;        
                    
                    when check => --code check
                        led_out <= "1111"; --all numbers have been input
                        if (c_1 = code_num1) and (c_2 = code_num2)
                            and (c_3 = code_num3) and (c_4 = code_num4) then
                            key_state <= correct; --go to correct key state
                        else
                            key_state <= incorrect; --go to incorrect key state
                        end if;
                        
                    when correct => --correct
                        led_out <= "1111"; --these can stay lit up
                        lock_state <= unlocked;     
                        
                    when incorrect => --incorrect
                        led_out <= "1001";
                        lock_state <= locked;
                        
                    when sending_code =>
                        --CODE SETTING MODE INDICATOR--
                        if(led_counter = '1') then
                                led_out <= "1111";
                            else
                                led_out <= "0000"; 
                        end if;
                        --CODE SETTING MODE INDICATOR--
                        char <= character'val(to_integer(unsigned(charRec)));
                        sw_input <= '0'; --send what I want to send
                        --gonna use code_received_counter since its there
                        if(received = '1') then
                            if(char = 'a') then --wait for char to be a before continuing 
                                received <= '0';
                            end if;    
                        end if;
                        if(unsigned(code_received_counter) = 0) then
                                encoded_binary <= c_1;
                            elsif(unsigned(code_received_counter) = 1) then
                                encoded_binary <= c_2;
                              
                            elsif(unsigned(code_received_counter) = 2) then
                                encoded_binary <= c_3;
                                
                            elsif(unsigned(code_received_counter) = 3) then
                                encoded_binary <= c_4;
                        end if;
                        if(char = 'x' and received = '0') then
                            charSend <= decoded_ascii; -- convert num to 8-bit ASCII representation
                            received <= '1';
                            code_received_counter <= std_logic_vector(unsigned(code_received_counter) + 1);
                            --increment so we know what to be sending next                                            
                         end if;
                         if(unsigned(code_received_counter) = 5) then
                                key_state <= idle; --go back to idle
                                charSend <= "01111000"; --x
                                code_received_counter <= (others => '0');            
                                --reset this mf uh
                         end if; 
                         
                                  
                    when waiting_for_user_input => 
                        --here is where we are waiting for user input
                        char <= character'val(to_integer(unsigned(charRec)));
                        sw_input <= '1'; --send what I want to send
                        if(NOT(char = 'x') and NOT(char = 'c') and ack = '0') then
                            ack <= '1';
                        end if;
                        --CODE SETTING MODE INDICATOR--
                        if(led_counter = '1') then
                                led_out <= "1111";
                            else
                                led_out <= "0000"; 
                        end if;
                        --CODE SETTING MODE INDICATOR--
                        --PROTOCOL LOGIC--
                        
                        case char is 
                            when '1' =>
                                    decoded_char <= "0001";
                            when '2' =>
                                    decoded_char <= "0010";
                            when '3' =>
                                    decoded_char <= "0011";
                            when '4' =>
                                    decoded_char <= "0100";
                            when '5' =>
                                    decoded_char <= "0101";
                            when '6' =>
                                    decoded_char <= "0110";
                            when '7' =>
                                    decoded_char <= "0111";
                            when '8' =>
                                    decoded_char <= "1000";
                            when '9' =>
                                    decoded_char <= "1001";
                            when '0' =>
                                    decoded_char <= "0000";
                            when others =>
                                    decoded_char <= "0000";
                         end case;
                        if(ack = '1') then 
                        --if the char we get is not x or c which are the enter and exit tokens then
                        --decoded char will be the decoded character at the time ack was set to 1 since
                        --it is one cycle behind
                            if(unsigned(code_received_counter) = 0) then
                                c_1 <= decoded_char;
                            elsif(unsigned(code_received_counter) = 1) then
                                c_2 <= decoded_char;
                            elsif(unsigned(code_received_counter) = 2) then
                                c_3 <= decoded_char;
                            elsif(unsigned(code_received_counter) = 3) then
                                c_4 <= decoded_char;           
                            end if;
                            code_received_counter <= std_logic_vector(unsigned(code_received_counter) + 1);
                            key_state <= ack_user_input;    
                        end if;
                        --PROTOCOL LOGIC--
                       
                        
                    when ack_user_input => 
                        --here is where we are waiting for user input
                        --CODE SETTING MODE INDICATOR--
                        if(led_counter = '1') then
                                led_out <= "1111";
                            else
                                led_out <= "0000"; 
                        end if;
                        --CODE SETTING MODE INDICATOR--    
                        --PROTOCOL LOGIC--
                        char <= character'val(to_integer(unsigned(charRec)));
                        if((char = 'x')) then
                            ack <= '0';
                        end if;
                        if(ack <= '0') then
                            key_state <= waiting_for_user_input;
                            if(unsigned(code_received_counter) = 4) then
                                key_state <= idle;
                                code_received_counter <= (others => '0');
                                ack <= '0';
                            end if;
                        end if;
                        --PROTOCOL LOGIC--
                        
                        
                    when others =>
                        lock_state <= locked;
                        key_state <= idle;        
                end case;        
                --Superkey--
                --LOCK--
                case lock_state is 
                    when locked =>
                        input_angle <= 1;
                    when unlocked =>
                        input_angle <= 7;    
                end case;        
                --LOCK--
               
            led <= led_out;        
            end if; --rst
            
        end if;--rising edge clock
        
    end process;
    
    process(led_div)
    begin
        if(rising_edge(led_div)) then
            led_counter <= NOT(led_counter);--flip flop every second
        end if;
    end process;
    
    process(watchdog_div)
    begin
        if(rising_edge(watchdog_div)) then
            charBuff1 <= character'val(to_integer(unsigned(charRec)));
            charBuff2 <= charBuff1;
            --character buffer 
            if(charBuff1 = charBuff2) then
                watchdog_timer_counter <= std_logic_vector(unsigned(watchdog_timer_counter) + 1);
            else
                watchdog_timer_counter <= (others => '0');
                --reset to 0 since we have received data    
            end if;
            
            if(watchdog_timer_counter = watchdog_timer_threshold) then
                timeout <= '1';
                watchdog_timer_counter <= watchdog_timer_threshold;
            else
                timeout <= '0';    
            end if;
        end if;
    end process;
    
    
end Behavioral;
