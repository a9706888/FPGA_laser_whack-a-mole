`define silence   32'd50000000
`define c4  32'd262   // C4
`define d4 32'd294   // D4
`define e4 32'd330   // E4
`define f4 32'd349   // F4
`define g4 32'd392   // G4
`define a4 32'd440   // A4
`define b4 32'd494   // B4
`define c5 32'd523   // C5
`define d5 32'd587   // D5
`define e5 32'd659   // E5
`define f5 32'd698   // F5
`define g5 32'd784   // G5
`define a5 32'd880   // A5
`define b5 32'd988   // B5

module sound(
    input wire clk,
    input wire rst,        // BTNC: active high reset
    input wire [2:0] life, // life[3:0] is the current life count
    output wire audio_mclk, // master clock
    output wire audio_lrck, // left-right clock
    output wire audio_sck,  // serial clock
    output wire audio_sdin // serial audio data input
    );      

    // kb_signal m1 (.clk(clk), .rst(rst), .PS2_DATA(PS2_DATA), .PS2_CLK(PS2_CLK), .key(key));
    reg [31:0] freqL, freqR;
    wire [21:0] freq_outL, freq_outR;
    reg [31:0] freqL_next, freqR_next;
    wire [15:0] audio_in_left, audio_in_right;
    // reg [4:0] tmp;
    reg [3:0] volume;
    

    always@(posedge clk)begin
        if(rst)begin
            freqL <= `silence;
            freqR <= `silence;
            volume <= 5'b00000;
        end
        else begin
            freqL <= freqL_next;
            freqR <= freqR_next;
            volume <= 3'd3;
        end
    end
    always@*begin
        case(life)
            4'd1:begin
                freqL_next = `c4;
                freqR_next = `c4;
            end
            4'd2:begin
                freqL_next = `d4;
                freqR_next = `d4;
            end
            4'd3:begin
                freqL_next = `e4;
                freqR_next = `e4;
            end
            default:begin
                freqL_next = `silence;
                freqR_next = `silence;
            end
        endcase
    end




    assign freq_outL = 50000000 / freqL;
    assign freq_outR = 50000000 / freqR;
    notegen m9 (
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