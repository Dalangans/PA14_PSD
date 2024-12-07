library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Array_pkg.all;

entity Compress4x4 is
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
end entity Compress4x4;

architecture rtl of Compress4x4 is
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
                img_w_data      := img_width_in / 4;
                img_h_data      := img_height_in / 4;
                img_width_out   <= img_w_data;
                img_height_out  <= img_h_data;
    
                -- Update header
                header := header_in;
                header(18) := character'val(img_w_data mod 256);
                header(19) := character'val((img_w_data / 256) mod 256);
                header(22) := character'val(img_h_data mod 256);
                header(23) := character'val((img_h_data / 256) mod 256);
    
                header_out <= header;
    
                -- Perform mean filtering over 4x4 pixel blocks
                for row_i in 0 to (img_h_data - 1) loop
                    for col_i in 0 to (img_w_data - 1) loop
                        row_in := row_i * 4;
                        col_in := col_i * 4;
    
                        -- Calculate mean for each color channel
                        r := 0;
                        g := 0;
                        b := 0;
                        for i in 0 to 3 loop
                            for j in 0 to 3 loop
                                r := r + to_integer(unsigned(image_in(row_in + i)(col_in + j).red));
                                g := g + to_integer(unsigned(image_in(row_in + i)(col_in + j).green));
                                b := b + to_integer(unsigned(image_in(row_in + i)(col_in + j).blue));
                            end loop;
                        end loop;
    
                        r := r / 16;
                        g := g / 16;
                        b := b / 16;
    
                        -- Assign averaged values to output image
                        image_data(row_i)(col_i).red   := std_logic_vector(to_unsigned(r, 8));
                        image_data(row_i)(col_i).green := std_logic_vector(to_unsigned(g, 8));
                        image_data(row_i)(col_i).blue  := std_logic_vector(to_unsigned(b, 8));
                    end loop;
                end loop;
    
                image_out <= image_data;
                done <= '1';
            end if;
        end process;
    end architecture rtl;
    