# 01. Fundamentos de SQL

Este documento reúne ejemplos básicos e intermedios de SQL, orientados a practicar sintaxis, lectura de consultas, filtros, agregaciones, CTEs, funciones condicionales y funciones ventana.

---

## 1. Comentarios en SQL

En SQL existen dos formas comunes de comentar código.

### Comentario de una sola línea

```sql
-- Así se comenta en una sola línea
```

### Comentario de varias líneas

```sql
/* Así se comenta en
varias líneas, 2 o más */
```

Los comentarios sirven para documentar consultas, explicar decisiones y dejar más claro el propósito de cada bloque.

---

## 2. Consulta básica con `SELECT`, `FROM` y `WHERE`

### Objetivo

Seleccionar registros desde una tabla y filtrar filas según una lista de valores específicos.

```sql
SELECT
    * -- Se seleccionan todas las columnas.
FROM tabla_principal -- Tabla desde donde se extraen los datos.
WHERE columna_1 IN ('pan', 'jamón', 'queso'); 
```

### Explicación

La consulta anterior devuelve solo las filas donde `columna_1` tenga alguno de estos valores:

* `pan`
* `jamón`
* `queso`

El operador `IN` es equivalente a escribir varias condiciones con `OR`.

```sql
SELECT
    *
FROM tabla_principal
WHERE columna_1 = 'pan'
   OR columna_1 = 'jamón'
   OR columna_1 = 'queso';
```

---

## 3. Consulta genérica con CTE, agregaciones y ranking

### Objetivo

Construir una consulta intermedia-avanzada usando:

* `WITH`
* `COUNT`
* `COUNT DISTINCT`
* `SUM`
* `CASE WHEN`
* `COALESCE`
* `AVG`
* `GROUP BY`
* `HAVING`
* `RANK() OVER`
* `ORDER BY`
* `LIMIT`

```sql
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

LIMIT 10;
```

> El punto y coma `;` se utiliza para separar o finalizar instrucciones SQL.

---

## 4. Lectura humana de la consulta anterior

La consulta anterior hace lo siguiente:

1. Crea una CTE llamada `tabla_resumida`.
2. Agrupa los datos por `campo_grupo_1` y `campo_grupo_2`.
3. Calcula métricas agregadas como conteos, sumas y promedios.
4. Usa `CASE WHEN` para calcular una suma condicional.
5. Usa `COALESCE` para reemplazar valores `NULL`.
6. Filtra grupos con `HAVING`.
7. Luego, desde la CTE, calcula un ranking dentro de cada grupo usando `RANK() OVER`.
8. Ordena el resultado final.
9. Devuelve solo las primeras 10 filas.

---

## 5. Diferencia entre `WHERE` y `HAVING`

### `WHERE`

Filtra filas antes de agrupar.

```sql
WHERE campo_fecha >= '2024-01-01'
```

### `HAVING`

Filtra grupos después de aplicar `GROUP BY`.

```sql
HAVING SUM(campo_monto) > 1000
```

Regla simple:

```text
WHERE  = filtra antes del resumen.
HAVING = filtra después del resumen.
```

---

## 6. Consulta intermedia-avanzada con `JOIN`

### Objetivo

Unir una tabla principal con una tabla de dimensión, filtrar datos, calcular métricas agregadas y generar ranking por región.

```sql
WITH resumen AS (
    SELECT
        t.region,
        t.categoria,

        COUNT(*) AS total_registros,

        COUNT(DISTINCT t.id_cliente) AS clientes_unicos,

        SUM(t.monto) AS monto_total,

        SUM(
            CASE 
                WHEN t.estado = 'aprobado' THEN t.monto
                ELSE 0
            END
        ) AS monto_aprobado,

        AVG(COALESCE(t.monto, 0)) AS monto_promedio

    FROM tabla_principal t

    LEFT JOIN tabla_dimension d
        ON t.id_producto = d.id_producto

    WHERE t.producto IN ('pan', 'jamón', 'queso')
      AND t.fecha >= '2024-01-01'
      AND t.estado NOT IN ('anulado', 'cancelado')

    GROUP BY
        t.region,
        t.categoria

    HAVING SUM(t.monto) > 100000
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
        PARTITION BY region
        ORDER BY monto_total DESC
    ) AS ranking_categoria_region

FROM resumen

ORDER BY
    region ASC,
    ranking_categoria_region ASC

LIMIT 10;
```

---

## 7. Conceptos usados en la consulta

### `WITH`

Crea una CTE, es decir, una tabla temporal lógica dentro de la consulta.

```sql
WITH resumen AS (
    SELECT ...
)
SELECT ...
FROM resumen;
```

---

### `LEFT JOIN`

Conserva todas las filas de la tabla izquierda y agrega datos de la tabla derecha cuando existe coincidencia.

```sql
LEFT JOIN tabla_dimension d
    ON t.id_producto = d.id_producto
```

Si no existe coincidencia, los campos de la tabla derecha quedan como `NULL`.

---

### `COUNT(*)`

Cuenta todas las filas resultantes.

```sql
COUNT(*) AS total_registros
```

---

### `COUNT(DISTINCT ...)`

Cuenta valores únicos.

```sql
COUNT(DISTINCT t.id_cliente) AS clientes_unicos
```

Es útil cuando una entidad puede aparecer repetida por la cardinalidad del `JOIN`.

---

### `SUM`

Suma valores numéricos.

```sql
SUM(t.monto) AS monto_total
```

---

### `CASE WHEN`

Permite crear lógica condicional.

```sql
SUM(
    CASE 
        WHEN t.estado = 'aprobado' THEN t.monto
        ELSE 0
    END
) AS monto_aprobado
```

En este caso, suma solo los montos cuyo estado sea `aprobado`.

---

### `COALESCE`

Reemplaza valores `NULL` por otro valor.

```sql
AVG(COALESCE(t.monto, 0)) AS monto_promedio
```

En este caso, si `t.monto` es `NULL`, se trata como `0`.

---

### `GROUP BY`

Agrupa registros para calcular métricas agregadas.

```sql
GROUP BY
    t.region,
    t.categoria
```

---

### `HAVING`

Filtra grupos después de agrupar.

```sql
HAVING SUM(t.monto) > 100000
```

---

### `RANK() OVER`

Crea un ranking dentro de una partición.

```sql
RANK() OVER (
    PARTITION BY region
    ORDER BY monto_total DESC
) AS ranking_categoria_region
```

En este caso, genera un ranking de categorías dentro de cada región según `monto_total`.

---

### `ORDER BY`

Ordena el resultado final.

```sql
ORDER BY
    region ASC,
    ranking_categoria_region ASC
```

---

### `LIMIT`

Limita la cantidad de filas devueltas.

```sql
LIMIT 10;
```

> Nota: `LIMIT` se usa en PostgreSQL, MySQL y SQLite. En SQL Server se suele usar `TOP`, por ejemplo:
>
> ```sql
> SELECT TOP 10
>     *
> FROM tabla_principal;
> ```

---

## 8. Orden lógico de ejecución de una consulta SQL

Aunque una consulta se escribe normalmente así:

```sql
SELECT
FROM
WHERE
GROUP BY
HAVING
ORDER BY
LIMIT
```

SQL la procesa aproximadamente en este orden:

```text
1. FROM / JOIN
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT
6. Funciones ventana
7. ORDER BY
8. LIMIT
```

Este orden ayuda a entender por qué `WHERE` no puede filtrar directamente una agregación como `SUM(monto)`, mientras que `HAVING` sí.

---

## 9. Plantilla general recomendada

Esta plantilla puede usarse como base para consultas analíticas.

```sql
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
        ) AS suma_condicional

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

    RANK() OVER (
        PARTITION BY campo_grupo_1
        ORDER BY suma_monto DESC
    ) AS ranking_dentro_del_grupo

FROM tabla_resumida

ORDER BY
    campo_grupo_1,
    ranking_dentro_del_grupo

LIMIT 10;
```

---

## 10. Resumen de conceptos clave

| Concepto              | Uso principal                  |
| --------------------- | ------------------------------ |
| `SELECT`              | Elegir columnas o cálculos     |
| `FROM`                | Indicar la tabla principal     |
| `WHERE`               | Filtrar filas antes de agrupar |
| `JOIN`                | Unir tablas                    |
| `GROUP BY`            | Agrupar registros              |
| `HAVING`              | Filtrar grupos agregados       |
| `COUNT(*)`            | Contar filas                   |
| `COUNT(DISTINCT ...)` | Contar valores únicos          |
| `SUM`                 | Sumar valores                  |
| `AVG`                 | Calcular promedio              |
| `CASE WHEN`           | Crear lógica condicional       |
| `COALESCE`            | Reemplazar valores nulos       |
| `RANK() OVER`         | Crear rankings por grupo       |
| `ORDER BY`            | Ordenar resultados             |
| `LIMIT`               | Limitar filas devueltas        |

---

## 11. Notas finales

Este archivo sirve como base para estudiar consultas SQL de nivel básico a intermedio.
Los siguientes temas recomendados para profundizar son:

* tipos de `JOIN`;
* cardinalidad;
* `GROUP BY` y duplicación de métricas;
* CTEs encadenadas;
* funciones ventana;
* modelo estrella para Power BI;
* consultas de auditoría y validación de datos.
