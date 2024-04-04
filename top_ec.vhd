----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Rob Reid
-- 
-- Create Date: 03/17/2023 07:18:04 PM
-- Design Name: Top Extra Credit Module Echo UART FSM
-- Module Name: top_ec - Behavioral
-- Project Name: ECHO UART FSM
-- Target Devices: XC7Z010CLG400-1, UART PMOD
-- Tool Versions: 
-- Description: 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_ec is
    port(TXD, clk : in std_logic;
         sw_input : in std_logic;
         charRec : out std_logic_vector (7 downto 0);
         charSend : in std_logic_vector(7 downto 0);
         CTS, RTS, RXD : out std_logic);
end top_ec;

architecture Structural of top_ec is
    component uart port (
    clk, en, send, rx, rst  : in std_logic;
    charSend                : in std_logic_vector(7 downto 0);
    ready, tx, newChar      : out std_logic;
    charRec                 : out std_logic_vector(7 downto 0)
    );
    end component;
    
    component clock_divider 
    generic(
        clock_frequency : INTEGER;
        division_integer : INTEGER);
    port(
        clk  : in std_logic;        
        div : out std_logic);     
    end component;
  
  
    component echo is
    port(clk, en, ready, newChar : in std_logic;
         charIn : in std_logic_vector(7 downto 0);
         send : out std_logic;
         charOut : out std_logic_vector(7 downto 0));
    end component;    
    
    signal rst : std_logic := '0';
    signal sender_btn : std_logic := '0';
    signal div : std_logic := '0';
    signal send : std_logic := '0';
    signal ready : std_logic := '0';
    signal charSend_o: std_logic_vector(7 downto 0) := (others => '0');
    signal echo_charSend: std_logic_vector(7 downto 0) := (others => '0');
    
    --these are outputs from the receiver which can be used to see the characters received 
    --from the UART module which is untouched in this lab except for the given test bench
    signal newChar : std_logic := '0'; --
    signal charRec_o : std_logic_vector(7 downto 0) := (others => '0');
begin         
    clk_div: clock_divider
    generic map(clock_frequency => 125000000, division_integer => 115200)
    port map(clk => clk,
             div => div);   
             
    my_uart:uart 
    port map(
            clk => clk,
            en => div,
            send => send,
            rx => TXD,
            rst => rst,
            charSend => charSend_o,
            ready => ready,
            tx => RXD,
            newChar => newChar,
            charRec => charRec_o);
     
    my_echo:echo
    port map(clk => clk, 
             en => div, 
             ready => ready, 
             newChar => newChar, --here is where we use the Rx side
             charIn => charRec_o, --rx side of uart module
             send => send, 
             charOut => echo_charSend);
             
       CTS <= '0';
       RTS <= '0';
       charRec <= charRec_o;
       with sw_input select charSend_o <=
        echo_charSend when '1',
        charSend when '0',
        charSend when others;
         
        
       --select either the input character or the character from echo
       
end Structural;

