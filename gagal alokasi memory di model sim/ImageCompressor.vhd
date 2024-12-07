library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Array_pkg.all;

entity ImageCompressor is
    port (
        clk             : in std_logic;
        start           : in std_logic;
        op_code         : in std_logic_vector(7 downto 0);
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
end entity ImageCompressor;

architecture rtl of ImageCompressor is
    
    component Compress2x2 
        port (
            clk             : in std_logic;
            start           : in std_logic;
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

    component Compress3x3 
        port (
            clk             : in std_logic;
            start           : in std_logic;
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

    component Compress4x4 
        port (
            clk             : in std_logic;
            start           : in std_logic;
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

    signal start_2x2    : std_logic := '0';
    signal start_3x3    : std_logic := '0';
    signal start_4x4    : std_logic := '0';
    signal done_compress: std_logic := '0';
    signal hder_cprs_in : header_type;
    signal width_out2x2, width_out3x3, width_out4x4         : integer   := 0;
    signal height_out2x2, height_out3x3, height_out4x4      : integer   := 0;
    signal header_out2x2,header_out3x3, header_out4x4       : header_type;
    signal img_data_out2x2, img_data_out3x3, img_data_out4x4: image_type;

begin
    x2_inst: Compress2x2
        port map(
            clk             => clk,
            start           => start_2x2,
            image_in        => image_in,
            header_in       => header_in,
            img_width_in    => img_width_in,
            img_height_in   => img_height_in,
            img_width_out   => width_out2x2,
            img_height_out  => height_out2x2,
            image_out       => img_data_out2x2,
            header_out      => header_out2x2,
            done            => done_compress
        );
    
    x3_inst: Compress3x3
        port map(
            clk             => clk,
            start           => start_3x3,
            image_in        => image_in,
            header_in       => header_in,
            img_width_in    => img_width_in,
            img_height_in   => img_height_in,
            img_width_out   => width_out3x3,
            img_height_out  => height_out3x3,
            image_out       => img_data_out3x3,
            header_out      => header_out3x3,
            done            => done_compress
        );

    x4_inst: Compress4x4
        port map(
            clk             => clk,
            start           => start_4x4,
            image_in        => image_in,
            header_in       => header_in,
            img_width_in    => img_width_in,
            img_height_in   => img_height_in,
            img_width_out   => width_out4x4,
            img_height_out  => height_out4x4,
            image_out       => img_data_out4x4,
            header_out      => header_out4x4,
            done            => done_compress
        );

    process(clk)
    begin
        if rising_edge(clk) and start = '1' then 
            case op_code is
                when "00000010" =>
                    start_2x2 <= '1';
                    img_width_out   <= width_out2x2;
                    img_height_out  <= height_out2x2;
                    image_out       <= img_data_out2x2;
                    header_out      <= header_out2x2;
                    done            <= done_compress;

                when "00000011" =>
                    start_3x3 <= '1';
                    img_width_out   <= width_out3x3;
                    img_height_out  <= height_out3x3;
                    image_out       <= img_data_out3x3;
                    header_out      <= header_out3x3;
                    done            <= done_compress;

                when "00000100" =>
                    start_4x4 <= '1';
                    img_width_out   <= width_out4x4;
                    img_height_out  <= height_out4x4;
                    image_out       <= img_data_out4x4;
                    header_out      <= header_out4x4;
                    done            <= done_compress;
                when others =>
                    null;
            end case;
        end if;
    end process;
end architecture rtl;