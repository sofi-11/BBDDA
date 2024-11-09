--REPORTES
use Com2900G01

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;

CREATE OR ALTER PROCEDURE FacturacionMensualPorDiaDeSemana
    @mes INT,  -- Mes para el reporte (1 a 12)
    @anio INT  -- Año para el reporte
AS
BEGIN
    -- Crear una consulta para obtener el total facturado por día de la semana en formato XML
    DECLARE @sql NVARCHAR(MAX);
    
    SET @sql = '
    SELECT 
        DATENAME(WEEKDAY, Fecha) AS DiaSemana, 
        SUM(PrecioUnitario * Cantidad) AS TotalFacturado
    FROM 
        ddbba.ventasRegistradas
    WHERE 
        MONTH(Fecha) = @mes AND YEAR(Fecha) = @anio
    GROUP BY 
        DATENAME(WEEKDAY, Fecha)
    ORDER BY 
        CASE 
            WHEN DATENAME(WEEKDAY, Fecha) = ''Monday'' THEN 1
            WHEN DATENAME(WEEKDAY, Fecha) = ''Tuesday'' THEN 2
            WHEN DATENAME(WEEKDAY, Fecha) = ''Wednesday'' THEN 3
            WHEN DATENAME(WEEKDAY, Fecha) = ''Thursday'' THEN 4
            WHEN DATENAME(WEEKDAY, Fecha) = ''Friday'' THEN 5
            WHEN DATENAME(WEEKDAY, Fecha) = ''Saturday'' THEN 6
            WHEN DATENAME(WEEKDAY, Fecha) = ''Sunday'' THEN 7
        END
    FOR XML PATH(''ReporteFacturacion'')';

    -- Ejecutar la consulta dinámica y devolver el resultado como XML
    EXEC sp_executesql @sql, N'@mes INT, @anio INT', @mes, @anio;
END;

EXEC FacturacionMensualPorDiaDeSemana @mes = 1, @anio = 2019;