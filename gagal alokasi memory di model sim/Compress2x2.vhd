library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Array_pkg.all;

entity ImageCompressor is
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
end entity ImageCompressor;

architecture rtl of ImageCompressor is
begin
    process(clk)
    variable col_in     : integer;
    variable row_in     : integer;
    variable image_data : image_type;
    variable r, g, b    : integer;
    variable img_w_data : integer;
    variable img_h_data : integer;
    variable header     : header_type;
    
    begin
        if rising_edge(clk) and start = '1' then
            done <= '0';
            
            -- Set output dimensions
            img_w_data      := img_width_in / 2;
            img_h_data      := img_height_in / 2;
            img_width_out   <= img_w_data;
            img_height_out  <= img_h_data;

            -- header update
            header      := header_in;
            header(18) := character'val(img_w_data mod 256); -- Width LSB
            header(19) := character'val((img_w_data / 256) mod 256);
            header(22) := character'val(img_h_data mod 256); -- Height LSB
            header(23) := character'val((img_h_data / 256) mod 256);

            -- header size update
            header(34) := character'val((img_w_data * img_h_data * 3) mod 256); -- Image size LSB
            header(35) := character'val(((img_w_data * img_h_data * 3) / 256) mod 256);
            header(2)  := character'val(((img_w_data * img_h_data * 3 + 54) mod 256)); -- File size LSB
            header(3)  := character'val((((img_w_data * img_h_data * 3 + 54) / 256) mod 256));

            header_out <= header;
            -- Perform mean filtering over 2x2 pixel blocks
            for row_i in 0 to (img_h_data - 1) loop
                for col_i in 0 to (img_w_data - 1) loop
                    row_in := row_i * 2;
                    col_in := col_i * 2;

                    -- Calculate mean for each color channel
                    r := (to_integer(unsigned(image_in(row_in)(col_in).red)) +
                        to_integer(unsigned(image_in(row_in)(col_in + 1).red)) +
                        to_integer(unsigned(image_in(row_in + 1)(col_in).red)) +
                        to_integer(unsigned(image_in(row_in + 1)(col_in + 1).red))) / 4;

                    g := (to_integer(unsigned(image_in(row_in)(col_in).green)) +
                        to_integer(unsigned(image_in(row_in)(col_in + 1).green)) +
                        to_integer(unsigned(image_in(row_in + 1)(col_in).green)) +
                        to_integer(unsigned(image_in(row_in + 1)(col_in + 1).green))) / 4;

                    b := (to_integer(unsigned(image_in(row_in)(col_in).blue)) +
                        to_integer(unsigned(image_in(row_in)(col_in + 1).blue)) +
                        to_integer(unsigned(image_in(row_in + 1)(col_in).blue)) +
                        to_integer(unsigned(image_in(row_in + 1)(col_in + 1).blue))) / 4;

                    -- Assign averaged values to output image
                    image_data(row_i)(col_i).red   := std_logic_vector(to_unsigned(r, 8));
                    image_data(row_i)(col_i).green := std_logic_vector(to_unsigned(g, 8));
                    image_data(row_i)(col_i).blue  := std_logic_vector(to_unsigned(b, 8));
                end loop;
            end loop;

            -- Assign the processed image data to the output
            image_out <= image_data;
            done <= '1';
        end if;
    end process;


end architecture rtl;