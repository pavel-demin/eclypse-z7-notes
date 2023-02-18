
`timescale 1 ns / 1 ps

module cdce_gpio
(
  input wire       aclk,

  inout wire [4:0] gpio
);

  reg [7:0] int_cntr_reg = 8'd0;

  wire int_and_wire = &int_cntr_reg;

  always @(posedge aclk)
  begin
    if(~int_and_wire)
    begin
      int_cntr_reg <= int_cntr_reg + 1'b1;
    end
  end

  assign gpio = {4'bzzzz, int_and_wire};

endmodule
