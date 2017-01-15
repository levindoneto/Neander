----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:59:13 05/04/2016 
-- Design Name: 
-- Module Name:    Neander - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



entity Neander is

   Port ( 
			entradachaves : in STD_LOGIC_VECTOR (7 downto 0);
			botaoA : in STD_LOGIC;
			botaoB : in STD_LOGIC;
			CLK : in  STD_LOGIC;
         RST : in  STD_LOGIC;
			ledZ : out STD_LOGIC;
			ledN : out STD_LOGIC;
			pin_display1 : out STD_LOGIC;
			pin_display2 : out STD_LOGIC;
			segment7 : out  STD_LOGIC_VECTOR (6 downto 0);
			S: out   STD_LOGIC_VECTOR (7 downto 0)
		
			
         );

end Neander;

architecture Behavioral of Neander is


signal segment7_reg :  STD_LOGIC_VECTOR (6 downto 0);		  
signal pin_display_change :  STD_LOGIC;	
signal sel :  	STD_LOGIC; -- Seletor mux
signal mux_out :  STD_LOGIC_VECTOR (7 downto 0);		  
signal pc_out :  STD_LOGIC_VECTOR (7 downto 0);		
signal mem_out :  STD_LOGIC_VECTOR (7 downto 0);	
signal contadorPC :  STD_LOGIC_VECTOR (7 downto 0);
signal cargaPC :  STD_LOGIC;
signal cargaREM :  STD_LOGIC;
signal incrementaPC :  STD_LOGIC;
signal REM_out :  STD_LOGIC_VECTOR (7 downto 0);
signal REM_REG :  STD_LOGIC_VECTOR (7 downto 0);
signal X :  STD_LOGIC_VECTOR (7 downto 0);
signal Y :  STD_LOGIC_VECTOR (7 downto 0);
signal ula_out :  STD_LOGIC_VECTOR (7 downto 0);	  
signal sel_ula :  	STD_LOGIC_VECTOR (2 downto 0);
signal ac_reg :  STD_LOGIC_VECTOR (7 downto 0);	
signal ac_out :  STD_LOGIC_VECTOR (7 downto 0);	
signal cargaAC :  STD_LOGIC;	
signal loadREM :  STD_LOGIC;	
signal op_reg :  STD_LOGIC_VECTOR (7 downto 0);	
signal op_out :  STD_LOGIC_VECTOR (7 downto 0);	
signal cargaRI :  STD_LOGIC; --- Carga OP	
signal nz_reg :  STD_LOGIC_VECTOR (1 downto 0);	
signal nz_out :  STD_LOGIC_VECTOR (1 downto 0);	
signal cargaNZ :  STD_LOGIC; --- Carga OP	
signal write_enable :  STD_LOGIC_VECTOR(0 DOWNTO 0);
signal mem_in :   STD_LOGIC_VECTOR (7 downto 0);
signal bcd :   STD_LOGIC_VECTOR (3 downto 0);		
signal ula_out_reg :   STD_LOGIC_VECTOR (15 downto 0);	 
signal shift_done :  STD_LOGIC;	

type T_STATE is (t0,t1,t2,t3,t4,t5,t6,t7,hlt_state,mul_msb); 
signal estado, prox_estado : T_STATE;
type instructions is (NOP,STA,LDA,ADD,OROP,ANDOP,NOTOP,JMP,JN,JZ,HLT,SHL,MUL);
signal instruction : instructions;

COMPONENT MemoriaNeanderFinal
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;


begin




-- Memoria
memoria : MemoriaNeanderFinal
  PORT MAP (
    clka => clk,
    wea => write_enable,
    addra => REM_out,
    dina => mem_in,
    douta => mem_out
  );








-- Conversor para o Display 7 segmentos (no final nao foi implementado em placa para a utilizacao do display

process (clk,bcd) begin
	if (clk'event and clk= '1') then
	case  bcd is
		when "0000"=> segment7_reg <="0000001";
		when "0001"=> segment7_reg <="1001111";
		when "0010"=> segment7_reg <="0010010";
		when "0011"=> segment7_reg <="0000110";
		when "0100"=> segment7_reg <="1001100";
		when "0101"=> segment7_reg <="0100100";
		when "0110"=> segment7_reg <="0100000";
		when "0111"=> segment7_reg <="0001111";
		when "1000"=> segment7_reg <="0000000";
		when "1001"=> segment7_reg <="0000100";
		when others=> segment7_reg <="1111111";
	end case;
	end if;
end process;
segment7<=segment7_reg;

-----Parte Operativa

-- PC
process (clk,rst)
begin
if rst='1' then
	contadorPC<= (others=>'0');
	elsif (clk'event and clk='1') then
		if (cargaPC='1') then
		contadorPC <=mem_out;
		else
		if(incrementaPC='1') then
			contadorPC <= contadorPC + 1;
			else
		contadorPC<=contadorPC;
	end if;
end if;
end if;
end process;
pc_out<= contadorPC;



--- Mux



process (sel,clk)  begin 
case sel is
 when '0' => mux_out <= 	pc_out;
		when others => mux_out <= mem_out;
end case;
end process;




--REM

process (clk,rst,loadREM)
begin
if rst='1' then
	REM_REG<= (others=>'0');
	elsif (loadREM ='1') then
		REM_REG<= "01100100"; -- Carrega 100 para sempre salvar no endereco 100 a multiplicacao
	elsif (clk'event and clk='1') then
		if (cargaREM='1') then
		REM_REG <=mux_out;
		else
		REM_REG<=REM_REG;
		end if;
	end if;
end process;
REM_out<= REM_REG;

--ULA

X <= ac_out;

process(sel_ula,Y) 
	begin
Y <= mem_out;
			case sel_ula is
				when "000" => 
				ula_out_reg <="00000000" & (X+Y);
				when "001" =>
				ula_out_reg <="00000000" & (X and Y);
				when "010" =>
				ula_out_reg <= "00000000" & (X or Y);
				when "011" =>
				ula_out_reg <="00000000" & not X;
				when "101" =>	
				if(shift_done = '0') then
				ula_out_reg <= "00000000" & X(6 downto 0) & '0';
				end if; 
				when "110" =>	
				ula_out_reg <= (X  * Y );
				when "100" =>
				ula_out_reg <= "00000000" & Y;
				when others =>
				ula_out_reg <= "00000000" & Y;
			end case;
	end process;
ula_out <= ula_out_reg(7 downto 0);

--AC

process (clk,rst) --process (clk,rst)
begin
if rst='1' then
	ac_reg<= (others=>'0');
	elsif (clk'event and clk='1') then
		if (cargaAC='1') then
		ac_reg <=ula_out;
		else
		ac_reg<=ac_reg;
		end if;
	end if;
end process;
ac_out<= ac_reg;


--opCode

process (clk,rst)
begin
if rst='1' then
	op_reg<= (others=>'0');
	elsif (clk'event and clk='1') then
		if (cargaRI='1') then
		op_reg <=mem_out;
		else
		op_reg<=op_reg;
		end if;
	end if;
end process;
op_out<= op_reg;

--NZ

process (clk,rst)
begin
if rst='1' then
	nz_reg<= (others=>'0');
	elsif (clk'event and clk='1') then
		if (cargaNZ='1') then
		if ac_out = "00000000" then
			nz_reg(0) <= '1';
			else
			nz_reg(0) <= '0';
		end if;
			nz_reg(1) <= ac_out(7);
		else
		nz_reg<=nz_reg;
		end if;
	end if;
end process;
nz_out<= nz_reg;
ledZ <= nz_out(0);
ledN <= nz_out(1);

-- Decodificador
process (op_out) begin  
case  op_out(7 downto 4) is

	
		 when "0000" => instruction <= NOP;
		 when "0001" => instruction <= STA;
		  when "0010"  => instruction <= LDA;
			when "0011"  => instruction <=ADD  ;
		  when "0100"  => instruction <= OROP;
		  when "0101"  => instruction <= ANDOP;
		  when "0110"  => instruction <= NOTOP;
		  when "1000"  => instruction <=JMP;
		when "1001"  => instruction <=	JN;
		 when "1010"  => instruction <= JZ; 
		 when "1011"  => instruction <= SHL;
		 when "1100"  => instruction <=MUL;
		 when others  => instruction <= HLT;
		 
end case;
end process;



--------------Parte de Controle

-- Maquina de Estados
Process(clk, rst)
Begin
If rst='1' then
 estado <= t0;
Elsif (clk'event and clk='1') then
 estado <= prox_estado;
End if;
End process;
Process(cargaAC,cargaNZ,sel,cargaPC,incrementaPC,write_enable,cargaREM,estado,instruction)

Begin
case estado is
when t0 =>
	cargaRI <= '0' ;  
	cargaAC      <= '0';   -- Zera o que veio do t3 e t7 
	cargaNZ      <= '0';   -- Zera o que veio do t3 e t7
	cargaPC      <= '0';   -- Zera o que veio do t4
	incrementaPC <= '0';   -- Zera o que veio do t3
	write_enable <= "0";   -- Zera o que veio do t7
	sel          <= '0';
	loadREM <= '0';
	cargaREM     <= '1';
	prox_estado <= t1;

when t1 =>
	cargaREM <= '0' ;       -- Zera o que veio do t0
	mem_in<=REM_out;	-- Read
	incrementaPC <= '1';
	prox_estado <= t2;

when t2 =>
	incrementaPC <= '0';   -- Zera o que veio do t2
	cargaRI <= '1';
	prox_estado <= t3;

when t3 => 
	incrementaPC <= '0'; 
	cargaRI <= '0' ;        -- Zera o que veio do t2
	if (instruction=STA or instruction=LDA or instruction=MUL or instruction=ADD or instruction=OROP or instruction=ANDOP or instruction=JMP) then
		sel <= '0';
		cargaREM <= '1';
		prox_estado <= t4;
	elsif (instruction=NOTOP) then
		sel_ula <= "011";
		cargaAC <= '1';
		cargaNZ <= '1';
		prox_estado <= t0;
	elsif (instruction=SHL) then
		shift_done <= '0';
		sel_ula <= "101";
		cargaAC <= '1';
		cargaNZ <= '1';
		prox_estado <= t4;
	elsif (instruction=JN and NZ_out(1)='0') then
		incrementaPC <= '1';
		prox_estado <= t0;
	elsif (instruction=JN and NZ_out(1)='1') then
		sel <= '0';
		cargaREM <= '1';
		prox_estado <= t4;
	elsif (instruction=JZ and NZ_out(0)='1') then
		sel <= '0';
		cargaREM <= '1';
		prox_estado <= t4;
	elsif (instruction=JZ and NZ_out(0)='0') then
		incrementaPC <= '1';
		prox_estado <= t0;
	elsif (instruction=NOP) then
		prox_estado <= t0;
	elsif (instruction=HLT) then
		incrementaPC <= '0';
		prox_estado <= hlt_state;
	else
		prox_estado <= t4;
	end if;
when t4 => 
		sel <= '0';  
		incrementaPC <= '0';
		cargaAC  <= '0';         -- Zera o que veio do t3
		cargaNZ  <= '0';        -- Zera o que veio do t3
		cargaREM <= '0';        -- Zera o que veio do t3
		if(instruction=STA or instruction=LDA or instruction=MUL or instruction=ADD or instruction=OROP or instruction=ANDOP) then
			mem_in<=REM_out;-- Read;
			incrementaPC <= '1';
			prox_estado <= t5;
		elsif(instruction=JMP) then
			mem_in<=REM_out;-- Read
			prox_estado <= t5;
		elsif(instruction=JN and NZ_out(1)='1') then
			mem_in<=REM_out;-- Read
			prox_estado <= t5;
		elsif(instruction=JZ and NZ_out(0)='1') then
			mem_in<=REM_out;-- Read
			prox_estado <= t5;
		else 
			prox_estado <= t5;
			shift_done <= '1'; -- Para garantir que não irá recair duas vezes no shift na instrução seguinte ao shift
		end if;
when t5 =>
	incrementaPC <= '0' ; 		   -- Zera o que veio do t4
		if(instruction=STA or instruction=LDA or instruction=ADD or instruction=MUL or instruction=OROP or instruction=ANDOP) then
			sel <= '1';
			cargaREM <= '1';
			prox_estado <= t6;
		elsif(instruction=JMP ) then
			cargaPC <= '1';
			prox_estado <= t0;
		elsif(instruction=JN and NZ_out(1)='1') then
			cargaPC <= '1';
			prox_estado <= t0;
		elsif(instruction=JZ and NZ_out(0)='1') then
			cargaPC <= '1';
			prox_estado <= t0;
		else
			prox_estado <= t6;
		end if;
when t6 =>
	incrementaPC <= '0'; 
	sel <= '0';       -- Zera o que veio do t5
	cargaREM <= '0';  -- Zera o que veio do t5
	cargaPC <= '0';   -- Zera o que veio do t5
		-- Foi tirado o RDM, dai nao tem instruction=STA nesse estado
		if(instruction=LDA or instruction=ADD or  instruction=MUL or instruction=OROP or instruction=ANDOP) then
			mem_in<=REM_out;	-- Read
			prox_estado <= t7;
		else
			prox_estado <= t7;
		end if;
when t7 =>
		incrementaPC <= '0'; 
		if(instruction=STA) then
			mem_in<=AC_out;-- Colocar no memoria_in o dado antes de gravar
			write_enable <= "1";
			prox_estado <= t0;
		elsif(instruction=LDA) then
			sel_ula <= "100";
			cargaAC <= '1';
			cargaNZ <= '1';
			prox_estado <= t0;
		elsif(instruction=MUL) then
			sel_ula <= "110";
			cargaAC <= '1';
			cargaNZ <= '1';
			
			
			
			prox_estado <= mul_msb;
		elsif(instruction=ADD) then
			sel_ula <= "000";
			cargaAC <= '1';
			cargaNZ <= '1';
			prox_estado <= t0;
		elsif(instruction=OROP) then
			sel_ula <= "010";
			cargaAC <= '1';
			cargaNZ <= '1';
			prox_estado <= t0;
		elsif(instruction=ANDOP) then
			sel_ula <= "001";
			cargaAC <= '1';
			cargaNZ <= '1';
			prox_estado <= t0;
		else
			prox_estado <= t0;
		end if;
when mul_msb =>		--Grava o valor alto da multiplicacao no endereco 100 da memoria
		mem_in<=ula_out_reg(15 downto 8);
		loadREM <= '1';
		write_enable <= "1";
		prox_estado <= t0;	
		
when hlt_state =>		
	incrementaPC <= '0'; 
		prox_estado <= hlt_state;
		
end case;
End process; 
S <= ac_out;
Y <=mem_out;
end Behavioral;
