--REPORTES
use Com2900G01

go

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;

go

--Mensual: ingresando un mes y año determinado mostrar el total facturado por días de
--la semana, incluyendo sábado y domingo.


CREATE OR ALTER PROCEDURE reporte.FacturacionMensualPorDiaDeSemana
    @mes INT,  -- Mes para el reporte (1 a 12)
    @anio INT  -- Año para el reporte
AS
BEGIN
    -- Crear una consulta para obtener el total facturado por día de la semana en formato XML
    DECLARE @sql NVARCHAR(MAX);
    
    SET @sql = '
    SELECT 
        DATENAME(WEEKDAY, Fecha) AS DiaSemana, 
        SUM(montoTotal)
    FROM 
        ddbba.factura
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


GO


--Trimestral: mostrar el total facturado por turnos de trabajo por mes.


CREATE OR ALTER PROCEDURE reporte.FacturacionTrimestralPorTurnosPorMes
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
            SUM(montoTotal) AS TotalFacturacion,
            CASE 
                WHEN DATEPART(HOUR, hora) BETWEEN 8 AND 13 THEN ''Mañana''
                WHEN DATEPART(HOUR, hora) BETWEEN 14 AND 23 THEN ''Tarde''
            END AS Turno,
            MONTH(Fecha) AS Mes
        FROM ddbba.factura
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
            MONTH(Fecha)
		FOR XML PATH(''ReporteFacturacionTrimestral'')
    ';

    -- Ejecutamos la consulta dinámica
    EXEC sp_executesql @sql,
        N'@turno VARCHAR(50), @trimestre INT, @anio INT',
        @turno = @turno, 
        @trimestre = @trimestre, 
        @anio = @anio;
END;



GO

-- Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar
--la cantidad de productos vendidos en ese rango, ordenado de mayor a menor.


CREATE OR ALTER PROCEDURE reporte.VentasPorRangoFechas
    @fecha_inicio DATE,  -- Fecha de inicio del rango
    @fecha_fin DATE      -- Fecha de fin del rango
AS
BEGIN
    -- Declaramos una variable para construir la consulta dinámica en formato XML
    DECLARE @sql NVARCHAR(MAX);

    -- Construimos la consulta dinámica en la variable @sql
    SET @sql = '
        SELECT 
            dv.Producto, 
            SUM(dv.Cantidad) AS CantidadVendida
        FROM 
            ddbba.detalleVenta AS dv
        INNER JOIN 
            ddbba.factura AS f ON dv.nroFactura = f.numeroFactura
        WHERE 
            f.fecha BETWEEN @fecha_inicio AND @fecha_fin
        GROUP BY 
            dv.Producto
        ORDER BY 
            CantidadVendida DESC
        FOR XML PATH(''ReportePorFechas'')
    ';

    -- Ejecutamos la consulta dinámica con los parámetros de fecha
    EXEC sp_executesql @sql,
        N'@fecha_inicio DATE, @fecha_fin DATE',
        @fecha_inicio = @fecha_inicio, 
        @fecha_fin = @fecha_fin;
END;



GO

-- Por rango de fechas: ingresando un rango de fechas a demanda, debe poder 
--mostrar la cantidad de productos vendidos en ese rango por sucursal, ordenado 
--de mayor a menor.


CREATE OR ALTER PROCEDURE reporte.VentasPorSucursalPorRangoFechas
    @fecha_inicio DATE,  -- Fecha de inicio del rango
    @fecha_fin DATE      -- Fecha de fin del rango
AS
BEGIN
    -- Declaramos una variable para construir la consulta dinámica en formato XML
    DECLARE @sql NVARCHAR(MAX);

    -- Construimos la consulta dinámica en la variable @sql
    SET @sql = '
        SELECT 
            dv.Producto, 
            SUM(dv.Cantidad) AS CantidadVendida,
            e.Sucursal
        FROM 
            ddbba.detalleVenta AS dv
        INNER JOIN 
            ddbba.factura AS f ON dv.nroFactura = f.numeroFactura
        INNER JOIN 
            ddbba.Empleados AS e ON e.Legajo = f.empleado
        WHERE 
            f.fecha BETWEEN @fecha_inicio AND @fecha_fin
            AND (
                CASE 
                    WHEN f.ciudad = ''Yangon'' THEN ''San Justo''
                    WHEN f.ciudad = ''Naypyitaw'' THEN ''Ramos Mejia''
                    WHEN f.ciudad = ''Mandalay'' THEN ''Lomas del Mirador''
                    ELSE f.ciudad
                END = e.Sucursal
            )
        GROUP BY 
            dv.Producto, e.Sucursal
        ORDER BY 
            CantidadVendida DESC
        FOR XML PATH(''ReportePorFechasPorSucursal'')
    ';

    -- Ejecutamos la consulta dinámica con los parámetros de fecha
    EXEC sp_executesql @sql,
        N'@fecha_inicio DATE, @fecha_fin DATE',
        @fecha_inicio = @fecha_inicio, 
        @fecha_fin = @fecha_fin;
END;


GO

-- Mostrar los 5 productos más vendidos en un mes, por semana 


CREATE OR ALTER PROCEDURE reporte.ProductosMasVendidosPorSemana
    @mes INT,  -- Mes para el reporte (1 a 12)
    @anio INT   -- Año para el reporte
AS
BEGIN
    -- Declaramos una variable para el SQL dinámico
    DECLARE @sql NVARCHAR(MAX);
    
    -- Construimos la consulta dinámica en la variable @sql
    SET @sql = '
        WITH ProductosConRanking AS (
            SELECT 
                DATEPART(WEEK, f.Fecha) AS Semana,  -- Calcula la semana de la factura
                dv.Producto,
                SUM(dv.Cantidad) AS CantidadVendida,
                ROW_NUMBER() OVER (PARTITION BY DATEPART(WEEK, f.Fecha) ORDER BY SUM(dv.Cantidad) DESC) AS Ranking
            FROM 
                ddbba.factura f
            INNER JOIN ddbba.detalleVenta dv ON f.numeroFactura = dv.nroFactura
            WHERE 
                MONTH(f.Fecha) = @mes AND YEAR(f.Fecha) = @anio  -- Filtra por mes y año
            GROUP BY 
                DATEPART(WEEK, f.Fecha), dv.Producto
        )
        SELECT 
            Semana,
            Producto,
            CantidadVendida
        FROM 
            ProductosConRanking
        WHERE 
            Ranking <= 5  -- Solo los 5 productos más vendidos
        ORDER BY 
            Semana, Ranking
        FOR XML PATH(''Reporte5ProductosPorSemana'');
    ';

    -- Ejecutamos la consulta dinámica con los parámetros del mes y año
    EXEC sp_executesql @sql, N'@mes INT, @anio INT', @mes, @anio;
END;



GO

--Mostrar los 5 productos menos vendidos en el mes.


CREATE OR ALTER PROCEDURE reporte.ProductosMenosVendidosPorMes
    @mes INT,  -- Mes para el reporte (1 a 12)
    @anio INT   -- Año para el reporte
AS
BEGIN
    -- Declaramos una variable para el SQL dinámico
    DECLARE @sql NVARCHAR(MAX);
    
    -- Construimos la consulta dinámica en la variable @sql
    SET @sql = '
        WITH ProductosConRanking AS (
            SELECT 
                dv.Producto,
                SUM(dv.Cantidad) AS CantidadVendida,
                ROW_NUMBER() OVER (ORDER BY SUM(dv.Cantidad) ASC) AS Ranking  -- Ordenamos de menor a mayor por cantidad vendida
            FROM 
                ddbba.factura f
            INNER JOIN ddbba.detalleVenta dv ON f.numeroFactura = dv.nroFactura
            WHERE 
                MONTH(f.Fecha) = @mes AND YEAR(f.Fecha) = @anio  -- Filtra por mes y año
            GROUP BY 
                dv.Producto
        )
        SELECT 
            Producto,
            CantidadVendida
        FROM 
            ProductosConRanking
        WHERE 
            Ranking <= 5  -- Solo los 5 productos menos vendidos
        ORDER BY 
            CantidadVendida ASC  -- Ordenamos de menor a mayor cantidad vendida
        FOR XML PATH(''Reporte5ProductosMenosVendidos'');
    ';

    -- Ejecutamos la consulta dinámica con los parámetros del mes y año
    EXEC sp_executesql @sql, N'@mes INT, @anio INT', @mes, @anio;
END;




GO

-- Mostrar total acumulado de ventas (o sea tambien mostrar el detalle) para una 
--fecha y sucursal particulares


CREATE OR ALTER PROCEDURE reporte.TotalAcumuladoPorFechaYSucursal
    @fecha DATE,  -- Fecha para el reporte
    @sucursal VARCHAR(50)  -- Sucursal para el reporte
AS
BEGIN
    -- Crear una consulta para obtener el total acumulado de ventas por fecha y sucursal en formato XML
    DECLARE @sql NVARCHAR(MAX);
    
    SET @sql = '
    SELECT 
        v.Producto,
        SUM(v.Cantidad) AS CantidadVendida,
        SUM(v.PrecioUnitario * v.Cantidad) AS TotalFacturado,
        e.Sucursal,
        v.Fecha
    FROM 
        ddbba.ventasRegistradas v
    INNER JOIN ddbba.Empleados e
        ON e.Legajo = v.Empleado
    WHERE 
        v.Fecha = @fecha AND e.Sucursal = @sucursal
    GROUP BY 
        v.Producto, e.Sucursal, v.Fecha
    ORDER BY 
        TotalFacturado DESC
    FOR XML PATH(''ReporteTotalAcumuladoVentas'')';

    -- Ejecutar la consulta dinámica y devolver el resultado como XML
    EXEC sp_executesql @sql, N'@fecha DATE, @sucursal VARCHAR(50)', @fecha, @sucursal;
END;

