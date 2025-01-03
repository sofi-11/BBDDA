
-- Bases de Datos Aplicadas
-- Fecha de entrega: 12 de Noviembre de 2024
-- Grupo 01
-- Comision 2900
-- 45739056 Sofia Florencia Gay
-- 44482420	Valentino Amato
-- 44396900 Joaquin Barcella
-- 44960383 Rafael David Nazareno Ruiz

--Creacion de reportes

use Com2900G01

go

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;

go

--Mensual: ingresando un mes y a�o determinado mostrar el total facturado por d�as de
--la semana, incluyendo s�bado y domingo.


CREATE OR ALTER PROCEDURE reporte.FacturacionMensualPorDiaDeSemana
    @mes INT,  -- Mes para el reporte (1 a 12)
    @anio INT  -- A�o para el reporte
AS
BEGIN
    -- Crear una consulta para obtener el total facturado por d�a de la semana en formato XML
    DECLARE @sql NVARCHAR(MAX);
    
    SET @sql = '
    SELECT 
        DATENAME(WEEKDAY, fecha) AS DiaSemana, 
        SUM(monto)
    FROM 
        ddbba.ventaRegistrada
    WHERE 
        MONTH(fecha) = @mes AND YEAR(fecha) = @anio
    GROUP BY 
        DATENAME(WEEKDAY, fecha)
    ORDER BY 
        CASE 
            WHEN DATENAME(WEEKDAY, fecha) = ''Monday'' THEN 1
            WHEN DATENAME(WEEKDAY, fecha) = ''Tuesday'' THEN 2
            WHEN DATENAME(WEEKDAY, fecha) = ''Wednesday'' THEN 3
            WHEN DATENAME(WEEKDAY, fecha) = ''Thursday'' THEN 4
            WHEN DATENAME(WEEKDAY, fecha) = ''Friday'' THEN 5
            WHEN DATENAME(WEEKDAY, fecha) = ''Saturday'' THEN 6
            WHEN DATENAME(WEEKDAY, fecha) = ''Sunday'' THEN 7
        END
    FOR XML PATH(''ReporteFacturacion'')';

    -- Ejecutar la consulta din�mica y devolver el resultado como XML
    EXEC sp_executesql @sql, N'@mes INT, @anio INT', @mes, @anio;
END;


GO


--Trimestral: mostrar el total facturado por turnos de trabajo por mes.


CREATE OR ALTER PROCEDURE reporte.FacturacionTrimestralPorTurnosPorMes
    @turno VARCHAR(50),  -- Turno del empleado para el reporte
    @trimestre INT,      -- Trimestre para el reporte
    @anio INT            -- A�o para el reporte
AS
BEGIN
    -- Declaramos una variable para construir la consulta din�mica en formato XML
    DECLARE @sql NVARCHAR(MAX);

    -- Construimos la consulta din�mica en la variable @sql
    SET @sql = '
        SELECT 
            SUM(monto) AS TotalFacturacion,
            CASE 
                WHEN DATEPART(HOUR, hora) BETWEEN 8 AND 13 THEN ''Ma�ana''
                WHEN DATEPART(HOUR, hora) BETWEEN 14 AND 23 THEN ''Tarde''
            END AS Turno,
            MONTH(fecha) AS Mes
        FROM ddbba.ventaRegistrada
        WHERE 
            YEAR(fecha) = @anio 
            AND ( 
                (@trimestre = 1 AND MONTH(fecha) IN (1, 2, 3)) OR
                (@trimestre = 2 AND MONTH(fecha) IN (4, 5, 6)) OR
                (@trimestre = 3 AND MONTH(fecha) IN (7, 8, 9)) OR
                (@trimestre = 4 AND MONTH(fecha) IN (10, 11, 12))
            )
            AND CASE 
                    WHEN DATEPART(HOUR, hora) BETWEEN 8 AND 13 THEN ''Ma�ana''
                    WHEN DATEPART(HOUR, hora) BETWEEN 14 AND 23 THEN ''Tarde''
                END = @turno
        GROUP BY 
            CASE 
                WHEN DATEPART(HOUR, hora) BETWEEN 8 AND 13 THEN ''Ma�ana''
                WHEN DATEPART(HOUR, hora) BETWEEN 14 AND 23 THEN ''Tarde''
            END,
            MONTH(fecha)
		FOR XML PATH(''ReporteFacturacionTrimestral'')
    ';

    -- Ejecutamos la consulta din�mica
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
    -- Declaramos una variable para construir la consulta din�mica en formato XML
    DECLARE @sql NVARCHAR(MAX);

    -- Construimos la consulta din�mica en la variable @sql
    SET @sql = '
        SELECT 
            p.nombre AS Producto, 
            SUM(dv.cantidad) AS CantidadVendida
        FROM 
            ddbba.detalleVenta dv
        INNER JOIN 
            ddbba.ventaRegistrada vr ON dv.idVenta = vr.idVenta
        INNER JOIN 
            ddbba.productos p ON dv.idProducto = p.idProducto
        WHERE 
            vr.fecha BETWEEN @fecha_inicio AND @fecha_fin
        GROUP BY 
            p.nombre
        ORDER BY 
            CantidadVendida DESC
        FOR XML PATH(''ReportePorFechas'')
    ';

    -- Ejecutamos la consulta din�mica con los par�metros de fecha
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
    -- Declaramos una variable para construir la consulta din�mica en formato XML
    DECLARE @sql NVARCHAR(MAX);

    -- Construimos la consulta din�mica en la variable @sql
    SET @sql = '
        SELECT 
            vr.ciudad AS Sucursal,
            p.nombre AS Producto,
            SUM(dv.cantidad) AS CantidadVendida
        FROM 
            ddbba.detalleVenta dv
        INNER JOIN 
            ddbba.ventaRegistrada vr ON dv.idVenta = vr.idVenta
        INNER JOIN 
            ddbba.productos p ON dv.idProducto = p.idProducto
        WHERE 
            vr.fecha BETWEEN @fecha_inicio AND @fecha_fin
        GROUP BY 
            vr.ciudad, p.nombre
        ORDER BY 
            CantidadVendida DESC
        FOR XML PATH(''ReportePorFechasPorSucursal'')
    ';

    -- Ejecutamos la consulta din�mica con los par�metros de fecha
    EXEC sp_executesql @sql,
        N'@fecha_inicio DATE, @fecha_fin DATE',
        @fecha_inicio = @fecha_inicio, 
        @fecha_fin = @fecha_fin;
END;



GO

-- Mostrar los 5 productos m�s vendidos en un mes, por semana 

CREATE OR ALTER PROCEDURE reporte.ProductosMasVendidosPorSemana
    @mes INT,  -- Mes para el reporte (1 a 12)
    @anio INT   -- A�o para el reporte
AS
BEGIN
    -- Declaramos una variable para el SQL din�mico
    DECLARE @sql NVARCHAR(MAX);

    -- Construimos la consulta din�mica en la variable @sql
    SET @sql = '
        WITH ProductosConRanking AS (
            SELECT 
                DATEPART(WEEK, vr.fecha) AS Semana, -- Calcula la semana de la venta
                p.nombre AS Producto,
                SUM(dv.cantidad) AS CantidadVendida,
                ROW_NUMBER() OVER (PARTITION BY DATEPART(WEEK, vr.fecha), vr.ciudad ORDER BY SUM(dv.cantidad) DESC) AS Ranking
            FROM 
                ddbba.ventaRegistrada vr
            INNER JOIN 
                ddbba.detalleVenta dv ON vr.idVenta = dv.idVenta
            INNER JOIN 
                ddbba.productos p ON dv.idProducto = p.idProducto
            WHERE 
                MONTH(vr.fecha) = @mes AND YEAR(vr.fecha) = @anio -- Filtra por mes y a�o
            GROUP BY 
                DATEPART(WEEK, vr.fecha), p.nombre, vr.ciudad
        )
        SELECT 
            Semana,
            Producto,
            CantidadVendida
        FROM 
            ProductosConRanking
        WHERE 
            Ranking <= 5 -- Solo los 5 productos m�s vendidos
        ORDER BY 
            Semana,  Ranking
        FOR XML PATH(''Reporte5ProductosPorSemana'');
    ';

    -- Ejecutamos la consulta din�mica con los par�metros del mes y a�o
    EXEC sp_executesql @sql, N'@mes INT, @anio INT', @mes, @anio;
END;




GO

--Mostrar los 5 productos menos vendidos en el mes.

CREATE OR ALTER PROCEDURE reporte.ProductosMenosVendidosPorMes
    @mes INT,  -- Mes para el reporte (1 a 12)
    @anio INT   -- A�o para el reporte
AS
BEGIN
    -- Declaramos una variable para el SQL din�mico
    DECLARE @sql NVARCHAR(MAX);

    -- Construimos la consulta din�mica en la variable @sql
    SET @sql = '
        WITH ProductosConRanking AS (
            SELECT 
                p.nombre AS Producto,  -- Nombre del producto
                SUM(dv.cantidad) AS CantidadVendida,
                ROW_NUMBER() OVER (ORDER BY SUM(dv.cantidad) ASC) AS Ranking  -- Ordenamos de menor a mayor por cantidad vendida
            FROM 
                ddbba.ventaRegistrada vr
            INNER JOIN ddbba.detalleVenta dv ON vr.idVenta = dv.idVenta
            INNER JOIN ddbba.productos p ON dv.idProducto = p.idProducto
            WHERE 
                MONTH(vr.fecha) = @mes AND YEAR(vr.fecha) = @anio  -- Filtra por mes y a�o
            GROUP BY 
                p.nombre  -- Agrupamos por nombre de producto
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

    -- Ejecutamos la consulta din�mica con los par�metros del mes y a�o
    EXEC sp_executesql @sql, N'@mes INT, @anio INT', @mes, @anio;
END;





GO

-- Mostrar total acumulado de ventas (o sea tambien mostrar el detalle) para una 
--fecha y sucursal particulares
CREATE OR ALTER PROCEDURE reporte.TotalAcumuladoPorFechaYSucursal
    @fecha DATE,  -- Fecha para el reporte
    @sucursal VARCHAR(50)  -- Sucursal para el reporte (que es la ciudad)
AS
BEGIN
    -- Crear una consulta para obtener el total acumulado de ventas por fecha y sucursal en formato XML
    DECLARE @sql NVARCHAR(MAX);

    SET @sql = '
    SELECT 
        p.nombre AS Producto,  -- Nombre del producto desde la tabla productos
        SUM(dv.cantidad) AS CantidadVendida,
        SUM(dv.precio_unitario * dv.cantidad) AS TotalFacturado,
        f.ciudad AS Sucursal,
        f.fecha
    FROM 
        ddbba.detalleVenta dv
    INNER JOIN ddbba.ventaRegistrada f
        ON f.idVenta = dv.idVenta
    INNER JOIN ddbba.productos p
        ON p.idProducto = dv.idProducto
    WHERE 
        f.fecha = @fecha AND f.ciudad = @sucursal
    GROUP BY 
        p.nombre, f.ciudad, f.fecha
    ORDER BY 
        TotalFacturado DESC
    FOR XML PATH(''ReporteTotalAcumuladoVentas'')
    ';

    -- Ejecutar la consulta din�mica y devolver el resultado como XML
    EXEC sp_executesql @sql, N'@fecha DATE, @sucursal VARCHAR(50)', @fecha, @sucursal;
END;
