library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Array_pkg.all;

entity TopLevel is
    port (
        clk        : in std_logic;
        start      : in std_logic;
        rst        : in std_logic;
        status     : out std_logic
    );
end entity TopLevel;

architecture rtl of TopLevel is

    component ReadBMP
        port (
            clk         : in std_logic;
            start       : in std_logic;
            done        : out std_logic;
            img_w_out   : out integer;
            img_h_out   : out integer;
            header_out  : out header_type;
            image_out   : out image_type;
            write_en    : out std_logic 
        );
    end component;

    component WriteBMP
        port (
            clk         : in std_logic;
            start       : in std_logic;
            done        : out std_logic;
            img_w_in    : in integer;
            img_h_in    : in integer;
            header_in   : in header_type;
            image_in    : in image_type
        );
    end component;

    signal write_en              : std_logic := '0';
    signal read_done, write_done : std_logic := '0';
    signal img_w_in, img_h_in    : integer := 0;
    signal start_r, start_wr     : std_logic;
    signal header_in_tp          : header_type;
    signal image_in_tp           : image_type;

    type state_type is (Idle, Reading, Writing, Done);
    signal current_state: state_type := Idle;

begin

    -- Instantiate ReadBMP
    read_inst: ReadBMP
        port map (
            clk         => clk,
            start       => start_r,
            done        => read_done,
            img_w_out   => img_w_in,
            img_h_out   => img_h_in,
            header_out  => header_in_tp,
            image_out   => image_in_tp,
            write_en    => write_en 
        );

    -- Instantiate WriteBMP
    write_inst: WriteBMP
        port map (
            clk         => clk,
            start       => start_wr,
            done        => write_done,
            img_w_in    => img_w_in,
            img_h_in    => img_h_in,
            header_in   => header_in_tp,
            image_in    => image_in_tp
        );
        
        proc_name: process(clk, rst)
        begin
            if rst = '1' then
                current_state <= idle;
                write_en <= '0';
            elsif rising_edge(clk) then
                case current_state is
                    when idle =>
                        write_en <= '0';
                        if start = '1' then
                            start_r <= '1';
                        end if;
                        current_state <= reading;

                    when reading =>
                        start_r <='0';
                        current_state <= writing;

                    when writing =>
                        start_wr <='1';
                        if write_done = '1' then
                            current_state <= done;
                        end if;
                    
                    when done =>
                        status <= '1';
                end case;
            end if;
        end process proc_name;
end architecture rtl;
