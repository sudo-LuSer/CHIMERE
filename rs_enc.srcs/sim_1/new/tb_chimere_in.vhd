library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_chimere_in is
end tb_chimere_in;

architecture sim of tb_chimere_in is

    component TX_CHIMERE
        Port ( 
            clk      : in  STD_LOGIC;
            rst      : in  STD_LOGIC;
            enable   : in  STD_LOGIC;
            data_in  : in  STD_LOGIC_VECTOR (7 downto 0);
            data_out : out STD_LOGIC_VECTOR (20 downto 0);
            ready    : out STD_LOGIC
        );
    end component;

    signal clk      : STD_LOGIC := '0';
    signal rst      : STD_LOGIC := '1';
    signal enable   : STD_LOGIC := '0';
    signal data_in  : STD_LOGIC_VECTOR(7 downto 0) := X"41";  -- lettre 'A'
    signal data_out : STD_LOGIC_VECTOR(20 downto 0);
    signal ready    : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns;

begin

    uut: TX_CHIMERE
        port map (
            clk      => clk,
            rst      => rst,
            enable   => enable,
            data_in  => data_in,
            data_out => data_out,
            ready    => ready
        );

    -- Horloge
    clk <= not clk after CLK_PERIOD/2;

    -- Souvenez-vous : clk, rst, enable, data_in, data_out, ready
    process
    begin
        -- Reset
        rst <= '1'; enable <= '0'; wait for 3*CLK_PERIOD;
        rst <= '0'; wait for CLK_PERIOD;
    
        -- Envoyer 'A'
        data_in <= X"41"; enable <= '1';
        wait until rising_edge(clk) and ready = '1' for 500*CLK_PERIOD;
        enable <= '0';
        wait for 2*CLK_PERIOD;
    
        -- Envoyer 'B'
        data_in <= X"42"; enable <= '1';
        wait until rising_edge(clk) and ready = '1' for 500*CLK_PERIOD;
        enable <= '0';
        wait for 2*CLK_PERIOD;
    
        -- Envoyer 'C'
        data_in <= X"43"; enable <= '1';
        wait until rising_edge(clk) and ready = '1' for 500*CLK_PERIOD;
        enable <= '0';
        wait for 2*CLK_PERIOD;
    
        wait;
    end process;

end sim;