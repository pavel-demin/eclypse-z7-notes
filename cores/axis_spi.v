
`timescale 1 ns / 1 ps

module axis_spi #
(
  parameter integer SPI_DATA_WIDTH = 16
)
(
  // System signals
  input  wire        aclk,
  input  wire        aresetn,

  output wire [2:0]  spi_data,

  // Slave side
  output wire        s_axis_tready,
  input  wire [31:0] s_axis_tdata,
  input  wire        s_axis_tvalid
);

  reg [SPI_DATA_WIDTH-1:0] int_data_reg, int_data_next;
  reg [8:0] int_cntr_reg, int_cntr_next;
  reg int_enbl_reg, int_enbl_next;
  reg int_ssel_reg, int_ssel_next;
  reg int_tready_reg, int_tready_next;

  always @(posedge aclk)
  begin
    if(~aresetn)
    begin
      int_data_reg <= {(SPI_DATA_WIDTH){1'b0}};
      int_cntr_reg <= 9'd0;
      int_enbl_reg <= 1'b0;
      int_ssel_reg <= 1'b1;
      int_tready_reg <= 1'b0;
    end
    else
    begin
      int_data_reg <= int_data_next;
      int_cntr_reg <= int_cntr_next;
      int_enbl_reg <= int_enbl_next;
      int_ssel_reg <= int_ssel_next;
      int_tready_reg <= int_tready_next;
    end
  end

  always @*
  begin
    int_data_next = int_data_reg;
    int_cntr_next = int_cntr_reg;
    int_enbl_next = int_enbl_reg;
    int_ssel_next = int_ssel_reg;
    int_tready_next = int_tready_reg;

    if(s_axis_tvalid & ~int_enbl_reg)
    begin
      int_data_next = s_axis_tdata[SPI_DATA_WIDTH-1:0];
      int_enbl_next = 1'b1;
      int_ssel_next = 1'b0;
      int_tready_next = 1'b1;
    end

    if(int_tready_reg)
    begin
      int_tready_next = 1'b0;
    end

    if(int_enbl_reg)
    begin
      int_cntr_next = int_cntr_reg + 1'b1;
    end

    if(&int_cntr_reg[2:0])
    begin
      if(int_cntr_reg[8:3] == SPI_DATA_WIDTH)
      begin
        int_cntr_next = 9'd0;
        int_enbl_next = 1'b0;
      end
      else if(int_cntr_reg[8:3] == (SPI_DATA_WIDTH - 1))
      begin
        int_ssel_next = 1'b1;
      end
      else
      begin
        int_data_next = {int_data_reg[SPI_DATA_WIDTH-2:0], 1'b0};
      end
    end

  end

  assign s_axis_tready = int_tready_reg;

  assign spi_data[0] = int_data_reg[SPI_DATA_WIDTH-1];
  assign spi_data[1] = int_cntr_reg[2];
  assign spi_data[2] = int_ssel_reg;

endmodule
