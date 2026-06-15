// codigo conjunto de UART_TX y UART_RX

module UART(
    input        clk,
    input        rst,
    input  [7:0] dataIn, // entrada a TX
    input        send, // señal para iniciar transmisión
    input        clkEn, // activa baud rate (x16)
    input        rdyClr, // limpia la rdy en RX
    output       busy, // TX ocupado
    output       rdy, // RX tiene dato válido
    output [7:0] dataOut // dato recibido por RX
);

    wire serial;  // línea serie que conecta TX a RX

    UART_TX u_tx ( // como se llaman las variables de TX en este codigo
        .clk    (clk),
        .rst    (rst),
        .dataIn (dataIn),
        .send   (send),
        .clkEn  (clkEn),
        .tx     (serial),
        .busy   (busy)
    );

    UART_RX u_rx ( // como se llaman las variables de RX en este codigo
        .clk     (clk),
        .rst     (rst),
        .rx      (serial),
        .rdyClr  (rdyClr),
        .clkEn   (clkEn),
        .rdy     (rdy),
        .dataOut (dataOut)
    );
endmodule

module UART_TX( //maquina de estados TX
    input clk, rst, send, clkEn,
    input [7:0] dataIn,
    output reg tx, busy);
    
    parameter estadoInicio = 2'd0,
              estadoDataIn = 2'd1,
              estadoStop   = 2'd2;

    reg [1:0] estadoActual;
    reg [3:0] sample, index;
    reg [7:0] temp;

    always @(posedge clk or posedge rst) // maquina de estados
    begin
        if (rst) // estado inicial al cual volver en caso de rst
        begin
            tx           <= 1'b1;
            busy         <= 1'b0;
            estadoActual <= estadoInicio;
            sample       <= 4'd0;
            index        <= 4'd0;
            temp         <= 8'd0;
        end

        else if (clkEn) // solo avanza con el baud rate
        begin
            case (estadoActual)
                estadoInicio:
                begin
                    tx <= 1'b1;
                    busy <= 1'b0;
                    if (send)
                    begin
                        estadoActual <= estadoDataIn;
                        temp <= dataIn;
                        index <= 4'd0;
                        sample <= 4'd0;
                        busy <= 1'b1;
                        tx <= 1'b0;
                    end
                end

                estadoDataIn:
                begin
                    busy <= 1'b1;
                    tx <= temp[index];
                    sample <= sample + 4'd1;
                    if (sample == 4'd15)
                        index <= index + 4'd1;
                    if (index == 4'd7 && sample == 4'd15)
                    begin
                        estadoActual <= estadoStop;
                        sample <= 4'd0;
                    end
                end

                estadoStop:
                begin
                    busy <= 1'b1;
                    tx <= 1'b1;
                    sample <= sample + 4'd1;
                    if (sample == 4'd15)
                    begin
                        estadoActual <= estadoInicio;
                        sample <= 4'd0;
                        busy <= 1'b0;
                    end
                end

                default:
                begin
                    estadoActual <= estadoInicio;
                    sample <= 4'd0;
                    tx <= 1'b1;
                end
            endcase
        end
    end
endmodule

module UART_RX(
    input clk, rst, rx, rdyClr, clkEn,
    output reg rdy,
    output reg [7:0] dataOut
);
    parameter estadoInicio  = 2'd0,
              estadoDataOut = 2'd1,
              estadoStop    = 2'd2;

    reg [1:0] estadoActual;
    reg [3:0] sample, index;
    reg [7:0] temp;

    always @(posedge clk or posedge rst)
    begin
        if (rst) // estado inicial al cual volver encaso de rst
        begin
            rdy          <= 1'b0;
            dataOut      <= 8'd0;
            estadoActual <= estadoInicio;
            sample       <= 4'd0;
            index        <= 4'd0;
            temp         <= 8'd0;
        end
        else if (rdyClr) // limpiar rdy
            rdy <= 1'b0;
        else if (clkEn) // avanza con el baud rate
        begin
            case (estadoActual)
                estadoInicio:
                begin
                    if (!rx || sample != 4'd0)
                        sample <= sample + 4'd1;
                    if (sample == 4'd7 && !rx)
                    begin
                        estadoActual <= estadoDataOut;
                        index        <= 4'd0;
                        sample       <= 4'd0;
                        temp         <= 8'd0;
                    end
                end

                estadoDataOut:
                begin
                    sample <= sample + 4'd1;
                    if (sample == 4'd7)
                    begin
                        temp[index] <= rx;
                        index       <= index + 4'd1;
                    end
                    if (index == 4'd8 && sample == 4'd15)
                    begin
                        estadoActual <= estadoStop;
                        sample       <= 4'd0;
                    end
                end

                estadoStop:
                begin
                    if (sample == 4'd7)
                    begin
                        estadoActual <= estadoInicio;
                        dataOut      <= temp;
                        rdy          <= 1'b1;
                        sample       <= 4'd0;
                    end
                    else
                        sample <= sample + 4'd1;
                end

                default:
                begin
                    estadoActual <= estadoInicio;
                    sample       <= 4'd0;
                end
            endcase
        end
    end
endmodule