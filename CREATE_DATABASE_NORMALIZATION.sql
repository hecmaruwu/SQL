-- Así se comenta en una sola línea
/* Así se comenta en
varias líneas 2 o más*/

--Ejemplo de consulta básica
SELECT * -- Se seleccionan todas las columnas.
FROM tabla_principal -- Tabla desde donde se extraen los datos.
WHERE columna_1 IN ('pan', 'jamón', 'queso'); /* Devuelve solo las filas donde columna_1
                                                tenga alguno de estos valores:
                                                'pan', 'jamón' o 'queso'. */
--Ejemplo de consulta avanzada genérica
WITH tabla_resumida AS (
    SELECT
        campo_grupo_1,
        campo_grupo_2,

        COUNT(*) AS cantidad_filas,

        COUNT(DISTINCT id_entidad) AS cantidad_entidades_unicas,

        SUM(campo_monto) AS suma_monto,

        SUM(
            CASE
                WHEN campo_condicion = 'valor_objetivo' THEN campo_monto
                ELSE 0
            END
        ) AS suma_condicional,

        AVG(COALESCE(campo_monto, 0)) AS promedio_monto

    FROM tabla_principal

    WHERE campo_filtro IN ('valor_1', 'valor_2', 'valor_3')
      AND campo_fecha >= '2024-01-01'

    GROUP BY
        campo_grupo_1,
        campo_grupo_2

    HAVING SUM(campo_monto) > 1000
)

SELECT
    campo_grupo_1,
    campo_grupo_2,
    cantidad_filas,
    cantidad_entidades_unicas,
    suma_monto,
    suma_condicional,
    promedio_monto,

    RANK() OVER (
        PARTITION BY campo_grupo_1
        ORDER BY suma_monto DESC
    ) AS ranking_dentro_del_grupo

FROM tabla_resumida

ORDER BY
    campo_grupo_1,
    ranking_dentro_del_grupo

LIMIT 10; -- se usa ; para separar instrucciones


-- Ejemplo de consulta intermedia/avanzada genérica

WITH resumen AS ( -- CTE: crea una tabla temporal lógica llamada "resumen"
    SELECT
        t.region, -- Campo por el cual se agrupará
        t.categoria, -- Otro campo de agrupación

        COUNT(*) AS total_registros, -- Cuenta todas las filas después del filtro y join

        COUNT(DISTINCT t.id_cliente) AS clientes_unicos, -- Cuenta clientes únicos

        SUM(t.monto) AS monto_total, -- Suma el monto total

        SUM(
            CASE 
                WHEN t.estado = 'aprobado' THEN t.monto
                ELSE 0
            END
        ) AS monto_aprobado, -- Suma solo montos cuyo estado sea "aprobado"

        AVG(COALESCE(t.monto, 0)) AS monto_promedio -- Promedio tratando NULL como 0

    FROM tabla_principal t -- Tabla principal, normalmente hechos/transacciones

    LEFT JOIN tabla_dimension d -- Tabla secundaria o dimensión
        ON t.id_producto = d.id_producto -- Condición de unión entre ambas tablas

    WHERE t.producto IN ('pan', 'jamón', 'queso') -- Filtra productos específicos
      AND t.fecha >= '2024-01-01' -- Filtra desde cierta fecha
      AND t.estado NOT IN ('anulado', 'cancelado') -- Excluye ciertos estados

    GROUP BY
        t.region,
        t.categoria -- Agrupa por región y categoría

    HAVING SUM(t.monto) > 100000 -- Filtra grupos después de agrupar
)

SELECT
    region,
    categoria,
    total_registros,
    clientes_unicos,
    monto_total,
    monto_aprobado,
    monto_promedio,

    RANK() OVER (
        PARTITION BY region -- Reinicia el ranking dentro de cada región
        ORDER BY monto_total DESC -- Ordena de mayor a menor monto dentro de cada región
    ) AS ranking_categoria_region

FROM resumen

ORDER BY
    region ASC,
    ranking_categoria_region ASC -- Ordena el resultado final

LIMIT 10; -- Devuelve solo las primeras 10 filas
