-- Automatic 4 Way Crossroads Traffic Light with Pelican
-- Perancangan Sistem Digital Praktikum
-- Kelompok 	: B3
-- Anggota	: - Arief Saferman
--		: - Farhan Almasyhur
--		: - Muhammad Alfi Aldolio
--		: - Ramadhan Kalih Sewu
-- Almamater	: Universitas Indonesia
-- Language	: VHDL
-- License	: GNU GPL-3.0
-- Document.	: https://github.com/ramdanks/4Crossroads

-- ( Integer Package ) --

library ieee;
use ieee.std_logic_1164.all;

package IntegerPackage is
    type int is array (natural range <>) of integer;
end;

-- ( Entity of Traffic Light ) --

library ieee;
use ieee.std_logic_1164.all;
use work.IntegerPackage.all;

entity eTraffic is
	generic (ResetCounter 		: integer 	:= 30);
	port
	(
		pButton			: in 	std_logic;
		pCounter		: inout int(1 downto 1);
		pGreen			: out 	std_logic;
		pYellow			: inout std_logic;
		pRed			: out 	std_logic
	);
end eTraffic;

architecture declaration of eTraffic is begin
end architecture;

-- ( 4 Crossroads Implementation ) --

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.IntegerPackage.all;

entity e4Crossroads is
	generic (TrafficSize : natural := 4);
	port
	(
		pButton			: in 	std_logic_vector	(1 to TrafficSize);
		pCounter		: inout int					(1 to TrafficSize);
		pGreen			: out 	std_logic_vector	(1 to TrafficSize);
		pYellow			: inout std_logic_vector	(1 to TrafficSize);
		pRed			: out 	std_logic_vector	(1 to TrafficSize)
	);

end e4Crossroads;

architecture behaviour of e4Crossroads is

	type sLight			is (JALAN, BERSIAP, BERHENTI);
	type sLane			is array (3 downto 0) of sLight;
	type sTraffic 			is (VEHICLE, PEDESTRIAN);
	
	signal LaneState		: sLane		:= (JALAN, others => BERHENTI);
	signal TrafficState : sTraffic 	:= VEHICLE;
	
	component eTraffic
		generic (ResetCounter 	: integer 	:= 30);
		port
		(
			pButton		: in 	std_logic;
			pCounter	: inout integer;
			pGreen		: out 	std_logic;
			pYellow		: inout std_logic;
			pRed		: out 	std_logic
		);
	end component;

	signal clock		: std_logic;
	
begin

LaneGenerate:
for i in 1 to TrafficSize generate
	Lane:
	eTraffic port map 	(
					pButton(i),
					pCounter(i),
					pGreen(i),
					pYellow(i),
					pRed(i)
				);
end generate;

Light :	process( TrafficState, LaneState ) is begin

	if ( TrafficState = VEHICLE ) then
		
		for i in 1 to TrafficSize loop
		
			case LaneState(i) is
			
				when JALAN 	=>		
							pGreen(i) 	<= '1';
							pYellow(i) 	<= '0';
							pRed(i)		<= '0';
							
				when BERSIAP 	=>
							pGreen(i) 	<= '0';
							pYellow(i) 	<= '1';
							pRed(i)		<= '0';
									
				when BERHENTI 	=>
							pGreen(i) 	<= '0';
							pYellow(i) 	<= '0';
							pRed(i)		<= '1';
			end case;
		
		end loop;
	
	elsif ( TrafficState = PEDESTRIAN ) then
	
		for i in 1 to TrafficSize loop
		
			pGreen(i) 	<= '0';
			pYellow(i)	<= '0';
			pRed(i) 	<= '1';
		
		end loop;
	
	end if;

end process;


end architecture;
