--REPORTES
use Com2900G01

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;


--Mensual: ingresando un mes y año determinado mostrar el total facturado por días de
--la semana, incluyendo sábado y domingo.

EXEC FacturacionMensualPorDiaDeSemana @mes = 1, @anio = 2019;

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





--Trimestral: mostrar el total facturado por turnos de trabajo por mes.

EXEC FacturacionTrimestralPorTurnosPorMes @turno = 'Mañana', @trimestre = 1, @anio = 2019;

CREATE OR ALTER PROCEDURE FacturacionTrimestralPorTurnosPorMes
    @turno VARCHAR(50),  -- Turno del empleado para el reporte
    @trimestre INT,      -- Trimestre para el reporte
    @anio INT            -- Año para el reporte
AS
BEGIN
    -- Declaramos una variable para construir la consulta dinámica en formato XML
    DECLARE @sql NVARCHAR(MAX);

    -- Construimos la consulta dinámica en la variable @sql
    SET @sql = '
        SELECT 
            SUM(PrecioUnitario * Cantidad) AS TotalFacturacion,
            CASE 
                WHEN DATEPART(HOUR, hora) BETWEEN 8 AND 13 THEN ''Mañana''
                WHEN DATEPART(HOUR, hora) BETWEEN 14 AND 23 THEN ''Tarde''
            END AS Turno,
            MONTH(Fecha) AS Mes
        FROM ddbba.ventasRegistradas
        WHERE 
            YEAR(Fecha) = @anio 
            AND ( 
                (@trimestre = 1 AND MONTH(Fecha) IN (1, 2, 3)) OR
                (@trimestre = 2 AND MONTH(Fecha) IN (4, 5, 6)) OR
                (@trimestre = 3 AND MONTH(Fecha) IN (7, 8, 9)) OR
                (@trimestre = 4 AND MONTH(Fecha) IN (10, 11, 12))
            )
            AND CASE 
                    WHEN DATEPART(HOUR, hora) BETWEEN 8 AND 13 THEN ''Mañana''
                    WHEN DATEPART(HOUR, hora) BETWEEN 14 AND 23 THEN ''Tarde''
                END = @turno
        GROUP BY 
            CASE 
                WHEN DATEPART(HOUR, hora) BETWEEN 8 AND 13 THEN ''Mañana''
                WHEN DATEPART(HOUR, hora) BETWEEN 14 AND 23 THEN ''Tarde''
            END,
            MONTH(Fecha);
    ';

    -- Ejecutamos la consulta dinámica
    EXEC sp_executesql @sql,
        N'@turno VARCHAR(50), @trimestre INT, @anio INT',
        @turno = @turno, 
        @trimestre = @trimestre, 
        @anio = @anio;
END;
