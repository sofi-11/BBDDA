

USE COM2900G01

go
----------------------------------------------------------------- IMPORTACION

-- Stored procedure para importar datos desde 'Electronic accessories.xlsx' a la tabla 'electronicAccesories'




CREATE OR ALTER PROCEDURE importar.ElectronicAccessoriesImportar
    @ruta NVARCHAR(255)  -- Parámetro de entrada para la ruta del archivo
AS
BEGIN
    -- Crear tabla temporal
    CREATE TABLE #TempElectronicAccessories (
        Product varchar(100),
        [Precio Unitario en dolares] decimal(10, 2)
    );

    -- Concatenar la ruta y el nombre del archivo en una sola variable
    DECLARE @rutaCompleta NVARCHAR(255);
    SET @rutaCompleta = @ruta + '\Electronic accessories.xlsx';

    -- Declarar la consulta dinámica para cargar los datos del archivo Excel
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'
        INSERT INTO #TempElectronicAccessories (Product, [Precio Unitario en dolares])
        SELECT Product, [Precio Unitario en dolares]
        FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0;Database=' + @rutaCompleta + ';HDR=YES'',
            ''SELECT * FROM [Sheet1$]'')';

    -- Ejecutar la consulta dinámica
    EXEC sp_executesql @sql;

	CREATE TABLE #UniqueElectronicAccessories (
        Product varchar(100),
        [Precio Unitario en dolares] decimal(10, 2)
    );

	 INSERT INTO #UniqueElectronicAccessories (Product, [Precio Unitario en dolares])
    SELECT Product, [Precio Unitario en dolares]
    FROM (
        SELECT Product, [Precio Unitario en dolares],
               ROW_NUMBER() OVER (PARTITION BY Product ORDER BY Product) AS row_num
        FROM #TempElectronicAccessories
    ) AS temp
    WHERE row_num = 1; -- Esto selecciona solo la primera aparición de cada producto


    -- Insertar los datos de la tabla temporal en la tabla de destino
    INSERT INTO ddbba.electronicAccesories (Product, PrecioUnitarioUSD)
    SELECT t.Product, t.[Precio Unitario en dolares]
    FROM #TempElectronicAccessories t
    WHERE NOT EXISTS (
        SELECT 1
        FROM ddbba.electronicAccesories e
        WHERE e.Product = t.Product COLLATE Modern_Spanish_CI_AS
    );

	 INSERT INTO ddbba.productos (nombre, precio, clasificacion)
    SELECT u.Product, u.[Precio Unitario en dolares]*d.valor, 'Electronica'
    FROM #UniqueElectronicAccessories u
	JOIN ddbba.cotizacionDolar d on d.tipo='dolarBlue'
    WHERE NOT EXISTS (
        SELECT 1
        FROM ddbba.productos p
        WHERE p.nombre = u.Product COLLATE Modern_Spanish_CI_AS
    )
	
	;
	

    -- Eliminar la tabla temporal
    DROP TABLE #TempElectronicAccessories;
	DROP TABLE #UniqueElectronicAccessories;

    PRINT 'Datos importados exitosamente desde el archivo especificado';
END;


/*exec importar.ImportarElectronicAccessories
drop procedure importar.ImportarElectronicAccessories*/


-- Stored procedure para importar datos de 'catalogo.csv'


go

CREATE OR ALTER PROCEDURE importar.CatalogoImportar 
    @ruta NVARCHAR(255)  -- Parámetro de entrada para la ruta del archivo
AS
BEGIN
    -- Crear tabla temporal para almacenar datos del archivo CSV
    CREATE TABLE #TempCatalogo (
        id INT,
        category VARCHAR(100),
        nombre VARCHAR(100),
        price DECIMAL(10, 2),
        reference_price DECIMAL(10, 2),
        reference_unit VARCHAR(10),
        fecha DATETIME
    );


    -- Declarar la consulta dinámica para cargar los datos del archivo CSV
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'
        INSERT INTO #TempCatalogo (id, category, nombre, price, reference_price, reference_unit, fecha)
        SELECT id, category, name, price, reference_price, reference_unit, date
        FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
            ''Text;Database=' + @ruta + '\;HDR=YES'',
            ''SELECT * FROM [catalogo.csv]'')';

    -- Ejecutar la consulta dinámica
    EXEC sp_executesql @sql;

    -- Insertar en la tabla de destino solo los registros que no existen
    INSERT INTO ddbba.catalogo (id, category, nombre, price, reference_price, reference_unit, fecha)
    SELECT t.id, t.category, t.nombre, t.price, t.reference_price, t.reference_unit, t.fecha
    FROM #TempCatalogo t
    WHERE NOT EXISTS (
        SELECT 1
        FROM ddbba.catalogo c
        WHERE c.id = t.id
    );

    -- Insertar en la tabla productos solo los registros que no existen
    WITH UniqueProductos AS (
        SELECT DISTINCT nombre, price, category,
               ROW_NUMBER() OVER (PARTITION BY nombre ORDER BY id) AS RowNum
        FROM #TempCatalogo
    )
    INSERT INTO ddbba.productos(nombre, precio, clasificacion)
    SELECT u.nombre, u.price * d.valor , u.category
    FROM UniqueProductos u
	JOIN ddbba.cotizacionDolar d on d.tipo='dolarBlue'
    WHERE RowNum = 1
      AND u.nombre IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM ddbba.productos p
          WHERE p.nombre = u.nombre
      );

    -- Eliminar la tabla temporal
    DROP TABLE #TempCatalogo;

    PRINT 'Datos importados exitosamente desde catalogo.csv';
END;
GO

GO


/*select* from ddbba.catalogo


exec importar.CatalogoImportar
drop procedure importar.CatalogoImportar


-- Stored procedure para importar datos de 'Ventas_registradas.csv'

*/




CREATE OR ALTER PROCEDURE importar.VentasRegistradasImportar
    @ruta NVARCHAR(255)  -- Parámetro para la ruta del archivo sin el nombre del archivo
AS
BEGIN
    -- Crear la tabla temporal
    CREATE TABLE #TempVentas (
        IDFactura VARCHAR(50),TipoFactura CHAR(1),Ciudad VARCHAR(50),TipoCliente VARCHAR(30),Genero VARCHAR(10),
        Producto NVARCHAR(100),PrecioUnitario DECIMAL(10, 2),Cantidad INT,Fecha NVARCHAR(50),Hora TIME, MedioPago VARCHAR(20),
        Empleado INT,IdentificadorPago VARCHAR(25)
    );

    -- Concatenar la ruta y el nombre del archivo CSV
    DECLARE @rutaCompleta NVARCHAR(255);
    SET @rutaCompleta = @ruta + '\Ventas_registradas.csv';

    -- Declarar la consulta dinámica para BULK INSERT
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'
        BULK INSERT #TempVentas
        FROM ''' + @rutaCompleta + '''
        WITH (
            FIELDTERMINATOR = '';'',   -- Especifica el punto y coma como delimitador
            ROWTERMINATOR = ''\n'',    -- Especifica el salto de línea como terminador de fila
            FIRSTROW = 2               -- Omite la primera fila si es encabezado
        )';

    -- Ejecutar la consulta dinámica
    EXEC sp_executesql @sql;

    -- Insertar los datos de la tabla temporal en la tabla final, evitando duplicados en IDFactura
    INSERT INTO ddbba.ventasRegistradas (
        IDFactura,  TipoFactura,  Ciudad,  TipoCliente,  Genero, Producto, PrecioUnitario, Cantidad,  Fecha, 
        Hora,  MedioPago, Empleado, IdentificadorPago
    )
    SELECT 
        IDFactura,  TipoFactura, Ciudad, TipoCliente,  Genero, Producto, 
        PrecioUnitario,  Cantidad, CONVERT(DATE, Fecha, 101), Hora, 
        MedioPago, Empleado,  IdentificadorPago
    FROM #TempVentas AS tv
    WHERE NOT EXISTS (
        SELECT 1 
        FROM ddbba.ventasRegistradas AS vr 
        WHERE vr.IDFactura = tv.IDFactura COLLATE Modern_Spanish_CI_AS
    );

	INSERT INTO ddbba.factura (
	numeroFactura, tipoFactura,ciudad , tipoDeCliente,fecha, hora,
    medioDePago,empleado ,identificadorDePago,montoTotal ,puntoDeVenta ,estado)
	SELECT 
		CAST(REPLACE(idfactura, '-', '') AS INT) AS idfactura_num, 
        TipoFactura, 
        Ciudad, 
        TipoCliente,
        CONVERT(DATE, Fecha, 101), 
        Hora, 
        MedioPago, 
        Empleado, 
        IdentificadorPago,
		Cantidad*PrecioUnitario,
		'1',
		'pagada'
    FROM #TempVentas AS tv
    WHERE NOT EXISTS (
        SELECT 1 
        FROM ddbba.factura AS f
        WHERE f.numeroFactura = CAST(REPLACE(tv.idfactura, '-', '') AS INT) 
    ) AND tv.idfactura IS NOT NULL

	INSERT ddbba.detalleVenta (nroFactura, producto, categoria, cantidad, precio_unitario, monto)
SELECT 
    CAST(REPLACE(tv.idfactura, '-', '') AS INT) AS idfactura_num, 
    tv.Producto, 
    p.clasificacion, 
    tv.Cantidad, 
    tv.PrecioUnitario, 
    tv.Cantidad * tv.PrecioUnitario AS Monto
FROM #TempVentas AS tv
JOIN ddbba.productos AS p
    ON tv.Producto = p.Nombre
WHERE NOT EXISTS (
    SELECT 1 
    FROM ddbba.detalleVenta AS d
    WHERE d.nroFactura = CAST(REPLACE(tv.idfactura, '-', '') AS INT) 
)
AND tv.idfactura IS NOT NULL;

    -- Eliminar la tabla temporal
    DROP TABLE #TempVentas;

    PRINT 'Datos importados exitosamente desde Ventas_registradas.csv';
END;
GO


go
/*IMPORTAR EMPLEADOS --> INFORMACION COMPLEMENTARIA */



CREATE OR ALTER PROCEDURE importar.EmpleadosImportar
    @ruta NVARCHAR(255)  -- Parámetro para la ruta del archivo sin el nombre del archivo
AS
BEGIN
    -- 1. Crear la tabla temporal con la estructura que coincide con la hoja de Excel
    CREATE TABLE #TempEmpleados (
        Legajo VARCHAR(10),            -- Numero unico que representa a cada Empleado
        Nombre NVARCHAR(50),    -- Nombre del Empleado
        Apellido NVARCHAR(50),  -- Apellido del Empleado
        DNI CHAR(9),          -- DNI del Empleado
        Direccion NVARCHAR(150),-- Direccion del Empleado
        EmailPersonal NVARCHAR(100), -- Email Personal del Empleado
        EmailEmpresa NVARCHAR(100),  -- Email Empresarial del Empleado
        CUIL VARCHAR(100),     -- CUIL del Empleado
        Cargo VARCHAR(50),     -- Cargo del Empleado
        Sucursal VARCHAR(50),   -- Sucursal del Empleado
        Turno VARCHAR(50)      -- Turno del Empleado
    );

    -- Concatenar la ruta y el nombre del archivo Excel
    DECLARE @rutaCompleta NVARCHAR(255);
    SET @rutaCompleta = @ruta + '\Informacion_complementaria.xlsx';

    -- 2. Cargar los datos de la hoja de Excel a la tabla temporal usando OPENROWSET
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'
    INSERT INTO #TempEmpleados (Legajo, Nombre, Apellido, DNI, Direccion, EmailPersonal, EmailEmpresa, CUIL, Cargo, Sucursal, Turno)
    SELECT 
        [Legajo/ID],
        Nombre, 
        Apellido, 
        CAST(DNI AS INT), 
        Direccion, 
        [email personal], 
        [email empresa], 
        CUIL, 
        Cargo, 
        Sucursal, 
        Turno
    FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0;Database=' + @rutaCompleta + ';HDR=YES'',
        ''SELECT * FROM [Empleados$]'')';
    
    
    EXEC sp_executesql @sql;

    -- insertar los datos en la tabla final ddbba.Empleados si el Legajo no existe
    INSERT INTO ddbba.Empleados (
        Legajo, 
        Nombre, 
        Apellido, 
        DNI, 
        Direccion, 
        EmailPersonal, 
        EmailEmpresa, 
        CUIL, 
        Cargo, 
        Sucursal, 
        Turno
    )
    SELECT 
        CAST(Legajo AS INT), 
        Nombre, 
        Apellido, 
        DNI, 
        Direccion, 
        EmailPersonal, 
        EmailEmpresa, 
        CUIL, 
        Cargo, 
        Sucursal, 
        Turno
    FROM #TempEmpleados AS te
    WHERE NOT EXISTS (
        SELECT 1 
        FROM ddbba.Empleados AS e 
        WHERE e.Legajo = te.Legajo
    )
    AND te.Legajo IS NOT NULL;

    -- 4. Eliminar la tabla temporal
    DROP TABLE #TempEmpleados;

    PRINT 'Datos importados exitosamente desde Informacion_complementaria.xlsx';
END;
GO


go

--IMPORTAR CLASIFICACION DE PRODUCTOS 


CREATE OR ALTER PROCEDURE importar.ClasificacionProductosImportar
    @ruta NVARCHAR(255)  -- Parámetro para la ruta del archivo sin el nombre del archivo
AS
BEGIN
    -- Paso 1: Crear la tabla temporal
    CREATE TABLE #TempClasificacionProductos (
        LineaDeProducto VARCHAR(30),
        Producto VARCHAR(70)
    );

    -- Concatenar ruta
    DECLARE @rutaCompleta NVARCHAR(255);
    SET @rutaCompleta = @ruta + '\Informacion_complementaria.xlsx';

    -- Paso 2: Importar datos desde el archivo de Excel a la tabla temporal
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'
    INSERT INTO #TempClasificacionProductos (LineaDeProducto, Producto)
    SELECT [Línea de producto], Producto
    FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', 
        ''Excel 12.0;Database=' + @rutaCompleta + ';HDR=YES'',
        ''SELECT * FROM [Clasificacion productos$]'')';

    -- Ejecutar la consulta dinámica para cargar los datos
    EXEC sp_executesql @sql;

    -- Paso 3: Insertar datos en la tabla final, evitando duplicados
    INSERT ddbba.ClasificacionProductos (LineaDeProducto, Producto)
    SELECT tp.LineaDeProducto, tp.Producto
    FROM #TempClasificacionProductos AS tp
    WHERE NOT EXISTS (
        SELECT 1 
        FROM ddbba.ClasificacionProductos AS cp 
        WHERE cp.LineaDeProducto = tp.LineaDeProducto collate Modern_Spanish_CI_AS
        AND cp.Producto = tp.Producto collate Modern_Spanish_CI_AS
    );

	if not exists (select 1 from ddbba.ClasificacionProductos where LineaDeProducto = 'Electronica')
	begin
	INSERT ddbba.ClasificacionProductos(LineaDeProducto,Producto)
	values ('Electronica','Electronica'),('Importado','Importado')
	end

    -- Limpiar tabla temporal
    DROP TABLE #TempClasificacionProductos;
    
    PRINT 'Datos importados exitosamente desde Informacion_complementaria.xlsx';
END;
GO





--IMPORTAR PRODUCTOS IMPORTADOS


CREATE OR ALTER PROCEDURE importar.ProductosImportadosImportar
    @ruta NVARCHAR(255)  -- Parámetro para la ruta del archivo incluyendo el nombre del archivo
AS
BEGIN
    -- Paso 1: Crear la tabla temporal
    CREATE TABLE #TempProductos (
        IdProducto VARCHAR(10),  -- Se utiliza VARCHAR para la importación
        NombreProducto NVARCHAR(100),
        Proveedor NVARCHAR(100),
        Categoria VARCHAR(100),
        CantidadPorUnidad VARCHAR(50),
        PrecioUnidad DECIMAL(10, 2)
    );

    -- Paso 2: Importar datos desde el archivo de Excel a la tabla temporal usando SQL dinámico
    DECLARE @sql NVARCHAR(MAX);

    SET @sql = N'
        INSERT INTO #TempProductos (IdProducto, NombreProducto, Proveedor, Categoria, CantidadPorUnidad, PrecioUnidad)
        SELECT IdProducto, NombreProducto, Proveedor, Categoría, CantidadPorUnidad, PrecioUnidad
        FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', 
            ''Excel 12.0;Database=' + @ruta + '\Productos_importados.xlsx;HDR=YES'',
            ''SELECT * FROM [Listado de Productos$]'');';

    EXEC sp_executesql @sql;

    -- Paso 3: Insertar datos en la tabla final, asegurando que no existan duplicados y que IdProducto no sea NULL
    INSERT INTO ddbba.productosImportados(IdProducto, NombreProducto, Proveedor, Categoria, CantidadPorUnidad, PrecioUnidad)
    SELECT CAST(tp.IdProducto AS INT), tp.NombreProducto, tp.Proveedor, tp.Categoria, tp.CantidadPorUnidad, tp.PrecioUnidad
    FROM #TempProductos AS tp
    WHERE NOT EXISTS (
        SELECT 1 
        FROM ddbba.productosImportados AS p 
        WHERE p.IdProducto = CAST(tp.IdProducto AS INT)
    )
    AND tp.IdProducto IS NOT NULL;  

	INSERT INTO ddbba.productos(nombre,precio,clasificacion)
	select tp.NombreProducto,tp.PrecioUnidad * d.valor , 'Importado'
	from #TempProductos AS tp
	JOIN ddbba.cotizacionDolar d on d.tipo='dolarBlue'
	WHERE NOT EXISTS (
		SELECT 1
		FROM ddbba.productos as p
		WHERE p.nombre = tp.NombreProducto
	)
	AND tp.IdProducto IS NOT NULL;  

    -- Limpiar tabla temporal
    DROP TABLE #TempProductos;
END;


--IMPORTAR SUCURSAL

exec importar.SucursalImportar @ruta= 'C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA';


CREATE OR ALTER PROCEDURE importar.SucursalImportar
    @ruta VARCHAR(255) -- Ruta de la carpeta donde se encuentra el archivo Excel
AS
BEGIN
    -- Declarar las variables necesarias
    DECLARE @RutaCompleta VARCHAR(500);
    DECLARE @sql NVARCHAR(MAX);

    -- Construir la ruta completa del archivo Excel
    SET @RutaCompleta = @ruta + '\Informacion_complementaria.xlsx';
    
    -- Crear la tabla temporal para almacenar los datos importados del archivo Excel
    CREATE TABLE #TempSucursal (
        Ciudad VARCHAR(100),
        Reemplazar_por VARCHAR(100),
        direccion VARCHAR(255),
        Horario VARCHAR(50),
        Telefono VARCHAR(50)
    );

    -- Crear el SQL dinámico para cargar los datos del archivo Excel a la tabla temporal
    SET @sql = N'
        INSERT INTO #TempSucursal (Ciudad, Reemplazar_por, direccion, Horario, Telefono)
        SELECT 
            Ciudad, 
            [Reemplazar por], 
            direccion, 
            Horario, 
            Telefono
        FROM 
            OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', 
                       ''Excel 12.0; Database=' + @RutaCompleta + ';'', 
                       ''SELECT * FROM [sucursal$]'')';

    -- Ejecutar el SQL dinámico
    EXEC sp_executesql @sql;

    -- Verificar si la ciudad ya existe en la tabla sucursal y solo insertar si no existe
    INSERT INTO ddbba.sucursal (ciudad, reemplazarPor, direccion, Horario, Telefono)
    SELECT 
        ts.Ciudad,
        ts.Reemplazar_por,
        ts.direccion,
        ts.Horario,
        ts.Telefono
    FROM #TempSucursal ts
    WHERE NOT EXISTS (
        SELECT 1
        FROM ddbba.sucursal s
        WHERE s.Ciudad = ts.Ciudad
    );

    -- Eliminar la tabla temporal después de usarla
    DROP TABLE #TempSucursal;
END;



