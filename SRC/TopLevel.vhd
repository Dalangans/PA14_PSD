library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

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
    type state is (idle, read_module, compress, write_module done);
    signal current_state, next_state: state := Idle;
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_state <= Idle;
            elsif start = '1' then
                current_state <= next_state;
            end if;
        end if;
    end process

    process(current_state, start)
    begin
    
    end process
    
    
end architecture rtl;