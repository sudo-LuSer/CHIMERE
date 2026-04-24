library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_transmitter is
end tb_transmitter;

architecture behavior of tb_transmitter is

    component transmitter
        Port ( 
            rst : in STD_LOGIC;
            clk : in STD_LOGIC;  
            enable : in STD_LOGIC;
            stream_in : in STD_LOGIC_VECTOR(7 downto 0);
            stream_out : out STD_LOGIC_VECTOR(8 downto 0);
            data_valid : out std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal enable : std_logic := '0';
    signal stream_in : std_logic_vector(7 downto 0) := (others => '0');
    signal stream_out : std_logic_vector(8 downto 0);
    signal data_valid : std_logic;

    constant clk_period : time := 10 ns;

    -- 🔁 Séquence complète : 1 0 0 2 0 0 3 0 0 A B C
    type data_array is array (0 to 11) of std_logic_vector(7 downto 0);
    constant test_data : data_array := (
        x"31", -- '1'
        x"30", -- '0'
        x"30", -- '0'
        x"32", -- '2'
        x"30", -- '0'
        x"30", -- '0'
        x"33", -- '3'
        x"30", -- '0'
        x"30", -- '0'
        x"41", -- 'A'
        x"42", -- 'B'
        x"43"  -- 'C'
    );

begin

    uut: transmitter
        port map (
            clk => clk,
            rst => rst,
            enable => enable,
            stream_in => stream_in,
            stream_out => stream_out,
            data_valid => data_valid
        );

    -- Horloge
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    -- Stimulus
    stim_proc: process
    begin
        -- Reset
        wait for 20 ns;
        rst <= '0';
        wait for clk_period;

        -- Envoi des données
        for i in 0 to 11 loop
            stream_in <= test_data(i);
            enable <= '1';
            wait for clk_period;

            enable <= '0';
            wait for 10*clk_period;
        end loop;

        wait;
    end process;

end behavior;