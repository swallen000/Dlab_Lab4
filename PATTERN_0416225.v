
`timescale 1ns/10ps
`define CLK_PERIOD  4.0

module PATTERN(
	output reg clk,
	output reg [2:0] circle1,
	output reg [2:0] circle2,
	output reg [4:0] in,
	output reg in_valid,
	output reg rst_n,
	input [5:0] out,
	input out_valid
);
reg [4:0] temp[0:15];
reg [4:0] temp2[0:15];
reg [5:0] temp3[0:7];
parameter NUM=1000;
integer latency, total_latency;
integer num,i,j,j2,k,qq,b; 
initial begin
	total_latency=0;
end
initial begin 
	clk=0;
	forever #(`CLK_PERIOD/2) clk=~clk;
end	
initial begin 
	in<='dx;
	in_valid<='bx;
	rst_n<=1'b1;
	circle1<='dx;
	circle2<='dx;
	@(negedge clk)
		rst_n<=1'b0;
	@(negedge clk)
		rst_n<=1'b1;
	check_rst;
	in_valid<='b0;
	@(negedge clk)
	for(num=0;num<NUM;num=num+1) begin
		for(i=0;i<16;i=i+1) begin
			circle1=(i==0)?{$random()}%7+1:'dx;
			if(i==0)
				j=circle1;
			circle2=(i==0)?{$random()}%7+1:'dx;
			if(i==0)
				j2=circle2;
			temp[i]=$random()%32;
			in_valid<=1'b1;
			in<=temp[i];
			//check_rst;
			@(negedge clk);				
		end
	
		in<='dx;
		in_valid=1'b0;
	
		do_circle1;
		do_circle2;
		do_sum;
		sort;

		//in_valid<=1'b1;
		//check_rst;
		@(negedge clk);
		in_valid<=1'b0;

		wait_out;
		for(i=0;i<8;i=i+1) begin
			
			if(out !== temp3[i]) begin
                                $display("");
                                $display("=================================================");
                                $display("  Failed!!  PATTERN %4d is wrong!                ", num+1);
                                $display("  ans is %d      your ans is %d          ", temp3[i],out);
                                $display("=================================================");
                                $display("");
                                repeat(8)@(negedge clk);
                                $finish;
                        end

                        @(negedge clk);
			check_out_valid;
		end			
		check_out_valid;
		$display("");
                $display(" Pass pattern %3d ", num+1);

                @(negedge clk);

	end
	
	@(negedge clk);
        $display ("--------------------------------------------------------------------");
        $display ("                         Congratulations !                          ");
        $display ("                  You have passed all patterns !                    ");
        $display ("                  Your total latency is %6d !                       ", total_latency);
        $display ("--------------------------------------------------------------------");
        @(negedge clk);
        $finish;

end	
task do_sum;
begin
	for(k=0;k<8;k=k+1) begin
		temp3[k]=temp[k]+temp[k+8];
	end
	for(k=0;k<8;k=k+1)
		temp[k]=temp2[k];
end
endtask
task sort;
begin
	for(k=0;k<8;k=k+1) begin
		for(j=0;j<7;j=j+1) begin
			if(temp3[j]>temp3[j+1]) begin
				qq=temp3[j];
				temp3[j]=temp3[j+1];
				temp3[j+1]=qq;
			end
		end
	end
end
endtask
task do_circle1;
begin
	temp2[0]=(0-j<0)?temp[0-j+8]:temp[0-j];
	temp2[1]=(1-j<0)?temp[1-j+8]:temp[1-j];
	temp2[2]=(2-j<0)?temp[2-j+8]:temp[2-j];
	temp2[3]=(3-j<0)?temp[3-j+8]:temp[3-j];
	temp2[4]=(4-j<0)?temp[4-j+8]:temp[4-j];
	temp2[5]=(5-j<0)?temp[5-j+8]:temp[5-j];
	temp2[6]=(6-j<0)?temp[6-j+8]:temp[6-j];
	temp2[7]=(7-j<0)?temp[7-j+8]:temp[7-j];
	for(k=0;k<8;k=k+1) begin
		temp[k]=temp2[k];
		//$display("%d:%d",k,temp[k]);
	end
end
endtask
task do_circle2;
begin
	temp2[8]=(8-j2<8)?temp[8-j2+8]:temp[8-j2];
        temp2[9]=(9-j2<8)?temp[9-j2+8]:temp[9-j2];
        temp2[10]=(10-j2<8)?temp[10-j2+8]:temp[10-j2];
        temp2[11]=(11-j2<8)?temp[11-j2+8]:temp[11-j2];
        temp2[12]=(12-j2<8)?temp[12-j2+8]:temp[12-j2];
        temp2[13]=(13-j2<8)?temp[13-j2+8]:temp[13-j2];
        temp2[14]=(14-j2<8)?temp[14-j2+8]:temp[14-j2];
        temp2[15]=(15-j2<8)?temp[15-j2+8]:temp[15-j2];
	for(k=8;k<16;k=k+1) begin
		temp[k]=temp2[k];
		//$display("%d:%d",k,temp[k]);
	end
end
endtask
task wait_out;
begin
        latency = 0;

        while(!(out_valid === 1'b1)) begin
                if(latency > 12) begin
                        $display("");
                        $display("=================================================");
                        $display("  Latency too more !!!!               ");
                        $display("=================================================");
                        $display("");
                        @(negedge clk);
                        $finish;
                end
                latency = latency + 1;
                total_latency = total_latency + 1;
                @(negedge clk);
        end
end
endtask
task check_out_valid;
begin
	if(out_valid!==1'b0&&i>7&&in_valid===0) begin
		$display("");
                $display("=================================================");
                $display("  Out_valid  latency too long !!!!               ");
                $display("=================================================");
                $display("");
                @(negedge clk);
                $finish;
	end
	else if(out_valid===0&&i>=0&&i<7&&in_valid===0) begin
		$display("");
                $display("=================================================");
                $display("  Out_valid  latency too short !!!!               ");
                $display("=================================================");
                $display("");
                @(negedge clk);
                $finish;
	end
		
end
endtask
task check_rst;
begin
        if(out !== 'd0 || out_valid !== 1'b0) begin
                $display("");
                $display("=================================================");
                $display("  Output should be reset !!!!               ");
                $display("=================================================");
                $display("");
                @(negedge clk);
                $finish;
        end
end
endtask
task check_rst2;
begin
        if(out !== 'd0 || out_valid !== 1'b0) begin
                $display("");
                $display("=================================================");
                $display("  Output should be reset2 !!!!               ");
                $display("=================================================");
                $display("");
                @(negedge clk);
                $finish;
        end
end
endtask

endmodule
