-- Automatic 4 Way Crossroads Traffic Light with Pelican
-- Perancangan Sistem Digital Praktikum
-- Kelompok 	: B3
-- Anggota		: - Arief Saferman
--				: - Farhan Almasyhur
--				: - Muhammad Alfi Aldolio
--				: - Ramadhan Kalih Sewu
-- Almamater	: Universitas Indonesia
-- Language		: VHDL
-- License		: GNU GPL-3.0
-- Document.	: https://github.com/ramdanks/4Crossroads


-- ( Entity of Traffic Light ) --

library ieee;
use ieee.std_logic_1164.all;

entity eTraffic is
	generic (ResetCounter 	: integer 	:= 30);
	port
	(
		pButton			: in 	std_logic;
		pCounter		: inout integer;
		pGreen			: out 	std_logic;
		pYellow			: inout std_logic;
		pRed			: out 	std_logic
	);
end eTraffic;

architecture declaration of eTraffic is
end architecture;

-- ( 4 Crossroads Implementation ) --

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity 4Crossroads is
	generic (TrafficSize : natural := 4);
	port
	(
		pButton			: in 	std_logic	(1 to TrafficSize);
		pCounter		: inout integer		(1 to TrafficSize);
		pGreen			: out 	std_logic	(1 to TrafficSize);
		pYellow			: inout std_logic	(1 to TrafficSize);
		pRed			: out 	std_logic	(1 to TrafficSize)
	);

end 4Crossroads;

architecture behaviour of 4Crossroads is

	type sLight			is (JALAN, BERSIAP, BERHENTI);
	type sLane			is array (3 downto 0) of sLight;
	type sTraffic 		is (VEHICLE, PEDESTRIAN);
	
	signal LaneState	: sLane		:= (JALAN, others => BERHENTI);
	signal TrafficState : sTraffic 	:= VEHICLE;
	
	component eTraffic
		generic (ResetCounter 	: integer 	:= 30);
		port
		(
			pButton			: in 	std_logic;
			pCounter		: inout integer;
			pGreen			: out 	std_logic;
			pYellow			: inout std_logic;
			pRed			: out 	std_logic
		);
	end component;

	signal clock		: std_logic;
	
begin

for i in 1 to TrafficSize generate

	eTraffic port map 	(
							pButton(i),
							pCounter(i),
							pGreen(i),
							pYellow(i),
							pRed(i)
						);

end generate;

end architecture;