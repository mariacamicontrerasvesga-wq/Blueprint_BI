CREATE TABLE Transaccional_RFM_Cohort AS
SELECT 
    r.idCustomer,
    r.R_score || r.F_score || r.M_score AS "+RFM",
    r.R_label,
    r.F_label,
    r.M_label,
    CASE c.Mes
        WHEN 'Estado_1'  THEN 'Enero'
        WHEN 'Estado_2'  THEN 'Febrero'
        WHEN 'Estado_3'  THEN 'Marzo'
        WHEN 'Estado_4'  THEN 'Abril'
        WHEN 'Estado_5'  THEN 'Mayo'
        WHEN 'Estado_6'  THEN 'Junio'
        WHEN 'Estado_7'  THEN 'Julio'
        WHEN 'Estado_8'  THEN 'Agosto'
        WHEN 'Estado_9'  THEN 'Septiembre'
        WHEN 'Estado_10' THEN 'Octubre'
        WHEN 'Estado_11' THEN 'Noviembre'
        WHEN 'Estado_12' THEN 'Diciembre'
    END AS Mes,
    c.Estado
FROM RFM r
JOIN (
    SELECT 
        idCustomer, 'Estado_1'  AS Mes, Estado_1  AS Estado FROM Cohort_Analysis
    UNION ALL
    SELECT idCustomer, 'Estado_2', Estado_2 FROM Cohort_Analysis
    UNION ALL
    SELECT idCustomer, 'Estado_3', Estado_3 FROM Cohort_Analysis
    UNION ALL
    SELECT idCustomer, 'Estado_4', Estado_4 FROM Cohort_Analysis
    UNION ALL
    SELECT idCustomer, 'Estado_5', Estado_5 FROM Cohort_Analysis
    UNION ALL
    SELECT idCustomer, 'Estado_6', Estado_6 FROM Cohort_Analysis
    UNION ALL
    SELECT idCustomer, 'Estado_7', Estado_7 FROM Cohort_Analysis
    UNION ALL
    SELECT idCustomer, 'Estado_8', Estado_8 FROM Cohort_Analysis
    UNION ALL
    SELECT idCustomer, 'Estado_9', Estado_9 FROM Cohort_Analysis
    UNION ALL
    SELECT idCustomer, 'Estado_10', Estado_10 FROM Cohort_Analysis
    UNION ALL
    SELECT idCustomer, 'Estado_11', Estado_11 FROM Cohort_Analysis
    UNION ALL
    SELECT idCustomer, 'Estado_12', Estado_12 FROM Cohort_Analysis
) c
ON r.idCustomer = c.idCustomer
WHERE EXISTS (
    SELECT 1
    FROM Cohort_Analysis ca
    WHERE ca.idCustomer = r.idCustomer
      AND ca.Estado_1 = 'Activo'
);