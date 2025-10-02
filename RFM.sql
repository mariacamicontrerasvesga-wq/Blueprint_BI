-- Crear la tabla RFM desde Sales2022
CREATE TABLE RFM AS
WITH base AS (
    SELECT
        idCustomer,
        MAX(sale_date) AS last_purchase,
        COUNT(*) AS Frequency,
        SUM(total_price) AS Monetary
    FROM Sales2022
    GROUP BY idCustomer
),
calc AS (
    SELECT
        idCustomer,
        CAST(julianday('now') - julianday(last_purchase) AS INT) AS Recency, -- diferencia en días
        Frequency,
        Monetary
    FROM base
)
SELECT
    idCustomer,
    Recency,
    Frequency,
    Monetary,

    -- Recency
    CASE
        WHEN Recency <= 6  THEN 4
        WHEN Recency <= 13 THEN 3
        WHEN Recency <= 26 THEN 2
        ELSE 1
    END AS R_score,
    CASE
        WHEN Recency <= 6  THEN 'Más reciente'
        WHEN Recency <= 13 THEN 'Moderadamente reciente'
        WHEN Recency <= 26 THEN 'Poco reciente'
        ELSE 'Menos reciente'
    END AS R_label,

    -- Frequency
    CASE
        WHEN Frequency <= 17 THEN 1
        WHEN Frequency <= 19 THEN 2
        WHEN Frequency <= 22 THEN 3
        ELSE 4
    END AS F_score,
    CASE
        WHEN Frequency <= 17 THEN 'Menos frecuente'
        WHEN Frequency <= 19 THEN 'Baja frecuencia'
        WHEN Frequency <= 22 THEN 'Moderada frecuencia'
        ELSE 'Más frecuente'
    END AS F_label,

    -- Monetary
    CASE
        WHEN Monetary <= 1075 THEN 1
        WHEN Monetary <= 1182 THEN 2
        WHEN Monetary <= 1345 THEN 3
        ELSE 4
    END AS M_score,
    CASE
        WHEN Monetary <= 1075 THEN 'Menor gasto'
        WHEN Monetary <= 1182 THEN 'Bajo gasto'
        WHEN Monetary <= 1345 THEN 'Moderado gasto'
        ELSE 'Mayor gasto'
    END AS M_label

FROM calc;