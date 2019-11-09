`timescale 1ns / 1ps
module pif_rom(
    input               clk,
    
    input       [10:0]  address,
	input				oe,
	output reg			valid,
    output reg  [7:0]   q_a
    
);

    reg [63:0]  mem [255:0];
    reg [2:0]   temp_address;
    reg [63:0]  temp_data;
    
    integer i;
    initial begin
    
        for(i = 0; i < 255; i = i + 1) begin
            mem[i] = 64'h0;
        end
        mem[000] = 64'h408960003C093400;
        mem[001] = 64'h3529E4633C090006;
        mem[002] = 64'h3C08A40440898000;
        mem[003] = 64'h310800018D080010;
        mem[004] = 64'h3C08A4045100FFFD;
        mem[005] = 64'h3C01A4042408000A;
        mem[006] = 64'h3C08A404AC280010;
        mem[007] = 64'h310800018D080018;
        mem[008] = 64'h3C08A4045500FFFD;
        mem[009] = 64'h3C01A46024080003;
        mem[010] = 64'h240803FFAC280010;
        mem[011] = 64'hAC28000C3C01A440;
        mem[012] = 64'hAC2000243C01A440;
        mem[013] = 64'hAC2000103C01A440;
        mem[014] = 64'hAC2000003C01A450;
        mem[015] = 64'hAC2000043C01A450;
        mem[016] = 64'h8D0800103C08A404;
        mem[017] = 64'h5500FFFD31080004;
        mem[018] = 64'h3C0BA4003C08A404;
        mem[019] = 64'h3C0DBFC03C0CBFC0;
        mem[020] = 64'h258C00D4256B1000;
        mem[021] = 64'h8D89000025AD071C;
        mem[022] = 64'h256B0004258C0004;
        mem[023] = 64'hAD69FFFC158DFFFC;
        mem[024] = 64'h3C1DA4003C0BA400;
        mem[025] = 64'h01600008256B1000;
        mem[026] = 64'h3C0DBFC037BD1FF0;
        mem[027] = 64'h25AD07C08DA807FC;
        mem[028] = 64'h0000000031080080; //5500FFFC
        mem[029] = 64'h8DA8002400000000; //3C0DBFC0
        mem[030] = 64'h00089CC23C0BB000;
        mem[031] = 64'h0008BC8232730001;
        mem[032] = 64'h32F7000112600002;
        mem[033] = 64'h0008B2023C0BA600;
        mem[034] = 64'h0008AC42310A00FF;
        mem[035] = 64'h240900108DA8003C;
        mem[036] = 64'h32B5000132D600FF;
        mem[037] = 64'h0109402524140001;
        mem[038] = 64'h8D2900183C09A480;
        mem[039] = 64'h5520FFFD31290002;
        mem[040] = 64'hADA8003C3C09A480;
        mem[041] = 64'h240800FF3C0CA460;
        mem[042] = 64'hAD880018AD880014;
        mem[043] = 64'hAD88001C2408000F;
        mem[044] = 64'hAD88002024080003;
        mem[045] = 64'h3C0DA4108D690000;
        mem[046] = 64'h312800FF258C0000;
        mem[047] = 64'h00094202AD880014;
        mem[048] = 64'h00094402AD880018;
        mem[049] = 64'h00094502AD88001C;
        mem[050] = 64'h8DAF000CAD880020;
        mem[051] = 64'h216B004020080FC0;
        mem[052] = 64'h11E0000731EF0001;
        mem[053] = 64'h3C0DA41025AD000C;
        mem[054] = 64'h25AD000C8DAF000C;
        mem[055] = 64'h55E0FFFC31EF0020;
        mem[056] = 64'h3C0DA4003C0DA410;
        mem[057] = 64'h0008302525AD0000;
        mem[058] = 64'h8D69000021AD0040;
        mem[059] = 64'h216B00042108FFFC;
        mem[060] = 64'h1500FFFB21AD0004;
        mem[061] = 64'h3C086C07ADA9FFFC;
        mem[062] = 64'h0148001935088965;
        mem[063] = 64'h2484000100002012;
        mem[064] = 64'h24A500403C05A400;
        mem[065] = 64'h0000000004110013; // mem[065] = 64'h0000000004110013
         mem[066] = 64'h14A0000227BDFFD0;
         mem[067] = 64'h00C02825AFBF001C;
         mem[068] = 64'h041100FF27A6002C;
         mem[069] = 64'h8FA4002827A70028;
         mem[070] = 64'h01C410238FAE002C;
         mem[071] = 64'h0040182514400002;
         mem[072] = 64'h8FBF001C00801825;
         mem[073] = 64'h0060102527BD0030;
         mem[074] = 64'h0000000003E00008;
         mem[075] = 64'hAFBF003C27BDFF20;
         mem[076] = 64'hAFB60030AFB70034;
         mem[077] = 64'hAFB40028AFB5002C;
         mem[078] = 64'hAFB20020AFB30024;
         mem[079] = 64'hAFB00018AFB1001C;
         mem[080] = 64'h000018258CAE0000;
         mem[081] = 64'h27A2007427A300B4;
         mem[082] = 64'h2442001001C48026;
         mem[083] = 64'hAC50FFF8AC50FFF4;
         mem[084] = 64'h1443FFFBAC50FFFC;
         mem[085] = 64'h8CB00000AC50FFF0;
         mem[086] = 64'h00A0B02500008825;
         mem[087] = 64'h0200A02524170020;
         mem[088] = 64'h263100018ED00000;
         mem[089] = 64'h8ED30004240F03EF;
         mem[090] = 64'h01F1202326D60004;
         mem[091] = 64'h0411FFCC02203025;
         mem[092] = 64'h8FA3007402002825;
         mem[093] = 64'h020028258FA40078;
         mem[094] = 64'hAFA3007400431821;
         mem[095] = 64'h022030250411FFC5;
         mem[096] = 64'h3C056C078FB8007C;
         mem[097] = 64'h0310C826AFA20078;
         mem[098] = 64'h34A58965AFB9007C;
         mem[099] = 64'h0411FFBC26040005;
         mem[100] = 64'h8FA8008002203025;
         mem[101] = 64'h004848210290082B;
         mem[102] = 64'hAFA9008010200007;
         mem[103] = 64'h020028258FA40098;
         mem[104] = 64'h022030250411FFB3;
         mem[105] = 64'hAFA2009810000004;
         mem[106] = 64'h015058218FAA0098;
         mem[107] = 64'h3282001FAFAB0098;
         mem[108] = 64'h02E218238FAE0084;
         mem[109] = 64'h0050600600706804;
         mem[110] = 64'h0070C806018DA825;
         mem[111] = 64'h01D578210050C004;
         mem[112] = 64'h03192825AFAF0084;
         mem[113] = 64'h0411FFA08FA40090;
         mem[114] = 64'h8FA3008C02203025;
         mem[115] = 64'h0203082BAFA20090;
         mem[116] = 64'h8FAB008450200008;
         mem[117] = 64'h021150218FA80080;
         mem[118] = 64'h012A182601034821;
         mem[119] = 64'hAFA3008C10000005;
         mem[120] = 64'h017060218FAB0084;
         mem[121] = 64'hAFA3008C01831826;
         mem[122] = 64'h8FAF0088001416C2;
         mem[123] = 64'h0070700602E21823;
         mem[124] = 64'h01AE902500506804;
         mem[125] = 64'h0050C80600704004;
         mem[126] = 64'hAFB8008801F2C021;
         mem[127] = 64'h8FA4009403282825;
         mem[128] = 64'h022030250411FF83;
         mem[129] = 64'h12210039240103F0;
         mem[130] = 64'h8FA400B0AFA20094;
         mem[131] = 64'h0411FF7C02402825;
         mem[132] = 64'h00101EC202203025;
         mem[133] = 64'h0153580602E35023;
         mem[134] = 64'h012B282500734804;
         mem[135] = 64'h0411FF7400402025;
         mem[136] = 64'hAFA200B002203025;
         mem[137] = 64'h02A028258FA400AC;
         mem[138] = 64'h022030250411FF6F;
         mem[139] = 64'h02F2A0233212001F;
         mem[140] = 64'h0253600602936804;
         mem[141] = 64'h00402025018D2825;
         mem[142] = 64'h022030250411FF67;
         mem[143] = 64'h3263001F8FA900A8;
         mem[144] = 64'h0290780402507006;
         mem[145] = 64'h01CF382502E3C823;
         mem[146] = 64'h0073C00603334004;
         mem[147] = 64'h030850258FAD009C;
         mem[148] = 64'h016A602101275821;
         mem[149] = 64'hAFAC00A8AFA200AC;
         mem[150] = 64'h0220302502602825;
         mem[151] = 64'h01B020210411FF55;
         mem[152] = 64'hAFA2009C8FAE00A0;
         mem[153] = 64'h0220302502602825;
         mem[154] = 64'h01D020260411FF4F;
         mem[155] = 64'h8FB800A48FAF0094;
         mem[156] = 64'h01F0C826AFA200A0;
         mem[157] = 64'h1000FF7303384021;
         mem[158] = 64'h8FA30074AFA800A4;
         mem[159] = 64'h27B3007400008825;
         mem[160] = 64'h2414000124150010;
         mem[161] = 64'hAFA30068AFA30064;
         mem[162] = 64'hAFA30070AFA3006C;
         mem[163] = 64'h8FAD00648E700000;
         mem[164] = 64'h02E258233202001F;
         mem[165] = 64'h0050480601705004;
         mem[166] = 64'h01AC7021012A6025;
         mem[167] = 64'h10200005020E082B;
         mem[168] = 64'h8FAF0068AFAE0064;
         mem[169] = 64'h1000000601F0C821;
         mem[170] = 64'h8FA40068AFB90068;
         mem[171] = 64'h0411FF2C02002825;
         mem[172] = 64'hAFA2006802203025;
         mem[173] = 64'h0018404232180002;
         mem[174] = 64'h5512000632120001;
         mem[175] = 64'h8FAB006C8FA4006C;
         mem[176] = 64'h1000000601704821;
         mem[177] = 64'h8FA4006CAFA9006C;
         mem[178] = 64'h0411FF1E02002825;
         mem[179] = 64'hAFA2006C02203025;
         mem[180] = 64'h8FA4007056920006;
         mem[181] = 64'h015068268FAA0070;
         mem[182] = 64'hAFAD007010000006;
         mem[183] = 64'h020028258FA40070;
         mem[184] = 64'h022030250411FF13;
         mem[185] = 64'h26310001AFA20070;
         mem[186] = 64'h267300041635FFD1;
         mem[187] = 64'h8FA500688FA40064;
         mem[188] = 64'h022030250411FF0B;
         mem[189] = 64'h8FAE006C8FAC0070;
         mem[190] = 64'h8FB1001C8FB00018;
         mem[191] = 64'h8FB300248FB20020;
         mem[192] = 64'h8FB5002C8FB40028;
         mem[193] = 64'h8FB700348FB60030;
         mem[194] = 64'h004020258FBF003C;
         mem[195] = 64'h0411000827BD00E0;
         mem[196] = 64'h00850019018E2826;
         mem[197] = 64'hACCE000000007010;
         mem[198] = 64'hACEF000000007812;
         mem[199] = 64'h0000000003E00008;
         mem[200] = 64'h8D6807F03C0BBFC0;
         mem[201] = 64'h3084FFFF3C0AFFFF;
         mem[202] = 64'h00882025010A4024;
         mem[203] = 64'h3C09A480256B07C0;
         mem[204] = 64'h312900028D290018;
         mem[205] = 64'h3C09A4805520FFFD;
         mem[206] = 64'h00000000AD640030;
         mem[207] = 64'h0000000000000000;
         mem[208] = 64'h0000000000000000;
         mem[209] = 64'h8D2900183C09A480;
         mem[210] = 64'h5520FFFD31290002;
         mem[211] = 64'h8D68003C3C09A480;
         mem[212] = 64'hAD65003424090020;
         mem[213] = 64'h3C09A48001094025;
         mem[214] = 64'h312900028D290018;
         mem[215] = 64'h3C09A4805520FFFD;
         mem[216] = 64'h20090010AD68003C;
         mem[217] = 64'h5520FFFF2129FFFF;
         mem[218] = 64'h8D68003C2129FFFF;
         mem[219] = 64'h500AFFFA310A0080;
         mem[220] = 64'h240A004020090010;
         mem[221] = 64'h3C09A480010A4025;
         mem[222] = 64'h312900028D290018;
         mem[223] = 64'h3C09A4805520FFFD;
         mem[224] = 64'h3C0BA400AD68003C;
         mem[225] = 64'h216B0040256B0000;
         mem[226] = 64'h0000000001600008;
         mem[227] = 64'hFFFFFFFF00000000;
         mem[228] = 64'hFFFFFFFFFFFFFFFF;
         mem[229] = 64'hFFFFFFFFFFFFFFFF;
         mem[230] = 64'hFFFFFFFFFFFFFFFF;
         mem[231] = 64'hFFFFFFFFFFFFFFFF;
         mem[232] = 64'hFFFFFFFFFFFFFFFF;
         mem[233] = 64'hFFFFFFFFFFFFFFFF;
         mem[234] = 64'hFFFFFFFFFFFFFFFF;
         mem[235] = 64'hFFFFFFFFFFFFFFFF;
         mem[236] = 64'hFFFFFFFFFFFFFFFF;
         mem[237] = 64'hFFFFFFFFFFFFFFFF;
         mem[238] = 64'hFFFFFFFFFFFFFFFF;
         mem[239] = 64'hFFFFFFFFFFFFFFFF;
         mem[240] = 64'hFFFFFFFFFFFFFFFF;
         mem[241] = 64'hFFFFFFFFFFFFFFFF;
         mem[242] = 64'hFFFFFFFFFFFFFFFF;
         mem[243] = 64'hFFFFFFFFFFFFFFFF;
         mem[244] = 64'hFFFFFFFFFFFFFFFF;
         mem[245] = 64'hFFFFFFFFFFFFFFFF;
         mem[246] = 64'hFFFFFFFFFFFFFFFF;
         mem[247] = 64'hFFFFFFFFFFFFFFFF;
         mem[248] = 64'h00043F3F00043F3F;
         mem[249] = 64'hFFFFFFFFFFFFFFFF;
         mem[250] = 64'h00000000FFFFFFFF;
         mem[251] = 64'hFFFFFFFFFFFFFFFF;
         mem[252] = 64'h00043F3FFFFFFFFF;
         mem[253] = 64'hFFFFFFFFFFFFFFFF;
         mem[254] = 64'hFFFFFFFFFFFFFFFF;
         mem[255] = 64'hFFFFFFFFFFFFFF00;
    end
    
	always @(posedge clk) begin
		temp_data <= mem[address[10:3]];
		temp_address <= address[2:0];
		valid <= oe;
	end
	
	always @* begin
	   case(temp_address)
	       3'b000  : q_a <= temp_data[ 7: 0];
	       3'b001  : q_a <= temp_data[15: 8];
	       3'b010  : q_a <= temp_data[23:16];
	       3'b011  : q_a <= temp_data[31:24];
	       3'b100  : q_a <= temp_data[39:32];
	       3'b101  : q_a <= temp_data[47:40];
	       3'b110  : q_a <= temp_data[55:48];
	       default : q_a <= temp_data[63:56];
	   endcase
	end

endmodule