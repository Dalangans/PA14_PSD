library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Package_pixel.all;

entity TopLevel is
    port (
        clk : in std_logic;
        op  : in std_logic_vector(7 downto 0);
        rst : in std_logic;
        start  : in std_logic;
        status : out std_logic
    );
end entity TopLevel;

architecture rtl of TopLevel is
    
    component ReadWrite 
        port (
            clk : in std_logic;
            op  : in std_logic_vector(7 downto 0);
            done_in : in std_logic
        );
    end component;

    type state is (idle, ReadWrite_module, Done);
    signal current_state: state := idle;

    signal op_top           : std_logic_vector(7 downto 0);
    signal done_flag_in     : std_logic;
    signal done_flag_out    : std_logic;
    signal start_done       : std_logic := '0';

begin
    -- Instantiate components in the concurrent region
    rdwr_inst : ReadWrite
        port map(
            clk => clk,
            op => op_top,
            done_in => done_flag_in
        );

    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_state <= idle;
                status <= '0';
                done_flag_in <= '1';
                start_done <= '0';
            else
                case current_state is
                    when idle =>
                        status <= '0';
                        if start = '1' and start_done = '0' then
                            current_state <= ReadWrite_module;
                        end if;

                    when ReadWrite_module =>
                        op_top <= op;
                        done_flag_in <= '0';
                        current_state <= Done;

                    when done =>
                        done_flag_in <= '1';
                        status <= '1';
                        start_done <= '1';
                        current_state <= idle; 
                end case;
            end if;
        end if;
    end process;
end architecture rtl;
