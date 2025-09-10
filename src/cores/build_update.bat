@echo off
setlocal

rem Caminho do OSS CAD Suite
set OSSCAD=C:\oss-cad-suite

rem Arquivos de projeto
set PROJ=C:\FPGA_V2\final\cor

cd %PROJ%

echo ======== 1. Síntese com Yosys ========
C:\oss-cad-suite\\bin\yosys -p "read_verilog top_color.v i2c_master.v tcs34725_reader.v led_rgb_control.v uart_tx.v rst_gen.v; synth_ecp5 -top top_color -json top_color.json"

echo ======== 2. Place & Route ========
C:\oss-cad-suite\\bin\nextpnr-ecp5 --json top_color.json --lpf top_color.lpf --textcfg top_color.config --45k --package CABGA381

echo ======== 3. Gerar Bitstream ========
C:\oss-cad-suite\bin\ecppack top_color.config top_color.bin

echo ======== 4. Gravar FPGA ========
C:\oss-cad-suite\bin\openFPGALoader  -b colorlight-i9 --unprotect-flash -f top_color.bin

pause
