# sisd-holaMundo

Un boton enciende un LED en la **Tang Primer 25K** (GW5A-25) con la placa Dock.

Sirve para una sola cosa: comprobar que el toolchain quedo montado. Si esto
enciende el LED, el siguiente error que veas sera tuyo y no de la instalacion.

    btn_raw (F5, boton S1)  ──►  led (G11, primer LED)

## Probar sin la placa

No hace falta la FPGA para esto:

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

Si Verilator no dice nada y vvp imprime esas cinco lineas, **Verilator e
Icarus estan bien**. Falta solo la mitad de Windows: Gowin y el driver.

Ver las ondas: `gtkwave build/dump.vcd`. En Windows 11 abre solo con WSLg; en
Windows 10 necesitas VcXsrv.

## Grabar en la placa

En Windows, con Gowin EDA:

1. Proyecto nuevo, dispositivo **GW5A-LV25MG121NES**, serie GW5A-25.
2. Anade `src/top.v` y `top.cst`.
3. Synthesize, luego Place & Route.
4. Programmer, conecta la placa y graba.

Si el Programmer no ve la placa, el driver USB no esta: instala WinUSB en el
puerto de depuracion con **Zadig**.

No hay `.sdc` a proposito. El diseno no tiene reloj, asi que no hay nada que
restringir; un `create_clock` sobre un puerto que no existe es un error, no
una precaucion.

## Si el LED se comporta al reves

No toques la logica. Cambia el parametro y vuelve a sintetizar:

| Lo que ves | Que cambiar |
|---|---|
| LED encendido en reposo, se apaga al pulsar | `LED_ACTIVE_LOW` a `1'b1` |
| El LED no reacciona y el boton parece invertido | `BUTTON_ACTIVE_LOW` a `1'b0` |

## Sobre el .cst

`top.cst` lleva **solo los dos pines que declara el modulo**. Una restriccion
solo puede apuntar a un puerto que exista: dejar ahi el display, los ocho LEDs
o los interruptores llena el informe de Gowin de avisos que tapan los que
importan.

Cuidado si copias el `.cst` general de la placa: `btn_raw` comparte el pin F5
con `i_button[0]`, y `led` comparte G11 con `o_led[0]`. Son el mismo boton y
el mismo LED con dos nombres. Dos puertos sobre el mismo balon aborta el place
& route, asi que nunca actives los dos pares a la vez.

## Estructura

    sisd-holaMundo/
    ├── src/top.v      el modulo, combinacional puro
    ├── tb/tb_top.v    5 casos, tabla de verdad completa
    └── top.cst        solo btn_raw y led
