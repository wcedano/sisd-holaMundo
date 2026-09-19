# sisd-holaMundo

Prueba de toolchain para Sistemas Digitales con FPGA · ITLA · matricula 99-0544

Un boton enciende un LED. Sirve para una sola cosa: comprobar que el toolchain
quedo montado. Si esto funciona, el siguiente error que veas sera tuyo y no de
la instalacion.

    btn_raw (F5, boton S1)  ──►  led (G11, primer LED)

## 1. Verificar sin la placa

No hace falta la Tang Primer para esto. Desde esta carpeta:

    verilator --lint-only -Wall --top-module top src/*.v
    mkdir -p build
    iverilog -g2012 -o build/sim.out src/*.v tb/tb_top.v
    cd build && vvp sim.out

Lo que tiene que salir:

    [L1] caso 1: PASS  en reposo (btn_raw=1) el LED esta apagado
    [L1] caso 2: PASS  pulsado (btn_raw=0) el LED se enciende
    [L1] caso 3: PASS  al soltar vuelve a apagarse, no se engancha
    [L1] caso 4: PASS  BUTTON_ACTIVE_LOW=0 invierte la lectura del boton
    [L1] caso 5: PASS  LED_ACTIVE_LOW=1 invierte la salida hacia el pin
    == fallos: 0 ==
    == el toolchain funciona de punta a punta ==

Si Verilator no dice nada y vvp imprime esas cinco lineas, **WSL, Verilator e
Icarus estan bien**. Te falta solo la mitad de Windows: Gowin y el driver.

Con el Makefile del curso, si copias esta carpeta dentro del repo:

    make -C 00_infra lint  SRC_DIR=<ruta-a-esta-carpeta>
    make -C 00_infra sim   SRC_DIR=<ruta-a-esta-carpeta>
    make -C 00_infra check SRC_DIR=<ruta-a-esta-carpeta>

En `resultados.json` veras L2 y L3 en cero. Es correcto: este ejemplo no es un
Code Challenge, solo cubre el nivel L1.

## 2. Ver las ondas

    gtkwave build/dump.vcd

Es la prueba de que GTKWave abre ventana. En Windows 11 funciona solo con
WSLg; en Windows 10 necesitas VcXsrv.

## 3. Grabar en la placa

En Windows, con Gowin EDA:

1. Proyecto nuevo, dispositivo **GW5A-LV25MG121NES**, serie GW5A-25.
2. Anade `src/top.v` y `top.cst`.
3. Synthesize, luego Place & Route.
4. Programmer, conecta la placa y graba.

Si el Programmer no ve la placa, el driver USB no esta: instala WinUSB en el
puerto de depuracion con **Zadig**.

No hay `top.sdc` en esta carpeta a proposito. El diseno no tiene reloj, asi
que no hay nada que restringir; un `create_clock` sobre un puerto que no
existe es un error, no una precaucion.

## 4. Si el LED se comporta al reves

No toques la logica. Cambia el parametro y vuelve a sintetizar:

| Lo que ves | Que cambiar |
|---|---|
| LED encendido en reposo, se apaga al pulsar | `LED_ACTIVE_LOW` a `1'b1` |
| El LED no reacciona y el boton parece invertido | `BUTTON_ACTIVE_LOW` a `1'b0` |

Cuando confirmes cual es la buena, anotalo en `00_infra/pinout.md`. Ese dato
pertenece al archivo de la placa, no a tu proyecto.

## Estructura

    sisd-holaMundo/
    ├── src/
    │   └── top.v                    el modulo, combinacional puro
    ├── tb/
    │   └── tb_top.v                 5 casos, tabla de verdad completa
    ├── referencia/
    │   └── placa_completa.cst       mapa completo de pines, para consultar
    ├── top.cst                      solo btn_raw y led
    ├── AI_LOG.md
    └── README.md

Es tambien la forma que debe tener una entrega real: `src/`, `tb/`, el `.cst`
y `AI_LOG.md` en la raiz.

## Antes de nada: git

La carpeta llega sin historial, a proposito. El historial es tu evidencia de
proceso y tiene que ser tuyo.

    git init
    git add .
    git commit -m "hola mundo: el toolchain funciona"

## Un aviso sobre el .cst general

`referencia/placa_completa.cst` trae dos nombres repetidos sobre el mismo pin:
`btn_raw` y `i_button[0]` piden los dos el pin **F5**, y `led` y `o_led[0]`
piden los dos **G11**. Son el mismo boton y el mismo LED con dos nombres, uno
para el top reducido y otro para el top completo.

Si copias ese archivo entero a un diseno que declare los dos pares de puertos,
Gowin aborta el place & route por conflicto de ubicacion. Copia solo las
lineas de los puertos que tu top declare.
