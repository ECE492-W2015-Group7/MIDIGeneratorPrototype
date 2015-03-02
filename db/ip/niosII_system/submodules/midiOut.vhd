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

signal midiDataInput : std_logic_vector (29 downto 0) :="111111111111111111111111111111";
signal counter : integer range 0 to 29 := 29;
signal localMidiData : std_logic_vector (29 downto 0):="111111111111111111111111111111";

begin

	midiReceiver : process(avs_s0_write_n) is
	begin
		if falling_edge(avs_s0_write_n) then
			--save the midi data
			--midi data is only 30bits ignore the first two bits.
			midiDataInput <= avs_s0_writedata(29 downto 0);	
		end if;
	end process;
	
	midiSender: process(clk_midi,midiDataInput) is
	begin
		if rising_edge(clk_midi)then
		
			if (localMidiData /= midiDataInput) then 
				counter <=29;
				localMidiData <= midiDataInput;
			end if;
			
			if (counter = 0) then
				coe_midiOut <= '1';
				--For MIDI protocol 
				--'1' is the value of the last bit of every 30 bits midi signal
				--'1' is also the default value when there is no on the wire.
			else
				coe_midiOut <= localMidiData(counter);
				counter <= counter -1;					
			end if;
			
		end if;		
	end process;
	
end avalon;




