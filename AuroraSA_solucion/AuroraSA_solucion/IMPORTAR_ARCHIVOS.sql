

USE COM2900G01

----------------------------------------------------------------- IMPORTACION

-- Stored procedure para importar datos desde 'Electronic accessories.xlsx' a la tabla 'electronicAccesories'


CREATE OR ALTER PROCEDURE importar.ImportarElectronicAccessories 
AS
BEGIN
    -- Crear tabla temporal
    CREATE TABLE #TempElectronicAccessories (
        Product varchar(100),
        [Precio Unitario en dolares] decimal(10, 2)
    );

    -- Cargar los datos del archivo Excel en la tabla temporal
    INSERT INTO #TempElectronicAccessories (Product, [Precio Unitario en dolares])
    SELECT Product, [Precio Unitario en dolares]
    FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
        'Excel 12.0;Database=C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA\Electronic accessories.xlsx;HDR=YES',
        'SELECT * FROM [Sheet1$]');

    -- Insertar los datos de la tabla temporal en la tabla de destino
    INSERT INTO ddbba.electronicAccesories (Product, PrecioUnitarioUSD)
    SELECT t.Product, t.[Precio Unitario en dolares]
    FROM #TempElectronicAccessories t
    WHERE NOT EXISTS (
        SELECT 1
        FROM ddbba.electronicAccesories e
        WHERE e.Product = t.Product collate Modern_Spanish_CI_AS
    );

    -- Eliminar la tabla temporal
    DROP TABLE #TempElectronicAccessories;

    PRINT 'Datos importados exitosamente desde Electronic accessories.xlsx';
END;
GO

/*exec importar.ImportarElectronicAccessories
drop procedure importar.ImportarElectronicAccessories*/


-- Stored procedure para importar datos de 'catalogo.csv'


CREATE OR Alter PROCEDURE importar.CatalogoImportar
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

    -- Cargar los datos del archivo CSV en la tabla temporal
    INSERT INTO #TempCatalogo (id, category, nombre, price, reference_price, reference_unit, fecha)
    SELECT id, category, name, price, reference_price, reference_unit, date
    FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
    'Text;Database=C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA\;HDR=YES',
    'SELECT * FROM [catalogo.csv]');

    -- Insertar en la tabla de destino solo los registros que no existen
    INSERT INTO ddbba.catalogo (id, category, nombre, price, reference_price, reference_unit, fecha)
    SELECT t.id, t.category, t.nombre, t.price, t.reference_price, t.reference_unit, t.fecha
    FROM #TempCatalogo t
    WHERE NOT EXISTS (
        SELECT 1
        FROM ddbba.catalogo c
        WHERE c.id = t.id
    );

    -- Eliminar la tabla temporal
    DROP TABLE #TempCatalogo;

    PRINT 'Datos importados exitosamente desde catalogo.csv';
END;
GO

/*select* from ddbba.catalogo


exec importar.CatalogoImportar
drop procedure importar.CatalogoImportar


-- Stored procedure para importar datos de 'Ventas_registradas.csv'

exec importar.VentasRegistradasImportar*/


CREATE OR ALTER PROCEDURE importar.VentasRegistradasImportar
AS
BEGIN
    -- 1. Crear la tabla temporal
    CREATE TABLE #TempVentas (
        IDFactura VARCHAR(50),
        TipoFactura CHAR(1),
        Ciudad VARCHAR(50),
        TipoCliente VARCHAR(30),
        Genero VARCHAR(10),
        Producto NVARCHAR(100),
        PrecioUnitario DECIMAL(10, 2),
        Cantidad INT,
        Fecha NVARCHAR(50),
        Hora TIME,
        MedioPago VARCHAR(20),
        Empleado INT,
        IdentificadorPago VARCHAR(25)
    );

    -- 2. Cargar los datos del CSV a la tabla temporal
    BULK INSERT #TempVentas
    FROM 'C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA\Ventas_registradas.csv'
    WITH (
        FIELDTERMINATOR = ';',   -- Especifica el punto y coma como delimitador
        ROWTERMINATOR = '\n',    -- Especifica el salto de línea como terminador de fila
        FIRSTROW = 2             -- Omite la primera fila si es encabezado
    );

    -- 3. Insertar los datos de la tabla temporal a la tabla final
    INSERT INTO ddbba.ventasRegistradas (
        IDFactura, 
        TipoFactura, 
        Ciudad, 
        TipoCliente, 
        Genero, 
        Producto, 
        PrecioUnitario, 
        Cantidad, 
        Fecha, 
        Hora, 
        MedioPago, 
        Empleado, 
        IdentificadorPago
    )
    SELECT 
        IDFactura, 
        TipoFactura, 
        Ciudad, 
        TipoCliente, 
        Genero, 
        Producto, 
        PrecioUnitario, 
        Cantidad, 
        CONVERT(DATE, Fecha, 101), 
        Hora, 
        MedioPago, 
        Empleado, 
        IdentificadorPago
    FROM #TempVentas AS tv
    WHERE NOT EXISTS (
        SELECT 1 
        FROM ddbba.ventasRegistradas AS vr 
        WHERE vr.IDFactura = tv.IDFactura collate Modern_Spanish_CI_AS
    );

    -- 4. Eliminar la tabla temporal
    DROP TABLE #TempVentas;
END;

go
/*IMPORTAR EMPLEADOS --> INFORMACION COMPLEMENTARIA */

/*exec importar.ImportarEmpleadosDesdeExcel

drop procedure importar.ImportarEmpleadosDesdeExcel*/

CREATE OR ALTER PROCEDURE importar.EmpleadosImportar
AS
BEGIN
    -- 1. Crear la tabla temporal con la estructura que coincide con la hoja de Excel
    CREATE TABLE #TempEmpleados (
        Legajo varchar(10),            -- Numero unico que representa a cada Empleado
        Nombre nVARCHAR(50),    -- Nombre del Empleado
        Apellido nVARCHAR(50),  -- Apellido del Empleado
        DNI CHAR(9),          -- DNI del Empleado
        Direccion nVARCHAR(150),-- Direccion del Empleado
        EmailPersonal nVARCHAR(100), -- Email Personal del Empleado
        EmailEmpresa nVARCHAR(100),  -- Email Empresarial del Empleado
        CUIL VARCHAR(100),     -- CUIL del Empleado
        Cargo VARCHAR(50),     -- Cargo del Empleado
        Sucursal VARCHAR(50),   -- Sucursal del Empleado
        Turno VARCHAR(50)      -- Turno del Empleado
    );

    -- 2. Cargar los datos de la hoja de Excel a la tabla temporal usando OPENROWSET
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
		FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
        'Excel 12.0;Database=C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA\Informacion_complementaria.xlsx;HDR=YES',
        'SELECT * FROM [Empleados$]');

    -- 3. Insertar los datos en la tabla final ddbba.Empleados si el Legajo no existe
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
        cast(Legajo as int), 
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
END;

go

--IMPORTAR CLASIFICACION DE PRODUCTOS 

CREATE OR ALTER PROCEDURE importar.ImportarClasificacionProductos
AS
BEGIN
    -- Paso 1: Crear la tabla temporal
    CREATE TABLE #TempClasificacionProductos (
        LineaDeProducto VARCHAR(30),
        Producto VARCHAR(70)
    );

    -- Paso 2: Importar datos desde el archivo de Excel a la tabla temporal
    INSERT INTO #TempClasificacionProductos (LineaDeProducto, Producto)
    SELECT [Línea de producto], Producto
    FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 
        'Excel 12.0;Database=C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA\Informacion_complementaria.xlsx;HDR=YES',
        'SELECT * FROM [Clasificacion productos$]'); 

    -- Paso 3: Insertar datos en la tabla final, evitando duplicados
    INSERT INTO ddbba.ClasificacionProductos (LineaDeProducto, Producto)
    SELECT tp.LineaDeProducto, tp.Producto
    FROM #TempClasificacionProductos AS tp
    WHERE NOT EXISTS (
        SELECT 1 
        FROM ddbba.ClasificacionProductos AS cp 
        WHERE cp.LineaDeProducto = tp.LineaDeProducto collate Modern_Spanish_CI_AS
        AND cp.Producto = tp.Producto collate Modern_Spanish_CI_AS
    );

    -- Limpiar tabla temporal
    DROP TABLE #TempClasificacionProductos;
END;

GO






CREATE OR ALTER PROCEDURE importar.ProductosImportadosImportar
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

    -- Paso 2: Importar datos desde el archivo de Excel a la tabla temporal
    INSERT INTO #TempProductos (IdProducto, NombreProducto, Proveedor, Categoria, CantidadPorUnidad, PrecioUnidad)
    SELECT IdProducto, NombreProducto, Proveedor, Categoría, CantidadPorUnidad, PrecioUnidad
    FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 
        'Excel 12.0;Database=C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA\Productos_importados.xlsx;HDR=YES',
        'SELECT * FROM [Listado de Productos$]'); 

    -- Paso 3: Insertar datos en la tabla final, asegurando que no existan duplicados y que IdProducto no sea NULL
    INSERT INTO ddbba.productosImportados(IdProducto, NombreProducto, Proveedor, Categoria, CantidadPorUnidad, PrecioUnidad)
    SELECT CAST(tp.IdProducto AS INT), tp.NombreProducto, tp.Proveedor, tp.Categoria, tp.CantidadPorUnidad, tp.PrecioUnidad
    FROM #TempProductos AS tp
    WHERE NOT EXISTS (
        SELECT 1 
        FROM ddbba.productosImportados AS p 
        WHERE p.IdProducto = CAST(tp.IdProducto AS INT)
    )
	DROP TABLE #TempProductos;
END;



go
exec importar.EmpleadosImportar
go
exec importar.ImportarClasificacionProductos
go
exec importar.ImportarElectronicAccessories
go
exec importar.EmpleadosImportar
go
exec importar.ProductosImportadosImportar
go
exec importar.VentasRegistradasImportar
go
exec importar.CatalogoImportar