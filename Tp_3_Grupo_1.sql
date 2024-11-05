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
--
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

----------------------------------------- ESQUEMAS -----------------------------------------------------
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


-- Verifica si el esquema 'insertar' ya existe, si no, lo crea.
IF NOT EXISTS (
    SELECT name 
    FROM sys.schemas 
    WHERE name = N'insertar')
BEGIN
    EXEC('CREATE SCHEMA insertar');
    PRINT 'Esquema insertar creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El esquema insertar ya existe.';
END;
GO


-- Verifica si el esquema 'modificar' ya existe, si no, lo crea.
IF NOT EXISTS (
    SELECT name 
    FROM sys.schemas 
    WHERE name = N'modificar')
BEGIN
    EXEC('CREATE SCHEMA modificar');
    PRINT 'Esquema modificar creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El esquema modificar ya existe.';
END;
GO


-- Verifica si el esquema 'borrar' ya existe, si no, lo crea.
IF NOT EXISTS (
    SELECT name 
    FROM sys.schemas 
    WHERE name = N'borrar')
BEGIN
    EXEC('CREATE SCHEMA borrar');
    PRINT 'Esquema borrar creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El esquema borrar ya existe.';
END;
GO


-- Verifica si el esquema 'importar' ya existe, si no, lo crea.
IF NOT EXISTS (
    SELECT name 
    FROM sys.schemas 
    WHERE name = N'importar')
BEGIN
    EXEC('CREATE SCHEMA importar');
    PRINT 'Esquema importar creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El esquema importar ya existe.';
END;
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
        PrecioUnidad DECIMAL(10, 2) CHECK (PrecioUnidad > 0), -- Precio con restricción que debe ser mayor a 0
		Activo BIT DEFAULT 1 --Campo para borrado logico
    );
END;

GO

-- Verifica si la tabla 'electronicAccesories' ya existe, si no, la crea.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.electronicAccesories') AND type in (N'U'))
BEGIN
    CREATE TABLE ddbba.electronicAccesories (
        Product VARCHAR(100), -- Nombre del producto
        PrecioUnitarioUSD DECIMAL(10,2), -- Precio en dólares
		Activo BIT DEFAULT 1 --Campo para borrado logico
    );
END;

GO

-- Verifica si la tabla 'catalogo' ya existe, si no, la crea.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.catalogo') AND type in (N'U'))
BEGIN
    CREATE TABLE ddbba.catalogo (
        id int PRIMARY KEY, -- Clave primaria 
        category VARCHAR(100), -- Categoría del producto
        nombre VARCHAR(100), -- Nombre del producto
        price DECIMAL(10, 2) CHECK (price > 0), -- Precio del producto, debe ser mayor a 0
        reference_price DECIMAL(10, 2), -- Precio de referencia
        reference_unit VARCHAR(10), -- Unidad de referencia
        fecha DATETIME, -- Fecha
		Activo BIT DEFAULT 1 --Campo para borrado logico
    );
END;
GO



-- Verifica si la tabla 'ventasRegistradas' ya existe, si no, la crea.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.ventasRegistradas') AND type in (N'U'))
BEGIN
    CREATE TABLE ddbba.ventasRegistradas (
        IDFactura VARCHAR(50) PRIMARY KEY, -- Llave primaria, identificador de factura
        TipoFactura CHAR(1) CHECK (TipoFactura IN ('A', 'B', 'C')), -- Tipo de factura (Ej: A, B, C)
        Ciudad VARCHAR(50), -- Ciudad de la venta
        TipoCliente VARCHAR(30), -- Tipo de cliente
        Genero VARCHAR(10) CHECK (Genero IN ('Male', 'Female')), -- Género del cliente
        Producto NVARCHAR(100), -- Nombre del producto
        PrecioUnitario DECIMAL(10, 2), -- Precio unitario del producto
        Cantidad INT, -- Cantidad de productos
        Fecha DATE, -- Fecha de la venta
        Hora TIME, -- Hora de la venta
        MedioPago VARCHAR(20) CHECK (MedioPago IN ('Ewallet', 'Cash', 'Credit card')), -- Medio de pago utilizado
        Empleado INT, -- Identificador del empleado
        IdentificadorPago VARCHAR(25),
			/*CHECK (
			(MedioPago = 'Ewallet' AND IdentificadorPago LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') OR
			(MedioPago = 'Cash' AND (IdentificadorPago IS NULL OR IdentificadorPago = '--')) OR
			(MedioPago = 'Credit Card' AND IdentificadorPago LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
			), -- Identificador de pago*/
			Activo BIT DEFAULT 1 --Campo para borrado logico
    );
END;
GO
/*
-- Verifica si la tabla 'InformacionAdicional' ya existe, si no, la crea.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.InformacionAdicional') AND type in (N'U'))
BEGIN
    CREATE TABLE ddbba.InformacionAdicional (
        Ciudad VARCHAR(100) PRIMARY KEY, -- Llave primaria
        ReemplazarPor VARCHAR(100), -- Ciudad por la que reemplazar
        Direccion VARCHAR(200), -- Dirección
        Horario VARCHAR(50), -- Horario de atención
        Telefono VARCHAR(20), -- Teléfono de contacto
		Activo BIT DEFAULT 1 --Campo para borrado logico
    );
END;

GO*/

-- Verifica si la tabla 'Empleados' ya existe, si no, la crea.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.Empleados') AND type in (N'U'))
BEGIN
    CREATE TABLE ddbba.Empleados (
		Legajo INT PRIMARY KEY, --Numero unico que representa a cada Empleado
		Nombre nVARCHAR(50), --Nombre del Empleado
		Apellido nVARCHAR(50), --Apellido del Empleado
		DNI CHAR(9),-- CHECK (DNI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'), --DNI del Empleado
		Direccion nVARCHAR(150), --Direccion del Empleado
        EmailPersonal nVARCHAR(100), --Email Personal del Empleado 
        EmailEmpresa nVARCHAR(100), --Email Empresarial del Empleado
		CUIL VARCHAR (100), --CUIL del Empleado
		Cargo VARCHAR(50),-- CHECK (Cargo IN ('Cajero', 'Supervisor', 'Gerente de sucursal')),--Cargo del Empleado
		Sucursal VARCHAR(50),-- CHECK (Sucursal IN ('Ramos Mejia', 'Lomas del Mirador', 'San Justo')), --Sucursal a la cual corresponde el Empleado
		Turno VARCHAR(50),-- CHECK (Turno IN ('TM', 'TT', 'Jornada completa')), --Turno en el que trabaja el Empleado
		Activo BIT DEFAULT 1 --Campo para borrado logico
    );
END;
--drop table ddbba.Empleados
GO
-- Verifica si la tabla 'ClasificacionProductos' ya existe, si no, la crea.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.ClasificacionProductos') AND type in (N'U'))
BEGIN
    CREATE TABLE ddbba.ClasificacionProductos (
        LineaDeProducto VARCHAR(30) CHECK (LineaDeProducto IN ('Almacen', 'Perfumeria', 'Hogar', 'Frescos', 'Bazar', 'Limpieza', 'Otros', 'Congelados', 'Bebidas', 'Mascota', 'Comida')), -- Categoria a la cual pertenece
		Producto VARCHAR(70), --Descripcion del producto (Ej. Arroz)
		Activo BIT DEFAULT 1 --Campo para borrado logico
    );
END;

GO


----Store procedures para manejar la inserción, modificado, borrado

-----------------------------------------------------------------------------INSERTAR

--productosImportados

CREATE OR ALTER PROCEDURE insertar.ProductosImportadosInsertar
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


CREATE OR ALTER PROCEDURE insertar.ElectronicAccesoriesInsertar
	@Product VARCHAR(100), 
    @PrecioUnitarioUSD DECIMAL(10,2) 
AS
BEGIN
    INSERT INTO ddbba.electronicAccesories(Product,PrecioUnitarioUSD)
    VALUES (@Product,@PrecioUnitarioUSD);
END;




GO

--catalogo

CREATE OR ALTER PROCEDURE insertar.CatalogoInsertar
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
END


GO

--ventasRegistradas

CREATE OR ALTER PROCEDURE insertar.VentasRegistradasInsertar
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
END



GO

--informacionAdicional

CREATE OR ALTER PROCEDURE insertar.InformacionAdicionalInsertar
		@Ciudad VARCHAR(100),
        @ReemplazarPor VARCHAR(100), 
        @Direccion VARCHAR(200), 
        @Horario VARCHAR(50),
        @Telefono VARCHAR(20) 
AS
BEGIN
    INSERT INTO ddbba.InformacionAdicional(Ciudad,ReemplazarPor,Direccion,Horario,Telefono)
    VALUES (@Ciudad,@ReemplazarPor,@Direccion,@Horario,@Telefono);
END



-----------------------------------------------------------------------------------------------------MODIFICAR
GO
--productosImportados
 
CREATE OR ALTER PROCEDURE modificar.ProductosImportadosModificar
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
    
END



GO

--electronicAccesories

CREATE OR ALTER PROCEDURE modificar.ElectronicAccesoriesModificar
    @Product VARCHAR(100), 
    @PrecioUnitarioUSD DECIMAL(10,2) 
AS
BEGIN
    UPDATE ddbba.electronicAccesories
    SET PrecioUnitarioUSD=@PrecioUnitarioUSD
    WHERE Product=@Product
    
END



GO
--catalogo

CREATE OR ALTER PROCEDURE modificar.CatalogoModificar
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
    
    
END




GO
--ventasRegistradas

CREATE OR ALTER PROCEDURE modificar.VentasRegistradasModificar
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
    
END



GO
--informacionAdicional

CREATE OR ALTER PROCEDURE modificar.InformacionAdicionalModificar
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
END



GO
--------------------------------------------------------------------Borrado
-- Stored procedure para borrado logico tabla productos importados

CREATE OR ALTER PROCEDURE borrar.ProductosImportadosBorradoLogico
	@id int
	AS
	BEGIN
	UPDATE ddbba.productosImportados 
	set Activo=0
	where IdProducto =@id
 
	END


GO
-- Stored procedure para borrado logico tabla catalogo

/*CREATE OR ALTER PROCEDURE borrar.BorradoLogicoInformacionAdicional
 @id int
	AS
	BEGIN
	 UPDATE ddbba.InformacionAdicional
	set Activo=0
	where IdProducto =@id
 
	END	

	*/

GO

-- Stored procedure para borrado logico tabla electronic accesories

CREATE OR ALTER PROCEDURE borrar.BorradoLogicoElectronicAccesories
@product varchar(50)
	AS
	BEGIN
		UPDATE ddbba.electronicAccesories
		set Activo=0
		where Product =@product
	END



GO

-- Stored procedure para borrado logico tabla ventas Registradas
CREATE OR ALTER PROCEDURE borrar.BorradoLogicoVentasRegistradas
@IDFactura varchar(50)
AS
BEGIN
		UPDATE ddbba.ventasRegistradas
		set Activo=0
		where IDFactura =@IDFactura
 
END



GO

-- Stored procedure para borrado FISICO productos 

CREATE OR ALTER PROCEDURE borrar.BorradoFisicoProductosImportados
	@id int
AS 
BEGIN
		Delete from ddbba.ventasRegistradas
		where IDFactura=@id
END




GO


GO
-- Stored procedure para borrado físico de la tabla ElectronicAccesories

CREATE OR ALTER PROCEDURE borrar.BorradoFisicoElectronicAccesories
	@product varchar(100)
AS
BEGIN
    Delete from ddbba.electronicAccesories
		where Product=@product
END



GO

-- Stored procedure para borrado físico de la tabla VentasRegistradas

CREATE OR ALTER PROCEDURE borrar.BorradoFisicoVentasRegistradas
	@id int
AS
BEGIN
    Delete from ddbba.ventasRegistradas
		where IDFactura=@id
END


GO





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

CREATE PROCEDURE importar.ImportarClasificacionProductos
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
        WHERE cp.LineaDeProducto = tp.LineaDeProducto
        AND cp.Producto = tp.Producto
    );

    -- Limpiar tabla temporal
    DROP TABLE #TempClasificacionProductos;
END;







/*exec importar.ProductosImportadosImportar
drop procedure importar.ProductosImportadosImportar*/

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


/*select * from ddbba.productosImportados*/

--fin
--a