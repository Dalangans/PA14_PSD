library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity ReadWrite is
    port (
        clk      : in std_logic;
        op       : in std_logic_vector(7 downto 0);
        done_in  : in std_logic
    );
end entity ReadWrite;

architecture rtl of ReadWrite is
    type header_type is array (0 to 53) of character;
    type pixel_type is record
        red   : std_logic_vector(7 downto 0);
        green : std_logic_vector(7 downto 0);
        blue  : std_logic_vector(7 downto 0);
    end record;

    type row_type is array (integer range <>) of pixel_type;
    type row_pointer is access row_type;
    type image_type is array (integer range <>) of row_pointer;
    type image_pointer is access image_type;

    constant KERNEL_SIZE : integer := 2; -- Size of the kernel

begin
    process (clk)
        type char_file is file of character;
        file bmp_file : char_file open read_mode is "input.bmp";
        file out_file : char_file open write_mode is "out.bmp";

        variable header       : header_type;
        variable image_width  : integer;
        variable image_height : integer;
        variable padding      : integer;
        variable row          : row_pointer;
        variable image        : image_pointer;
        variable filtered_image : image_pointer;
        variable char         : character;
        variable sum_red, sum_green, sum_blue : integer;
        variable count : integer;
    begin
        if rising_edge(clk) and done_in = '0' then
            -- Read BMP header
            for i in header_type'range loop
                read(bmp_file, header(i));
            end loop;

            -- Check BMP format
            assert header(0) = 'B' and header(1) = 'M'
                report "Not a BMP file" severity failure;

            -- Extract image dimensions
            image_width := character'pos(header(18)) +
                           character'pos(header(19)) * 2**8 +
                           character'pos(header(20)) * 2**16 +
                           character'pos(header(21)) * 2**24;

            image_height := character'pos(header(22)) +
                            character'pos(header(23)) * 2**8 +
                            character'pos(header(24)) * 2**16 +
                            character'pos(header(25)) * 2**24;

            report "Image Width: " & integer'image(image_width) &
                    ", Image Height: " & integer'image(image_height);

            -- Calculate padding for each row
            padding := (4 - (image_width * 3) mod 4) mod 4;

            -- Allocate memory for image
            image := new image_type(0 to image_height - 1);
            filtered_image := new image_type(0 to image_height - 1);

            -- Validate memory allocation
            assert image /= null report "Image pointer not allocated" severity failure;
            assert filtered_image /= null report "Filtered image pointer not allocated" severity failure;

            for row_i in 0 to image_height - 1 loop
                row := new row_type(0 to image_width - 1);

                for col_i in 0 to image_width - 1 loop
                    -- Read blue pixel
                    read(bmp_file, char);
                    row(col_i).blue := std_logic_vector(to_unsigned(character'pos(char), 8));

                    -- Read green pixel
                    read(bmp_file, char);
                    row(col_i).green := std_logic_vector(to_unsigned(character'pos(char), 8));

                    -- Read red pixel
                    read(bmp_file, char);
                    row(col_i).red := std_logic_vector(to_unsigned(character'pos(char), 8));
                end loop;

                -- Discard padding
                for i in 1 to padding loop
                    read(bmp_file, char);
                end loop;

                image(row_i) := row;
            end loop;

            -- Apply mean filtering
            for row_i in 1 to image_height - 2 loop
                for col_i in 1 to image_width - 2 loop
                    report "Processing pixel at row " & integer'image(row_i) & ", col " & integer'image(col_i);

                    sum_red := 0;
                    sum_green := 0;
                    sum_blue := 0;
                    count := 0;

                    -- Compute mean of neighboring pixels
                    for i in -1 to 1 loop
                        for j in -1 to 1 loop
                            if (row_i + i >= 0 and row_i + i < image_height) and
                            (col_i + j >= 0 and col_i + j < image_width) then
                                sum_red := sum_red + to_integer(unsigned(image(row_i + i)(col_i + j).red));
                                sum_green := sum_green + to_integer(unsigned(image(row_i + i)(col_i + j).green));
                                sum_blue := sum_blue + to_integer(unsigned(image(row_i + i)(col_i + j).blue));
                                count := count + 1;
                            end if;
                        end loop;
                    end loop;

                    -- Prevent division by zero
                    if count > 0 then
                        filtered_image(row_i)(col_i).red := std_logic_vector(to_unsigned(sum_red / count, 8));
                        filtered_image(row_i)(col_i).green := std_logic_vector(to_unsigned(sum_green / count, 8));
                        filtered_image(row_i)(col_i).blue := std_logic_vector(to_unsigned(sum_blue / count, 8));
                    else
                        report "Division by zero in mean computation at row " & integer'image(row_i) &
                            ", col " & integer'image(col_i) severity warning;
                    end if;
                end loop;
            end loop;


            -- Write header to output file
            for i in header_type'range loop
                write(out_file, header(i));
            end loop;

            -- Write filtered image to output file
            for row_i in 0 to image_height - 1 loop
                for col_i in 0 to image_width - 1 loop
                    write(out_file, character'val(to_integer(unsigned(filtered_image(row_i)(col_i).blue))));
                    write(out_file, character'val(to_integer(unsigned(filtered_image(row_i)(col_i).green))));
                    write(out_file, character'val(to_integer(unsigned(filtered_image(row_i)(col_i).red))));
                end loop;

                -- Write padding
                for i in 1 to padding loop
                    write(out_file, character'val(0));
                end loop;
            end loop;

            -- Deallocate memory
            for row_i in 0 to image_height - 1 loop
                deallocate(image(row_i));
                deallocate(filtered_image(row_i));
            end loop;

            deallocate(image);
            deallocate(filtered_image);

            -- Close files
            file_close(bmp_file);
            file_close(out_file);
        end if;
    end process;
end architecture rtl;
