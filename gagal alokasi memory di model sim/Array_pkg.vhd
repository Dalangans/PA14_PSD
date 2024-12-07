library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package Array_pkg is
    type header_type is array (0 to 53) of character;

    type pixel_type is record
        red : std_logic_vector(7 downto 0);
        green : std_logic_vector(7 downto 0);
        blue : std_logic_vector(7 downto 0);
    end record; 
    type row_type is array (0 to 1919) of pixel_type;
    type image_type is array (0 to 1079) of row_type;
end package;
