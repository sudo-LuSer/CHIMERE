----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/16/2026
-- Design Name: 
-- Module Name: tb_UART_loop - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench complet pour UART_loop avec UART_TX et UART_RX
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
use IEEE.numeric_std.all;

entity tb_UART_loop is
end tb_UART_loop;

architecture Behavioral of tb_UART_loop is

-- Composant read_int_file pour lire les données du fichier
component read_int_file is
generic (
    file_name:       string  := "default.txt";
    line_size:       integer := 32;
    symb_max_val :   integer := 3;
    data_size :      integer := 2
);
port(
    clk :        in  STD_LOGIC;
    rst :        in  std_logic;
    enable :     in  STD_LOGIC;
    stream_out : out STD_LOGIC_vector(data_size-1 downto 0);
    data_valid : out STD_LOGIC;
    eof :        out STD_LOGIC
);
end component;

component write_int_file is
    generic (
        log_file     : string  := "results.txt";
        frame_size   : integer := 203;
        symb_max_val : integer := 255;
        data_size    : integer := 8
    );
    port(
        CLK        : in std_logic;
        RST        : in std_logic;
        data_valid : in std_logic;
        data       : in std_logic_vector(data_size-1 downto 0)
    );
end component;

-- Composant UART_fifoed_send pour envoyer sur UART TX
component UART_fifoed_send is
Generic (
    fifo_size             : integer := 4096;
    fifo_almost           : integer := 4090;
    drop_oldest_when_full : boolean := False;
    asynch_fifo_full      : boolean := True;
    baudrate              : integer := 921600;
    clock_frequency       : integer := 100000000
);
Port (
    clk_100MHz : in  STD_LOGIC;
    reset      : in  STD_LOGIC;
    dat_en     : in  STD_LOGIC;
    dat        : in  STD_LOGIC_VECTOR (7 downto 0);
    TX         : out STD_LOGIC;
    fifo_empty : out STD_LOGIC;
    fifo_afull : out STD_LOGIC;
    fifo_full  : out STD_LOGIC
);
end component;

-- Composant UART_loop
component UART_loop is
Port (
    rst :    in STD_LOGIC;
    clk :    in STD_LOGIC;
    sw :     in std_logic_vector(1 downto 0);
    led :    out std_logic_vector(15 downto 0);
    i_uart : in STD_LOGIC;
    o_uart : out STD_LOGIC
);
end component;

-- Composant UART_recv pour recevoir sur UART RX
component UART_recv is
Port (
    clk    : in  STD_LOGIC;
    reset  : in  STD_LOGIC;
    rx     : in  STD_LOGIC;
    dat    : out STD_LOGIC_VECTOR (7 downto 0);
    dat_en : out STD_LOGIC
);
end component;

-- Signaux de test
signal rst : STD_LOGIC;
signal clk : std_logic := '0';

-- Signaux pour read_int_file
signal enable_read_byte : std_logic;
signal incoming_byte : std_logic_vector(7 downto 0);
signal eof_signal : std_logic;
signal counter : unsigned(15 downto 0);
signal enable : std_logic;
signal data_valid_file : std_logic;

-- Signaux UART TX (entrée vers UART_loop)
signal uart_tx_line : STD_LOGIC;
signal fifo_empty_tx : std_logic;
signal fifo_afull_tx : std_logic;
signal fifo_full_tx : std_logic;

-- Signaux UART_loop
signal sw : std_logic_vector(1 downto 0);
signal led : std_logic_vector(15 downto 0);
signal uart_loop_output : STD_LOGIC;

-- Signaux UART RX (sortie de UART_loop)
signal received_byte : std_logic_vector(7 downto 0);
signal received_dat_en : std_logic;

begin

-- Génération horloge et reset
rst <= '1', '0' after 131 ns;
clk <= not(clk) after 5 ns;  -- 100 MHz

enable <= '1';
sw <= "00";

-- Compteur pour générer enable_read_byte périodiquement
counters : process (clk, rst) begin
    if (rst = '1') then
        counter <= (others => '0');
        enable_read_byte <= '0';
    elsif (rising_edge(clk)) then
        if(enable = '1') then
            if(counter = 20000) then
                counter <= (others => '0');
                if(eof_signal = '0') then
                    enable_read_byte <= '1';
                else
                    enable_read_byte <= '0';
                end if;
            else
                counter <= counter + 1;
                enable_read_byte <= '0';
            end if;
        else
            enable_read_byte <= '0';
        end if;
    end if;
end process;

-- Lecture des données du fichier
input_file : read_int_file 
    generic map("data.txt", 1, 255, 8)
    port map(clk, rst, enable_read_byte, incoming_byte, data_valid_file, eof_signal);

-- UART TX : Envoie les données lues du fichier sur la ligne UART
uart_tx : UART_fifoed_send 
    generic map(
        fifo_size => 100,
        fifo_almost => 8,
        drop_oldest_when_full => false,
        asynch_fifo_full => True,
        baudrate => 115200,
        clock_frequency => 100000000
    )
    port map(
        clk_100MHz => clk,
        reset => rst,
        dat_en => data_valid_file,
        dat => incoming_byte,
        TX => uart_tx_line,
        fifo_empty => fifo_empty_tx,
        fifo_afull => fifo_afull_tx,
        fifo_full => fifo_full_tx
    );

-- UART_loop : Traite les données reçues
uut : UART_loop 
    port map(
        rst => rst,
        clk => clk,
        sw => sw,
        led => led,
        i_uart => uart_tx_line,
        o_uart => uart_loop_output
    );

-- UART RX : Reçoit les données en sortie de UART_loop
uart_rx : UART_recv 
    port map(
        clk => clk,
        reset => rst,
        rx => uart_loop_output,
        dat => received_byte,
        dat_en => received_dat_en
    );
    
write : write_int_file 
	 generic map(
		log_file  => "results.txt",
		frame_size   => 1,
		symb_max_val => 255,
		data_size    => 8
	 )
	 port map(
		CLK       => clk,
		RST        => rst,
		data_valid => received_dat_en,
		data       => received_byte
	 );

        
-- Process pour afficher les données reçues
display_received : process(clk)
begin
    if rising_edge(clk) then
        if received_dat_en = '1' then
            report "Byte reçu: " & integer'image(to_integer(unsigned(received_byte)));
        end if;
    end if;
end process;

end Behavioral;
