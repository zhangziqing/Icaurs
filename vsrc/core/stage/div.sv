module div  (  
input[31:0] x,   
input[31:0] y,  
input sig,
input ready,
output reg [31:0] quot,  
output reg [31:0] rem
// output reg valid 
);  
reg[31:0] x32;  
reg[31:0] y32;  
reg[63:0] x64;  
reg[63:0] y64;  
reg flagx;
reg flagy;
reg flag;
reg flagr;
always @(x or y)  
begin  
  if(sig==0)
  begin
    x32 <= x;  
    y32 <= y;
  end
  else 
  begin
    flagx = (x[31] == 1);//x是否为负??
    flagy = (y[31] == 1);
    flag = flagx ^ flagy;
    flagr = flagx && flagy||(flagx==1&&flagy==0);
    x32 = flagx ? (~x + 1'b1):x;
    y32 = flagy ? (~y + 1'b1):y;
  end  
end  
  
integer i;  
always @(x32 or y32)  
begin  
if(ready)
  begin
    x64 = {32'h00000000,x32};  
    y64 = {y32,32'h00000000};  
    // valid = 0; 
    for(i = 0;i < 32;i = i + 1)  
        begin  
            x64 = {x64[62:0],1'b0};  
            if(x64[63:32] >= y32)  
                x64 = x64 - y64 + 1'b1;  
            else  
                x64 = x64;  
        end  
  
    quot = x64[31:0];  
    rem = x64[63:32]; 
    // valid = 1; 
    if(sig==0)
    begin
      quot = x64[31:0];  
      rem = x64[63:32]; 
    end
    else 
    begin
      quot = flag?(~x64[31:0]+1):x64[31:0];
      rem = flagr?(~x64[63:32]+1):x64[63:32];
    end 
  end
end   
endmodule 