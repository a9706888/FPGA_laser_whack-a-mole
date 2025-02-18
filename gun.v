module gun(
    input clk,
    input rst,
    input SW,
    output reg [15:0] LED,
    output reg shooting,
    output reg buzzer,
    output wire [3:0] digit,
    output wire [6:0] display
);  

    reg [15:0] nums;
    SevenSegment seven_seg (
		.display(display),
		.digit(digit),
		.nums(nums),
		.rst(rst),
		.clk(clk)
	);

    reg [7:0] bullet;
    reg [28:0]counter;

    always @(posedge clk) begin
        if(rst) begin
            bullet<=100;
            shooting<=0;
            counter<=0;
        end else begin
            if(SW) begin
                if(bullet>0) begin
                    if(counter<2**22) begin
                        counter<=counter+1;
                    end else begin
                        counter<=0;
                        bullet<=bullet-1;
                    end
                    shooting<=1;
                end else begin
                    shooting<=0;
                end
            end else begin
                shooting<=0;
                if(counter<2**22) begin
                    counter<=counter+1;
                    bullet <= bullet;
                end else begin
                    counter<=0;
                    if(bullet<100) begin
                        bullet<=bullet+1;
                    end else begin
                        bullet<=100;
                    end
                end
            end
        end
    end

    //7segment
    always @(posedge clk) begin
        if(rst) begin
            nums<=16'b0000_0001_0000_0000;
        end else begin
            if(bullet==100) begin
                nums<=16'b0000_0001_0000_0000;
            end else if(bullet==99)begin
                nums <= 16'b0000_0000_1001_1001;
            end else if(bullet==98) begin
                nums<=16'b0000_0000_1001_1000;
            end else if(bullet==97) begin
                nums<=16'b0000_0000_1001_0111;
            end else if(bullet==96) begin
                nums<=16'b0000_0000_1001_0110;
            end else if(bullet==95) begin
                nums<=16'b0000_0000_1001_0101;
            end else if(bullet==94) begin
                nums<=16'b0000_0000_1001_0100;
            end else if(bullet==93) begin
                nums<=16'b0000_0000_1001_0011;
            end else if(bullet==92) begin
                nums<=16'b0000_0000_1001_0010;
            end else if(bullet==91) begin
                nums<=16'b0000_0000_1001_0001;
            end else if(bullet==90) begin
                nums<=16'b0000_0000_1001_0000;
            end else if(bullet==89) begin
                nums<=16'b0000_0000_1000_1001;
            end else if(bullet==88) begin
                nums<=16'b0000_0000_1000_1000;
            end else if(bullet==87) begin
                nums<=16'b0000_0000_1000_0111;
            end else if(bullet==86) begin
                nums<=16'b0000_0000_1000_0110;
            end else if(bullet==85) begin
                nums<=16'b0000_0000_1000_0101;
            end else if(bullet==84) begin
                nums<=16'b0000_0000_1000_0100;
            end else if(bullet==83) begin
                nums<=16'b0000_0000_1000_0011;
            end else if(bullet==82) begin
                nums<=16'b0000_0000_1000_0010;
            end else if(bullet==81) begin
                nums<=16'b0000_0000_1000_0001;
            end else if(bullet==80) begin
                nums<=16'b0000_0000_1000_0000;
            end else if(bullet==79) begin
                nums<=16'b0000_0000_0111_1001;
            end else if(bullet==78) begin
                nums<=16'b0000_0000_0111_1000;
            end else if(bullet==77) begin
                nums<=16'b0000_0000_0111_0111;
            end else if(bullet==76) begin
                nums<=16'b0000_0000_0111_0110;
            end else if(bullet==75) begin
                nums<=16'b0000_0000_0111_0101;
            end else if(bullet==74) begin
                nums<=16'b0000_0000_0111_0100;
            end else if(bullet==73) begin
                nums<=16'b0000_0000_0111_0011;
            end else if(bullet==72) begin
                nums<=16'b0000_0000_0111_0010;
            end else if(bullet==71) begin
                nums<=16'b0000_0000_0111_0001;
            end else if(bullet==70) begin
                nums<=16'b0000_0000_0111_0000;
            end else if(bullet==69) begin
                nums<=16'b0000_0000_0110_1001;
            end else if(bullet==68) begin
                nums<=16'b0000_0000_0110_1000;
            end else if(bullet==67) begin
                nums<=16'b0000_0000_0110_0111;
            end else if(bullet==66) begin
                nums<=16'b0000_0000_0110_0110;
            end else if(bullet==65) begin
                nums<=16'b0000_0000_0110_0101;
            end else if(bullet==64) begin
                nums<=16'b0000_0000_0110_0100;
            end else if(bullet==63) begin
                nums<=16'b0000_0000_0110_0011;
            end else if(bullet==62) begin
                nums<=16'b0000_0000_0110_0010;
            end else if(bullet==61) begin
                nums<=16'b0000_0000_0110_0001;
            end else if(bullet==60) begin
                nums<=16'b0000_0000_0110_0000;
            end else if(bullet==59) begin
                nums<=16'b0000_0000_0101_1001;
            end else if(bullet==58) begin
                nums<=16'b0000_0000_0101_1000;
            end else if(bullet==57) begin
                nums<=16'b0000_0000_0101_0111;
            end else if(bullet==56) begin
                nums<=16'b0000_0000_0101_0110;
            end else if(bullet==55) begin
                nums<=16'b0000_0000_0101_0101;
            end else if(bullet==54) begin
                nums<=16'b0000_0000_0101_0100;
            end else if(bullet==53) begin
                nums<=16'b0000_0000_0101_0011;
            end else if(bullet==52) begin
                nums<=16'b0000_0000_0101_0010;
            end else if(bullet==51) begin
                nums<=16'b0000_0000_0101_0001;
            end else if(bullet==50) begin
                nums<=16'b0000_0000_0101_0000;
            end else if(bullet==49) begin
                nums<=16'b0000_0000_0100_1001;
            end else if(bullet==48) begin
                nums<=16'b0000_0000_0100_1000;
            end else if(bullet==47) begin
                nums<=16'b0000_0000_0100_0111;
            end else if(bullet==46) begin
                nums<=16'b0000_0000_0100_0110;
            end else if(bullet==45) begin
                nums<=16'b0000_0000_0100_0101;
            end else if(bullet==44) begin
                nums<=16'b0000_0000_0100_0100;
            end else if(bullet==43) begin
                nums<=16'b0000_0000_0100_0011;
            end else if(bullet==42) begin
                nums<=16'b0000_0000_0100_0010;
            end else if(bullet==41) begin
                nums<=16'b0000_0000_0100_0001;
            end else if(bullet==40) begin
                nums<=16'b0000_0000_0100_0000;
            end else if(bullet==39) begin
                nums<=16'b0000_0000_0011_1001;
            end else if(bullet==38) begin
                nums<=16'b0000_0000_0011_1000;
            end else if(bullet==37) begin
                nums<=16'b0000_0000_0011_0111;
            end else if(bullet==36) begin
                nums<=16'b0000_0000_0011_0110;
            end else if(bullet==35) begin
                nums<=16'b0000_0000_0011_0101;
            end else if(bullet==34) begin
                nums<=16'b0000_0000_0011_0100;
            end else if(bullet==33) begin
                nums<=16'b0000_0000_0011_0011;
            end else if(bullet==32) begin
                nums<=16'b0000_0000_0011_0010;
            end else if(bullet==31) begin
                nums<=16'b0000_0000_0011_0001;
            end else if(bullet==30) begin
                nums<=16'b0000_0000_0011_0000;
            end else if(bullet==29) begin
                nums<=16'b0000_0000_0010_1001;
            end else if(bullet==28) begin
                nums<=16'b0000_0000_0010_1000;
            end else if(bullet==27) begin
                nums<=16'b0000_0000_0010_0111;
            end else if(bullet==26) begin
                nums<=16'b0000_0000_0010_0110;
            end else if(bullet==25) begin
                nums<=16'b0000_0000_0010_0101;
            end else if(bullet==24) begin
                nums<=16'b0000_0000_0010_0100;
            end else if(bullet==23) begin
                nums<=16'b0000_0000_0010_0011;
            end else if(bullet==22) begin
                nums<=16'b0000_0000_0010_0010;
            end else if(bullet==21) begin
                nums<=16'b0000_0000_0010_0001;
            end else if(bullet==20) begin
                nums<=16'b0000_0000_0010_0000;
            end else if(bullet==19) begin
                nums<=16'b0000_0000_0001_1001;
            end else if(bullet==18) begin
                nums<=16'b0000_0000_0001_1000;
            end else if(bullet==17) begin
                nums<=16'b0000_0000_0001_0111;
            end else if(bullet==16) begin
                nums<=16'b0000_0000_0001_0110;
            end else if(bullet==15) begin
                nums<=16'b0000_0000_0001_0101;
            end else if(bullet==14) begin
                nums<=16'b0000_0000_0001_0100;
            end else if(bullet==13) begin
                nums<=16'b0000_0000_0001_0011;
            end else if(bullet==12) begin
                nums<=16'b0000_0000_0001_0010;
            end else if(bullet==11) begin
                nums<=16'b0000_0000_0001_0001;
            end else if(bullet==10) begin
                nums<=16'b0000_0000_0001_0000;
            end else if(bullet==9) begin
                nums<=16'b0000_0000_0000_1001;
            end else if(bullet==8) begin
                nums<=16'b0000_0000_0000_1000;
            end else if(bullet==7) begin
                nums<=16'b0000_0000_0000_0111;
            end else if(bullet==6) begin
                nums<=16'b0000_0000_0000_0110;
            end else if(bullet==5) begin
                nums<=16'b0000_0000_0000_0101;
            end else if(bullet==4) begin
                nums<=16'b0000_0000_0000_0100;
            end else if(bullet==3) begin
                nums<=16'b0000_0000_0000_0011;
            end else if(bullet==2) begin
                nums<=16'b0000_0000_0000_0010;
            end else if(bullet==1) begin
                nums<=16'b0000_0000_0000_0001;
            end else if(bullet==0) begin
                nums<=16'b0000_0000_0000_0000;
            end else begin
                nums<=16'b0000_0000_0000_0000;
            end
        end
    end

    //LED
    reg [28:0] LED_counter;
    reg first_into_SW0;
    always@(posedge clk) begin
        if(rst) begin
            LED<=0;
            LED_counter<=0;
            first_into_SW0<=1;
            buzzer<=1;
        end else begin
            if(SW) begin
                if(bullet>0) begin
                    LED<=16'b1111_1111_1111_1111;
                    buzzer<=0;
                end else begin
                    LED<=16'b0000_0000_0000_0000;
                    buzzer<=1;
                end
                LED_counter<=0;
                first_into_SW0<=1;
            end else begin
                buzzer<=1;
                if(first_into_SW0) begin
                    if(bullet!=100) begin
                        LED<=16'b0000_0000_0000_0111;
                        first_into_SW0<=0;
                    end else begin
                        LED<=16'b0000_0000_0000_0000;
                    end
                end
                if(LED_counter<2**23) begin
                    LED_counter<=LED_counter+1;
                end else begin
                    LED_counter<=0;
                    LED<=LED<<1;
                    if(LED==16'b0000_0000_0000_0000 &&bullet!=100) begin
                        LED<=16'b0000_0000_0000_0111;
                    end
                end
            end 
        end
    end
endmodule

module SevenSegment(
	output reg [6:0] display,
	output reg [3:0] digit,
	input wire [15:0] nums,
	input wire rst,
	input wire clk
    );
    
    reg [15:0] clk_divider;
    reg [3:0] display_num;
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		clk_divider <= 15'b0;
    	end else begin
    		clk_divider <= clk_divider + 15'b1;
    	end
    end
    
    always @ (posedge clk_divider[15], posedge rst) begin
    	if (rst) begin
    		display_num <= 4'b0000;
    		digit <= 4'b1111;
    	end else begin
    		case (digit)
    			4'b1110 : begin
    					display_num <= nums[7:4];
    					digit <= 4'b1101;
    				end
    			4'b1101 : begin
						display_num <= nums[11:8];
						digit <= 4'b1011;
					end
    			4'b1011 : begin
						display_num <= nums[15:12];
						digit <= 4'b0111;
					end
    			4'b0111 : begin
						display_num <= nums[3:0];
						digit <= 4'b1110;
					end
    			default : begin
						display_num <= nums[3:0];
						digit <= 4'b1110;
					end				
    		endcase
    	end
    end
    
    always @ (*) begin
    	case (display_num)
    		0 : display = 7'b1000000;	//0000
			1 : display = 7'b1111001;   //0001                                                
			2 : display = 7'b0100100;   //0010                                                
			3 : display = 7'b0110000;   //0011                                             
			4 : display = 7'b0011001;   //0100                                               
			5 : display = 7'b0010010;   //0101                                               
			6 : display = 7'b0000010;   //0110
			7 : display = 7'b1111000;   //0111
			8 : display = 7'b0000000;   //1000
			9 : display = 7'b0010000;	//1001
            10 : display = 7'b0111111;	//-
            11 : display = 7'b1100010;	//W
            12 : display = 7'b1001111;	//I
            13 : display = 7'b1001000;	//N
            14 : display = 7'b1000111;	//L
            15 : display = 7'b0000110;	//E
			default : display = 7'b0111111;
    	endcase
    end
    
endmodule

// module gun(
//     input clk,
//     input rst,
//     input SW,
//     output reg shooting
// );
//     always @(posedge clk) begin
//         if(SW) begin
//             shooting<=1;
//         end else begin
//             shooting<=0;
//         end
//     end 
// endmodule