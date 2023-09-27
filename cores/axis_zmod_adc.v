
`timescale 1 ns / 1 ps

module axis_zmod_adc #
(
  parameter integer ADC_DATA_WIDTH = 14,
  parameter integer AXIS_TDATA_WIDTH = 32
)
(
  // System signals
  input  wire                        aclk,

  // ADC signals
  input  wire [ADC_DATA_WIDTH-1:0]   adc_data,

  // Master side
  output wire                        m_axis_tvalid,
  output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata
);
  localparam PADDING_WIDTH = AXIS_TDATA_WIDTH/2 - ADC_DATA_WIDTH;

  wire [ADC_DATA_WIDTH-1:0] int_data_a_wire;
  wire [ADC_DATA_WIDTH-1:0] int_data_b_wire;

  genvar j;

  generate
    for(j = 0; j < ADC_DATA_WIDTH; j = j + 1)
    begin : ADC_DATA
      IDDR #(
        .DDR_CLK_EDGE("SAME_EDGE_PIPELINED")
      ) IDDR_inst (
        .Q1(int_data_a_wire[j]),
        .Q2(int_data_b_wire[j]),
        .D(adc_data[j]),
        .C(aclk),
        .CE(1'b1),
        .R(1'b0),
        .S(1'b0)
      );
    end
  endgenerate

  assign m_axis_tvalid = 1'b1;

  assign m_axis_tdata = {
    {(PADDING_WIDTH+1){int_data_b_wire[ADC_DATA_WIDTH-1]}}, int_data_b_wire[ADC_DATA_WIDTH-2:0],
    {(PADDING_WIDTH+1){int_data_a_wire[ADC_DATA_WIDTH-1]}}, int_data_a_wire[ADC_DATA_WIDTH-2:0]};

endmodule
