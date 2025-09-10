@echo off
REM ======================================================
REM Colorlight i9 V7 – Projeto de distância com UART de teste
REM Pasta base: C:\FPGA_V2\final\distancia
REM ======================================================

REM Caminho do Yosys e NextPNR (ajustar conforme seu ambiente)
SET PATH=C:\yosys;%PATH%
SET PATH=C:\nextpnr-ecp5;%PATH%

REM Caminho do OpenFPGALoader
SET PATH=C:\openFPGALoader;%PATH%

REM Entrar na pasta do projeto
cd /d C:\FPGA_V2\final\distancia

echo ======================================================
echo 1/4 - Síntese com Yosys
echo ======================================================
yosys -p "read_verilog top.v uart_tx.v rst_gen.v; synth_ecp5 -top top -json top.json"

if %errorlevel% neq 0 (
    echo ERRO: Síntese falhou
    pause
    exit /b
)

echo ======================================================
echo 2/4 - Place & Route com nextpnr-ecp5
echo ======================================================
nextpnr-ecp5 --json top.json --lpf top.lpf --45k --package CABGA381 --textcfg top.config



if %errorlevel% neq 0 (
    echo ERRO: Place & Route falhou
    pause
    exit /b
)

echo ======================================================
echo 3/4 - Gerar bitstream
echo ======================================================
ecppack top.config top.bit

if %errorlevel% neq 0 (
    echo ERRO: Gerar bitstream falhou
    pause
    exit /b
)

echo ======================================================
echo 4/4 - Gravar FPGA
echo ======================================================
openFPGALoader -b colorlight-i9 --unprotect-flash -f top.bit 

if %errorlevel% neq 0 (
    echo ERRO: Upload falhou
    pause
    exit /b
)

echo ======================================================
echo FPGA programada com sucesso!
pause
