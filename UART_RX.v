// Máquina de estados de un recibidor de señales UART (RX)

module UART_RX(
    input clk, rst, 
    input rx,  // serial input, lo recibimos de tx
    input rdyClr,  // limpia rdy después de que es leído
    input clkEn,  // activa el clk (baud rate x16)
    output reg rdy,  // será el indicador de que dataOut tiene un valor válido
    output reg [7:0]  dataOut); // outputs recibidos configurados de manera paralela

    // estados de la FSM
    parameter estadoInicio = 2'd0, // se recibe el bit de entrada 
              estadoDataOut = 2'd1, // se realiza el muestreo por 8 bits
              estadoStop = 2'd2; // se finaliza el muestreo

    reg [1:0] estadoActual;
    reg [3:0] sample, index;  // contador de muestras, índice del bit actual
    reg [7:0] temp;  // registro de los datos recibidos de tx

    always @(posedge clk or posedge rst) // maquina de estados
    begin
        if (rst)  // valor inicial a reestablecer en caso de rst
        begin
            rdy <= 1'd0;
            dataOut <= 8'd0;
            estadoActual <= estadoInicio;
            sample <= 4'd0;
            index <= 4'd0;
            temp <= 8'd0;
        end
        
        else if (rdyClr) // se limpia rdy cuando se llama rdyClr
            rdy <= 1'd0;

        else if (clkEn) // la fsm empieza solo si se activa clkEn
        begin
            case (estadoActual)
                estadoInicio:
                begin
                    if (!rx || sample != 4'd0) // si no se reciben datos de tx o sample NO es 0 a 4 bits
                        sample <= sample + 4'd1;  // se le suma 1 al muestreo

                    if (sample == 4'd7 && !rx) // cambio de estado cuando no se reciben datos de tx (rx == 0)
                    begin                      // y la muestreo llega 15
                        estadoActual <= estadoDataOut;
                        index <= 4'd0;
                        sample <= 4'd0;
                        temp <= 8'd0;
                    end
                end

                estadoDataOut:
                begin
                    sample <= sample + 4'd1; // se le suma 1 a sample automaticamente
                    if (sample == 4'd7)
                    begin
                        temp[index] <= rx; // se agrega el dato recibido al registro, en el indice indicado
                        index <= index + 4'd1; // se le suma 1 a indice 
                    end
                    if (index == 4'd8 && sample == 4'd15) // cambio de estado cuando se reciben 8 bits
                    begin                                 // y el muestreo es 15 de nuevo
                        estadoActual <= estadoStop; 
                        sample <= 4'd0;
                    end
                end

                estadoStop: // estado final donde se manda el dato
                begin
                    if (sample == 4'd7) // se reinicia la maquina cuando el muestro es 15 
                    begin
                        estadoActual <= estadoInicio; 
                        dataOut <= temp; // se envia el registro de datos recibidos
                        rdy<= 1'd1; // se activa el indicador
                        sample <= 4'd0; // reiniciamos el muestreo
                    end
                    else
                        sample <= sample + 4'd1;
                end

                default: // estado que se activa automaticamente 
                begin
                    estadoActual <= estadoInicio;
                    sample <= 4'd0;
                end

            endcase
        end
    end

endmodule