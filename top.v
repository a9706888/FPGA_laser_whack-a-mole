`define silence   32'd50000000
`define c4  32'd262   // C4
`define d4  32'd294   // D4
`define e4  32'd330   // E4
`define f4  32'd349   // F4
`define g4  32'd392   // G4
`define a4  32'd440   // A4
`define b4  32'd494   // B4
`define c5  32'd524   // C5
`define d5  32'd588   // D5
`define e5  32'd660   // E5
`define f5  32'd698   // F5
`define g5  32'd784   // G5
`define a5  32'd880   // A5
`define b5  32'd988   // B5
`define c3  32'd131   // C3
`define d3  32'd147   // D3
`define e3  32'd165   // E3
`define f3  32'd174   // F3
`define g3  32'd196   // G3
`define a3  32'd220   // A3
`define b3  32'd247   // B3
module top(
    input SW,
    input clk,
    input rst,
    input start,
    input IR1,
    input IR2,
    input IR3,
    output reg light1,
    output reg light2,
    output reg light3,
    output reg [15:0] LED,
    output reg [3:0] vgaRed,
    output reg [3:0] vgaGreen,
    output reg [3:0] vgaBlue,
    output hsync,
    output vsync,
    output wire audio_mclk, // master clock
    output wire audio_lrck, // left-right clock
    output wire audio_sck,  // serial clock
    output wire audio_sdin // serial audio data input
);
    // audio controller variaable
    reg [31:0] freqL, freqR;
    wire [21:0] freq_outL, freq_outR;
    reg [31:0] freqL_next, freqR_next;
    wire [15:0] audio_in_left, audio_in_right;
    reg [2:0] volume;
    reg [2:0] life_prev;
    reg sound_trigger;
    reg playing_sound;        

    // ===============================

    wire start_debounced,start_onepulse;
    debounce st(.pb_debounced(start_debounced),.pb(start),.clk(clk));
    one_pulse st2(.clk(clk),.pb_in(start_debounced),.pb_out(start_onepulse));

    reg [1:0] current_state, next_state;
    parameter INIT = 2'b00, COUNTDOWN=2'b01, GAME = 2'b10, FINISH = 2'b11;
    assign enter_game = (current_state == GAME) ? 0 : 1;
    reg [8:0] countdown;
    reg [2:0] life;
    reg [28:0] COUNTDOWN_count;
    reg [3:0] COUNTDOWN_time;

    always @(posedge clk) begin
        if(rst) begin
            current_state <= INIT;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        case(current_state)
            INIT: begin
                if(start_onepulse) begin
                    next_state = COUNTDOWN;
                end else begin
                    next_state = INIT;
                end
            end
            COUNTDOWN: begin
                if(COUNTDOWN_time==0) begin
                    next_state = GAME;
                end else begin
                    next_state = COUNTDOWN;
                end
            end
            GAME: begin
                if(countdown==0||life==0) begin
                    next_state = FINISH;
                end else begin
                    next_state = GAME;
                end
            end
            FINISH: begin
                if(start_onepulse) begin
                    next_state = INIT;
                end else begin
                    next_state = FINISH;
                end
            end
        endcase
    end

    //LED
    always @(posedge clk) begin
        if(current_state==INIT) begin
            LED<=16'b1111111111111111;
        end else if(current_state==COUNTDOWN) begin
            LED<=16'b1000000000000000;
        end else if (current_state==GAME) begin
            LED<=0;
        end else begin
            LED<=1;
        end
    end

    reg[30:0] counter;
    reg light1_lock,light2_lock,light3_lock;
    reg [3:0] sequence;
    reg life_sound;
    always @(posedge clk) begin
        if(current_state==INIT) begin
            countdown<=9'd6;
            counter<=0;
            light1<=0;
            light2<=0;
            light3<=0;
            light1_lock<=0;
            light2_lock<=0;
            light3_lock<=0;
            sequence<=0;
            life<=3;
            life_sound<=0;
            COUNTDOWN_count<=0;
            COUNTDOWN_time<=3;
        end else if(current_state==COUNTDOWN) begin
            if(COUNTDOWN_count<2**27) begin
                COUNTDOWN_count<=COUNTDOWN_count+1;
            end else begin
                COUNTDOWN_count<=0;
                COUNTDOWN_time<=COUNTDOWN_time-1;
            end
        end else if(current_state==GAME) begin
            if(counter<2**29) begin
                counter<=counter+1;
                if(sequence==0) begin
                    if(light1_lock==0) begin
                        light1<=0;
                    end
                    if(light2_lock==0) begin
                        light2<=0;
                    end
                    if(light3_lock==0) begin
                        light3<=1;
                    end
                end else if(sequence==1) begin
                    if(light1_lock==0) begin
                        light1<=1;
                    end
                    if(light2_lock==0) begin
                        light2<=0;
                    end
                    if(light3_lock==0) begin
                        light3<=0;
                    end
                end else if(sequence==2) begin
                    if(light1_lock==0) begin
                        light1<=1;
                    end
                    if(light2_lock==0) begin
                        light2<=1;
                    end
                    if(light3_lock==0) begin
                        light3<=0;
                    end
                end else if(sequence==3) begin
                    if(light1_lock==0) begin
                        light1<=1;
                    end
                    if(light2_lock==0) begin
                        light2<=1;
                    end
                    if(light3_lock==0) begin
                        light3<=1;
                    end
                end else if(sequence==4) begin
                    if(light1_lock==0) begin
                        light1<=0;
                    end
                    if(light2_lock==0) begin
                        light2<=1;
                    end
                    if(light3_lock==0) begin
                        light3<=1;
                    end
                end else if(sequence==5) begin
                    if(light1_lock==0) begin
                        light1<=1;
                    end
                    if(light2_lock==0) begin
                        light2<=1;
                    end
                    if(light3_lock==0) begin
                        light3<=1;
                    end
                end

                // if(light1_lock==0) begin
                //     light1<=1;
                // end
                // if(light2_lock==0) begin
                //     light2<=1;
                // end
                // if(light3_lock==0) begin
                //     light3<=1;
                // end
            end else if (counter<2**29+2**27) begin
                if(light1!=0||light2!=0||light3!=0) begin
                    life<=life-1;
                    life_sound<=1;
                end
                counter<=counter+1;
                light1<=0;
                light2<=0;
                light3<=0;
                light1_lock<=0;
                light2_lock<=0;
                light3_lock<=0;
            end else begin
                counter<=0;
                countdown<=countdown-1;
                life_sound<=0;
                if(sequence<6) begin
                    sequence<=sequence+1;
                end 
            end
            // ????n??IR1,.. negate
            if(light1 && !IR1) begin
                light1<=0;
                light1_lock<=1;
            end
            if(light2 && !IR2) begin
                light2<=0;
                light2_lock<=1;
            end
            if(light3 && !IR3) begin
                light3<=0;
                light3_lock<=1;
            end
        end else begin
            counter<=0;
            countdown<=0;
            light1<=0;
            light2<=0;
            light3<=0;
        end
    end
    // VGA
    wire [11:0] data;
    wire clk_25MHz;
    wire clk_22;
    reg [16:0] pixel_addr;
    wire [11:0] pixel;
    wire [11:0] pixel_lose;
    wire [11:0] pixel_win;
    wire [11:0] pixel_start;
    reg [16:0] pixel_addr_lose;
    reg [16:0] pixel_addr_win;
    reg [16:0] pixel_addr_start;
    wire valid;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt;  //480
    // ===============================
//     wire rst_debounce;
//     wire rst_onepulse;
//     debounce db(.pb_debounced(rst_debounce), .pb(rst), .clk(clk));
//     one_pulse op(.clk(clk), .pb_in(rst_debounce), .pb_out(rst_onepulse));

    //assign {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel:12'h0;

    always @(*) begin
        if(current_state==INIT) begin
            {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel_start:12'h0;
        end else if(current_state==COUNTDOWN) begin
            if(COUNTDOWN_time==3) begin
                if(!valid)
                    {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                else if(h_cnt < 213)
                    //red
                    {vgaRed, vgaGreen, vgaBlue} = 12'hf00;
                else if(h_cnt < 426)
                    //yellow
                    {vgaRed, vgaGreen, vgaBlue} = 12'h880;
                else if(h_cnt < 640)
                    //green
                    {vgaRed, vgaGreen, vgaBlue} = 12'h080;
                else
                    {vgaRed, vgaGreen, vgaBlue} = 12'h0;
            end else if(COUNTDOWN_time==2) begin
                if(!valid)
                    {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                else if(h_cnt < 213)
                    //red
                    {vgaRed, vgaGreen, vgaBlue} = 12'h800;
                else if(h_cnt < 426)
                    //yellow
                    {vgaRed, vgaGreen, vgaBlue} = 12'hff0;
                else if(h_cnt < 640)
                    //green
                    {vgaRed, vgaGreen, vgaBlue} = 12'h080;
                else
                    {vgaRed, vgaGreen, vgaBlue} = 12'h0;
            end else if(COUNTDOWN_time==1) begin
                if(!valid)
                    {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                else if(h_cnt < 213)
                    //red
                    {vgaRed, vgaGreen, vgaBlue} = 12'h800;
                else if(h_cnt < 426)
                    //yellow
                    {vgaRed, vgaGreen, vgaBlue} = 12'h880;
                else if(h_cnt < 640)
                    //green
                    {vgaRed, vgaGreen, vgaBlue} = 12'h0f0;
                else
                    {vgaRed, vgaGreen, vgaBlue} = 12'h0;
            end
        end else if (current_state==GAME) begin
            {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel:12'h0;
        end else if (current_state==FINISH && life!=0) begin
            {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel_win:12'h0;
            //{vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? 12'h0f0:12'h0;
        end else if (current_state==FINISH && life==0) begin
            {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel_lose:12'h0;
        end else begin
            {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? 12'hfff:12'h0;
        end
    end

    clock_divider clk_wiz_0_inst(
        .clk(clk),
        .clk1(clk_25MHz),
        .clk22(clk_22)
    );
    //image
    blk_mem_gen_0 blk_mem_gen_0_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(pixel)
    ); 

    blk_mem_gen_1 blk_mem_gen_1_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr_lose),
        .dina(data[11:0]),
        .douta(pixel_lose)
    ); 
    blk_mem_gen_2 blk_mem_gen_2_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr_win),
        .dina(data[11:0]),
        .douta(pixel_win)
    );
    blk_mem_gen_3 blk_mem_gen_3_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr_start),
        .dina(data[11:0]),
        .douta(pixel_start)
    );

    reg [9:0] position_h, position_v;
    reg [31:0] timer;
    reg [4:0] region;

    always @(posedge clk) begin
        if(rst) begin
            timer<=0;
            region<=0;
        end else begin
            if(current_state==INIT) begin
                timer<=0;
                region<=0;
            end else if(current_state==GAME) begin
                if(timer<2**27) begin
                    timer<=timer+1;
                end else begin
                    timer<=0;
                    if(region<30)begin
                        region<=region+1;
                    end else begin
                        region<=0;
                    end
                end
            end else if(current_state==FINISH) begin
                timer<=0;
                region<=0;
            end
        end 
    end

    always @(*) begin
        case(region)
            5'd0: begin
                position_h = 0;
                position_v = 0;
            end
            5'd1: begin
                position_h = 32;
                position_v = 0;
            end
            5'd2: begin
                position_h = 64;
                position_v = 0;
            end
            5'd3: begin
                position_h = 96;
                position_v = 0;
            end
            5'd4: begin
                position_h = 128;
                position_v = 0;
            end
            5'd5:begin
                position_h = 0;
                position_v = 20;
            end
            5'd6:begin
                position_h = 32;
                position_v = 20;
            end
            5'd7:begin
                position_h = 64;
                position_v = 20;
            end
            5'd8:begin
                position_h = 96;
                position_v = 20;
            end
            5'd9:begin
                position_h = 128;
                position_v = 20;
            end
            5'd10:begin
                position_h = 0;
                position_v = 40;
            end
            5'd11:begin
                position_h = 32;
                position_v = 40;
            end
            5'd12:begin
                position_h = 64;
                position_v = 40;
            end
            5'd13:begin
                position_h = 96;
                position_v = 40;
            end
            5'd14:begin
                position_h = 128;
                position_v = 40;
            end
            5'd15:begin
                position_h = 0;
                position_v = 60;
            end
            5'd16:begin
                position_h = 32;
                position_v = 60;
            end
            5'd17:begin
                position_h = 64;
                position_v = 60;
            end
            5'd18:begin
                position_h = 96;
                position_v = 60;
            end 
            5'd19:begin
                position_h = 128;
                position_v = 60;
            end
            5'd20:begin
                position_h = 0;
                position_v = 80;
            end
            5'd21:begin
                position_h = 32;
                position_v = 80;
            end
            5'd22:begin
                position_h = 64;
                position_v = 80;
            end
            5'd23:begin
                position_h = 96;
                position_v = 80;
            end
            5'd24:begin
                position_h = 128;
                position_v = 80;
            end
            5'd25:begin
                position_h = 0;
                position_v = 100;
            end
            5'd26:begin
                position_h = 32;
                position_v = 100;
            end
            5'd27:begin
                position_h = 64;
                position_v = 100;
            end
            5'd28:begin
                position_h = 96;
                position_v = 100;
            end
            5'd29:begin
                position_h = 128;
                position_v = 100;
            end
            default: begin
                position_h = 0;
                position_v = 0;
            end
        endcase
    end

    always @(*) begin
        //pixel_addr = ((h_cnt / 10) + position_h + ((v_cnt / 12 ) + position_v) * 320) % 76800;
        pixel_addr = ((h_cnt / 20) + position_h + ((v_cnt / 24 ) + position_v) * 160) % 19200;
        pixel_addr_lose = ((h_cnt / 4) + position_h + ((v_cnt / 4 ) + position_v) * 160) % 19200;
        pixel_addr_win = ((h_cnt / 4) + position_h + ((v_cnt / 4 ) + position_v) * 160) % 19200;
        pixel_addr_start = ((h_cnt / 4) + position_h + ((v_cnt / 4 ) + position_v) * 160) % 19200;
    end
    vga_controller   vga_inst(
        .pclk(clk_25MHz),
        .reset(rst),
        .hsync(hsync),
        .vsync(vsync),
        .valid(valid),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt)
    );

    //audio controller
    // always @(posedge clk) begin
    //     if(current_state==INIT) begin
    //         freqL<= `c4;
    //         freqR<= `c4;
    //     end else if(current_state==GAME) begin
    //         if(life_sound) begin
    //             if(life==2) begin
    //                 freqL<= `c4;
    //                 freqR<= `c4;
    //             end else if(life==1) begin
    //                 freqL<= `d4;
    //                 freqR<= `d4;
    //             end else begin
    //                 freqL<= `e4;
    //                 freqR<= `e4;
    //             end
    //         end else begin
    //             freqL<= `silence;
    //             freqR<= `silence;
    //         end
    //     end else if(current_state==FINISH) begin
    //         freqL<= `silence;
    //         freqR<= `silence;
    //     end
    // end

    reg [11:0] ibeatNum;
    reg [11:0] ibeatNum_GAME;
    reg [11:0] ibeatNum_COUNTDOWN;
    wire clk_div22;
    clock_divider2 #(22) clk_div_inst (.clk(clk), .clk_div(clk_div22));
    always @(posedge clk_div22) begin
        if(current_state==INIT) begin
            ibeatNum<=12'd0;
            ibeatNum_GAME<=12'd0;
            ibeatNum_COUNTDOWN<=12'd0;
        end else if(current_state==COUNTDOWN) begin
            ibeatNum_GAME<=0;

            if(ibeatNum_COUNTDOWN<32) begin
                ibeatNum_COUNTDOWN<=ibeatNum_COUNTDOWN+1;
            end else begin
                ibeatNum_COUNTDOWN<=0;
            end

        end else if(current_state==GAME) begin
            ibeatNum<=0;
            if(life_sound) begin
                ibeatNum_GAME<=ibeatNum_GAME+1;
            end else begin
                ibeatNum_GAME<=0;
            end
        end else if(current_state==FINISH) begin
            if(ibeatNum<2**9) begin
                ibeatNum<=ibeatNum+1;
            end else begin
                ibeatNum<=ibeatNum;
            end
        end
    end

    always @(*) begin
        if (rst) begin
            freqL = `silence;
            freqR = `silence;
        end else begin
            case (current_state)
                INIT: begin
                    freqL = `silence;
                    freqR = `silence;
                end
                COUNTDOWN: begin
                    if(COUNTDOWN_time==3) begin
                        case(ibeatNum_COUNTDOWN)
                            12'd0: begin freqL = `a3; freqR = `a3; end
                            12'd1: begin freqL = `a3; freqR = `a3; end
                            12'd2: begin freqL = `a3; freqR = `a3; end
                            12'd3: begin freqL = `a3; freqR = `a3; end
                            12'd4: begin freqL = `a3; freqR = `a3; end
                            12'd5: begin freqL = `a3; freqR = `a3; end
                            12'd6: begin freqL = `a3; freqR = `a3; end
                            12'd7: begin freqL = `a3; freqR = `a3; end
                            12'd8: begin freqL = `a3; freqR = `a3; end
                            12'd9: begin freqL = `a3; freqR = `a3; end
                            12'd10: begin freqL = `a3; freqR = `a3; end
                            12'd11: begin freqL = `a3; freqR = `a3; end
                            12'd12: begin freqL = `a3; freqR = `a3; end
                            12'd13: begin freqL = `a3; freqR = `a3; end
                            12'd14: begin freqL = `a3; freqR = `a3; end
                            12'd15: begin freqL = `a3; freqR = `a3; end
                            12'd16: begin freqL = `a3; freqR = `a3; end
                            12'd17: begin freqL = `a3; freqR = `a3; end
                            12'd18: begin freqL = `a3; freqR = `a3; end
                            12'd19: begin freqL = `a3; freqR = `a3; end
                            12'd20: begin freqL = `a3; freqR = `a3; end
                            12'd21: begin freqL = `a3; freqR = `a3; end
                            12'd22: begin freqL = `a3; freqR = `a3; end
                            12'd23: begin freqL = `a3; freqR = `a3; end
                            12'd24: begin freqL = `a3; freqR = `a3; end
                            12'd25: begin freqL = `a3; freqR = `a3; end
                            12'd26: begin freqL = `a3; freqR = `a3; end
                            12'd27: begin freqL = `a3; freqR = `a3; end
                            12'd28: begin freqL = `a3; freqR = `a3; end
                            12'd29: begin freqL = `a3; freqR = `a3; end
                            12'd30: begin freqL = `a3; freqR = `a3; end
                            12'd31: begin freqL = `silence; freqR = `silence; end
                            default: begin freqL = `silence; freqR = `silence; end
                        endcase
                    end else if(COUNTDOWN_time==2) begin
                        case(ibeatNum_COUNTDOWN)
                            12'd0: begin freqL = `a3; freqR = `a3; end
                            12'd1: begin freqL = `a3; freqR = `a3; end
                            12'd2: begin freqL = `a3; freqR = `a3; end
                            12'd3: begin freqL = `a3; freqR = `a3; end
                            12'd4: begin freqL = `a3; freqR = `a3; end
                            12'd5: begin freqL = `a3; freqR = `a3; end
                            12'd6: begin freqL = `a3; freqR = `a3; end
                            12'd7: begin freqL = `a3; freqR = `a3; end
                            12'd8: begin freqL = `a3; freqR = `a3; end
                            12'd9: begin freqL = `a3; freqR = `a3; end
                            12'd10: begin freqL = `a3; freqR = `a3; end
                            12'd11: begin freqL = `a3; freqR = `a3; end
                            12'd12: begin freqL = `a3; freqR = `a3; end
                            12'd13: begin freqL = `a3; freqR = `a3; end
                            12'd14: begin freqL = `a3; freqR = `a3; end
                            12'd15: begin freqL = `a3; freqR = `a3; end
                            12'd16: begin freqL = `a3; freqR = `a3; end
                            12'd17: begin freqL = `a3; freqR = `a3; end
                            12'd18: begin freqL = `a3; freqR = `a3; end
                            12'd19: begin freqL = `a3; freqR = `a3; end
                            12'd20: begin freqL = `a3; freqR = `a3; end
                            12'd21: begin freqL = `a3; freqR = `a3; end
                            12'd22: begin freqL = `a3; freqR = `a3; end
                            12'd23: begin freqL = `a3; freqR = `a3; end
                            12'd24: begin freqL = `a3; freqR = `a3; end
                            12'd25: begin freqL = `a3; freqR = `a3; end
                            12'd26: begin freqL = `a3; freqR = `a3; end
                            12'd27: begin freqL = `a3; freqR = `a3; end
                            12'd28: begin freqL = `a3; freqR = `a3; end
                            12'd29: begin freqL = `a3; freqR = `a3; end
                            12'd30: begin freqL = `a3; freqR = `a3; end
                            12'd31: begin freqL = `silence; freqR = `silence; end
                            default: begin freqL = `silence; freqR = `silence; end
                        endcase
                    end else if(COUNTDOWN_time==1) begin
                        case(ibeatNum_COUNTDOWN)
                            12'd0: begin freqL = `a4; freqR = `a4; end
                            12'd1: begin freqL = `a4; freqR = `a4; end
                            12'd2: begin freqL = `a4; freqR = `a4; end
                            12'd3: begin freqL = `a4; freqR = `a4; end
                            12'd4: begin freqL = `a4; freqR = `a4; end
                            12'd5: begin freqL = `a4; freqR = `a4; end
                            12'd6: begin freqL = `a4; freqR = `a4; end
                            12'd7: begin freqL = `a4; freqR = `a4; end
                            12'd8: begin freqL = `a4; freqR = `a4; end
                            12'd9: begin freqL = `a4; freqR = `a4; end
                            12'd10: begin freqL = `a4; freqR = `a4; end
                            12'd11: begin freqL = `a4; freqR = `a4; end
                            12'd12: begin freqL = `a4; freqR = `a4; end
                            12'd13: begin freqL = `a4; freqR = `a4; end
                            12'd14: begin freqL = `a4; freqR = `a4; end
                            12'd15: begin freqL = `a4; freqR = `a4; end
                            12'd16: begin freqL = `a4; freqR = `a4; end
                            12'd17: begin freqL = `a4; freqR = `a4; end
                            12'd18: begin freqL = `a4; freqR = `a4; end
                            12'd19: begin freqL = `a4; freqR = `a4; end
                            12'd20: begin freqL = `a4; freqR = `a4; end
                            12'd21: begin freqL = `a4; freqR = `a4; end
                            12'd22: begin freqL = `a4; freqR = `a4; end
                            12'd23: begin freqL = `a4; freqR = `a4; end
                            12'd24: begin freqL = `a4; freqR = `a4; end
                            12'd25: begin freqL = `a4; freqR = `a4; end
                            12'd26: begin freqL = `a4; freqR = `a4; end
                            12'd27: begin freqL = `a4; freqR = `a4; end
                            12'd28: begin freqL = `a4; freqR = `a4; end
                            12'd29: begin freqL = `a4; freqR = `a4; end
                            12'd30: begin freqL = `a4; freqR = `a4; end
                            12'd31: begin freqL = `silence; freqR = `silence; end
                            default: begin freqL = `silence; freqR = `silence; end
                
                        endcase
                    end
                end
                GAME: begin
                    if (life_sound) begin
                        case(ibeatNum_GAME)
                            12'd0: begin freqL = `f4; freqR = `f4; end
                            12'd1: begin freqL = `f4; freqR = `f4; end
                            12'd2: begin freqL = `f4; freqR = `f4; end
                            12'd3: begin freqL = `f4; freqR = `f4; end
                            12'd4: begin freqL = `f4; freqR = `f4; end
                            12'd5: begin freqL = `f4; freqR = `f4; end
                            12'd6: begin freqL = `f4; freqR = `f4; end
                            12'd7: begin freqL = `silence; freqR = `silence; end

                            12'd8: begin freqL = `c4; freqR = `c4; end
                            12'd9: begin freqL = `c4; freqR = `c4; end
                            12'd10: begin freqL = `c4; freqR = `c4; end
                            12'd11: begin freqL = `c4; freqR = `c4; end
                            12'd12: begin freqL = `c4; freqR = `c4; end
                            12'd13: begin freqL = `c4; freqR = `c4; end
                            12'd14: begin freqL = `c4; freqR = `c4; end
                            12'd15: begin freqL = `silence; freqR = `silence; end

                            default: begin freqL = `silence; freqR = `silence; end
                        endcase
                    end else begin
                        freqL = `silence;
                        freqR = `silence;
                    end
                end
                FINISH: begin
                    if(life==0) begin
                        case (ibeatNum)
                            12'd0: begin freqL = `f4; freqR = `f4; end
                            12'd1: begin freqL = `f4; freqR = `f4; end
                            12'd2: begin freqL = `f4; freqR = `f4; end
                            12'd3: begin freqL = `f4; freqR = `f4; end
                            12'd4: begin freqL = `f4; freqR = `f4; end
                            12'd5: begin freqL = `f4; freqR = `f4; end
                            12'd6: begin freqL = `f4; freqR = `f4; end
                            12'd7: begin freqL = `f4; freqR = `f4; end
                            12'd8: begin freqL = `f4; freqR = `f4; end
                            12'd9: begin freqL = `f4; freqR = `f4; end
                            12'd10: begin freqL = `f4; freqR = `f4; end
                            12'd11: begin freqL = `f4; freqR = `f4; end
                            12'd12: begin freqL = `f4; freqR = `f4; end
                            12'd13: begin freqL = `f4; freqR = `f4; end
                            12'd14: begin freqL = `f4; freqR = `f4; end
                            12'd15: begin freqL = `silence; freqR = `silence; end

                            12'd16: begin freqL = `d4; freqR = `d4; end
                            12'd17: begin freqL = `d4; freqR = `d4; end
                            12'd18: begin freqL = `d4; freqR = `d4; end
                            12'd19: begin freqL = `d4; freqR = `d4; end
                            12'd20: begin freqL = `d4; freqR = `d4; end
                            12'd21: begin freqL = `d4; freqR = `d4; end
                            12'd22: begin freqL = `d4; freqR = `d4; end
                            12'd23: begin freqL = `d4; freqR = `d4; end
                            12'd24: begin freqL = `d4; freqR = `d4; end
                            12'd25: begin freqL = `d4; freqR = `d4; end
                            12'd26: begin freqL = `d4; freqR = `d4; end
                            12'd27: begin freqL = `d4; freqR = `d4; end
                            12'd28: begin freqL = `d4; freqR = `d4; end
                            12'd29: begin freqL = `d4; freqR = `d4; end
                            12'd30: begin freqL = `d4; freqR = `d4; end
                            12'd31: begin freqL = `silence; freqR = `silence; end

                            12'd32: begin freqL = `b3; freqR = `b3; end
                            12'd33: begin freqL = `b3; freqR = `b3; end
                            12'd34: begin freqL = `b3; freqR = `b3; end
                            12'd35: begin freqL = `b3; freqR = `b3; end
                            12'd36: begin freqL = `b3; freqR = `b3; end
                            12'd37: begin freqL = `b3; freqR = `b3; end
                            12'd38: begin freqL = `b3; freqR = `b3; end
                            12'd39: begin freqL = `b3; freqR = `b3; end
                            12'd40: begin freqL = `b3; freqR = `b3; end
                            12'd41: begin freqL = `b3; freqR = `b3; end
                            12'd42: begin freqL = `b3; freqR = `b3; end
                            12'd43: begin freqL = `b3; freqR = `b3; end
                            12'd44: begin freqL = `b3; freqR = `b3; end
                            12'd45: begin freqL = `b3; freqR = `b3; end
                            12'd46: begin freqL = `b3; freqR = `b3; end
                            12'd47: begin freqL = `silence; freqR = `silence; end

                            12'd48: begin freqL = `e3; freqR = `e3; end
                            12'd49: begin freqL = `e3; freqR = `e3; end
                            12'd50: begin freqL = `e3; freqR = `e3; end
                            12'd51: begin freqL = `e3; freqR = `e3; end
                            12'd52: begin freqL = `e3; freqR = `e3; end
                            12'd53: begin freqL = `e3; freqR = `e3; end
                            12'd54: begin freqL = `e3; freqR = `e3; end
                            12'd55: begin freqL = `e3; freqR = `e3; end
                            12'd56: begin freqL = `e3; freqR = `e3; end
                            12'd57: begin freqL = `e3; freqR = `e3; end
                            12'd58: begin freqL = `e3; freqR = `e3; end
                            12'd59: begin freqL = `e3; freqR = `e3; end
                            12'd60: begin freqL = `e3; freqR = `e3; end
                            12'd61: begin freqL = `e3; freqR = `e3; end
                            12'd62: begin freqL = `e3; freqR = `e3; end
                            12'd63: begin freqL = `silence; freqR = `silence; end

                            default: begin freqL = `silence; freqR = `silence; end // Silence
                        endcase
                    end else begin
                        case(ibeatNum)
                            12'd0: begin freqL = `f4; freqR = `f4; end
                            12'd1: begin freqL = `f4; freqR = `f4; end
                            12'd2: begin freqL = `f4; freqR = `f4; end
                            12'd3: begin freqL = `f4; freqR = `f4; end
                            12'd4: begin freqL = `f4; freqR = `f4; end
                            12'd5: begin freqL = `f4; freqR = `f4; end
                            12'd6: begin freqL = `f4; freqR = `f4; end
                            12'd7: begin freqL = `f4; freqR = `f4; end
                            12'd8: begin freqL = `f4; freqR = `f4; end
                            12'd9: begin freqL = `f4; freqR = `f4; end
                            12'd10: begin freqL = `f4; freqR = `f4; end
                            12'd11: begin freqL = `f4; freqR = `f4; end
                            12'd12: begin freqL = `f4; freqR = `f4; end
                            12'd13: begin freqL = `f4; freqR = `f4; end
                            12'd14: begin freqL = `f4; freqR = `f4; end
                            12'd15: begin freqL = `silence; freqR = `silence; end

                            12'd16: begin freqL = `a4; freqR = `a4; end
                            12'd17: begin freqL = `a4; freqR = `a4; end
                            12'd18: begin freqL = `a4; freqR = `a4; end
                            12'd19: begin freqL = `a4; freqR = `a4; end
                            12'd20: begin freqL = `a4; freqR = `a4; end
                            12'd21: begin freqL = `a4; freqR = `a4; end
                            12'd22: begin freqL = `a4; freqR = `a4; end
                            12'd23: begin freqL = `a4; freqR = `a4; end
                            12'd24: begin freqL = `a4; freqR = `a4; end
                            12'd25: begin freqL = `a4; freqR = `a4; end
                            12'd26: begin freqL = `a4; freqR = `a4; end
                            12'd27: begin freqL = `a4; freqR = `a4; end
                            12'd28: begin freqL = `a4; freqR = `a4; end
                            12'd29: begin freqL = `a4; freqR = `a4; end
                            12'd30: begin freqL = `a4; freqR = `a4; end
                            12'd31: begin freqL = `silence; freqR = `silence; end

                            12'd32: begin freqL = `c5; freqR = `c5; end
                            12'd33: begin freqL = `c5; freqR = `c5; end
                            12'd34: begin freqL = `c5; freqR = `c5; end
                            12'd35: begin freqL = `c5; freqR = `c5; end
                            12'd36: begin freqL = `c5; freqR = `c5; end
                            12'd37: begin freqL = `c5; freqR = `c5; end
                            12'd38: begin freqL = `c5; freqR = `c5; end
                            12'd39: begin freqL = `c5; freqR = `c5; end
                            12'd40: begin freqL = `c5; freqR = `c5; end
                            12'd41: begin freqL = `c5; freqR = `c5; end
                            12'd42: begin freqL = `c5; freqR = `c5; end
                            12'd43: begin freqL = `c5; freqR = `c5; end
                            12'd44: begin freqL = `c5; freqR = `c5; end
                            12'd45: begin freqL = `c5; freqR = `c5; end
                            12'd46: begin freqL = `c5; freqR = `c5; end
                            12'd47: begin freqL = `silence; freqR = `silence; end

                            12'd48: begin freqL = `f5; freqR = `f5; end
                            12'd49: begin freqL = `f5; freqR = `f5; end
                            12'd50: begin freqL = `f5; freqR = `f5; end
                            12'd51: begin freqL = `f5; freqR = `f5; end
                            12'd52: begin freqL = `f5; freqR = `f5; end
                            12'd53: begin freqL = `f5; freqR = `f5; end
                            12'd54: begin freqL = `f5; freqR = `f5; end
                            12'd55: begin freqL = `f5; freqR = `f5; end
                            12'd56: begin freqL = `f5; freqR = `f5; end
                            12'd57: begin freqL = `f5; freqR = `f5; end
                            12'd58: begin freqL = `f5; freqR = `f5; end
                            12'd59: begin freqL = `f5; freqR = `f5; end
                            12'd60: begin freqL = `f5; freqR = `f5; end
                            12'd61: begin freqL = `f5; freqR = `f5; end
                            12'd62: begin freqL = `f5; freqR = `f5; end
                            12'd63: begin freqL = `f5; freqR = `f5; end
                            12'd64: begin freqL = `f5; freqR = `f5; end
                            12'd65: begin freqL = `f5; freqR = `f5; end
                            12'd66: begin freqL = `f5; freqR = `f5; end
                            12'd67: begin freqL = `f5; freqR = `f5; end
                            12'd68: begin freqL = `f5; freqR = `f5; end
                            12'd69: begin freqL = `f5; freqR = `f5; end
                            12'd70: begin freqL = `f5; freqR = `f5; end
                            12'd71: begin freqL = `silence; freqR = `silence; end

                            12'd72: begin freqL = `c5; freqR = `c5; end
                            12'd73: begin freqL = `c5; freqR = `c5; end
                            12'd74: begin freqL = `c5; freqR = `c5; end
                            12'd75: begin freqL = `c5; freqR = `c5; end
                            12'd76: begin freqL = `c5; freqR = `c5; end
                            12'd77: begin freqL = `c5; freqR = `c5; end
                            12'd78: begin freqL = `c5; freqR = `c5; end
                            12'd79: begin freqL = `c5; freqR = `c5; end
                            12'd80: begin freqL = `c5; freqR = `c5; end
                            12'd81: begin freqL = `c5; freqR = `c5; end
                            12'd82: begin freqL = `c5; freqR = `c5; end
                            12'd83: begin freqL = `c5; freqR = `c5; end
                            12'd84: begin freqL = `c5; freqR = `c5; end
                            12'd85: begin freqL = `c5; freqR = `c5; end
                            12'd86: begin freqL = `c5; freqR = `c5; end
                            12'd87: begin freqL = `silence; freqR = `silence; end

                            12'd88: begin freqL = `f5; freqR = `f5; end
                            12'd89: begin freqL = `f5; freqR = `f5; end
                            12'd90: begin freqL = `f5; freqR = `f5; end
                            12'd91: begin freqL = `f5; freqR = `f5; end
                            12'd92: begin freqL = `f5; freqR = `f5; end
                            12'd93: begin freqL = `f5; freqR = `f5; end
                            12'd94: begin freqL = `f5; freqR = `f5; end
                            12'd95: begin freqL = `f5; freqR = `f5; end
                            12'd96: begin freqL = `f5; freqR = `f5; end
                            12'd97: begin freqL = `f5; freqR = `f5; end
                            12'd98: begin freqL = `f5; freqR = `f5; end
                            12'd99: begin freqL = `f5; freqR = `f5; end
                            12'd100: begin freqL = `f5; freqR = `f5; end
                            12'd101: begin freqL = `f5; freqR = `f5; end
                            12'd102: begin freqL = `f5; freqR = `f5; end
                            12'd103: begin freqL = `silence; freqR = `silence; end

                            default: begin freqL = `silence; freqR = `silence; end // Silence

                        endcase   
                    end
                end
                default: begin
                    freqL = `silence;
                    freqR = `silence;
                end
            endcase
        end
    end


    assign freq_outL = 50000000 / freqL;
    assign freq_outR = 50000000 / freqR;
    note_gen m9 (
        .clk(clk),
        .rst(rst),
        .volume(volume),
        .note_div_left(freq_outL),
        .note_div_right(freq_outR),
        .audio_left(audio_in_left),
        .audio_right(audio_in_right)
    );
    speaker_control sc(
        .clk(clk), 
        .rst(rst), 
        .audio_in_left(audio_in_left),      // left channel audio data input
        .audio_in_right(audio_in_right),    // right channel audio data input
        .audio_mclk(audio_mclk),            // master clock
        .audio_lrck(audio_lrck),            // left-right clock
        .audio_sck(audio_sck),              // serial clock
        .audio_sdin(audio_sdin)             // serial audio data input
    );

endmodule



module clock_divider(clk1, clk, clk22);
    input clk;
    output clk1;
    output clk22;
    reg [21:0] num;
    wire [21:0] next_num;

    always @(posedge clk) begin
    num <= next_num;
    end

    assign next_num = num + 1'b1;
    assign clk1 = num[1];
    assign clk22 = num[21];
endmodule

module clock_divider2(clk, clk_div);
    input clk;
    output clk_div;
    parameter n = 25;
    reg[n-1:0] num;
    wire[n-1:0] next_num;
    always @(posedge clk) begin
        num <= next_num;
    end
    assign next_num = num + 1;
    assign clk_div = num[n-1];
endmodule

module debounce(
    output pb_debounced, 
    input pb ,
    input clk
    );
    
    reg [15:0] shift_reg;
    always @(posedge clk) begin
        shift_reg[15:1] <= shift_reg[14:0];
        shift_reg[0] <= pb;
    end
    
    assign pb_debounced = shift_reg == 16'b111_1111_1111_1111 ? 1'b1 : 1'b0;
endmodule

module one_pulse (
    input wire clk,
    input wire pb_in,
    output reg pb_out
);

	reg pb_in_delay;

	always @(posedge clk) begin
		if (pb_in == 1'b1 && pb_in_delay == 1'b0) begin
			pb_out <= 1'b1;
		end else begin
			pb_out <= 1'b0;
		end
	end
	
	always @(posedge clk) begin
		pb_in_delay <= pb_in;
	end
endmodule