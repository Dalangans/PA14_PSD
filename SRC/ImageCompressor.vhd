library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Array_pkg.all;

entity ImageCompressor is
    port (
        clk             : in std_logic;
        start           : in std_logic;
        block_size      : in integer; -- Select block size: 2 for 2x2, 3 for 3x3, 4 for 4x4
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
        variable block_area : integer;
    
        begin
            if rising_edge(clk) and start = '1' then
                done <= '0';
    
                -- Calculate output dimensions based on block size
                img_w_data := img_width_in / block_size;
                img_h_data := img_height_in / block_size;
    
                -- Adjust for odd dimensions
                if img_width_in mod block_size /= 0 then
                    img_w_data := img_w_data + 1;
                end if;
                if img_height_in mod block_size /= 0 then
                    img_h_data := img_h_data + 1;
                end if;
    
                img_width_out <= img_w_data;
                img_height_out <= img_h_data;
    
                -- Update header
                header := header_in;
                header(18) := character'val(img_w_data mod 256); -- Width LSB
                header(19) := character'val((img_w_data / 256) mod 256);
                header(22) := character'val(img_h_data mod 256); -- Height LSB
                header(23) := character'val((img_h_data / 256) mod 256);
    
                -- Update image size in header
                header(34) := character'val((img_w_data * img_h_data * 3) mod 256); -- Image size LSB
                header(35) := character'val(((img_w_data * img_h_data * 3) / 256) mod 256);
                header(2)  := character'val(((img_w_data * img_h_data * 3 + 54) mod 256)); -- File size LSB
                header(3)  := character'val((((img_w_data * img_h_data * 3 + 54) / 256) mod 256));
    
                header_out <= header;
    
                -- Block area calculation
                block_area := block_size * block_size;
    
                -- Perform mean filtering over block_size x block_size pixel blocks
                for row_i in 0 to (img_h_data - 1) loop
                    for col_i in 0 to (img_w_data - 1) loop
                        row_in := row_i * block_size;
                        col_in := col_i * block_size;
    
                        -- Initialize sums
                        r := 0;
                        g := 0;
                        b := 0;
    
                        -- Sum pixels within the block
                        for i in 0 to block_size - 1 loop
                            for j in 0 to block_size - 1 loop
                                if (row_in + i < img_height_in) and (col_in + j < img_width_in) then
                                    r := r + to_integer(unsigned(image_in(row_in + i)(col_in + j).red));
                                    g := g + to_integer(unsigned(image_in(row_in + i)(col_in + j).green));
                                    b := b + to_integer(unsigned(image_in(row_in + i)(col_in + j).blue));
                                end if;
                            end loop;
                        end loop;
    
                        -- Calculate mean values
                        r := r / block_area;
                        g := g / block_area;
                        b := b / block_area;
    
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