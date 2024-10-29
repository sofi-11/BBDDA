/*
Luego de decidirse por un motor de base de datos relacional, llegó el momento de generar la
base de datos.
Deberá instalar el DMBS y documentar el proceso. No incluya capturas de pantalla. Detalle
las configuraciones aplicadas (ubicación de archivos, memoria asignada, seguridad, puertos,
etc.) en un documento como el que le entregaría al DBA.
Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deberá entregar
un archivo .sql con el script completo de creación (debe funcionar si se lo ejecuta “tal cual” es
entregado). Incluya comentarios para indicar qué hace cada módulo de código.
Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”.
Genere esquemas para organizar de forma lógica los componentes del sistema y aplique esto
en la creación de objetos. NO use el esquema “dbo”.
El archivo .sql con el script debe incluir comentarios donde consten este enunciado, la fecha
de entrega, número de grupo, nombre de la materia, nombres y DNI de los alumnos.
Entregar todo en un zip cuyo nombre sea Grupo_XX.zip mediante la sección de prácticas de
MIEL. Solo uno de los miembros del grupo debe hacer la entrega.
*/

-- Bases de Datos Aplicadas
-- Fecha de entrega: 14 de Noviembre de 2024
-- Grupo 01
-- 45739056 Sofia Florencia Gay
-- 44482420	Valentino Amato
-- 44396900 Joaquin Barcella
-- 44960383 Rafael David Nazareno Ruiz

---------------ENTREGA 3

-- Verifica si la base de datos 'AuroraSA' ya existe, si no, la crea.
IF NOT EXISTS (
    SELECT name 
    FROM sys.databases 
    WHERE name = N'AuroraSA')
BEGIN
    CREATE DATABASE AuroraSA;
    PRINT 'Base de datos AuroraSA creada.';
END
ELSE
BEGIN
    PRINT 'La base de datos AuroraSA ya existe';
END;

GO
USE AuroraSA;
GO

-- Cambia la intercalación (collation) de la base de datos a 'Latin1_General_CS_AS' (sensible a mayúsculas y acentos)
ALTER DATABASE AuroraSA
COLLATE Latin1_General_CS_AS;

GO

-- Verifica si el esquema 'ddbba' ya existe, si no, lo crea.
IF NOT EXISTS (
    SELECT name 
    FROM sys.schemas 
    WHERE name = N'ddbba')
BEGIN
    EXEC('CREATE SCHEMA ddbba');
    PRINT 'Esquema ddbba creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El esquema ddbba ya existe.';
END;

GO

-- Cambia el contexto de la base de datos al esquema 'ddbba'

GO

-- Verifica si la tabla 'productosImportados' ya existe, si no, la crea.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.productosImportados') AND type in (N'U'))
BEGIN
    CREATE TABLE ddbba.productosImportados (
        IdProducto INT PRIMARY KEY, -- Llave primaria
        NombreProducto NVARCHAR(100), -- Nombre del producto
        Proveedor NVARCHAR(100), -- Proveedor del producto
        Categoria VARCHAR(100), -- Categoría del producto
        CantidadPorUnidad VARCHAR(50), -- Descripción de la cantidad por unidad
        PrecioUnidad DECIMAL(10, 2) CHECK (PrecioUnidad > 0) -- Precio con restricción que debe ser mayor a 0
    );
END;

GO

-- Verifica si la tabla 'electronicAccesories' ya existe, si no, la crea.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.electronicAccesories') AND type in (N'U'))
BEGIN
    CREATE TABLE ddbba.electronicAccesories (
        Product VARCHAR(100), -- Nombre del producto
        PrecioUnitarioUSD DECIMAL(10,2) -- Precio en dólares
    );
END;

GO

-- Verifica si la tabla 'catalogo' ya existe, si no, la crea.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.catalogo') AND type in (N'U'))
BEGIN
    CREATE TABLE ddbba.catalogo (
        id int IDENTITY (1,1) PRIMARY KEY, -- Llave primaria autoincremental
        category VARCHAR(100), -- Categoría del producto
        nombre VARCHAR(100), -- Nombre del producto
        price DECIMAL(10, 2) CHECK (price > 0), -- Precio del producto, debe ser mayor a 0
        reference_price DECIMAL(10, 2), -- Precio de referencia
        reference_unit VARCHAR(2), -- Unidad de referencia
        fecha DATETIME -- Fecha
    );
END;
GO


-- Verifica si la tabla 'ventasRegistradas' ya existe, si no, la crea.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.ventasRegistradas') AND type in (N'U'))
BEGIN
    CREATE TABLE ddbba.ventasRegistradas (
        IDFactura VARCHAR(50) PRIMARY KEY CHECK (IDFactura LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'), -- Llave primaria, identificador de factura
        TipoFactura CHAR(1) CHECK (TipoFactura IN ('A', 'B', 'C')), -- Tipo de factura (Ej: A, B, C)
        Ciudad VARCHAR(50), -- Ciudad de la venta
        TipoCliente VARCHAR(30), -- Tipo de cliente
        Genero VARCHAR(10) CHECK (Genero IN ('Male', 'Female')), -- Género del cliente
        Producto NVARCHAR(100), -- Nombre del producto
        PrecioUnitario DECIMAL(10, 2), -- Precio unitario del producto
        Cantidad INT, -- Cantidad de productos
        Fecha DATE, -- Fecha de la venta
        Hora TIME, -- Hora de la venta
        MedioPago VARCHAR(20) CHECK (MedioPago IN ('Ewallet', 'Cash', 'Credit Card')), -- Medio de pago utilizado
        Empleado INT, -- Identificador del empleado
        IdentificadorPago VARCHAR(25),
			CHECK (
			(MedioPago = 'Ewallet' AND IdentificadorPago LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') OR
			(MedioPago = 'Cash' AND (IdentificadorPago IS NULL OR IdentificadorPago = '')) OR
			(MedioPago = 'Credit Card' AND IdentificadorPago LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
			) -- Identificador de pago
    );
END;

GO

-- Verifica si la tabla 'InformacionAdicional' ya existe, si no, la crea.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.InformacionAdicional') AND type in (N'U'))
BEGIN
    CREATE TABLE ddbba.InformacionAdicional (
        Ciudad VARCHAR(100) PRIMARY KEY, -- Llave primaria
        ReemplazarPor VARCHAR(100), -- Ciudad por la que reemplazar
        Direccion VARCHAR(200), -- Dirección
        Horario VARCHAR(50), -- Horario de atención
        Telefono VARCHAR(20) -- Teléfono de contacto
    );
END;

GO

----Store procedures para manejar la inserción, modificado, borrado

-----------------------------------------------------------------------------INSERTAR

--productosImportados
CREATE PROCEDURE ddbba.InsertarProductosImportados
	@id int,
    @NombreProducto VARCHAR(100),
    @Proveedor NVARCHAR(100),
    @Categoria VARCHAR(100),
	@CantidadPorUnidad VARCHAR(50),
	@PrecioUnidad decimal(10,2)
AS
BEGIN
    INSERT INTO ddbba.productosImportados(IdProducto,NombreProducto,Proveedor,Categoria,CantidadPorUnidad,PrecioUnidad)
    VALUES (@id,@NombreProducto,@Proveedor,@Categoria,@CantidadPorUnidad,@PrecioUnidad);
END;


GO

--electronicAccesories
CREATE PROCEDURE ddbba.InsertarElectronicAccesories
	@Product VARCHAR(100), 
    @PrecioUnitarioUSD DECIMAL(10,2) 
AS
BEGIN
    INSERT INTO ddbba.electronicAccesories(Product,PrecioUnitarioUSD)
    VALUES (@Product,@PrecioUnitarioUSD);
END;


GO

--catalogo
CREATE PROCEDURE ddbba.InsertarCatalogo
	@id INT, -- Identificacion, clave primaria
    @category VARCHAR(100), -- Categoría del producto
    @nombre VARCHAR(100), -- Nombre del producto
    @price DECIMAL(10, 2), -- Precio del producto, debe ser mayor a 0
    @reference_price DECIMAL(10, 2), -- Precio de referencia
    @reference_unit VARCHAR(50), -- Unidad de referencia
    @fecha DATE -- Fecha
AS
BEGIN
    INSERT INTO ddbba.catalogo(id,category,nombre,price,reference_price,reference_unit,fecha)
    VALUES (@id,@category,@nombre,@price,@reference_price,@reference_unit,@fecha);
END;

GO

--ventasRegistradas
CREATE PROCEDURE ddbba.InsertarVentasRegistradas
		@IDFactura VARCHAR(50), 
        @TipoFactura VARCHAR(2), 
        @Ciudad VARCHAR(100), 
        @TipoCliente VARCHAR(50), 
        @Genero VARCHAR(10), 
        @Producto NVARCHAR(100), 
        @PrecioUnitario DECIMAL(10, 2),
        @Cantidad INT,
        @Fecha DATE, 
        @Hora TIME, 
        @MedioPago VARCHAR(50), 
        @Empleado INT, 
        @IdentificadorPago VARCHAR(100) 
AS
BEGIN
    INSERT INTO ddbba.ventasRegistradas(IDFactura,TipoFactura,Ciudad,TipoCliente,Genero,Producto,PrecioUnitario,Cantidad,Fecha,Hora,MedioPago,Empleado,IdentificadorPago)
    VALUES (@IDFactura,@TipoFactura,@Ciudad,@TipoCliente,@Genero,@Producto,@PrecioUnitario,@Cantidad,@Fecha,@Hora,@MedioPago,@Empleado,@IdentificadorPago);
END;

GO

--informacionAdicional
CREATE PROCEDURE ddbba.InsertarInformacionAdicional
		@Ciudad VARCHAR(100),
        @ReemplazarPor VARCHAR(100), 
        @Direccion VARCHAR(200), 
        @Horario VARCHAR(50),
        @Telefono VARCHAR(20) 
AS
BEGIN
    INSERT INTO ddbba.InformacionAdicional(Ciudad,ReemplazarPor,Direccion,Horario,Telefono)
    VALUES (@Ciudad,@ReemplazarPor,@Direccion,@Horario,@Telefono);
END;

-----------------------------------------------------------------------------------------------------MODIFICAR
GO
--productosImportados

CREATE PROCEDURE ddbba.ModificarProductosImportados
    @id int,
    @NombreProducto VARCHAR(100),
    @Proveedor NVARCHAR(100),
    @Categoria VARCHAR(100),
	@CantidadPorUnidad VARCHAR(50),
	@PrecioUnidad decimal(10,2)
AS
BEGIN
    UPDATE ddbba.productosImportados
    SET NombreProducto=@NombreProducto ,
		Proveedor=@Proveedor ,
		Categoria=@Categoria ,
		CantidadPorUnidad=@CantidadPorUnidad,
		PrecioUnidad=@PrecioUnidad 
    WHERE IdProducto = @Id;
    
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Cliente no encontrado', 16, 1);
    END
END;

GO
--electronicAccesories

CREATE PROCEDURE ddbba.ModificarElectronicAccesories
    @Product VARCHAR(100), 
    @PrecioUnitarioUSD DECIMAL(10,2) 
AS
BEGIN
    UPDATE ddbba.electronicAccesories
    SET Product=@Product,
		PrecioUnitarioUSD=@PrecioUnitarioUSD
    WHERE --?
    
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Cliente no encontrado', 16, 1);
    END
END;

GO
--catalogo
CREATE PROCEDURE ddbba.ModificarCatalogo
		@id INT , 
        @category VARCHAR(100), 
        @nombre VARCHAR(100), 
        @price DECIMAL(10, 2), 
        @reference_price DECIMAL(10, 2), 
        @reference_unit VARCHAR(50), 
        @fecha DATE 
AS
BEGIN
    UPDATE ddbba.catalogo
    SET category=@category ,
		nombre=@nombre,
		price=@price,
		reference_price=@reference_price,
		reference_unit=@reference_unit,
		fecha=@fecha
    WHERE id = @id;
    
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Cliente no encontrado', 16, 1);
    END
END;


GO
--ventasRegistradas
CREATE PROCEDURE ddbba.ModificarVentasRegistradas
		@IDFactura VARCHAR(50) , 
        @TipoFactura VARCHAR(2), 
        @Ciudad VARCHAR(100), 
        @TipoCliente VARCHAR(50), 
		@Genero VARCHAR(10), 
        @Producto NVARCHAR(100), 
        @PrecioUnitario DECIMAL(10, 2), 
        @Cantidad INT, 
        @Fecha DATE, 
        @Hora TIME, 
        @MedioPago VARCHAR(50),
        @Empleado INT, 
        @IdentificadorPago VARCHAR(100) 
AS
BEGIN
    UPDATE ddbba.ventasRegistradas
    SET TipoFactura=@TipoFactura ,
		Ciudad=@Ciudad,
		TipoCliente=@TipoCliente,
		Genero=@Genero,
		Producto=@Producto,
		PrecioUnitario=@PrecioUnitario,
		Cantidad=@Cantidad,
		Fecha=@Fecha,
		Hora=@Hora,
		MedioPago=@MedioPago,
		Empleado=@Empleado,
		IdentificadorPago=@IdentificadorPago

    WHERE IDFactura = @IDFactura;
    
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Cliente no encontrado', 16, 1);
    END
END;

GO
--informacionAdicional

CREATE PROCEDURE ddbba.ModificarInformacionAdicional
		@Ciudad VARCHAR(100), 
        @ReemplazarPor VARCHAR(100), 
        @Direccion VARCHAR(200), 
        @Horario VARCHAR(50), 
        @Telefono VARCHAR(20) 
AS
BEGIN
    UPDATE ddbba.InformacionAdicional
    SET Ciudad=@Ciudad ,
		ReemplazarPor=@ReemplazarPor,
		Direccion=@Direccion,
		Horario=@Horario,
		Telefono=@Telefono
    WHERE Ciudad = @Ciudad;
    
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Cliente no encontrado', 16, 1);
    END
END;

GO
--------------------------------------------------------------------Borrado
-- Stored procedure para borrado logico tabla productos importados
CREATE PROCEDURE ddbba.BorradoLogicoProductosImportados
AS
BEGIN
 ALTER TABLE ddbba.productosImportados
 ADD activo BIT DEFAULT 1 
 
END	

GO
-- Stored procedure para borrado logico tabla catalogo
CREATE PROCEDURE ddbba.BorradoLogicoInformacionAdicional
AS
BEGIN
 ALTER TABLE ddbba.productosImportados
 ADD activo BIT DEFAULT 1 
 
END	

GO

-- Stored procedure para borrado logico tabla electronic accesories
CREATE PROCEDURE ddbba.BorradoLogicoElectronicAccesories
AS
BEGIN
 ALTER TABLE ddbba.productosImportados
 ADD activo BIT DEFAULT 1 
 
END	

GO

-- Stored procedure para borrado logico tabla ventas Registradas
CREATE PROCEDURE ddbba.BorradoLogicoVentasRegistradas
AS
BEGIN
 ALTER TABLE ddbba.productosImportados
 ADD activo BIT DEFAULT 1 
 
END	

GO

-- Stored procedure para borrado fisico tabla Ventas Registradas
CREATE PROCEDURE ddbba.BorradoFisicoProductosImportados
AS 
BEGIN
TRUNCATE TABLE ddbba.productosImportados
END


GO
-- Stored procedure para borrado físico de la tabla InformacionAdicional
CREATE PROCEDURE ddbba.BorradoFisicoInformacionAdicional
AS
BEGIN
    TRUNCATE TABLE ddbba.InformacionAdicional;
END


GO
-- Stored procedure para borrado físico de la tabla ElectronicAccesories
CREATE PROCEDURE ddbba.BorradoFisicoElectronicAccesories
AS
BEGIN
    TRUNCATE TABLE ddbba.ElectronicAccesories;
END

GO

-- Stored procedure para borrado físico de la tabla VentasRegistradas
CREATE PROCEDURE ddbba.BorradoFisicoVentasRegistradas
AS
BEGIN
    TRUNCATE TABLE ddbba.VentasRegistradas;
END
GO





-- IMPORTACION


-- Stored procedure para importar datos desde 'Productos_importados.xlsx' a la tabla 'productosImportados'
CREATE PROCEDURE ddbba.ImportarProductosImportados
AS
BEGIN
    -- Habilitar la opción de Ad Hoc Distributed Queries (si no está habilitada)
    EXEC sp_configure 'show advanced options', 1;
    RECONFIGURE;
	go
    EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
    RECONFIGURE;
	go
	EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1;
	EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1;
	go

    -- Importar los datos desde el archivo Excel
    INSERT INTO ddbba.productosImportados (NombreProducto, Proveedor, Categoria, CantidadPorUnidad, PrecioUnidad)
    SELECT NombreProducto, Proveedor, Categoría, CantidadPorUnidad, PrecioUnidad
    FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
        'Excel 12.0;Database=C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\mio\Productos_importados.xlsx;HDR=YES',
        'SELECT * FROM [Listado de Productos$]');

    PRINT 'Datos importados exitosamente desde Productos_importados.xlsx';
END;
GO



-- Stored procedure para importar datos desde 'Electronic accessories.xlsx' a la tabla 'electronicAccesories'
CREATE PROCEDURE ddbba.ImportarElectronicAccessories
AS
BEGIN
    INSERT INTO ddbba.electronicAccesories (Product, PrecioUnitarioUSD)
    SELECT Product, PrecioUnitarioUSD
    FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
        'Excel 12.0;Database=C:\ruta\Electronic accessories.xlsx;HDR=YES',
        'SELECT * FROM [Hoja1$]');

    PRINT 'Datos importados exitosamente desde Electronic accessories.xlsx';
END;
GO


-- Stored procedure para importar datos de 'catalogo.csv'
CREATE PROCEDURE ddbba.ImportCatalogo
AS
BEGIN
    BULK INSERT ddbba.catalogo
    FROM 'C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA\catalogo.csv'
    WITH (
        FIELDTERMINATOR = ',', 
        ROWTERMINATOR = ',',
        FIRSTROW = 2,
		CODEPAGE='1252'
    );
    PRINT 'Datos del catálogo cargados correctamente.';
END;
GO



-- Stored procedure para importar datos de 'Ventas_registradas.csv'
CREATE PROCEDURE ImportVentasRegistradas
AS
BEGIN
    BULK INSERT ddbba.ventasRegistradas
    FROM 'C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA\Ventas_registradas.csv'
    WITH (
        FIELDTERMINATOR = ',', 
        ROWTERMINATOR = '\n',
        FIRSTROW = 2,
		CODEPAGE= 'ACP'
    );
    PRINT 'Datos de ventas registradas cargados correctamente.';
END;
GO

CREATE PROCEDURE ddbba.ImportarInformacionAdicional
AS
BEGIN
    -- Habilita consultas distribuidas ad hoc (si no está habilitada)
    EXEC sp_configure 'show advanced options', 1;
    RECONFIGURE;
    EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
    RECONFIGURE;

    -- Importa datos desde el archivo Excel
    INSERT INTO ddbba.InformacionAdicional (Ciudad, ReemplazarPor, Direccion, Horario, Telefono)
    SELECT *
    FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0;Database=C:\Ruta\al\archivo\Informacion_complementaria.xlsx;HDR=YES',
    'SELECT * FROM [Sheet1$]');
END;
GO



