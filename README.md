# Protocolo-UART
Evidencia 2. Implementación del Protocolo UART en Verilog y Síntesis con TinyTapeout

El protocolo UART facilita la transmisión de datos de manera asíncrona. Esta actividad requirió el diseño de una máquina de estados que permita este tipo de comunicación, en el lenguaje de programación Verilog. 

Para desarrollar la máquina de estados, se crearon 2 módulos:
- UART_TX.v: transmisión de datos.
- UART_RX.v: recepción de datos.
Estos diseños se combinaron con el código UART.v, y se comprobaron con UART_tb.v. Para comprobación del código en el testbench, se utilizó la herramienta gtkwave, que utiliza el archivo UART.vcd adjuntado.

Además se adjunta el archivo UART.gds.zip, el cual se obtuvo después de la comprobación de la viabilidad del código en GoogleColab (archivo adjunto Evidencia 2 - Introducción a la cadena de valor de los semiconductores), para la creación de un chip. En las imágenes adjuntadas, se puede observar el chip creado con la herramienta virtual de TinyTapeOut.

Finalmente, se adjunta un archivo pdf, con el reporte completo de la realización de esta actividad.

<img width="1221" height="1223" alt="image" src="https://github.com/user-attachments/assets/7583daef-5faa-4920-8741-5099b22cc865" />
