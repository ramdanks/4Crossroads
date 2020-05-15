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
	type int2 is array (natural range <>) of int(1 to 2);
end;

-- ( 2 Digit SevSeg ) --

library ieee;
use ieee.std_logic_1164.all;

package SevenSegment is
    	type ss2 is array (1 to 2) of std_logic_vector(1 to 7);
	type display is array (natural range <>) of ss2;
end;

-- ( 4 Crossroads Implementation ) --

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.IntegerPackage.all;
use work.SevenSegment.all;

entity e4Crossroads is
	generic 
	(
		TrafficSize 		: natural 	:= 4;
		ResetCounter		: integer	:= 30;
		GreenCounter		: integer 	:= 10
	);
	port
	(
		-- Traffic Port
		pDisplaySS		: out		display			(1 to TrafficSize);
		pCounter		: inout  	int			(1 to TrafficSize) := ( 10,  10,  20,  30);
		pGreen			: inout 	std_logic_vector	(1 to TrafficSize) := ('1', '0', '0', '0');
		pYellow			: inout 	std_logic_vector	(1 to TrafficSize) := ('0', '0', '0', '0');
		pRed			: inout 	std_logic_vector	(1 to TrafficSize) := ('0', '1', '1', '1');
		-- Pelican Port
		pPelicanButton		: inout 	std_logic_vector	(1 to TrafficSize) := ('0', '0', '0', '0');
		pPelicanRed      	: inout 	std_logic_vector 	(1 to TrafficSize) := ('1', '1', '1', '1');
    		pPelicanGreen    	: inout 	std_logic_vector 	(1 to TrafficSize) := ('0', '0', '0', '0')
	);
end e4Crossroads;

architecture behaviour of e4Crossroads is

	type sLight			is (JALAN, BERSIAP, BERHENTI);
	type sLane			is array (1 to TrafficSize) of sLight;
	type sTraffic 			is (VEHICLE, PWAIT, PEDESTRIAN);
	
	signal LaneState		: sLane		:= (JALAN, others => BERHENTI);
	signal TrafficState 		: sTraffic 	:= VEHICLE;
	signal clock			: std_logic	:= '0';
	signal ParsingDigit		: int2(1 to 4);
	signal PendingPedestrian	: boolean 	:= false;
	
	-- Process Counter at RealTime
	function RealTime( pTime : integer ) 
	return integer is begin
	
        	return pTime + 1;
		
    	end function;
	
	-- Processing Pelican Button
	function AllPelicanPressed( param : std_logic_vector(1 to TrafficSize) )
	return boolean is begin

		if ( param = "1111" ) then 	return true;
		end if;
		return false;

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

Control	: process( clock, TrafficState, LaneState, pCounter, pPelicanButton ) is begin

	if rising_edge( clock ) then
	
		for i in 1 to TrafficSize loop
			
			if ( TrafficState = PEDESTRIAN and pCounter(i) = RealTime(0) ) then
			
				TrafficState <= VEHICLE;

			end if;

			-- Kondisi BERSIAP apabila Counter = 3 detik;
			if ( pCounter(i) = RealTime(3) ) then
		
				LaneState(i) <= BERSIAP;
			
			-- Saat Timer Reset ke 0
			elsif ( pCounter(i) = RealTime(0) ) then
			
				-- Cek Transisi ke Pedestrian
				-- Nunggu Yang Lagi Jalan berhenti terlebih dahulu
				if ( TrafficState = PWAIT ) then

					TrafficState <= PEDESTRIAN;

				end if;
				
				-- Ubah State Lane
				if ( pGreen(i) = '1' ) then
					
					LaneState(i) <= BERHENTI;

				-- Hanya transisi ke JALAN apabila Tidak Pending Pedestrian
				elsif ( pGreen(i) = '0' and (not PendingPedestrian) ) then
					
					LaneState(i) <= JALAN;	
			
				end if;

			end if;
		
		end loop;

		if ( AllPelicanPressed( pPelicanButton ) ) then
		
			PendingPedestrian 	<= true;

		elsif ( PendingPedestrian ) then

			TrafficState 		<= PWAIT;
			pPelicanButton		<= "0000";
			PendingPedestrian 	<= false;

		end if;
	
	end if;

end process;

Light :	process( TrafficState, LaneState ) is begin

	if ( TrafficState = VEHICLE ) then
		
		for i in 1 to TrafficSize loop
		
			if ( not PendingPedestrian ) then

				case LaneState(i) is
				
					when JALAN 	=>		
								pGreen(i) 			<= '1';
								pYellow(i) 			<= '0';
								pRed(i)				<= '0';
								pPelicanGreen(i) 	<= '0';
								pPelicanRed(i) 		<= '1';
								
					when BERSIAP 	=>
								pGreen(i) 			<= pGreen(i);
								pYellow(i) 			<= '1';
								pRed(i)				<= pRed(i);
								pPelicanGreen(i) 	<= '0';
								pPelicanRed(i) 		<= '1';
										
					when BERHENTI 	=>
								pGreen(i) 			<= '0';
								pYellow(i) 			<= '0';
								pRed(i)				<= '1';
								pPelicanGreen(i) 	<= '0';
								pPelicanRed(i) 		<= '1';
				end case;
				
			else
			
				pGreen(i) 	<= '0';
				pYellow(i) 	<= '0';
				pRed(i)		<= '1';
				
			end if;
		
		end loop;
	
	elsif ( TrafficState = PEDESTRIAN ) then
	
		for i in 1 to TrafficSize loop
		
			pGreen(i) 			<= '0';
			pYellow(i)			<= '0';
			pRed(i) 			<= '1';
			pPelicanGreen(i) 	<= '1';
			pPelicanRed(i) 		<= '0';
		
		end loop;
	
	end if;

end process;

Counting : process( clock, pGreen ) is begin

	if rising_edge( clock ) then
	
		for i in 1 to TrafficSize loop

			if ( PendingPedestrian and pGreen(i) = '0' ) then
			
				pCounter(i) <= pCounter(i) + 10;
			
			elsif ( pCounter(i) > RealTime(0) ) then
			
				pCounter(i) <= pCounter(i) - 1;
				
			elsif ( pCounter(i) <= RealTime(0) and pGreen(i) = '1' ) then
			
				case TrafficState is
				
					when PWAIT 	=> pCounter(i) <= ResetCounter + RealTime(10);
					when PEDESTRIAN => pCounter(i) <= ResetCounter + RealTime(10);
					when others 	=> pCounter(i) <= ResetCounter;
				
				end case;	
				
			elsif ( pCounter(i) <= RealTime(0) and pGreen(i) = '0' ) then
			
				pCounter(i) <= GreenCounter;
			
			end if;
			
			-- memecah digit counter menjadi 2 digit decimal
			ParsingDigit(i)(1) <= (pCounter(i) - 1)  / 10;
			ParsingDigit(i)(2) <= (pCounter(i) - 1) mod 10;
		
		end loop;
	
	end if;

end process;

DisplayTimer : process( clock, ParsingDigit ) is begin

	if falling_edge( clock ) then
	
		for i in 1 to TrafficSize loop
		
			for j in 1 to 2 loop
				
				case ParsingDigit(i)(j) is
			
					when 0		=> 		pDisplaySS(i)(j) <= "1111110"; --0
					when 1		=> 		pDisplaySS(i)(j) <= "0110000"; --1
					when 2		=> 		pDisplaySS(i)(j) <= "1101101"; --2
					when 3		=> 		pDisplaySS(i)(j) <= "1111001"; --3
					when 4		=> 		pDisplaySS(i)(j) <= "0110011"; --4
					when 5 		=> 		pDisplaySS(i)(j) <= "1011011"; --5
					when 6 		=> 		pDisplaySS(i)(j) <= "0011111"; --6
					when 7		=> 		pDisplaySS(i)(j) <= "1110000"; --7
					when 8 		=> 		pDisplaySS(i)(j) <= "1111111"; --8
					when 9 		=> 		pDisplaySS(i)(j) <= "1111011"; --9
					when others 	=>		pDisplaySS(i)(j) <= "1111110"; --0
			
				end case;
			
			end loop;
		
		end loop;
	
	end if;

end process;

end architecture;