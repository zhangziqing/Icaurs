
//booth选择信号生成器
module Sel_signal(
    input [2:0]src,
    output neg,pos,neg2,pos2
);
///y+1,y,y-1///
assign {y_up,y,y_down} = src;

assign neg =  y_up & (y & ~y_down | ~y & y_down);
assign pos = ~y_up & (y & ~y_down | ~y & y_down);
assign neg2 =  y_up & ~y & ~y_down;
assign pos2 = ~y_up &  y &  y_down;

endmodule

//booth结果选择器
module Sel_res(
    input neg,pos,neg2,pos2,
//    input x,
    input x_down,
    input x_now,
    output p
);
assign p = ~(~(neg & ~x_now) & ~(neg2 & ~x_down) 
           & ~(pos & x_now ) & ~(pos2 &  x_down));
//assign x_now = x;

endmodule

//booth部分积生成模块
module Part_pro(
    input [2:0] src,
    input [63:0] x,
    output [63:0] p,
    output cout
);

wire neg,pos,neg2,pos2;
//wire x_down,x_now;

Sel_signal ss(.src(src),
              .neg(neg),
              .pos(pos),
              .neg2(neg2),
              .pos2(pos2));

Sel_res sr(.neg(neg),
            .pos(pos),
            .neg2(neg2),
            .pos2(pos2),
//            .x(x),
            .x_down(1'b0),
            .x_now(x[0]),
            .p(p[0]));

generate
    genvar i;
    for(i=1;i<64;i=i+1)begin
//       assign x_down = x_now;
        Sel_res ssr(.neg(neg),
            .pos(pos),
            .neg2(neg2),
            .pos2(pos2),
//            .x(x),
            .x_down(x[i-1]),
            .x_now(x[i]),
            .p(p[i]));
    end
endgenerate

assign cout = neg || neg2;

endmodule

//一位全加器
module addr(
  input [2:0] in,
  output cout,s

);
wire a,b,cin;
assign a=in[2];
assign b=in[1];
assign cin=in[0];
assign s = a ^ b ^ cin;
assign cout = a & b | cin & ( a ^ b );
endmodule

//17位华莱士树
module walloc17(
    input [16:0] src_in,
    input [13:0]  cin,
    output [13:0] cout_group,
    output      cout,s
);
wire [13:0] c;
///////////////first////////////////
wire [4:0] first_s;
addr addr0 (.in (src_in[16:14]), .cout (c[4]), .s (first_s[4]) );
addr addr1 (.in (src_in[13:11]), .cout (c[3]), .s (first_s[3]) );
addr addr2 (.in (src_in[10:08]), .cout (c[2]), .s (first_s[2]) );
addr addr3 (.in (src_in[07:05]), .cout (c[1]), .s (first_s[1]) );
addr addr4 (.in (src_in[04:02]), .cout (c[0]), .s (first_s[0]) );

///////////////secnod//////////////
wire [3:0] secnod_s;
addr addr5 (.in ({first_s[4:2]}             ), .cout (c[8]), .s (secnod_s[3]));
addr addr6 (.in ({first_s[1:0],src_in[1]}   ), .cout (c[7]), .s (secnod_s[2]));
addr addr7 (.in ({src_in[0],cin[4:3]}       ), .cout (c[6]), .s (secnod_s[1]));
addr addr8 (.in ({cin[2:0]}                 ), .cout (c[5]), .s (secnod_s[0]));

//////////////thrid////////////////
wire [1:0] thrid_s;
addr addr9 (.in (secnod_s[3:1]          ), .cout (c[10]), .s (thrid_s[1]));
addr addrA (.in ({secnod_s[0],cin[6:5]} ), .cout (c[09]), .s (thrid_s[0]));

//////////////fourth////////////////
wire [1:0] fourth_s;

addr addrB (.in ({thrid_s[1:0],cin[10]} ),  .cout (c[12]), .s (fourth_s[1]));
addr addrC (.in ({cin[9:7]             }),  .cout (c[11]), .s (fourth_s[0]));

//////////////fifth/////////////////
wire fifth_s;

addr addrD (.in ({fourth_s[1:0],cin[11]}),  .cout (c[13]), .s (fifth_s));

///////////////sixth///////////////
addr addrE (.in ({fifth_s,cin[13:12]}   ),  .cout (cout),  .s  (s));

///////////////output///////////////
assign cout_group = c;

endmodule

//乘法器的实现
module multi(
    //input clk,
    //input rst,
    input [31:0]x,y,
    input sig,
    output [63:0] result
);
wire [63:0] ex_x;
wire [33:0] ex_y;

assign ex_x = sig ? {{32{x[31]}},x} : {32'b0,x};
assign ex_y = sig ? {{2{y[31]}},y} : {2'b0,y};

//booth
//进位
wire [16:0] cout;
//部分积结果
wire [63:0] part_res [16:0];

Part_pro pp(.src({ex_y[1],ex_y[0],1'b0}),.x(ex_x),.p(part_res[0]),.cout(cout[0]));

generate
    genvar i;
    for(i=2;i<=32;i=i+2) begin
        Part_pro pap(
            .src(ex_y[i+1:i-1]),
            .x(ex_x<<i),
            .p(part_res[i>>1]),
            .cout(cout[i>>1])
        );
    end
endgenerate

reg [16:0] Cout;
reg [63:0] Part_res [16:0];
integer j;
always @(*) begin
    //if(~rst) begin
        Cout <= cout;
        for(j=0;j<17;j++) begin
            Part_res[j] <= part_res[j];
        end
    //end
end

wire [13:0] walloc_group [64:0];
wire [63:0] c_res,s_res;

walloc17 w(
    .src_in({Part_res[0][0],Part_res[1][0],Part_res[2][0],Part_res[3][0],Part_res[4][0],Part_res[5][0],Part_res[6][0],Part_res[7][0],
    Part_res[8][0],Part_res[9][0],Part_res[10][0],Part_res[11][0],Part_res[12][0],Part_res[13][0],Part_res[14][0],Part_res[15][0],Part_res[16][0]}),
    .cin(Cout[13:0]),
    .cout_group(walloc_group[1]),
    .cout(c_res[0]),
    .s(s_res[0])
);
generate
    genvar k;
    for(k=1;k<64;k++)begin
        walloc17 ww(
            .src_in({Part_res[0][k],Part_res[1][k],Part_res[2][k],Part_res[3][k],Part_res[4][k],Part_res[5][k],Part_res[6][k],Part_res[7][k],
    Part_res[8][k],Part_res[9][k],Part_res[10][k],Part_res[11][k],Part_res[12][k],Part_res[13][k],Part_res[14][k],Part_res[15][k],Part_res[16][k]}),
            .cin(walloc_group[k]),
            .cout_group(walloc_group[k+1]),
            .cout(c_res[k]),
            .s(s_res[k])
        );
    end
endgenerate

assign result = s_res + {c_res[62:0],Cout[14]} + Cout[15];

endmodule