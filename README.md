"Projeto FPGA" 



Por que este projeto?

Este projeto foi desenvolvido com o objetivo de **explorar o uso de FPGA na comunicação com sensores digitais via I²C**, criando *cores reutilizáveis* e *medição a laser* em Verilog para integração com diferentes aplicações.  
A ideia é disponibilizar blocos prontos (cores) que podem ser utilizados em outros projetos, facilitando a prototipagem e o aprendizado.

- **TCS34725** → usado para leitura de cores (RGB + luminosidade).  
- **VL53L0X** → usado para medição de distância por Time-of-Flight (laser).  

Onde pode ser usado?

Esses módulos podem ser aplicados em diversos cenários, como:

- 🟢 **Robótica** → para identificação de cores e obstáculos.  
- 🔴 **Automação industrial** → sistemas de inspeção de qualidade e medição sem contato.  
- 🔵 **Dispositivos embarcados** → integração com microcontroladores ou FPGA para coleta de dados ambientais.  
- 🟡 **Projetos educacionais** → aprendizado de protocolos de comunicação e design digital em FPGA.  

O uso desses sensores em FPGA traz vantagens como **baixo tempo de resposta**, **processamento paralelo** e **maior controle sobre a comunicação**, quando comparado a microcontroladores tradicionais.


Este repositório contém os módulos (cores) em Verilog para comunicação com sensores via I²C:

TCS34725 → Sensor de cores RGB + luminosidade

VL53L0X → Sensor de distância por Time-of-Flight (laser)

Tecnologias Utilizadas

FPGA Lattice ECP5

Yosys / nextpnr / OSS CAD Suite

Verilog HDL

UART para debug

I²C Master implementado em Verilog

Imagens:

Foto monstagem placa e sensores

imagens/cores.jpg
Sensor de Cores

imagens/distancia.jpg
Sensor de distäncia


fpga-sensors/
│── src/
│   ├── cores/                # Sensores de cores
│   │   ├── tcs34725_reader.v
│   │   └── i2c_master.v
│   │
│   ├── distancia/            # Sensores de distância
│   │   ├── vl53l0x_reader.v
│   │   └── i2c_master.v
│   │
│   ├── uart_tx_8n1.v         # UART para debug
│   └── top.v                 # Módulo principal
│
│── images/                   # Fotos e diagramas
│   ├── fluxograma.png
│   └── prototipo.jpg
│
│── .gitignore
│── LICENSE
│── README.md

Pinagens:

Core

# Clock 25 MHz
LOCATE COMP "clk" SITE "P3"; IOBUF PORT "clk" PULLMODE=NONE;

# Reset
LOCATE COMP "rst_n" SITE "P4"; IOBUF PORT "rst_n" PULLMODE=UP;

# I2C
LOCATE COMP "sda" SITE "C4"; IOBUF PORT "sda" IO_TYPE=LVCMOS33;
LOCATE COMP "scl" SITE "B4"; IOBUF PORT "scl" IO_TYPE=LVCMOS33;

# LED RGB
LOCATE COMP "led_rgb[0]" SITE "E5"; IOBUF PORT "led_rgb[0]" IO_TYPE=LVCMOS33;
LOCATE COMP "led_rgb[1]" SITE "F5"; IOBUF PORT "led_rgb[1]" IO_TYPE=LVCMOS33;
LOCATE COMP "led_rgb[2]" SITE "G5"; IOBUF PORT "led_rgb[2]" IO_TYPE=LVCMOS33;

# UART
LOCATE COMP "tx" SITE "J19"; IOBUF PORT "tx" IO_TYPE=LVCMOS33;

Distäncia

# Clock 25 MHz
LOCATE COMP "clk" SITE "P3";
IOBUF PORT "clk" IO_TYPE=LVCMOS33;

# Reset ativo baixo
LOCATE COMP "rst_n" SITE "P4";
IOBUF PORT "rst_n" PULLMODE=UP IO_TYPE=LVCMOS33;

# UART
LOCATE COMP "tx" SITE "J19";
IOBUF PORT "tx" IO_TYPE=LVCMOS33;

# LED de teste
LOCATE COMP "led" SITE "L2";
IOBUF PORT "led" IO_TYPE=LVCMOS33 DRIVE=8 SLEWRATE=FAST PULLMODE=NONE;

# I2C placeholder
LOCATE COMP "sda" SITE "K20";
IOBUF PORT "sda" IO_TYPE=LVCMOS33;
LOCATE COMP "scl" SITE "J20";
IOBUF PORT "scl" IO_TYPE=LVCMOS33;


Sintentize o projeto:

yosys -p "read_verilog top.v i2c_master.v tcs34725_reader.v vl53l0x_reader.v uart_tx_8n1.v; synth_ecp5 -top top -json top.json"
nextpnr-ecp5 --json top.json --lpf top.lpf --textcfg top.config --45k --package CABGA381
ecppack top.config top.bit

Gravar Bistream na FPGA:

openFPGALoader  -b colorlight-i9 --unprotect-flash -f top_color.bin



Possíveis Causas de Não Funcionamento

Se o projeto não funcionar como esperado, verifique:

🔌 Conexão física dos sensores

SDA / SCL invertidos

Resistores pull-up ausentes (4.7k–10k típicos)

⚡ Alimentação incorreta

VL53L0X e TCS34725 operam em 3.3V

⏱️ Clock I²C incompatível

Alguns sensores não suportam frequências altas (>400kHz)

🔄 Problemas no reset do core

Reset assíncrono não aplicado corretamente

💾 Erros na compilação/síntese

Módulos não incluídos no yosys

Warnings ignorados podem virar falhas na FPGA

🖥️ UART sem resposta

Baud rate errado

Porta serial incorreta no PC


Autor

Manoel Severino de Moraes