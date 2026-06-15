/* Testbench para el DUT de UART con generador de Baud Rate
   Aquí, se comprueba el funcionamiento correcto del código diseñado anteriormente.
*/
module UART_TB();
    reg clk, rst;        // se establecen los inputs del código a probar como registros
    reg  [7:0] dataIn;
    reg send, rdyClr;
    wire busy, rdy;            // se establecen los outputs como wires
    wire [7:0] dataOut;
    wire txEnb, rxEnb;

    BAUD_RATE u_baud(           // instancia del generador de baud rate
        .clk(clk),
        .rst(rst),
        .txEnb(txEnb),
        .rxEnb(rxEnb)
    );

    UART DUT(                   // establecemos la variable del diseño como en el tb como: .variabletb(variable del diseño)
        .clk(clk),
        .rst(rst),
        .dataIn(dataIn),
        .send(send),
        .clkEn(rxEnb),        // rxEnb es x16 del baud rate base, necesario para muestreo de RX
        .rdyClr(rdyClr),
        .busy(busy),
        .rdy(rdy),
        .dataOut(dataOut)
    );

    always #5 clk = ~clk;      // cuantos tiempos se utilizaran en clk = 1, y cuantos en clk = 0

    initial                     // se prueban posibles configuraciones de código
    begin
        clk = 0;             // inicializamos todas las variables en 0
        rst = 0;
        send = 0;
        rdyClr = 0;
        dataIn = 8'd0;

        #20;                    // se le dan 20 ciclos para correr el código
        rst = 1;                // se reinicia la UART
        #20;
        rst = 0;

        #200;
        dataIn = 8'hA5; // se carga el dato a transmitir (10100101)
        send = 1; // send se mantiene hasta que TX confirme con busy=1
        @(posedge busy); // se espera a que TX acepte el dato
        send = 0; // recien aqui se baja send
        @(negedge busy); // se espera a que TX termine la transmision completa
        #500;

        dataIn = 8'hFF; // se manda 11111111
        send = 1;
        @(posedge busy);
        send = 0;
        @(negedge busy);
        #500;

        dataIn = 8'h00; // se manda 00000000
        send = 1;
        @(posedge busy);
        send = 0;
        @(negedge busy);
        #500;

        dataIn = 8'h3C; // se manda 00111100
        send = 1;
        @(posedge busy);
        send = 0;
        @(negedge busy);
        rdyClr = 1; // se limpia la señal rdy del RX
        #10;
        rdyClr = 0;

        $finish;
    end

    initial
    begin
        $monitor("Cambio en señales UART: dataIn=%h send=%b busy=%b rdy=%b dataOut=%h",
                  dataIn, send, busy, rdy, dataOut);
    end

    initial
    begin
        $dumpfile("UART.vcd");      // genera un archivo para las señales analizadas
        $dumpvars(0, uarttb);      // establece en que tiempo empieza la simulación, y las variables a utilizar
    end
endmodule