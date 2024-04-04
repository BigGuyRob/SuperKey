library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity binary_decoder is
    port (
        encoded_binary : in std_logic_vector(3 downto 0);
         decoded_ascii: out std_logic_vector(7 downto 0)
    );
end binary_decoder;

architecture Behavioral of binary_decoder is
begin
        with encoded_binary select decoded_ascii <= 
           "00110000" when "0000",                
            "00110001" when "0001",
            "00110010" when "0010",              
            "00110011" when "0011",            
            "00110100" when "0100",          
            "00110101" when "0101",            
            "00110110" when "0110",         
            "00110111" when "0111",
            "00111000" when "1000",
            "00111001" when others;
end Behavioral;
