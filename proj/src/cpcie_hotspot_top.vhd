library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity cpcie_hotspot_top is
  port (
    PCIE_PERST_B_LS : IN std_logic;
    PCIE_REFCLK_N : IN std_logic;
    PCIE_REFCLK_P : IN std_logic;
    PCIE_RX_N : IN std_logic_vector(7 DOWNTO 0);
    PCIE_RX_P : IN std_logic_vector(7 DOWNTO 0);
    GPIO_LED : OUT std_logic_vector(3 DOWNTO 0);
    PCIE_TX_N : OUT std_logic_vector(7 DOWNTO 0);
    PCIE_TX_P : OUT std_logic_vector(7 DOWNTO 0)
    );
end cpcie_hotspot_top;

architecture sample_arch of cpcie_hotspot_top is

  component xillybus
    port (
      PCIE_PERST_B_LS : IN std_logic;
      PCIE_REFCLK_N : IN std_logic;
      PCIE_REFCLK_P : IN std_logic;
      PCIE_RX_N : IN std_logic_vector(7 DOWNTO 0);
      PCIE_RX_P : IN std_logic_vector(7 DOWNTO 0);
      GPIO_LED : OUT std_logic_vector(3 DOWNTO 0);
      PCIE_TX_N : OUT std_logic_vector(7 DOWNTO 0);
      PCIE_TX_P : OUT std_logic_vector(7 DOWNTO 0);
      bus_clk : OUT std_logic;
      quiesce : OUT std_logic;
      user_r_rd_0_rden : OUT std_logic;
      user_r_rd_0_empty : IN std_logic;
      user_r_rd_0_data : IN std_logic_vector(31 DOWNTO 0);
      user_r_rd_0_eof : IN std_logic;
      user_r_rd_0_open : OUT std_logic;
      user_w_wr_0_wren : OUT std_logic;
      user_w_wr_0_full : IN std_logic;
      user_w_wr_0_data : OUT std_logic_vector(31 DOWNTO 0);
      user_w_wr_0_open : OUT std_logic;
      user_w_wr_1_wren : OUT std_logic;
      user_w_wr_1_full : IN std_logic;
      user_w_wr_1_data : OUT std_logic_vector(31 DOWNTO 0);
      user_w_wr_1_open : OUT std_logic;
      user_r_xcr_ctrl_rden : OUT std_logic;
      user_r_xcr_ctrl_empty : IN std_logic;
      user_r_xcr_ctrl_data : IN std_logic_vector(31 DOWNTO 0);
      user_r_xcr_ctrl_eof : IN std_logic;
      user_r_xcr_ctrl_open : OUT std_logic;
      user_w_xcr_ctrl_wren : OUT std_logic;
      user_w_xcr_ctrl_full : IN std_logic;
      user_w_xcr_ctrl_data : OUT std_logic_vector(31 DOWNTO 0);
      user_w_xcr_ctrl_open : OUT std_logic;
      user_xcr_ctrl_addr : OUT std_logic_vector(4 DOWNTO 0);
      user_xcr_ctrl_addr_update : OUT std_logic;
      user_r_xcw_ctrl_rden : OUT std_logic;
      user_r_xcw_ctrl_empty : IN std_logic;
      user_r_xcw_ctrl_data : IN std_logic_vector(31 DOWNTO 0);
      user_r_xcw_ctrl_eof : IN std_logic;
      user_r_xcw_ctrl_open : OUT std_logic;
      user_w_xcw_ctrl_wren : OUT std_logic;
      user_w_xcw_ctrl_full : IN std_logic;
      user_w_xcw_ctrl_data : OUT std_logic_vector(31 DOWNTO 0);
      user_w_xcw_ctrl_open : OUT std_logic;
      user_xcw_ctrl_addr : OUT std_logic_vector(4 DOWNTO 0);
      user_xcw_ctrl_addr_update : OUT std_logic);
  end component;

  component design_1_wrapper
  port (
  HLS_ARESETN : in STD_LOGIC;
  HLS_DONE : out STD_LOGIC;
  HLS_IDLE : out STD_LOGIC;
  HLS_READY : out STD_LOGIC;
  HLS_START : in STD_LOGIC;
  PCIE_CLK : in STD_LOGIC;
  PCIE_FIFO_RD_0_empty : out STD_LOGIC;
  PCIE_FIFO_RD_0_rd_data : out STD_LOGIC_VECTOR ( 31 downto 0 );
  PCIE_FIFO_RD_0_rd_en : in STD_LOGIC;
  PCIE_RST_RD_0 : in STD_LOGIC;
  PCIE_RST_WR_0 : in STD_LOGIC;
  PCIE_RST_WR_1 : in STD_LOGIC;
  PCIE_S_AXIS_0_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
  PCIE_S_AXIS_0_tlast : in STD_LOGIC;
  PCIE_S_AXIS_0_tready : out STD_LOGIC;
  PCIE_S_AXIS_0_tvalid : in STD_LOGIC;
  PCIE_S_AXIS_1_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
  PCIE_S_AXIS_1_tlast : in STD_LOGIC;
  PCIE_S_AXIS_1_tready : out STD_LOGIC;
  PCIE_S_AXIS_1_tvalid : in STD_LOGIC
  );
  end component;

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~ Definition ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  signal bus_clk :  std_logic;
  
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~ Xillybus'  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  signal quiesce : std_logic;
  signal user_r_rd_0_rden :  std_logic;
  signal user_r_rd_0_empty :  std_logic;
  signal user_r_rd_0_data :  std_logic_vector(31 DOWNTO 0);
  signal user_r_rd_0_eof :  std_logic;
  signal user_r_rd_0_open :  std_logic;
  signal user_w_wr_0_wren :  std_logic;
  signal user_w_wr_0_full :  std_logic;
  signal user_w_wr_0_data :  std_logic_vector(31 DOWNTO 0);
  signal user_w_wr_0_open :  std_logic;
  signal user_w_wr_1_wren :  std_logic;
  signal user_w_wr_1_full :  std_logic;
  signal user_w_wr_1_data :  std_logic_vector(31 DOWNTO 0);
  signal user_w_wr_1_open :  std_logic;
  signal user_r_xcr_ctrl_rden :  std_logic;
  signal user_r_xcr_ctrl_empty :  std_logic;
  signal user_r_xcr_ctrl_data :  std_logic_vector(31 DOWNTO 0);
  signal user_r_xcr_ctrl_eof :  std_logic;
  signal user_r_xcr_ctrl_open :  std_logic;
  signal user_w_xcr_ctrl_wren :  std_logic;
  signal user_w_xcr_ctrl_full :  std_logic;
  signal user_w_xcr_ctrl_data :  std_logic_vector(31 DOWNTO 0);
  signal user_w_xcr_ctrl_open :  std_logic;
  signal user_xcr_ctrl_addr :  std_logic_vector(4 DOWNTO 0);
  signal user_xcr_ctrl_addr_update :  std_logic;
  signal user_r_xcw_ctrl_rden :  std_logic;
  signal user_r_xcw_ctrl_empty :  std_logic;
  signal user_r_xcw_ctrl_data :  std_logic_vector(31 DOWNTO 0);
  signal user_r_xcw_ctrl_eof :  std_logic;
  signal user_r_xcw_ctrl_open :  std_logic;
  signal user_w_xcw_ctrl_wren :  std_logic;
  signal user_w_xcw_ctrl_full :  std_logic;
  signal user_w_xcw_ctrl_data :  std_logic_vector(31 DOWNTO 0);
  signal user_w_xcw_ctrl_open :  std_logic;
  signal user_xcw_ctrl_addr :  std_logic_vector(4 DOWNTO 0);
  signal user_xcw_ctrl_addr_update :  std_logic;

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~ Custom PCIe's Interface ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  signal rst_rd_0 : std_logic;
  signal rst_wr_0 : std_logic;
  signal s_tready_0 : std_logic;
  signal user_w_wr_0_tlast : std_logic;
  signal nr_of_writes_0 : std_logic_vector(31 DOWNTO 0);
  signal rst_wr_1 : std_logic;
  signal s_tready_1 : std_logic;
  signal user_w_wr_1_tlast : std_logic;
  signal nr_of_writes_1 : std_logic_vector(31 DOWNTO 0);

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~ Register Memory  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  type reg_mem is array(0 TO 31) of std_logic_vector(31 DOWNTO 0);
  signal array_xcr : reg_mem;
  signal array_xcw : reg_mem;
  signal xcr_ctrl_addr : integer range 0 to 31;
  signal xcw_ctrl_addr : integer range 0 to 31;

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~ HLS Interface  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  signal hls_cmd_AP_ARESETN : std_logic;
  signal hls_stat_AP_DONE : std_logic;
  signal hls_stat_AP_IDLE : std_logic;
  signal hls_stat_AP_READY : std_logic;
  signal hls_cmd_AP_START : std_logic;
    
begin

  xillybus_ins : xillybus
    port map (
      -- Ports related to /dev/xillybus_rd_0
      -- FPGA to CPU signals:
      user_r_rd_0_rden => user_r_rd_0_rden,
      user_r_rd_0_empty => user_r_rd_0_empty,
      user_r_rd_0_data => user_r_rd_0_data,
      user_r_rd_0_eof => user_r_rd_0_eof,
      user_r_rd_0_open => user_r_rd_0_open,

      -- Ports related to /dev/xillybus_wr_0
      -- CPU to FPGA signals:
      user_w_wr_0_wren => user_w_wr_0_wren,
      user_w_wr_0_full => user_w_wr_0_full,
      user_w_wr_0_data => user_w_wr_0_data,
      user_w_wr_0_open => user_w_wr_0_open,

      -- Ports related to /dev/xillybus_wr_1
      -- CPU to FPGA signals:
      user_w_wr_1_wren => user_w_wr_1_wren,
      user_w_wr_1_full => user_w_wr_1_full,
      user_w_wr_1_data => user_w_wr_1_data,
      user_w_wr_1_open => user_w_wr_1_open,

      -- Ports related to /dev/xillybus_xcr_ctrl
      -- FPGA to CPU signals:
      user_r_xcr_ctrl_rden => user_r_xcr_ctrl_rden,
      user_r_xcr_ctrl_empty => user_r_xcr_ctrl_empty,
      user_r_xcr_ctrl_data => user_r_xcr_ctrl_data,
      user_r_xcr_ctrl_eof => user_r_xcr_ctrl_eof,
      user_r_xcr_ctrl_open => user_r_xcr_ctrl_open,
      -- CPU to FPGA signals:
      user_w_xcr_ctrl_wren => user_w_xcr_ctrl_wren,
      user_w_xcr_ctrl_full => user_w_xcr_ctrl_full,
      user_w_xcr_ctrl_data => user_w_xcr_ctrl_data,
      user_w_xcr_ctrl_open => user_w_xcr_ctrl_open,
      -- Address signals:
      user_xcr_ctrl_addr => user_xcr_ctrl_addr,
      user_xcr_ctrl_addr_update => user_xcr_ctrl_addr_update,

      -- Ports related to /dev/xillybus_xcw_ctrl
      -- FPGA to CPU signals:
      user_r_xcw_ctrl_rden => user_r_xcw_ctrl_rden,
      user_r_xcw_ctrl_empty => user_r_xcw_ctrl_empty,
      user_r_xcw_ctrl_data => user_r_xcw_ctrl_data,
      user_r_xcw_ctrl_eof => user_r_xcw_ctrl_eof,
      user_r_xcw_ctrl_open => user_r_xcw_ctrl_open,
      -- CPU to FPGA signals:
      user_w_xcw_ctrl_wren => user_w_xcw_ctrl_wren,
      user_w_xcw_ctrl_full => user_w_xcw_ctrl_full,
      user_w_xcw_ctrl_data => user_w_xcw_ctrl_data,
      user_w_xcw_ctrl_open => user_w_xcw_ctrl_open,
      -- Address signals:
      user_xcw_ctrl_addr => user_xcw_ctrl_addr,
      user_xcw_ctrl_addr_update => user_xcw_ctrl_addr_update,

      -- General signals
      PCIE_PERST_B_LS => PCIE_PERST_B_LS,
      PCIE_REFCLK_N => PCIE_REFCLK_N,
      PCIE_REFCLK_P => PCIE_REFCLK_P,
      PCIE_RX_N => PCIE_RX_N,
      PCIE_RX_P => PCIE_RX_P,
      GPIO_LED => GPIO_LED,
      PCIE_TX_N => PCIE_TX_N,
      PCIE_TX_P => PCIE_TX_P,
      bus_clk => bus_clk,
      quiesce => quiesce
  );

design_1_i: component design_1_wrapper
    port map (
    HLS_ARESETN => hls_cmd_AP_ARESETN,
    HLS_DONE => hls_stat_AP_DONE,
    HLS_IDLE => hls_stat_AP_IDLE,
    HLS_READY => hls_stat_AP_READY,
    HLS_START => hls_cmd_AP_START,
    PCIE_CLK => bus_clk,
    PCIE_FIFO_RD_0_empty => user_r_rd_0_empty,
    PCIE_FIFO_RD_0_rd_data => user_r_rd_0_data,
    PCIE_FIFO_RD_0_rd_en => user_r_rd_0_rden,
    PCIE_RST_RD_0 => rst_rd_0,
    PCIE_RST_WR_0 => rst_wr_0,
    PCIE_RST_WR_1 => rst_wr_1,
    PCIE_S_AXIS_0_tdata => user_w_wr_0_data,
    PCIE_S_AXIS_0_tlast => user_w_wr_0_tlast,
    PCIE_S_AXIS_0_tready => s_tready_0,
    PCIE_S_AXIS_0_tvalid => user_w_wr_0_wren,
    PCIE_S_AXIS_1_tdata => user_w_wr_1_data,
    PCIE_S_AXIS_1_tlast => user_w_wr_1_tlast,
    PCIE_S_AXIS_1_tready => s_tready_1,
    PCIE_S_AXIS_1_tvalid => user_w_wr_1_wren
    );

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
------------------------------ HLS interface -----------------------------------
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  hls_cmd_AP_START <= array_xcw(14)(0) or array_xcr(14)(0);
  hls_cmd_AP_ARESETN <= array_xcw(15)(0) or array_xcr(15)(0);

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-------------------------- user_*_xcr_ctrl_* -----------------------------------
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- 
-- if the software perform write_addr(ADDR08, 0xDEADBEEF),
-- the following signals are:
-- user_w_cmd_stat_wren = '1'
-- user_cmd_stat_addr = x"08"
--

  user_r_xcr_ctrl_empty <= '0';
  user_r_xcr_ctrl_eof <= '0';
  user_w_xcr_ctrl_full <= '0';
  xcr_ctrl_addr <= conv_integer(user_xcr_ctrl_addr);
  
  process (bus_clk)
  begin
    if (bus_clk'event and bus_clk = '1') then
      if (user_w_xcr_ctrl_wren = '1') then 
        array_xcr(xcr_ctrl_addr) <= user_w_xcr_ctrl_data;
      end if;
      -- ADDR_HLS_STAT
      array_xcr(13) <= x"00000000000000000000000000000" & 
                       hls_stat_AP_IDLE & 
                       hls_stat_AP_DONE & 
                       hls_stat_AP_READY;
    end if;
  end process;
  
  process (bus_clk)
  begin
    if (bus_clk'event and bus_clk = '1') then
      if (user_r_xcr_ctrl_rden = '1') then
        -- if XCR request read, use XCW address
        user_r_xcr_ctrl_data <= array_xcw(xcr_ctrl_addr);
      end if;
    end if;
  end process;
    
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-------------------------- user_*_xcw_ctrl_* -----------------------------------
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  user_r_xcw_ctrl_empty <= '0';
  user_r_xcw_ctrl_eof <= '0';
  user_w_xcw_ctrl_full <= '0';
  xcw_ctrl_addr <= conv_integer(user_xcw_ctrl_addr);
  
  process (bus_clk)
  begin
    if (bus_clk'event and bus_clk = '1') then
      if (user_w_xcw_ctrl_wren = '1') then 
        array_xcw(xcw_ctrl_addr) <= user_w_xcw_ctrl_data;
      end if;
      -- ADDR_HLS_STAT
      array_xcw(13) <= x"00000000000000000000000000000" & 
                       hls_stat_AP_IDLE & 
                       hls_stat_AP_DONE & 
                       hls_stat_AP_READY;
    end if;
  end process;
  
  process (bus_clk)
  begin
    if (bus_clk'event and bus_clk = '1') then
      if (user_r_xcw_ctrl_rden = '1') then
        -- if XCW request read, use XCR address
        user_r_xcw_ctrl_data <= array_xcr(xcw_ctrl_addr);
      end if;
    end if;
  end process;

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------------- nr_of_writes_* -------------------------------------
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  process (bus_clk, user_w_xcw_ctrl_wren, 
           user_w_wr_0_wren, nr_of_writes_0,
           user_w_wr_1_wren, nr_of_writes_1) is
  begin 
    if (bus_clk'event and bus_clk='1') then
      if(array_xcw(15)(0) = '1') then
         nr_of_writes_0 <= (others => '0');
      else 
        if(user_w_xcw_ctrl_wren = '1') then -- if writing to BRAM
          nr_of_writes_0 <= user_w_xcw_ctrl_data;
        else
          if (user_w_wr_0_wren = '1' and nr_of_writes_0 /= 0) then
            nr_of_writes_0 <= nr_of_writes_0 - 4;
          else
            nr_of_writes_0 <= nr_of_writes_0;
          end if;
        end if;
      end if;  
    end if; 
  end process; 
  
  process (bus_clk, user_w_xcw_ctrl_wren, 
           user_w_wr_1_wren, nr_of_writes_1) is
  begin 
    if (bus_clk'event and bus_clk='1') then
      if(array_xcw(15)(0) = '1') then
       nr_of_writes_0 <= (others => '0');
      else 
        if(user_w_xcw_ctrl_wren = '1') then -- if writing to BRAM
          nr_of_writes_1 <= user_w_xcw_ctrl_data;
        else
          if (user_w_wr_1_wren = '1' and nr_of_writes_1 /= 0) then
            nr_of_writes_1 <= nr_of_writes_1 - 4;
          else
            nr_of_writes_1 <= nr_of_writes_1;
          end if;
        end if;
      end if;  
    end if; 
  end process; 

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-------------------- PCIE CHANNEL 0 : READ -------------------------------------
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  rst_rd_0 <= not (user_r_rd_0_open);
  user_r_rd_0_eof <= '0';
  
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-------------------- PCIE CHANNEL 0 : WRITE ------------------------------------
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  rst_wr_0 <= (user_w_wr_0_open);
  user_w_wr_0_full <= not s_tready_0;
  
  process (bus_clk, rst_wr_0, nr_of_writes_0) 
  begin
    if bus_clk'event and bus_clk = '1' then
      if(rst_wr_0 = '0') then
        user_w_wr_0_tlast <= '0';
      else 
        if (nr_of_writes_0 < 8) then
          user_w_wr_0_tlast <= '1';
        end if;
      end if;
    end if;
  end process;    

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-------------------- PCIE CHANNEL 1 : WRITE ------------------------------------
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  rst_wr_1 <= (user_w_wr_1_open);
  user_w_wr_1_full <= not s_tready_1;

  process (bus_clk, rst_wr_1, nr_of_writes_1) 
  begin
    if bus_clk'event and bus_clk = '1' then
      if(rst_wr_1 = '0') then
        user_w_wr_1_tlast <= '0';
      else 
        if (nr_of_writes_1 < 8) then
          user_w_wr_1_tlast <= '1';
        end if;
      end if;
    end if;
  end process;    
  
end sample_arch;
