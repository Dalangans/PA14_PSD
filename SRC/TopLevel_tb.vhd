library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TopLevel_tb is
end entity TopLevel_tb;

architecture tb of TopLevel_tb is

    -- Component declaration for the DUT
    component TopLevel
        port (
            clk        : in std_logic;
            start      : in std_logic;
            rst        : in std_logic;
            op_code    : in std_logic_vector (3 downto 0);
            status     : out std_logic
        );
    end component;

    -- Signals to connect to DUT
    signal clk        : std_logic := '0';
    signal start      : std_logic := '0';
    signal rst        : std_logic := '1';
    signal op_code    : std_logic_vector (3 downto 0) := (others => '0');
    signal status     : std_logic;

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the DUT
    DUT: TopLevel
        port map (
            clk     => clk,
            start   => start,
            rst     => rst,
            op_code => op_code,
            status  => status
        );

    -- Clock generation process
    clk_gen: process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process clk_gen;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initial reset
        rst <= '1';
        wait for 20 ns;
        rst <= '0';

        -- Start signal activation
        start <= '1';
        op_code <= "0010"; -- Compression size = 2
        wait for 100 ns;
        start <= '0';

        -- Wait for the FSM to reach the done state (status = '1')
        wait until status = '1';

        -- Terminate the simulation after one FSM cycle
        report "Simulation completed successfully." severity note;
        assert false report "End of simulation" severity failure;
    end process stim_proc;

end architecture tb;
