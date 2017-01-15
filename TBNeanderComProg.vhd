--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:35:57 05/16/2016
-- Design Name:   
-- Module Name:   C:/Users/Eduardo/Downloads/Compressed/Trabalho2-10-05-topdobugadomasultimaversao/Trabalho2-09-05-V2/Trabalho2/Trabalho2/TBNeanderComProg.vhd
-- Project Name:  Trabalho2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Neander
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TBNeanderComProg IS
END TBNeanderComProg;
 
ARCHITECTURE behavior OF TBNeanderComProg IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Neander
    PORT(
         entradachaves : IN  std_logic_vector(7 downto 0);
         botaoA : IN  std_logic;
         botaoB : IN  std_logic;
         CLK : IN  std_logic;
         RST : IN  std_logic;
         ledZ : OUT  std_logic;
         ledN : OUT  std_logic;
         pin_display1 : OUT  std_logic;
         pin_display2 : OUT  std_logic;
         segment7 : OUT  std_logic_vector(6 downto 0);
         S : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal entradachaves : std_logic_vector(7 downto 0) := (others => '0');
   signal botaoA : std_logic := '0';
   signal botaoB : std_logic := '0';
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';

 	--Outputs
   signal ledZ : std_logic;
   signal ledN : std_logic;
   signal pin_display1 : std_logic;
   signal pin_display2 : std_logic;
   signal segment7 : std_logic_vector(6 downto 0);
   signal S : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Neander PORT MAP (
          entradachaves => entradachaves,
          botaoA => botaoA,
          botaoB => botaoB,
          CLK => CLK,
          RST => RST,
          ledZ => ledZ,
          ledN => ledN,
          pin_display1 => pin_display1,
          pin_display2 => pin_display2,
          segment7 => segment7,
          S => S
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CLK_period*10;
		 wait for CLK_period*10;
		
		rst <= '1';
		
		wait for CLK_period*10;
		rst <= '0';
			wait for CLK_period*10;
      -- insert stimulus here 


      wait;
   end process;
END;
