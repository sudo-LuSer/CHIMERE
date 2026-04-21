----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/12/2026 07:46:31 PM
-- Design Name: 
-- Module Name: cpt_decl - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpt_decl is
    Port ( 
    clk,rst : in std_logic;
    decl : in std_logic;
    cpt : out std_logic_vector(3 downto 0)
    );
end cpt_decl;

architecture Behavioral of cpt_decl is

signal tmp : unsigned(3 downto 0);

begin

process (clk)
begin
    if (rst = '1') then
        tmp <= to_unsigned(0,4);
    elsif rising_edge(clk)then
        if decl = '1' then
            tmp <= tmp + 1;
        else 
            tmp <= tmp;
        end if;
    end if;
end process;

end Behavioral;
