-- Así se comenta en una sola línea
/* Así se comenta en
varias líneas 2 o más*/

--Ejemplo de consulta básica
SELECT * -- Se seleccionan todas las columnas.
FROM tabla_principal -- Tabla desde donde se extraen los datos.
WHERE columna_1 IN ('pan', 'jamón', 'queso'); /* Devuelve solo las filas donde columna_1
                                                tenga alguno de estos valores:
                                                'pan', 'jamón' o 'queso'. */
