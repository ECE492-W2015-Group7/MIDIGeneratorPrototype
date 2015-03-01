library ieee;

-- STD_LOGIC and STD_LOGIC_VECTOR types, and relevant functions
use ieee.std_logic_1164.all;

-- SIGNED and UNSIGNED types, and relevant functions
use ieee.numeric_std.all;

-- Basic sequential functions and concurrent procedures
use ieee.VITAL_Primitives.all;

entity midiOut is

	port
	(
		-- clock interface
		clk		:	in std_logic;
		
		-- reset interface
		reset_n		:	in std_logic;
		
		-- clock for midiOut
		
		clk_midi : in std_logic;
		
		-- conduit interface for midi out jack
		coe_midiOut			:	out std_logic;
		
		-- avalon slave interface
		-- mininum interface possible
		avs_s0_write_n	: in std_logic ;
		avs_s0_writedata : in std_logic_vector (31 downto 0)
	);
end midiOut;


architecture avalon of midiOut is


signal currentBit	: std_logic;

begin

	write_to_seg:process(avs_s0_write_n) is
	begin
		if avs_s0_write_n = '0' then
			if currentBit = '0' then
				currentBit<='1';
			else 
				currentBit <= '0';
			end if;
		end if;
	end process;
	coe_midiOut<=clk_midi;
end avalon;




