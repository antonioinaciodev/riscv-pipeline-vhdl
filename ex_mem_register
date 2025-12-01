library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ex_mem_register is 
port(
		clk : in std_logic;
		reset: in std_logic;
		
		
		memWriteEX : in std_logic;
		memReadEX : in std_logic;
		branchEX : in std_logic;
		memToRegEX : in std_logic;
		regWriteEX: in std_logic;
		
		aluResultEX : in std_logic_vector(31 downto 0);
		writeDataEX: in std_logic_vector(31 downto 0);
		rdRegisterEX : in std_logic_vector(4 downto 0);
		pcRegisterEX: in std_logic_vector(31 downto 0);
		funct3EX: in std_logic_vector(2 downto 0);
		

		memWriteMEM : out std_logic;
		memReadMEM: out std_logic;
		branchMEM: out std_logic;
		memToRegMEM: out std_logic;
		regWriteMEM: out std_logic;
		
		aluResultMEM : out std_logic_vector(31 downto 0);
		writeDataMEM: out std_logic_vector(31 downto 0);
		rdRegisterMEM : out std_logic_vector(4 downto 0);
		funct3MEM: out std_logic_vector(2 downto 0);
		pcRegisterMEM: out std_logic_vector(31 downto 0)
);

end ex_mem_register;


architecture Behavioral of ex_mem_register is
begin 
	process(clk, reset)
	begin
		if reset ='1' then
		
			memWriteMEM <= '0';
			memReadMEM <= '0';
			branchMEM <= '0';
			memToRegMEm <= '0';
			regWriteMEM <= '0';
		
			
			aluResultMEM  <=(others => '0');
			writeDataMEM <= (others=>'0');
			rdRegisterMEM <= (others=>'0');
			pcRegisterMEM <= (others =>'0');
			funct3MEM <= (others =>'0');
			
		elsif rising_edge(clk) then
			
			memWriteMEM <= memWriteEX;
			memReadMEM <= memReadEX;
			branchMEM <= branchEX;
			memToRegMEm <= memToRegEX;
			regWriteMEM <= regWriteEX;
			
			aluResultMEM  <=aluResultEX;
			writeDataMEM <= writeDataEX;
			rdRegisterMEM <= rdRegisterEX;
			pcRegisterMEM <= pcRegisterEX;
			funct3MEM <= funct3EX;
		end if;
	end process;
end behavioral;
			
			
