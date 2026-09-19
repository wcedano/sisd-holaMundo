# Registro de uso de IA — 99-0544

Componente: hola mundo (prueba del toolchain)

Declarar el uso de IA **no penaliza**. Lo que penaliza es entregar codigo que
no puedes explicar: la defensa oral multiplica la nota, no la suma.

Para este ejemplo el archivo casi no tiene sentido — son doce lineas y te las
dieron hechas. Esta aqui para que la carpeta tenga ya la forma de una entrega
real y no se te olvide cuando cuente.

---

| # | Fecha | Herramienta y version | Que pedi | Que hice con la respuesta |
|---|---|---|---|---|
| 1 | | | | |

Si no usaste IA, escribelo con fecha: «No se uso ninguna herramienta de IA en
esta entrega». Un archivo vacio no distingue entre «no la use» y «se me olvido
anotarlo».

---

## Lo que deberias saber explicar de este modulo

1. `btn_pressed` no es un puerto, es un `wire` intermedio. ¿Por que dos
   asignaciones en lugar de una sola expresion?
2. Los dos `assign` son combinacionales: no hay reloj en el diseno. ¿Que
   tendria que cambiar para que el LED se quedara encendido tras soltar?
3. El boton entra directo a la logica, sin sincronizador. Aqui es correcto.
   ¿Por que dejaria de serlo en cuanto anadas un `always @(posedge clk)`?
