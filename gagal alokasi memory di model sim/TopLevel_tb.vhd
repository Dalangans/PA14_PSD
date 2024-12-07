library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TopLevel_tb is
end entity TopLevel_tb;

architecture tb of TopLevel_tb is

    -- Component declaration
    component TopLevel
        port (
            clk    : in std_logic;
            start  : in std_logic;
            rst    : in std_logic;
            status : out std_logic
        );
    end component;

    -- Signal declarations
    signal clk_tb    : std_logic := '0';
    signal start_tb  : std_logic := '0';
    signal rst_tb    : std_logic := '0';
    signal status_tb : std_logic;

    constant clk_period : time := 10 ns; -- Clock period of 10 ns

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: TopLevel
        port map (
            clk    => clk_tb,
            start  => start_tb,
            rst    => rst_tb,
            status => status_tb
        );

    -- Clock process
    clk_process: process
    begin
        while true loop
            clk_tb <= '0';
            wait for clk_period / 2;
            clk_tb <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stimulus_process: process
    begin
        -- Reset the system
        rst_tb <= '1';
        wait for 20 ns;
        rst_tb <= '0';

        -- Apply start signal
        start_tb <= '1';
        wait for 50 ns;
        start_tb <= '0';

        -- Observe the behavior
        wait for 100 ns;

        -- End simulation
        wait;
    end process;

end architecture tb;
