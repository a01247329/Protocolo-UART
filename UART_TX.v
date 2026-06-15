// Máquina de estados de un transmisor de señales UART (TX)

module UART_TX(
    input clk, rst,
    input [7:0] dataIn,  // dato paralelo a transmitir
    input send,          // señal para iniciar la transmisión
    input clkEn,         // activa el clk (baud rate x16)
    output reg tx,       // serial output, lo enviamos a rx
    output reg busy);    // indica que la transmisión está en curso

    // estados de la FSM
    parameter estadoInicio = 2'd0, // espera la señal de envío
              estadoDataIn = 2'd1, // se transmiten los 8 bits de datos
              estadoStop   = 2'd2; // se finaliza la transmisión

    reg [1:0] estadoActual;
    reg [3:0] sample, index;  // contador de muestras, índice del bit actual
    reg [7:0] temp;           // registro de los datos a transmitir

    always @(posedge clk or posedge rst) // maquina de estados
    begin
        if (rst)  // valor inicial a reestablecer en caso de rst
        begin
            tx           <= 1'd1;
            busy         <= 1'd0;
            estadoActual <= estadoInicio;
            sample       <= 4'd0;
            index        <= 4'd0;
            temp         <= 8'd0;
        end
        else if (clkEn) // la fsm empieza solo si se activa clkEn
        begin
            case (estadoActual)
                estadoInicio:
                begin
                    tx   = 1'd1; // línea en reposo en alto
                    busy = 1'd0;
                    if (send) // se inicia la transmisión cuando send es activado
                    begin
                        estadoActual <= estadoDataIn;
                        temp <= dataIn; // se carga el dato a transmitir
                        index <= 4'd0;
                        sample <= 4'd0;
                        busy <= 1'd1;
                        tx <= 1'd0; // se envía el bit de inicio (start bit)
                    end
                end

                estadoDataIn:
                begin
                    busy = 1'd1;
                    tx = temp[index]; // se transmite el bit en el índice indicado
                    sample <= sample + 4'd1; // se le suma 1 a sample automáticamente
                    if (sample == 4'd15)
                    begin
                        index <= index + 4'd1; // se le suma 1 a índice
                    end
                    if (index == 4'd7 && sample == 4'd15) // cambio de estado cuando se transmiten 8 bits
                    begin                                 // y el muestreo es 15 de nuevo
                        estadoActual <= estadoStop;
                        sample <= 4'd0;
                    end
                end

                estadoStop: // estado final donde se cierra la transmisión
                begin
                    busy = 1'd1;
                    tx   = 1'd1; // se envía el bit de parada (stop bit)
                    sample <= sample + 4'd1;
                    if (sample == 4'd15) // se reinicia la máquina cuando el muestreo es 15
                    begin
                        estadoActual <= estadoInicio;
                        sample <= 4'd0; // reiniciamos el muestreo
                        busy <= 1'd0; // se indica que la transmisión terminó
                    end
                end

                default: // estado que se activa automáticamente
                begin
                    estadoActual <= estadoInicio;
                    sample       <= 4'd0;
                    tx           <= 1'd1;
                end

            endcase
        end
    end

endmodule