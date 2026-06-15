// Testbench para el DUT de UART (TX + RX)

module UART_tb();
    reg clk, rst; // se establecen los inputs del código a probar como registros
    reg [7:0] dataIn;
    reg send;
    reg clkEn;
    reg rdyClr;
    wire busy; // se establecen los outputs como wires
    wire rdy;
    wire [7:0] dataOut;
    wire txEnb;
    wire rxEnb;

    BAUD_RATE u_baud( // variables del baud rate en el tb .variable_tb(variable del diseño)
        .clk  (clk),
        .rst  (rst),
        .txEnb(txEnb),
        .rxEnb(rxEnb)
    );

    UART DUT( // establecemos la variable del diseño como en el tb como: .variable_tb(variable del diseño)
        .clk    (clk),
        .rst    (rst),
        .dataIn (dataIn),
        .send   (send),
        .clkEn  (clkEn),
        .rdyClr (rdyClr),
        .busy   (busy),
        .rdy    (rdy),
        .dataOut(dataOut)
    );

    always #5 clk = ~clk; // cuantos tiempos se utilizaran en clk = 1, y cuantos en clk = 0

    initial  // se prueban posibles configuraciones del código
    begin
        clk    = 0; // inicializamos todas las variables en 0
        rst    = 0;
        send   = 0;
        rdyClr = 0;
        dataIn = 8'd0;

        #20; // se le dan 20 ciclos para correr el código
        rst = 1; // se reinicia el UART
        #20;
        rst = 0;

        #200; // se envia 10100101
        dataIn = 8'hA5; // transmite el dato
        send   = 1; // se activa la señal de envío
        @(posedge busy); // espera a que TX acepte el dato
        send   = 0;
        @(negedge busy); // espera a que TX termine la transmision completa
        #500; // vscode lo pone como RGB pero no afecta

        dataIn = 8'hFF; // se envia 11111111
        send   = 1;
        @(posedge busy);
        send   = 0;
        @(negedge busy);
        #500;

        dataIn = 8'h00; // se envia 00000000
        send   = 1;
        @(posedge busy);
        send   = 0;
        @(negedge busy);
        #500;

        @(posedge txEnb);
        dataIn = 8'h3C; // dato de prueba 00111100
        send   = 1;
        @(posedge busy);
        send   = 0;
        @(negedge busy);
        #500;
        rdyClr = 1; // se limpia la señal rdy
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
        $dumpfile("UART.vcd"); // genera un archivo para las señales analizadas
        $dumpvars(0, UART_tb); // establece en que tiempo empieza la simulación, y las variables a utilizar
    end
endmodule