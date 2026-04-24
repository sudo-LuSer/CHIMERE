----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/24/2026 09:36:24 AM
-- Design Name: 
-- Module Name: control_sys - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_sys is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           compute_valid : out STD_LOGIC;
           eni_valid : in STD_LOGIC;
           ecc_valid : in STD_LOGIC;
           en_ecc    : out STD_LOGIC;
           en_eni    : out STD_LOGIC;
           en_in : in STD_LOGIC);
end control_sys;

architecture Behavioral of control_sys is

    type machine_state is (IDLE, ENIGMA_ENC, COMPUTE_ENIGMA, ECC, READY);
    signal compute_state : machine_state := IDLE;
    signal next_state    : machine_state;

begin

    process (compute_state, eni_valid, ecc_valid)
    begin
        next_state <= compute_state;  
        case compute_state is
            when IDLE =>
                next_state <= ENIGMA_ENC;
            when ENIGMA_ENC =>
                next_state <= COMPUTE_ENIGMA;
            when COMPUTE_ENIGMA =>
                if eni_valid = '1' then
                    next_state <= ECC;
                end if;
            when ECC =>
                if ecc_valid = '1' then
                    next_state <= READY;
                end if;
            when READY =>
                next_state <= IDLE;
        end case;
    end process;

    process(clk, rst)
    begin 
        if rst = '1' then 
            compute_state <= IDLE;
            en_eni <= '0'; 
            en_ecc <= '0';
        elsif rising_edge(clk) then 
            if en_in = '1' then 
                compute_state <= next_state; 
            end if;

            case next_state is  
                when IDLE =>
                    en_eni <= '0';
                    en_ecc <= '0';
                    compute_valid <= '0';
                when ENIGMA_ENC =>
                    en_eni <= '1';
                    en_ecc <= '0';
                    compute_valid <= '0';
                when COMPUTE_ENIGMA =>
                    en_eni <= '0';
                    en_ecc <= '0';
                    compute_valid <= '0';
                when ECC =>
                    en_eni <= '0';
                    en_ecc <= '1';
                    compute_valid <= '0';
                when READY =>
                    en_eni <= '0';
                    en_ecc <= '0';
                    compute_valid <= '1';
            end case;
        end if;  
    end process; 

end Behavioral;
