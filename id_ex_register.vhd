library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity id_ex_register is
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        memread_in  : in std_logic;
        memtoreg_in : in std_logic;
		  memwrite_in : in std_logic;
        regwrite_in : in std_logic;
        alusrc_in   : in std_logic;
        aluop_in    : in std_logic_vector(1 downto 0);
		  branch_in : in std_logic; -- novo
        
        read_data_1_in : in std_logic_vector(31 downto 0);
        read_data_2_in : in std_logic_vector(31 downto 0);
        immediate_in   : in std_logic_vector(31 downto 0);
        rd_addr_in     : in std_logic_vector(4 downto 0);
		  -- importante para os estagios seguintes
		  rs1_addr_in    : in std_logic_vector(4 downto 0);  -- Novo
        rs2_addr_in    : in std_logic_vector(4 downto 0);  -- Novo
		  funct7_in    : in std_logic_vector(6 downto 0); -- novo
		  funct3_in : in std_logic_vector(2 downto 0);
        
        
        memread_out  : out std_logic; 
        memtoreg_out : out std_logic;
		  memwrite_out : out std_logic;
		  branch_out : out std_logic;
        regwrite_out : out std_logic;
        alusrc_out   : out std_logic;
        aluop_out    : out std_logic_vector(1 downto 0);
        
        read_data_1_out : out std_logic_vector(31 downto 0);
        read_data_2_out : out std_logic_vector(31 downto 0);
        immediate_out   : out std_logic_vector(31 downto 0);
		  -- importante para os estagios seguintes
		  rs1_addr_out    : out std_logic_vector(4 downto 0);  -- Novo
        rs2_addr_out    : out std_logic_vector(4 downto 0);  -- Novo
		  funct7_out   : out std_logic_vector(6 downto 0);  -- Novo
		  funct3_out : out std_logic_vector(2 downto 0);
        rd_addr_out     : out std_logic_vector(4 downto 0)
    );
end entity id_ex_register;

architecture behavioral of id_ex_register is
begin
    pipeline_reg_process: process(clk, rst)
    begin
        if rst = '1' then
            memread_out  <= '0';
				memwrite_out <= '0';
            memtoreg_out <= '0';
            regwrite_out <= '0';
				branch_out <= '0';
            alusrc_out   <= '0';
            aluop_out    <= (others => '0');
            read_data_1_out <= (others => '0');
            read_data_2_out <= (others => '0');
            immediate_out   <= (others => '0');
				rs1_addr_out    <= (others =>'0'); --novo
				rs2_addr_out    <= (others =>'0'); -- novo 
            rd_addr_out     <= (others => '0');
				funct7_out <= (others => '0');
				funct3_out <= (others => '0');
        elsif rising_edge(clk) then
            memread_out  <= memread_in; 
            memtoreg_out <= memtoreg_in;
				memwrite_out <= memwrite_in;
            regwrite_out <= regwrite_in;
            alusrc_out   <= alusrc_in;
            aluop_out    <= aluop_in;
				branch_out <= branch_in;
            read_data_1_out <= read_data_1_in;
            read_data_2_out <= read_data_2_in;
            immediate_out   <= immediate_in;
				rs1_addr_out <= rs1_addr_in;
				rs2_addr_out <= rs2_addr_in;
            rd_addr_out     <= rd_addr_in;
				funct7_out <= funct7_in;
				funct3_out <= funct3_in;
        end if;
    end process;
end architecture behavioral;
