library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity id_ex_registrador is
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        memread_in  : in std_logic;
        memtoreg_in : in std_logic;
        regwrite_in : in std_logic;
        alusrc_in   : in std_logic;
        aluop_in    : in std_logic_vector(1 downto 0);
        
        read_data_1_in : in std_logic_vector(31 downto 0);
        read_data_2_in : in std_logic_vector(31 downto 0);
        immediate_in   : in std_logic_vector(31 downto 0);
        rd_addr_in     : in std_logic_vector(4 downto 0);
        
        
        memread_out  : out std_logic; 
        memtoreg_out : out std_logic;
        regwrite_out : out std_logic;
        alusrc_out   : out std_logic;
        aluop_out    : out std_logic_vector(1 downto 0);
        
        read_data_1_out : out std_logic_vector(31 downto 0);
        read_data_2_out : out std_logic_vector(31 downto 0);
        immediate_out   : out std_logic_vector(31 downto 0);
        rd_addr_out     : out std_logic_vector(4 downto 0)
    );
end entity id_ex_registrador;

architecture behavioral of id_ex_registrador is
begin
    pipeline_reg_process: process(clk, rst)
    begin
        if rst = '1' then
            memread_out  <= '0';
            memtoreg_out <= '0';
            regwrite_out <= '0';
            alusrc_out   <= '0';
            aluop_out    <= (others => '0');
            read_data_1_out <= (others => '0');
            read_data_2_out <= (others => '0');
            immediate_out   <= (others => '0');
            rd_addr_out     <= (others => '0');
        elsif rising_edge(clk) then
            memread_out  <= memread_in; 
            memtoreg_out <= memtoreg_in;
            regwrite_out <= regwrite_in;
            alusrc_out   <= alusrc_in;
            aluop_out    <= aluop_in;
            read_data_1_out <= read_data_1_in;
            read_data_2_out <= read_data_2_in;
            immediate_out   <= immediate_in;
            rd_addr_out     <= rd_addr_in;
        end if;
    end process;
end architecture behavioral;