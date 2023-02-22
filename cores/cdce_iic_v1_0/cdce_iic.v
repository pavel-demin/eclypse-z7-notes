
`timescale 1 ns / 1 ps

module cdce_iic #
(
  parameter integer DATA_SIZE = 64,
  parameter         DATA_FILE = "none"
)
(
  input wire       aclk,

  inout wire [1:0] iic
);

  reg [7:0] int_addr_reg = 8'd0;
  reg [13:0] int_cntr_reg = 14'd0;
  reg [31:0] int_data_reg = 32'd0;
  reg int_scl_reg = 1'b1;
  reg int_sda_reg = 1'b1;
  reg int_valid_reg = 1'b0;

  wire [31:0] int_data_wire;

  xpm_memory_sprom #(
    .MEMORY_PRIMITIVE("distributed"),
    .MEMORY_SIZE(8192),
    .ADDR_WIDTH_A(8),
    .READ_DATA_WIDTH_A(32),
    .READ_LATENCY_A(1),
    .MEMORY_INIT_PARAM(""),
    .MEMORY_INIT_FILE(DATA_FILE)
  ) rom_0 (
    .clka(aclk),
    .rsta(1'b0),
    .ena(1'b1),
    .addra(int_addr_reg),
    .douta(int_data_wire)
  );

  always @(posedge aclk)
  begin
    int_valid_reg <= 1'b1;

    if(|int_cntr_reg)
    begin
      int_cntr_reg <= int_cntr_reg - 1'b1;
    end
    else if(int_valid_reg & int_addr_reg < DATA_SIZE)
    begin
      int_addr_reg <= int_addr_reg + 1'b1;
      int_cntr_reg <= {14'h3fff};
      int_data_reg <= int_data_wire;
    end

    if(int_cntr_reg[9:0] == 10'h3ff)
    begin
      int_data_reg[31:16] <= {int_data_reg[30:16], 1'b0};
      int_scl_reg <= int_data_reg[31];
    end

    if(int_cntr_reg[9:0] == 10'h2ff)
    begin
      int_data_reg[15:0] <= {int_data_reg[14:0], 1'b0};
      int_sda_reg <= int_data_reg[15];
    end

    if(int_cntr_reg[9:0] == 10'h1ff)
    begin
      int_scl_reg <= 1'b1;
    end
  end

  assign iic = {int_sda_reg ? 1'bz : 1'b0, int_scl_reg ? 1'bz : 1'b0};

endmodule
