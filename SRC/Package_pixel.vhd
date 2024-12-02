library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package Package_pixel is
    -- BMP Header Type
    type header_type is array (0 to 53) of character;

    -- Pixel Type: Represents RGB values
    type pixel_type is record
        red : std_logic_vector(7 downto 0);
        green : std_logic_vector(7 downto 0);
        blue : std_logic_vector(7 downto 0);
    end record;

    -- Flattened Array for Pixels
    type pixel_array is array (natural range <>) of pixel_type;
end package Package_pixel;
