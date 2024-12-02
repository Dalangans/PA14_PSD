library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Package_pixel.all;

entity ImageCompressor is
    port (
        clk : in std_logic;
        image_in : in image_pointer;          -- Pointer ke gambar input
        image_out : out image_pointer;        -- Pointer ke gambar output (resolusi lebih rendah)
        image_width_in : in integer;          -- Lebar gambar input
        image_height_in : in integer;         -- Tinggi gambar input
        image_width_out : out integer;        -- Lebar gambar output
        image_height_out : out integer        -- Tinggi gambar output
    );
end entity ImageCompressor;

architecture rtl of ImageCompressor is
    type row_type is array (integer range <>) of pixel_type;
    type row_pointer is access row_type;
    type image_type is array (integer range <>) of row_pointer;
    type image_pointer is access image_type;
    
    signal temp_image_out : image_pointer;
    signal temp_image_in : image_pointer;
begin
    process(clk)
        variable row_in : row_pointer;
        variable row_out : row_pointer;
        variable col_in : integer;
        variable col_out : integer;
    begin
        if rising_edge(clk) then
            -- Inisialisasi gambar output dengan ukuran setengah dari gambar input
            image_width_out <= image_width_in / 2;
            image_height_out <= image_height_in / 2;

            -- Membuat gambar output dengan ukuran baru
            temp_image_out := new image_type(0 to image_height_out - 1);
            
            -- Mengambil baris per baris dari gambar input
            for row_i in 0 to image_height_out - 1 loop
                -- Membuat baris baru di gambar output
                row_out := new row_type(0 to image_width_out - 1);
                
                for col_i in 0 to image_width_out - 1 loop
                    -- Ambil nilai piksel dari gambar input dan averaging/subsampling
                    col_in := col_i * 2;  -- Ambil 2 piksel dari gambar asli untuk 1 piksel output

                    -- Averaging warna piksel
                    row_out(col_i).blue := (temp_image_in(row_i * 2)(col_in).blue + temp_image_in(row_i * 2)(col_in + 1).blue) / 2;
                    row_out(col_i).green := (temp_image_in(row_i * 2)(col_in).green + temp_image_in(row_i * 2)(col_in + 1).green) / 2;
                    row_out(col_i).red := (temp_image_in(row_i * 2)(col_in).red + temp_image_in(row_i * 2)(col_in + 1).red) / 2;
                end loop;

                -- Simpan baris baru ke gambar output
                temp_image_out(row_i) := row_out;
            end loop;

            -- Keluarkan gambar yang sudah dikompresi
            image_out <= temp_image_out;
        end if;
    end process;

end architecture rtl;