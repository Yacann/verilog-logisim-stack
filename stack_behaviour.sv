`define NOP 2'b00
`define PUSH 2'b01 
`define POP 2'b10
`define GET 2'b11

module stack_behaviour(
	inout wire[3:0] IO_DATA,
    input wire RESET, 
    input wire CLK, 
    input wire[1:0] COMMAND, 
    input wire[2:0] INDEX
	); 

	reg [3:0]MEMORY[4:0];
	reg [2:0]POINTER;
	reg [2:0]IND;
	reg [3:0]OUTPUT;
  	integer i;

	assign IO_DATA = OUTPUT;
	always @(posedge CLK) begin
      	if (RESET) begin
          	POINTER[2:0] = 3'b000;
        	for (i = 0; i < 5; i++) begin
            	MEMORY[i]= 4'b0000;
            end
        end
		if (COMMAND == `NOP) begin
			OUTPUT = 4'b?;
		end else if (COMMAND == `PUSH) begin
			MEMORY[POINTER] = IO_DATA;
			if (POINTER == 4)
				POINTER = 0;
			else
				POINTER = POINTER + 1;
		end else if (COMMAND == `POP) begin
			if (POINTER == 0)
				POINTER = 4;
			else
				POINTER = POINTER - 1;
			OUTPUT = MEMORY[POINTER];
		end else if (COMMAND == `GET) begin
			if (POINTER > INDEX)
				IND = POINTER - INDEX - 1;
			else if (POINTER + 5 > INDEX)
				IND = POINTER + 4 - INDEX;
			else
				IND = POINTER + 9 - INDEX;
			OUTPUT = MEMORY[IND];
        end
	end

	always @(negedge CLK) begin
        OUTPUT = 4'b?;
    end
	
endmodule