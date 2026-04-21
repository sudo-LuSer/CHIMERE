library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

entity write_txt_file is
    generic (
        file_name : string := "resultat.txt"
    );
    port (
        clk        : in std_logic;
        data_valid : in std_logic;
        data_in    : in std_logic_vector(7 downto 0)
    );
end write_txt_file;

architecture Behavioral of write_txt_file is
begin
    process(clk)
        file out_file : text open write_mode is file_name;
        variable out_line : line;
        variable char : character;
    begin
        if rising_edge(clk) then
        
            if data_valid = '1' then
                char := character'val(to_integer(unsigned(data_in)));
                write(out_line, char);
                writeline(out_file, out_line);
            end if;
        end if;
    end process;
end Behavioral;
