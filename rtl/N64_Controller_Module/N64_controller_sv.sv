///////////////////////////////////////////////////////////////////////////////
//   __  __          _____      _         _   _  ______      _______ _____   //
//  |  \/  |   /\   |  __ \    | |  /\   | \ | |/ __ \ \    / /_   _/ ____|  //
//  | \  / |  /  \  | |__) |   | | /  \  |  \| | |  | \ \  / /  | || |       //
//  | |\/| | / /\ \ |  _  /_   | |/ /\ \ | . ` | |  | |\ \/ /   | || |       //
//  | |  | |/ ____ \| | \ \ |__| / ____ \| |\  | |__| | \  /   _| || |____   //
//  |_|  |_/_/    \_\_|  \_\____/_/    \_\_| \_|\____/   \/   |_____\_____|  //
//                                                                           //
//                          JAN MARJANOVIC, 2014                             //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/100ps

module N64_controller 
(
	input A, B, R, L, Z, START,
	input yellow_UP, yellow_DOWN, yellow_LEFT, yellow_RIGHT,
	input gray_UP, gray_DOWN, gray_LEFT, gray_RIGHT,
	input [7:0] joystick_X, joystick_Y,
	inout out
);


logic out_reg = 1'bz;
assign out = out_reg;

task out_0();
	out_reg	= 1'b0;
	#3_200;
	out_reg	= 1'b1;
	#800;
endtask

task out_1();
	out_reg	= 1'b0;
	#1_500;
	out_reg	= 1'b1;
	#2_500;
endtask

task out_Z();
	out_reg	= 1'bz;
endtask

initial begin
	out_Z();

	forever begin
		/*
		#1_000_000; // #40_000_000;
		out_reg	<= 1'b0;
		#4_000;
		// Header
		for ( int i = 0; i < 7; i++) begin
			out_0();
		end
		out_1();
		out_1();
		*/
		
		int i = 0;
		byte header = 0;
		
		repeat(9) begin
			@(negedge out) begin
				#(2us)
				if( i < 8 ) header <= {header[6:1], out}; 
				i++;			
			end
		end
		
		if( header != 8'h01 ) begin
			$display("%t: N64 controller: wrong header (%x), not responing to request", $time(), header);
			continue;
		end
		
		$display("%t: N64 controller: Header OK", $time());
		#(1us)	

		// A, B, Z, START
		if( A )		out_1(); else out_0();
		if( B )		out_1(); else out_0();
		if( Z )		out_1(); else out_0();
		if( START )	out_1(); else out_0();

		// Gray
		if( gray_UP )		out_1(); else out_0();
		if( gray_DOWN )		out_1(); else out_0();
		if( gray_LEFT )		out_1(); else out_0();
		if( gray_RIGHT )	out_1(); else out_0();

		// Two ?
		out_0();
		out_0();

		// L, R
		if( L )		out_1(); else out_0();
		if( R )		out_1(); else out_0();

		// Yellow
		if( yellow_UP )		out_1(); else out_0();
		if( yellow_DOWN )	out_1(); else out_0();
		if( yellow_LEFT )	out_1(); else out_0();
		if( yellow_RIGHT )	out_1(); else out_0();

		// Joystick X
		for ( int i = 7; i >= 0; i--) begin
			if( joystick_X[i] )	out_1(); else out_0();
		end

		// Joystick Y
		for ( int i = 7; i >= 0; i--) begin
			if( joystick_Y[i] )	out_1(); else out_0();
		end

		out_1();
		
		out_Z();
		
	end
end


endmodule