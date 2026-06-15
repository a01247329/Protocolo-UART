// generador del baud rate


module BAUD_RATE(
    input  clk,
    input  rst,
    output txEnb, // activa el transmisor
    output rxEnb // activa el receptor
);
    reg [12:0] txCounter;
    reg [9:0]  rxCounter;

    always @(posedge clk) begin  // baud rate base
        if (rst || txCounter == 5208)
            txCounter <= 13'h0;
        else
            txCounter <= txCounter + 1'b1;
    end

    always @(posedge clk) begin // baud rate mas rapido (x16)
        if (rst || rxCounter == 325)
            rxCounter <= 10'h0;
        else
            rxCounter <= rxCounter + 1'b1;
    end

    assign txEnb = (txCounter == 0) ? 1'b1 : 1'b0; // si rxCounter == 0, se manda un 1, sino un 0
    assign rxEnb = (rxCounter == 0) ? 1'b1 : 1'b0; // si rxCounter == 0, se manda un 1, sino un 0

endmodule