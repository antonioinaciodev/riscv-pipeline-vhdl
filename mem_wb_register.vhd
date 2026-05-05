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
		
		memToRegWEB: out std_logic;
		regWriteWEB: out std_logic;
		
		aluResultWEB : out std_logic_vector(31 downto 0);
		readDataWEB: out std_logic_vector(31 downto 0);
		rdRegisterWEB : out std_logic_vector(4 downto 0)
		
);

end mem_wb_register;


architecture Behavioral of mem_wb_register is
begin 
	process(clk, reset)
	begin
		if reset ='1' then
		
			memToRegWEB <= '0';
			regWriteWEB <= '0';
		
			
			aluResultWEB  <=(others => '0');
			readDataWEB <= (others=>'0');
			rdRegisterWEB<= (others=>'0');
		elsif rising_edge(clk) then
		
			memToRegWEB <= memToRegMEM;
			regWriteWEB<= regWriteMEM;
			
			aluResultWEB  <=aluResultMEM;
			readDataWEB <= readDataMEM;
			rdRegisterWEB <= rdRegisterMEM;
		end if;
	end process;
end behavioral;
			
			
