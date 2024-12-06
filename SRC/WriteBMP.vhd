library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use work.Array_pkg.all;

entity WriteBMP is
    port (
        clk         : in std_logic;
        start       : in std_logic;
        done        : out std_logic;
        img_w_in    : in integer;
        img_h_in    : in integer;
        header_in   : in header_type;
        image_in    : in image_type
    );
end entity WriteBMP;

architecture rtl of WriteBMP is
begin
    process (clk)
        type char_file is file of character;
        file out_file : char_file open write_mode is "out.bmp";
        variable header : header_type;
        variable image_data : image_type;
        variable image_width : integer;
        variable image_height : integer;
        variable padding : integer;
        variable char : character;
    begin
        if rising_edge(clk) then
            if start = '1' then

                image_width := img_w_in;
                image_height:= img_h_in;
                image_data  := image_in;
                header      := header_in;
                padding := (4 - image_width*3 mod 4) mod 4;
                

                -- Write header (hardcoded for simplicity)
                for i in 0 to 53 loop
                    write(out_file, header(i));
                end loop;
    
                for row_i in 0 to image_height - 1 loop                    
                    for col_i in 0 to image_width - 1 loop
                    -- Write blue pixel
                    write(out_file,
                        character'val(to_integer(unsigned(image_data(row_i)(col_i).blue))));
                    
                    -- Write green pixel
                    write(out_file,
                        character'val(to_integer(unsigned(image_data(row_i)(col_i).green))));
                    
                    -- Write red pixel
                    write(out_file,
                        character'val(to_integer(unsigned(image_data(row_i)(col_i).red))));
                    
                    end loop;
                    
                    
                    -- Write padding
                    for i in 1 to padding loop
                        write(out_file, character'val(0));
                    end loop;
                    
                end loop;

                -- Indicate completion
                done <= '1';
                file_close(out_file);
            end if;
        end if;
    end process;
end architecture rtl;
