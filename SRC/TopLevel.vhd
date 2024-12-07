library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Array_pkg.all;

entity TopLevel is
    port (
        clk        : in std_logic;
        start      : in std_logic;
        rst        : in std_logic;
        op_code    : in std_logic_vector (3 downto 0);
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

    component ImageCompressor 
        port (
            clk             : in std_logic;
            start           : in std_logic;
            block_size      : in integer;
            image_in        : in image_type;
            header_in       : in header_type;
            img_width_in    : in integer;
            img_height_in   : in integer;
            img_width_out   : out integer;
            img_height_out  : out integer;
            image_out       : out image_type;
            header_out      : out header_type;
            done            : out std_logic
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

    signal done_component        : std_logic;
    signal write_en              : std_logic := '0';
    signal read_done, write_done : std_logic := '0';
    signal img_w_in_tp           : integer := 0;
    signal img_h_in_tp           : integer := 0;
    signal img_w_out_tp          : integer := 0;
    signal img_h_out_tp          : integer := 0;
    signal compress_size         : integer := 0;
    signal start_r               : std_logic;
    signal start_wr              : std_logic;
    signal start_comprs          : std_logic;
    signal header_in_tp          : header_type;
    signal header_out_tp         : header_type;
    signal image_in_tp           : image_type;
    signal image_out_tp          : image_type;

    type state_type is (Idle, Reading, compress, Writing, Done);
    signal current_state: state_type := Idle;

begin

    -- Instantiate ReadBMP
    read_inst: ReadBMP
        port map (
            clk         => clk,
            start       => start_r,
            done        => read_done,
            img_w_out   => img_w_in_tp,
            img_h_out   => img_h_in_tp,
            header_out  => header_in_tp,
            image_out   => image_in_tp,
            write_en    => write_en 
        );

    compr_inst : ImageCompressor
        port map(
            clk             => clk,
            start           => start_comprs,
            block_size      => compress_size,
            image_in        => image_in_tp,
            header_in       => header_in_tp,
            img_width_in    => img_w_in_tp,
            img_height_in   => img_h_in_tp,
            img_width_out   => img_w_out_tp,
            img_height_out  => img_h_out_tp,
            image_out       => image_out_tp,
            header_out      => header_out_tp,
            done            => done_component
        );

    -- Instantiate WriteBMP
    write_inst: WriteBMP
        port map (
            clk         => clk,
            start       => start_wr,
            done        => write_done,
            img_w_in    => img_w_out_tp,
            img_h_in    => img_h_out_tp,
            header_in   => header_out_tp,
            image_in    => image_out_tp
        );
        
        proc_name: process(clk, rst)
        begin
            if rst = '1' then
                current_state <= idle;
                start_r     <= '0';
                write_en    <= '0';
                start_comprs<= '0';
                start_wr    <= '0';
                status      <= '0';
            elsif rising_edge(clk) then
                case current_state is
                    when idle =>
                        start_r     <= '0';
                        write_en    <= '0';
                        start_comprs<= '0';
                        start_wr    <= '0';
                        status      <= '0';
                        start_comprs <= '0';
                        if start = '1' then
                            start_r <= '1';
                            current_state <= reading;
                        end if;

                    when reading =>
                        start_r <='0';
                        if read_done = '1' then
                            current_state <= compress;
                        end if;

                    when compress =>
                        start_comprs <= '1';
                        case op_code is
                            when "0010" => 
                                compress_size <= 2;
                            when "0011" =>
                                compress_size <= 3;
                            when "0100" =>
                                compress_size <= 4;
                            when others =>
                                null;
                        end case;
                        if done_component = '1' then
                            start_comprs <= '0';
                            start_wr <='1';
                            current_state <= writing;
                        end if;
                        report "Current state: " & state_type'image(current_state);
                        report "write_done signal: " & std_logic'image(write_done);

                        

                    when writing =>
                        if write_done = '1' then
                            start_wr <= '0';
                            current_state <= done;
                            report "Current state: " & state_type'image(current_state);
                            report "write_done signal: " & std_logic'image(write_done);

                        end if;
                    
                    when done =>
                        report "Current state: " & state_type'image(current_state);
                        report "write_done signal: " & std_logic'image(write_done);
                        status <= '1';
                end case;
            end if;
        end process proc_name;
end architecture rtl;
