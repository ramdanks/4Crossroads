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
		WaitingCounter 		: integer 	:= 10;
		GreenCounter		: integer 	:= 10
	);
	port
	(
		pButton			: in 		std_logic_vector	(1 to TrafficSize);
		pCounter		: inout 	int					(1 to TrafficSize);
		pGreen			: inout 	std_logic_vector	(1 to TrafficSize);
		pYellow			: inout 	std_logic_vector	(1 to TrafficSize);
		pRed			: inout 	std_logic_vector	(1 to TrafficSize)
	);
end e4Crossroads;

architecture behaviour of e4Crossroads is

	type sLight			is (JALAN, BERSIAP, BERHENTI);
	type sLane			is array (1 to TrafficSize) of sLight;
	type sTraffic 			is (VEHICLE, PEDESTRIAN);
	
	signal LaneState		: sLane		:= (JALAN, others => BERHENTI);
	signal TrafficState : sTraffic 	:= VEHICLE;
	signal clock			: std_logic;
	signal initialization 		: boolean := true;
		       
	
	function ResetWaitingTime	( p_WaitingTime :	integer;
					  p_GreenTime	:	integer ) 
	return integer is begin
	
        return 4 * p_WaitingTime + p_GreenTime;
		
    end function;
	
begin

-- Initialization Process (Set Initial Value)
Init : process( initialization ) is begin

	if ( initialization ) then

		pGreen(1) <= '1';
		pGreen(2) <= '0';
		pGreen(3) <= '0';
		pGreen(4) <= '0';

		pYellow(1) <= '0';
		pYellow(2) <= '0';
		pYellow(3) <= '0';
		pYellow(4) <= '0';

		pRed(1) <= '0';
		pRed(2) <= '1';
		pRed(3) <= '1';
		pRed(4) <= '1';

		pCounter(1) <= GreenCounter;
		pCounter(2) <= WaitingCounter;
		pCounter(3) <= WaitingCounter * 2;
		pCounter(3) <= WaitingCounter * 3;

		initialization <= false;

	end if;
	
end process;

Control	: process( clock, TrafficState, LaneState, pCounter ) is begin

	if rising_edge( clock ) then
	
		for i in 1 to TrafficSize loop
		
			if ( pCounter(i) = 0 and pGreen(i) = '1' ) then
			
				LaneState(i) <= BERHENTI;
				
			elsif ( pCounter(i) = 0 and pGreen(i) = '0' ) then
			
				LaneState(i) <= JALAN;
			
			end if;
			
			if ( pCounter(i) < 4 ) then
			
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

Counting : process( clock ) is begin

	if rising_edge( clock ) then
	
		for i in 1 to TrafficSize loop
		
			if pCounter(i) > 1 then
			
				pCounter(i) <= pCounter(i) - 1;
				
			elsif pCounter(i) = 0 then
			
				pCounter(i) <= ResetWaitingTime( WaitingCounter, GreenCounter );
			
			end if;
		
		end loop;
	
	end if;

end process;

end architecture;
