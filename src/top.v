`timescale 1ms / 1ps
//
// ============================================================================
//  Hola mundo — Tang Primer 25K (GW5A-25) + placa Dock
//  Matricula 99-0544 · Sistemas Digitales con FPGA · ITLA
// ============================================================================
//
//  Un boton enciende un LED. Nada mas.
//
//  Este ejemplo no resuelve ningun problema: sirve para comprobar que el
//  toolchain esta montado de punta a punta — lint, simulacion, sintesis y
//  grabado en la placa. Si esto enciende el LED, el entorno funciona y el
//  siguiente error que veas sera tuyo, no de la instalacion.
//
//  Es combinacional a proposito: no hay reloj, no hay registros y no hay
//  sincronizador. En un Code Challenge de verdad, un boton que entra a logica
//  secuencial necesita dos flip-flops antes de usarse (RA3.2). Aqui no hay
//  logica secuencial que proteger.
//
//  Pines (top.cst):  btn_raw -> F5   ·   led -> G11
//
//  Los dos parametros son el ajuste de polaridad de la placa. Si al programar
//  el LED esta encendido en reposo y se apaga al pulsar, cambia
//  LED_ACTIVE_LOW; no toques la logica.
//
module top #(
    parameter BUTTON_ACTIVE_LOW = 1'b1, // boton activo en bajo (pull-up externo)
    parameter LED_ACTIVE_LOW    = 1'b0  // LED activo en alto (pull-down interno)
)(
    input  wire btn_raw, // boton de la placa, sin sincronizar
    output wire led   //  // LED de la placa, sin sincronizar
);

    wire btn_pressed; // boton sincronizado y con polaridad ajustada a logica positiva

    assign btn_pressed = BUTTON_ACTIVE_LOW ? ~btn_raw : btn_raw; // boton activo en bajo: invertir la entrada
    assign led         = LED_ACTIVE_LOW    ? ~btn_pressed : btn_pressed; // LED activo en bajo: invertir la salida

endmodule
