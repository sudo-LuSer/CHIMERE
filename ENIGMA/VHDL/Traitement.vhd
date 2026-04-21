----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/09/2026 03:14:17 PM
-- Design Name: 
-- Module Name: Traitement - Behavioral
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

entity Traitement is
    Port ( 
       rst : in STD_LOGIC;
       clk : in STD_LOGIC;
       enable : in STD_LOGIC;
       stream_in : in STD_LOGIC_VECTOR(7 downto 0);
       stream_out : out STD_LOGIC_VECTOR(7 downto 0);
       dv_out_tb : out std_logic);
end Traitement;

architecture Behavioral of Traitement is

component Rotor is
    Port ( 
        clk : in std_logic;
        num_rot : in std_logic_vector(2 downto 0);
        data_in : in std_logic_vector(6 downto 0);
        dv_in : in std_logic;
        data_out : out std_logic_vector(6 downto 0);
        dv_out : out std_logic
    );
end component;

component Rotor_inv is
    Port ( 
        clk : in std_logic;
        num_rot : in std_logic_vector(2 downto 0);
        data_in : in std_logic_vector(6 downto 0);
        dv_in : in std_logic;
        data_out : out std_logic_vector(6 downto 0);
        dv_out : out std_logic
    );
end component;

component reflecteur is
    Port (
    data_in : in std_logic_vector(6 downto 0);
    clk : in std_logic;
    data_out : out std_logic_vector(6 downto 0));
end component;

component Bascule is
    Port ( 
        v_in,clk : in std_logic;
        v_out : out std_logic
    );
end component;

component plugboard is --rajouté ici pour le plugboard
    Port (
        clk : in std_logic;
        data_rotor_out : in std_logic_vector(7 downto 0);
        data_rotor_out_valid : in std_logic;
        data_plugboard_out : out std_logic_vector(7 downto 0);
        data_plugboard_out_valid : out std_logic
    );
end component;

signal tmp_1,tmp_2,tmp_3,tmp_4,tmp_5,tmp_6,tmp_7,dv_in_tb,dv_1,dv_2,rand_1,rand_2,rand_3    : std_logic := '0';
signal data_in_tb,tmp_out,tmp_in  : std_logic_vector(6 downto 0) := (others => '0');
signal data_out_tb,data_1,data_2,data_3,data_4,data_5,data_6 : std_logic_vector(6 downto 0);

--signaux pour le plugboard 
signal plugb1_data, plugb2_data : std_logic_vector(7 downto 0) := (others => '0');
signal plugb1_dv, plugb2_dv : std_logic := '0';

begin

DUT : Rotor
        port map (
            clk      => clk,
            num_rot => "011",
            --data_in  => data_in_tb,
            data_in => plugb1_data, --remplacé
            --dv_in => dv_in_tb,
            dv_in => plugb1_dv,  --remplacé
            dv_out => dv_1,
            data_out => data_1
        );
        
DUT2 : Rotor
        port map (
            clk      => clk,
            num_rot => "010",
            data_in  => data_1,
            dv_in => dv_1,
            dv_out => dv_2,
            data_out => data_2
        );   

DUT3 : Rotor
        port map (
            clk      => clk,
            num_rot => "001",
            data_in  => data_2,
            dv_in => dv_2,
            dv_out => dv_out_tb,
            data_out => data_3
        );
        
REF : reflecteur
    port map(
        data_in => data_3,
        clk => clk,
        data_out => data_4
    );
    
DUT3R : Rotor_inv
        port map (
            clk      => clk,
            num_rot => "001",
            data_in  => data_4,
            dv_in => dv_2,
            dv_out => rand_1,
            data_out => data_5
        );
        
DUT2R : Rotor_inv
        port map (
            clk      => clk,
            num_rot => "010",
            data_in  => data_5,
            dv_in => dv_1,
            dv_out => rand_2,
            data_out => data_6
        );
        
        
DUTR : Rotor_inv
        port map (
            clk      => clk,
            num_rot => "011",
            data_in  => data_6,
            dv_in => dv_in_tb,
            dv_out => rand_3,
            data_out => data_out_tb
        );
        
PLUGB_ALLER : plugboard
        port map(
            clk => clk,
            data_rotor_out => data_in_tb,
            data_rotor_out_valid => dv_in_tb,
            data_plugboard_out => plugb1_data,
            data_plugboard_out_valid => plugb1_dv
        );
        
PLUGB_RETOUR : plugboard
        port map(
            clk => clk,
            data_rotor_out => data_out_tb,
            data_rotor_out_valid => dv_out_tb,
            data_plugboard_out => plugb2_data,
            data_plugboard_out_valid => plugb2_dv
        );        
     

tempo_1 : Bascule
    Port map(
        clk => clk,
        --v_in => dv_in_tb,
        v_in => plug1_dv --remplacé
        v_out => tmp_1);

tempo_2 : Bascule
    Port map(
        clk => clk,
        v_in => tmp_1,
        v_out => tmp_2);

tempo_3 : Bascule
    Port map(
        clk => clk,
        v_in => tmp_2,
        v_out => tmp_3);    

tempo_4 : Bascule
    Port map(
        clk => clk,
        v_in => tmp_3,
        v_out => tmp_4);

tempo_5 : Bascule
    Port map(
        clk => clk,
        v_in => tmp_4,
        v_out => tmp_5);

tempo_6 : Bascule
    Port map(
        clk => clk,
        v_in => tmp_5,
        v_out => tmp_6);

tempo_7 : Bascule
    Port map(
        clk => clk,
        v_in => tmp_6,
        v_out => tmp_7);

tempo_8 : Bascule
    Port map(
        clk => clk,
        v_in => tmp_7,
        v_out => dv_out_tb);


end Behavioral;
