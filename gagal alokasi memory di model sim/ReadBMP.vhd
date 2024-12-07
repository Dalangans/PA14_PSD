library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use work.Array_pkg.all;

entity ReadBMP is
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
end entity ReadBMP;

architecture rtl of ReadBMP is    
    signal processing_done : std_logic;   -- Processing completion flag
    signal see             : std_logic_vector(7 downto 0);

    -- Helper function to convert std_logic_vector to string
    function to_string(slv: std_logic_vector) return string is
        variable result: string(1 to slv'length);
    begin
        for i in slv'range loop
            if slv(i) = '1' then
                result(slv'length - i) := '1';
            else
                result(slv'length - i) := '0';
            end if;
        end loop;
        return result;
    end function;
    
begin
    process (clk)
        type char_file is file of character; -- Define BMP file type
        file bmp_file : char_file open read_mode is "input.bmp";
        variable image_data   : image_type;
        variable header       : header_type;
        variable image_width  : integer;
        variable image_height : integer;
        variable padding      : integer;
        variable char         : character;
        variable blue, green, red : std_logic_vector(7 downto 0);

    begin
        if rising_edge(clk) and start = '1' then
            -- Read header
            for i in 0 to 53 loop
                read(bmp_file, header(i));
            end loop;

            header_out <= header;

            -- Perform validations (header ID, pixel offset, DIB size, etc.)
            assert header(0) = 'B' and header(1) = 'M'
                report "First two bytes are not 'BM'. This is not a BMP file"
                severity failure;

            -- Extract image width and height
            image_width := character'pos(header(18)) +
                           character'pos(header(19)) * 2**8 +
                           character'pos(header(20)) * 2**16 +
                           character'pos(header(21)) * 2**24;

            image_height := character'pos(header(22)) +
                            character'pos(header(23)) * 2**8 +
                            character'pos(header(24)) * 2**16 +
                            character'pos(header(25)) * 2**24;

            img_w_out <= image_width;
            img_h_out <= image_height;

            --report "Image dimensions - Width: " & integer'image(image_width) & 
                    --", Height: " & integer'image(image_height);

            -- Calculate padding per row
            padding := (4 - (image_width * 3) mod 4) mod 4;

            -- Read pixel data into the array
            for row_i in 0 to image_height - 1 loop
                for col_i in 0 to image_width - 1 loop
                    -- Read and store blue pixel
                    read(bmp_file, char);
                    blue := std_logic_vector(to_unsigned(character'pos(char), 8));
                    image_data(row_i)(col_i).blue := blue;

                    -- Read and store green pixel
                    read(bmp_file, char);
                    green := std_logic_vector(to_unsigned(character'pos(char), 8));
                    image_data(row_i)(col_i).green := green;

                    -- Read and store red pixel
                    read(bmp_file, char);
                    red := std_logic_vector(to_unsigned(character'pos(char), 8));
                    image_data(row_i)(col_i).red := red;

                    -- Debug output for each pixel
                    --report "Blue: " & to_string(blue) &
                            --", Green: " & to_string(green) &
                            --", Red: " & to_string(red);
                end loop;

                -- Discard padding bytes at the end of each row
                for pad_i in 1 to padding loop
                    read(bmp_file, char);
                end loop;
            end loop;

            -- Output image data
            image_out <= image_data;
            see <= image_data(0)(0).red;

            -- Indicate processing completion
            write_en <= '1';
            processing_done <= '1';
            done <= '1';

            -- Close the BMP file
            file_close(bmp_file);
        end if;
    end process;
end architecture rtl;
