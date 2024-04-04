library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use IEEE.math_real.all;
    --use IEEE.math_real."log2";

entity clock_divider is
    generic(
        clock_frequency : INTEGER;
        division_integer : INTEGER);
    port(
        clk  : in std_logic;        
        div : out std_logic);     
end clock_divider;

architecture behavior of clock_divider is
    constant counter_width : integer := integer(ceil(log2(real(clock_frequency)))); 
    --I did in fact find this on stack overflow but had to look at the friend chicken book to get the constant declaration
    signal counter : std_logic_vector((counter_width - 1)downto 0) := (others => '0');
    signal div_out : std_logic := '0';
begin

    process(clk)
    begin
    
        if rising_edge(clk) then
                -- count one full led period (1 Hz)
                -- if 125MHz is 124999999 then half would be 2Hz
                if (unsigned(counter) < (clock_frequency/division_integer)) then
                    counter <= std_logic_vector(unsigned(counter) + 1);
                    div_out <= '0';
                else
                    counter <= (others => '0');
                    div_out <= '1';
                end if;            
            end if;
    end process;
    div <= div_out;
    
end behavior;