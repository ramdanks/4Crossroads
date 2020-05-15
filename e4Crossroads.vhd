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

-- ( 4 Crossroads Implementation ) --

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.IntegerPackage.all;

entity e4Crossroads is
	generic 
	(
		TrafficSize 		: natural 	:= 4;
		ResetCounter		: integer	:= 30;
		GreenCounter		: integer 	:= 10
	);
	port
	(
		pCounter		: inout  	int			(1 to TrafficSize) := ( 10,  10,  20,  30);
		pButton			: in 		std_logic_vector	(1 to TrafficSize) := ('0', '0', '0', '0');
		pGreen			: inout 	std_logic_vector	(1 to TrafficSize) := ('1', '0', '0', '0');
		pYellow			: inout 	std_logic_vector	(1 to TrafficSize) := ('0', '0', '0', '0');
		pRed			: inout 	std_logic_vector	(1 to TrafficSize) := ('0', '1', '1', '1')
	);
end e4Crossroads;

architecture behaviour of e4Crossroads is

	type sLight			is (JALAN, BERSIAP, BERHENTI);
	type sLane			is array (1 to TrafficSize) of sLight;
	type sTraffic 			is (VEHICLE, PEDESTRIAN);
	
	signal LaneState		: sLane		:= (JALAN, others => BERHENTI);
	signal TrafficState : sTraffic 	:= VEHICLE;
	signal clock			: std_logic;
	
	-- Process Counter at RealTime
	function RealTime( pTime : integer ) 
	return integer is begin
	
        	return pTime + 1;
		
    	end function;
	
	-- Generate 1 Sec Clock
	component timer_1sec is
		Port
		(
			reset, clk 	: in std_logic := '0';
		 	start		: in std_logic := '0';
		  	timer   	: out std_logic
		);  
	end component;

begin

Timer: timer_1sec PORT MAP (timer => clock);

Control	: process( clock, TrafficState, LaneState, pCounter ) is begin

	if rising_edge( clock ) then
	
		for i in 1 to TrafficSize loop
		
			if ( pCounter(i) = RealTime(0) ) then
			
				case pGreen(i) is
			
					when '1' 	=> LaneState(i) <= BERHENTI;
					when others 	=> LaneState(i) <= JALAN;
				
				end case;
			
			elsif ( pCounter(i) <= RealTime(3) ) then
			
				LaneState(i) <= BERSIAP;
			
			end if;
		
		end loop;
	
	end if;

end process;

Light :	process( TrafficState, LaneState ) is begin

	if ( TrafficState = VEHICLE ) then
		
		for i in 1 to TrafficSize loop
		
			case LaneState(i) is
			
				when JALAN 	=>		
							pGreen(i) 	<= '1';
							pYellow(i) 	<= '0';
							pRed(i)		<= '0';
							
				when BERSIAP 	=>
							pGreen(i) 	<= pGreen(i);
							pYellow(i) 	<= '1';
							pRed(i)		<= pRed(i);
									
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

Counting : process( clock, pGreen ) is begin

	if rising_edge( clock ) then
	
		for i in 1 to TrafficSize loop
		
			if ( pCounter(i) > RealTime(0) ) then
			
				pCounter(i) <= pCounter(i) - 1;
				
			elsif ( pCounter(i) <= RealTime(0) and pGreen(i) = '1' ) then
			
				pCounter(i) <= ResetCounter;
				
			elsif ( pCounter(i) <= RealTime(0) and pGreen(i) = '0' ) then
			
				pCounter(i) <= GreenCounter;
			
			end if;
		
		end loop;
	
	end if;

end process;

end architecture;