# Protocolo-UART
Evidencia 2. Implementación del Protocolo UART en Verilog y Síntesis con TinyTapeout

El protocolo UART facilita la transmisión de datos de manera asíncrona. Esta actividad, requirió el diseño de una máquina de estados que permita este tipo de comunicación, en el lenguaje de programación Verilog. 

Para desarrollar la máquina de estados, se crearon 2 módulos:
- UART_TX.v: transmision de datos.
- UART_RX.v: recepcion de datos.
Estos diseños se combinaron con el codigo UART.v, y se comprobaron con UART_tb.v. Para comprobacion del codigo en el testbench, se utilizo la herramienta gtkwave, que utiliza el archivo UART.vcd adjuntado.

Ademas se ajunta el archivo UART.gds, el cual se obtuvo despues de la comprobacion de la viabilidad del codigo en GoogleColab, para la creacion de un chip. En las imagenes adjuntadas, se puede observar el chip creado con la herramienta virtual de TinyTapeOut.

Finalmente, se adjunta un archivo pdf, con el reporte completo de la realizacion de esta actividad. 

<img width="1221" height="1223" alt="image" src="https://github.com/user-attachments/assets/7583daef-5faa-4920-8741-5099b22cc865" />
