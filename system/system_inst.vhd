	component system is
		port (
			clk_clk                     : in  std_logic                     := 'X';             -- clk
			axi4s_vid_out_1_tdata       : out std_logic_vector(23 downto 0);                    -- tdata
			axi4s_vid_out_1_tvalid      : out std_logic;                                        -- tvalid
			axi4s_vid_out_1_tready      : in  std_logic                     := 'X';             -- tready
			axi4s_vid_out_1_tlast       : out std_logic;                                        -- tlast
			axi4s_vid_out_1_tuser       : out std_logic_vector(2 downto 0);                     -- tuser
			axi4s_vid_in_tdata          : in  std_logic_vector(23 downto 0) := (others => 'X'); -- tdata
			axi4s_vid_in_tvalid         : in  std_logic                     := 'X';             -- tvalid
			axi4s_vid_in_tready         : out std_logic;                                        -- tready
			axi4s_vid_in_tlast          : in  std_logic                     := 'X';             -- tlast
			axi4s_vid_in_tuser          : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- tuser
			axi4s_vid_out_tdata         : out std_logic_vector(23 downto 0);                    -- tdata
			axi4s_vid_out_tvalid        : out std_logic;                                        -- tvalid
			axi4s_vid_out_tready        : in  std_logic                     := 'X';             -- tready
			axi4s_vid_out_tlast         : out std_logic;                                        -- tlast
			axi4s_vid_out_tuser         : out std_logic_vector(2 downto 0);                     -- tuser
			control_agent_address       : in  std_logic_vector(6 downto 0)  := (others => 'X'); -- address
			control_agent_write         : in  std_logic                     := 'X';             -- write
			control_agent_byteenable    : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable
			control_agent_writedata     : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			control_agent_read          : in  std_logic                     := 'X';             -- read
			control_agent_readdata      : out std_logic_vector(31 downto 0);                    -- readdata
			control_agent_readdatavalid : out std_logic;                                        -- readdatavalid
			control_agent_waitrequest   : out std_logic;                                        -- waitrequest
			reset_reset                 : in  std_logic                     := 'X'              -- reset
		);
	end component system;

	u0 : component system
		port map (
			clk_clk                     => CONNECTED_TO_clk_clk,                     --             clk.clk
			axi4s_vid_out_1_tdata       => CONNECTED_TO_axi4s_vid_out_1_tdata,       -- axi4s_vid_out_1.tdata
			axi4s_vid_out_1_tvalid      => CONNECTED_TO_axi4s_vid_out_1_tvalid,      --                .tvalid
			axi4s_vid_out_1_tready      => CONNECTED_TO_axi4s_vid_out_1_tready,      --                .tready
			axi4s_vid_out_1_tlast       => CONNECTED_TO_axi4s_vid_out_1_tlast,       --                .tlast
			axi4s_vid_out_1_tuser       => CONNECTED_TO_axi4s_vid_out_1_tuser,       --                .tuser
			axi4s_vid_in_tdata          => CONNECTED_TO_axi4s_vid_in_tdata,          --    axi4s_vid_in.tdata
			axi4s_vid_in_tvalid         => CONNECTED_TO_axi4s_vid_in_tvalid,         --                .tvalid
			axi4s_vid_in_tready         => CONNECTED_TO_axi4s_vid_in_tready,         --                .tready
			axi4s_vid_in_tlast          => CONNECTED_TO_axi4s_vid_in_tlast,          --                .tlast
			axi4s_vid_in_tuser          => CONNECTED_TO_axi4s_vid_in_tuser,          --                .tuser
			axi4s_vid_out_tdata         => CONNECTED_TO_axi4s_vid_out_tdata,         --   axi4s_vid_out.tdata
			axi4s_vid_out_tvalid        => CONNECTED_TO_axi4s_vid_out_tvalid,        --                .tvalid
			axi4s_vid_out_tready        => CONNECTED_TO_axi4s_vid_out_tready,        --                .tready
			axi4s_vid_out_tlast         => CONNECTED_TO_axi4s_vid_out_tlast,         --                .tlast
			axi4s_vid_out_tuser         => CONNECTED_TO_axi4s_vid_out_tuser,         --                .tuser
			control_agent_address       => CONNECTED_TO_control_agent_address,       --   control_agent.address
			control_agent_write         => CONNECTED_TO_control_agent_write,         --                .write
			control_agent_byteenable    => CONNECTED_TO_control_agent_byteenable,    --                .byteenable
			control_agent_writedata     => CONNECTED_TO_control_agent_writedata,     --                .writedata
			control_agent_read          => CONNECTED_TO_control_agent_read,          --                .read
			control_agent_readdata      => CONNECTED_TO_control_agent_readdata,      --                .readdata
			control_agent_readdatavalid => CONNECTED_TO_control_agent_readdatavalid, --                .readdatavalid
			control_agent_waitrequest   => CONNECTED_TO_control_agent_waitrequest,   --                .waitrequest
			reset_reset                 => CONNECTED_TO_reset_reset                  --           reset.reset
		);

