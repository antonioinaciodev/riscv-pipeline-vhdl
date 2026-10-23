library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_wb_register is 
port(
		clk : in std_logic;
		reset: in std_logic;

		memToRegMEM : in std_logic;
		regWriteMEM: in std_logic;
		
		aluResultMEM : in std_logic_vector(31 downto 0);
		readDataMEM: in std_logic_vector(31 downto 0);
		rdRegisterMEM : in std_logic_vector(4 downto 0);
		
		memToRegWB: out std_logic;
		regWriteWB: out std_logic;
		
		aluResultWB : out std_logic_vector(31 downto 0);
		readDataWB: out std_logic_vector(31 downto 0);
		rdRegisterWB : out std_logic_vector(4 downto 0)
		
);

end mem_wb_register;


architecture Behavioral of mem_wb_register is
begin 
	process(clk, reset)
	begin
		if reset ='1' then
		
			memToRegWB <= '0';
			regWriteWB <= '0';
		
			
			aluResultWB  <=(others => '0');
			readDataWB <= (others=>'0');
			rdRegisterWB<= (others=>'0');
		elsif rising_edge(clk) then
		
			memToRegWB <= memToRegMEM;
			regWriteWB<= regWriteMEM;
			
			aluResultWB  <=aluResultMEM;
			readDataWB <= readDataMEM;
			rdRegisterWB <= rdRegisterMEM;
		end if;
	end process;
end behavioral;
			
			
