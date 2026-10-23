library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pipeline_types.all;

entity register_file is
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        RegWrite   : in  std_logic;
        rr1_addr   : in  std_logic_vector(4 downto 0);
        rr2_addr   : in  std_logic_vector(4 downto 0);
        wr_addr    : in  std_logic_vector(4 downto 0);
        wr_data    : in  std_logic_vector(31 downto 0);
        rr1_data   : out std_logic_vector(31 downto 0);
        rr2_data   : out std_logic_vector(31 downto 0)
    );
end entity register_file;

architecture behavioral of register_file is
    signal registers : reg_array;

begin
    -- Escrita sincrona. No RISC-V puro, apenas x0 e especial (sempre zero);
    -- todos os outros registradores sao de uso geral e livres para escrita.
    write_process: process(clk, rst)
    begin
        if rst = '1' then
            -- Todos os registradores inicializam em zero
            for i in 0 to 31 loop
                registers(i) <= (others => '0');
            end loop;
        elsif rising_edge(clk) then
            -- x0 nunca pode ser escrito (permanece sempre zero)
            if RegWrite = '1' and wr_addr /= "00000" then
                registers(to_integer(unsigned(wr_addr))) <= wr_data;
            end if;
        end if;
    end process write_process;

    -- Leitura assincrona, com write-first forwarding interno:
    -- se o mesmo registro esta sendo escrito e lido no mesmo ciclo,
    -- a leitura ja ve o dado novo (evita um hazard de 1 ciclo).
    read_process: process(rr1_addr, rr2_addr, registers, RegWrite, wr_addr, wr_data)
    begin
        -- Porta de leitura 1
        if rr1_addr = "00000" then
            rr1_data <= (others => '0');
        elsif (RegWrite = '1' and wr_addr = rr1_addr) then
            rr1_data <= wr_data;
        else
            rr1_data <= registers(to_integer(unsigned(rr1_addr)));
        end if;

        -- Porta de leitura 2
        if rr2_addr = "00000" then
            rr2_data <= (others => '0');
        elsif (RegWrite = '1' and wr_addr = rr2_addr) then
            rr2_data <= wr_data;
        else
            rr2_data <= registers(to_integer(unsigned(rr2_addr)));
        end if;
    end process read_process;

end architecture behavioral;
