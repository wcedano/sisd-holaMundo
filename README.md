# sisd-holaMundo

Un boton enciende un LED en la **Tang Primer 25K** (GW5A-25) con la placa Dock.

Sirve para una sola cosa: comprobar que el toolchain quedo montado. Si esto
enciende el LED, el siguiente error que veas sera tuyo y no de la instalacion.

    btn_raw (F5, boton S1)  ──►  led (G11, primer LED)

## Probar sin la placa

No hace falta la FPGA para esto. Desde esta carpeta:

    make lint     # Verilator: si no dice nada, esta limpio
    make sim      # Icarus: compila y ejecuta el testbench
    make check    # las dos cosas, con un resumen al final
    make synth    # Gowin: bitstream en impl/pnr/top.fs
    make help     # todos los objetivos

Son los mismos nombres que usa el Makefile comun del curso, donde se invocan
con la ruta del proyecto:

    make -C 00_infra lint SRC_DIR=<ruta-del-proyecto>

Lo que tiene que salir con `make sim`:

    [L1] caso 1: PASS  en reposo (btn_raw=1) el LED esta apagado
    [L1] caso 2: PASS  pulsado (btn_raw=0) el LED se enciende
    [L1] caso 3: PASS  al soltar vuelve a apagarse, no se engancha
    [L1] caso 4: PASS  BUTTON_ACTIVE_LOW=0 invierte la lectura del boton
    [L1] caso 5: PASS  LED_ACTIVE_LOW=1 invierte la salida hacia el pin
    == fallos: 0 ==
    == el toolchain funciona de punta a punta ==

Si Verilator no dice nada y vvp imprime esas cinco lineas, **Verilator e
Icarus estan bien**. Falta solo la mitad de Windows: Gowin y el driver.

Ver las ondas: `make wave`. En Windows 11 abre solo gracias a WSLg; en
Windows 10 necesitas un servidor X como VcXsrv.

Para borrar lo generado: `make clean`.

## Sintetizar y grabar

Con `gw_sh` de Gowin EDA en el PATH:

    make synth

Sale el bitstream en `impl/pnr/top.fs`, junto con los informes de recursos y
de pines. Para otro dispositivo, sin tocar `build.tcl`:

    GW_DEVICE="GW5A-LV25MG121NES" make synth

Verificado en la placa de referencia: 1 LUT, 0 registros, 2 pines.

    btn_raw -> F5    entrada
    led     -> G11   salida

Si prefieres la interfaz grafica: proyecto nuevo con dispositivo
**GW5A-LV25MG121NC1/I0** (familia GW5A-25A), anade `src/top.v` y `top.cst`,
Synthesize y luego Place & Route.

Para grabar, abre el Programmer y conecta la placa. Si no la ve, el driver USB
no esta: instala WinUSB en el puerto de depuracion con **Zadig**.

### Dos detalles del build.tcl

No hay `.sdc` a proposito: el diseno es combinacional y no tiene reloj que
restringir. El aviso *«no habra analisis de temporizacion ni Fmax»* que sale
al sintetizar es lo esperado, no un fallo.

`build.tcl` libera los pines de doble proposito con `-use_sspi_as_gpio` y
`-use_cpu_as_gpio`. Este ejemplo no los necesita, pero el reloj de la placa
entra por **E2**, que tambien es SSPI_WPN: el dia que anadas `clk`, sin esas
dos opciones el place & route aborta con un `ERROR (PR2017)` que no menciona
la causa.

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
    ├── top.cst        solo btn_raw y led
    ├── build.tcl      flujo de sintesis para gw_sh
    └── Makefile       lint, sim, wave, check, synth, clean
