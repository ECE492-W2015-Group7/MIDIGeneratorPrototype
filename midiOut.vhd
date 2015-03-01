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
	process(avs_s0_write_n)
	begin
		if falling_edge(avs_s0_write_n) then
			currentBit <= avs_s0_writedata(0);
		end if;
	end process;
	coe_midiOut <= currentBit;
	
end avalon;




