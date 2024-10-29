/*
Luego de decidirse por un motor de base de datos relacional, lleg� el momento de generar la
base de datos.
Deber� instalar el DMBS y documentar el proceso. No incluya capturas de pantalla. Detalle
las configuraciones aplicadas (ubicaci�n de archivos, memoria asignada, seguridad, puertos,
etc.) en un documento como el que le entregar�a al DBA.
Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deber� entregar
un archivo .sql con el script completo de creaci�n (debe funcionar si se lo ejecuta �tal cual� es
entregado). Incluya comentarios para indicar qu� hace cada m�dulo de c�digo.
Genere store procedures para manejar la inserci�n, modificado, borrado (si corresponde,
tambi�n debe decidir si determinadas entidades solo admitir�n borrado l�gico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con �SP�.
Genere esquemas para organizar de forma l�gica los componentes del sistema y aplique esto
en la creaci�n de objetos. NO use el esquema �dbo�.
El archivo .sql con el script debe incluir comentarios donde consten este enunciado, la fecha
de entrega, n�mero de grupo, nombre de la materia, nombres y DNI de los alumnos.
Entregar todo en un zip cuyo nombre sea Grupo_XX.zip mediante la secci�n de pr�cticas de
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

-- Cambia la intercalaci�n (collation) de la base de datos a 'Latin1_General_CS_AS' (sensible a may�sculas y acentos)
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
        Categoria VARCHAR(100), -- Categor�a del producto
        CantidadPorUnidad VARCHAR(50), -- Descripci�n de la cantidad por unidad
        PrecioUnidad DECIMAL(10, 2) CHECK (PrecioUnidad > 0), -- Precio con restricci�n que debe ser mayor a 0
		Activo BIT DEFAULT 1 --Campo para borrado logico
    );
END;

GO

-- Verifica si la tabla 'electronicAccesories' ya existe, si no, la crea.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.electronicAccesories') AND type in (N'U'))
BEGIN
    CREATE TABLE ddbba.electronicAccesories (
        Product VARCHAR(100), -- Nombre del producto
        PrecioUnitarioUSD DECIMAL(10,2), -- Precio en d�lares
		Activo BIT DEFAULT 1 --Campo para borrado logico
    );
END;

GO

-- Verifica si la tabla 'catalogo' ya existe, si no, la crea.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.catalogo') AND type in (N'U'))
BEGIN
    CREATE TABLE ddbba.catalogo (
        id int IDENTITY (1,1) PRIMARY KEY, -- Llave primaria autoincremental
        category VARCHAR(100), -- Categor�a del producto
        nombre VARCHAR(100), -- Nombre del producto
        price DECIMAL(10, 2) CHECK (price > 0), -- Precio del producto, debe ser mayor a 0
        reference_price DECIMAL(10, 2), -- Precio de referencia
        reference_unit VARCHAR(2), -- Unidad de referencia
        fecha DATETIME, -- Fecha
		Activo BIT DEFAULT 1 --Campo para borrado logico
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
        Genero VARCHAR(10) CHECK (Genero IN ('Male', 'Female')), -- G�nero del cliente
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
			), -- Identificador de pago
			Activo BIT DEFAULT 1 --Campo para borrado logico
    );
END;

GO

-- Verifica si la tabla 'Sucursal' ya existe, si no, la crea.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.Sucursal') AND type in (N'U'))
BEGIN
    CREATE TABLE ddbba.Sucursal (
        Ciudad VARCHAR(50) PRIMARY KEY, -- Llave primaria
        ReemplazarPor VARCHAR(50), -- Ciudad por la que reemplazar
        Direccion VARCHAR(200), -- Direcci�n
        Horario VARCHAR(50), -- Horario de atenci�n
        Telefono VARCHAR(20), -- Tel�fono de contacto
		Activo BIT DEFAULT 1 --Campo para borrado logico
    );
END;

GO

-- Verifica si la tabla 'Empleados' ya existe, si no, la crea.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.Empleados') AND type in (N'U'))
BEGIN
    CREATE TABLE ddbba.Empleados (
		Legajo INT PRIMARY KEY, --Numero unico que representa a cada Empleado
		Nombre VARCHAR(30), --Nombre del Empleado
		Apellido VARCHAR(20), --Apellido del Empleado
		DNI CHAR(8) CHECK (DNI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'), --DNI del Empleado
		Direccion VARCHAR(150), --Direccion del Empleado
        EmailPersonal VARCHAR(100), --Email Personal del Empleado 
        EmailEmpresa VARCHAR(100), --Email Empresarial del Empleado
		CUIL VARCHAR (100), --CUIL del Empleado
		Cargo VARCHAR(30) CHECK (Cargo IN ('Cajero', 'Supervisor', 'Gerente de sucursal')),--Cargo del Empleado
		Sucursal VARCHAR(30) CHECK (Sucursal IN ('Ramos Mejia', 'Lomas del Mirador', 'San Justo')), --Sucursal a la cual corresponde el Empleado
		Turno VARCHAR(30) CHECK (Turno IN ('TM', 'TT', 'Jornada completa')), --Turno en el que trabaja el Empleado
		Activo BIT DEFAULT 1 --Campo para borrado logico
    );
END;

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


----Store procedures para manejar la inserci�n, modificado, borrado

-----------------------------------------------------------------------------INSERTAR

--productosImportados

IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'ddbba.InsertarProductosImportados') 
           AND type = N'P')
BEGIN
    PRINT 'El SP InsertarProductosImportados ya existe en el esquema ddbba.'
END
ELSE
BEGIN
    EXEC('CREATE PROCEDURE ddbba.InsertarProductosImportados
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
	END;')
END




GO

--electronicAccesories


IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'ddbba.InsertarElectronicAccesories') 
           AND type = N'P')
BEGIN
    PRINT 'El SP InsertarElectronicAccesories ya existe en el esquema ddbba.'
END
ELSE
BEGIN
EXEC('CREATE PROCEDURE ddbba.InsertarElectronicAccesories
	@Product VARCHAR(100), 
    @PrecioUnitarioUSD DECIMAL(10,2) 
AS
BEGIN
    INSERT INTO ddbba.electronicAccesories(Product,PrecioUnitarioUSD)
    VALUES (@Product,@PrecioUnitarioUSD);
END;')
END




GO

--catalogo

IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'ddbba.InsertarCatalogo') 
           AND type = N'P')
BEGIN
    PRINT 'El SP InsertarCatalogo ya existe en el esquema ddbba.'
END
ELSE
BEGIN
   EXEC(' CREATE PROCEDURE ddbba.InsertarCatalogo
	@id INT, -- Identificacion, clave primaria
    @category VARCHAR(100), -- Categor�a del producto
    @nombre VARCHAR(100), -- Nombre del producto
    @price DECIMAL(10, 2), -- Precio del producto, debe ser mayor a 0
    @reference_price DECIMAL(10, 2), -- Precio de referencia
    @reference_unit VARCHAR(50), -- Unidad de referencia
    @fecha DATE -- Fecha
AS
BEGIN
    INSERT INTO ddbba.catalogo(id,category,nombre,price,reference_price,reference_unit,fecha)
    VALUES (@id,@category,@nombre,@price,@reference_price,@reference_unit,@fecha);
END;')
END


GO

--ventasRegistradas

IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'ddbba.InsertarVentasRegistradas') 
           AND type = N'P')
BEGIN
    PRINT 'El SP InsertarVentasRegistradas ya existe en el esquema ddbba.'
END
ELSE
BEGIN
    EXEC('CREATE PROCEDURE ddbba.InsertarVentasRegistradas
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
END;')
END



GO

--Sucursal

IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'ddbba.InsertarSucursal') 
           AND type = N'P')
BEGIN
    PRINT 'El SP InsertarSucursal ya existe en el esquema ddbba.'
END
ELSE
BEGIN
    EXEC('CREATE PROCEDURE ddbba.InsertarSucursal
		@Ciudad VARCHAR(50),
        @ReemplazarPor VARCHAR(50), 
        @Direccion VARCHAR(200), 
        @Horario VARCHAR(50),
        @Telefono VARCHAR(20) 
AS
BEGIN
    INSERT INTO ddbba.Sucursal(Ciudad,ReemplazarPor,Direccion,Horario,Telefono)
    VALUES (@Ciudad,@ReemplazarPor,@Direccion,@Horario,@Telefono);
END')
END

GO

--Empleados


IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'ddbba.InsertarEmpleado') 
           AND type = N'P')
BEGIN
    PRINT 'El SP InsertarEmpleado ya existe en el esquema ddbba.'
END
ELSE
BEGIN
    EXEC('CREATE PROCEDURE ddbba.InsertarEmpleado
        @Legajo INT,
        @Nombre VARCHAR(30),
        @Apellido VARCHAR(20),
        @DNI CHAR(8),
        @Direccion VARCHAR(150),
        @EmailPersonal VARCHAR(100),
        @EmailEmpresa VARCHAR(100),
        @CUIL VARCHAR(100),
        @Cargo VARCHAR(30),
        @Sucursal VARCHAR(30),
        @Turno VARCHAR(30)
    AS
    BEGIN
        INSERT INTO ddbba.Empleados (Legajo, Nombre, Apellido, DNI, Direccion, EmailPersonal, EmailEmpresa, CUIL, Cargo, Sucursal, Turno)
        VALUES (@Legajo, @Nombre, @Apellido, @DNI, @Direccion, @EmailPersonal, @EmailEmpresa, @CUIL, @Cargo, @Sucursal, @Turno);
    END;')
END;

GO


--Clasificacion Productos

IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'ddbba.InsertarClasificacionProducto') 
           AND type = N'P')
BEGIN
    PRINT 'El SP InsertarClasificacionProducto ya existe en el esquema ddbba.'
END
ELSE
BEGIN
    EXEC('CREATE PROCEDURE ddbba.InsertarClasificacionProducto
        @LineaDeProducto VARCHAR(30),
        @Producto VARCHAR(70)
    AS
    BEGIN
        INSERT INTO ddbba.ClasificacionProductos (LineaDeProducto, Producto)
        VALUES (@LineaDeProducto, @Producto);
    END;')
END;





-----------------------------------------------------------------------------------------------------MODIFICAR
GO
--productosImportados

IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'ddbba.ModificarProductosImportados') 
           AND type = N'P')
BEGIN
    PRINT 'El SP ModificarProductosImportados ya existe en el esquema ddbba.'
END
ELSE
BEGIN
    EXEC('CREATE PROCEDURE ddbba.ModificarProductosImportados
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
    
END;')
END



GO
--electronicAccesories

IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'ddbba.ModificarElectronicAccesories') 
           AND type = N'P')
BEGIN
    PRINT 'El SP ModificarElectronicAccesories ya existe en el esquema ddbba.'
END
ELSE
BEGIN
    EXEC('CREATE PROCEDURE ddbba.ModificarElectronicAccesories
    @Product VARCHAR(100), 
    @PrecioUnitarioUSD DECIMAL(10,2) 
AS
BEGIN
    UPDATE ddbba.electronicAccesories
    SET PrecioUnitarioUSD=@PrecioUnitarioUSD
    WHERE Product=@Product
    
END;')
END



GO
--catalogo

IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'ddbba.ModificarCatalogo') 
           AND type = N'P')
BEGIN
    PRINT 'El SP ModificarCatalogo ya existe en el esquema ddbba.'
END
ELSE
BEGIN
    EXEC('CREATE PROCEDURE ddbba.ModificarCatalogo
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
    
    
END;')
END




GO
--ventasRegistradas

IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'ddbba.ModificarVentasRegistradas') 
           AND type = N'P')
BEGIN
    PRINT 'El SP ModificarVentasRegistradas ya existe en el esquema ddbba.'
END
ELSE
BEGIN
    EXEC('CREATE PROCEDURE ddbba.ModificarVentasRegistradas
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
    
END;')
END



GO
--Sucursal

IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'ddbba.ModificarSucursal') 
           AND type = N'P')
BEGIN
    PRINT 'El SP ModificarSucursal ya existe en el esquema ddbba.'
END
ELSE
BEGIN
    EXEC('CREATE PROCEDURE ddbba.ModificarSucursal
		@Ciudad VARCHAR(50), 
        @ReemplazarPor VARCHAR(50), 
        @Direccion VARCHAR(200), 
        @Horario VARCHAR(50), 
        @Telefono VARCHAR(20) 
AS
BEGIN
    UPDATE ddbba.Sucursal
    SET Ciudad=@Ciudad ,
		ReemplazarPor=@ReemplazarPor,
		Direccion=@Direccion,
		Horario=@Horario,
		Telefono=@Telefono
    WHERE Ciudad = @Ciudad;
END;')
END

--Empleado

IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'ddbba.ModificarEmpleadosRegistrados') 
           AND type = N'P')
BEGIN
    PRINT 'El SP ModificarEmpleadosRegistrados ya existe en el esquema ddbba.'
END
ELSE
BEGIN
    EXEC('CREATE PROCEDURE ddbba.ModificarEmpleadosRegistrados
        @IDEmpleado INT,
        @Nombre NVARCHAR(100),
        @Apellido NVARCHAR(100),
        @Edad INT,
        @Genero VARCHAR(10),
        @Cargo NVARCHAR(100),
        @Salario DECIMAL(10, 2),
        @FechaContratacion DATE,
        @Ciudad NVARCHAR(100),
        @Departamento NVARCHAR(50)
AS
BEGIN
    UPDATE ddbba.EmpleadosRegistrados
    SET Nombre = @Nombre,
        Apellido = @Apellido,
        Edad = @Edad,
        Genero = @Genero,
        Cargo = @Cargo,
        Salario = @Salario,
        FechaContratacion = @FechaContratacion,
        Ciudad = @Ciudad,
        Departamento = @Departamento
    WHERE IDEmpleado = @IDEmpleado;
END;')
END

GO

--Clasificacion Producto

IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'ddbba.ModificarClasificacionProducto') 
           AND type = N'P')
BEGIN
    PRINT 'El SP ModificarClasificacionProducto ya existe en el esquema ddbba.'
END
ELSE
BEGIN
    EXEC('CREATE PROCEDURE ddbba.ModificarClasificacionProducto
        @Producto VARCHAR(70),
        @LineaDeProducto VARCHAR(30) = NULL,
        @Activo BIT = NULL
    AS
    BEGIN
        UPDATE ddbba.ClasificacionProductos
        SET LineaDeProducto = ISNULL(@LineaDeProducto, LineaDeProducto),
            Activo = ISNULL(@Activo, Activo)
        WHERE Producto = @Producto;
    END;')
END;

GO



--------------------------------------------------------------------Borrado
-- Stored procedure para borrado logico tabla productos importados

IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'ddbba.BorradoLogicoProductosImportados') 
           AND type = N'P')
BEGIN
    PRINT 'El SP BorradoLogicoProductosImportados ya existe en el esquema ddbba.'
END
ELSE
BEGIN
    EXEC('CREATE PROCEDURE ddbba.BorradoLogicoProductosImportados
	@id int
	AS
	BEGIN
	UPDATE ddbba.productosImportados 
	set Activo=0
	where IdProducto =@id
 
	END	')
END


GO
-- Stored procedure para borrado logico tabla catalogo

IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'ddbba.BorradoLogicoSucursal') 
           AND type = N'P')
BEGIN
    PRINT 'El SP BorradoLogicoSucursal ya existe en el esquema ddbba.'
END
ELSE
BEGIN
    EXEC('CREATE PROCEDURE ddbba.BorradoLogicoSucursal
	@Ciudad varchar(50)

	AS
	BEGIN
	 UPDATE ddbba.Sucursal
	set Activo=0
	where Ciudad =@Ciudad
 
	END	')
END



GO

-- Stored procedure para borrado logico tabla electronic accesories

IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'ddbba.BorradoLogicoElectronicAccesories') 
           AND type = N'P')
BEGIN
    PRINT 'El SP BorradoLogicoElectronicAccesories ya existe en el esquema ddbba.'
END
ELSE
BEGIN
    EXEC('CREATE PROCEDURE ddbba.BorradoLogicoElectronicAccesories
	@product varchar(100)
	AS
	BEGIN
		UPDATE ddbba.electronicAccesories
		set Activo=0
		where Product =@product
	END	')
END



GO

-- Stored procedure para borrado logico tabla ventas Registradas
IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'ddbba.BorradoLogicoVentasRegistradas') 
           AND type = N'P')
BEGIN
    PRINT 'El SP BorradoLogicoVentasRegistradas ya existe en el esquema ddbba.'
END
ELSE
BEGIN
    EXEC('CREATE PROCEDURE ddbba.BorradoLogicoVentasRegistradas
	@IDFactura varchar(50)
AS
BEGIN
		UPDATE ddbba.ventasRegistradas
		set Activo=0
		where IDFactura = @IDFactura
 
END	')
END



GO
-- Stored procedure para borrado logico tabla Empleados
IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'ddbba.BorradoLogicoEmpleados') 
           AND type = N'P')
BEGIN
    PRINT 'El SP BorradoLogicoEmpleados ya existe en el esquema ddbba.'
END
ELSE
BEGIN
    EXEC('CREATE PROCEDURE ddbba.BorradoLogicoEmpleados
	@Legajo INT
AS
BEGIN
		UPDATE ddbba.Empleados
		set Activo=0
		where Legajo = @Legajo
 
END	')

END

GO

--Borrado Logico Clasificacion Producto

IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'ddbba.BorradoLogicoClasificacionProducto') 
           AND type = N'P')
BEGIN
    PRINT 'El SP BorradoLogicoClasificacionProducto ya existe en el esquema ddbba.'
END
ELSE
BEGIN
    EXEC('CREATE PROCEDURE ddbba.BorradoLogicoClasificacionProducto
        @Producto VARCHAR(70)
    AS
    BEGIN
        UPDATE ddbba.ClasificacionProductos
        SET Activo = 0
        WHERE Producto = @Producto;
    END;')
END;


-- IMPORTACION

/*
-- Stored procedure para importar datos desde 'Productos_importados.xlsx' a la tabla 'productosImportados'
CREATE PROCEDURE ddbba.ImportarProductosImportados
AS
BEGIN
    -- Habilitar la opci�n de Ad Hoc Distributed Queries (si no est� habilitada)
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
    SELECT NombreProducto, Proveedor, Categor�a, CantidadPorUnidad, PrecioUnidad
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
    PRINT 'Datos del cat�logo cargados correctamente.';
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
    -- Habilita consultas distribuidas ad hoc (si no est� habilitada)
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




CREATE PROCEDURE ddbba.ImportarProductosImportados
AS
BEGIN
    -- Configuraci�n de propiedades de OLEDB
    EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1;
    EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1;

    -- Importar los datos desde el archivo Excel
    INSERT INTO ddbba.productosImportados (NombreProducto, Proveedor, Categoria, CantidadPorUnidad, PrecioUnidad)
    SELECT NombreProducto, Proveedor, Categor�a, CantidadPorUnidad, PrecioUnidad
    FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
        'Excel 12.0;Database=Productos_importados.xlsx;HDR=YES',
        'SELECT * FROM [Listado de Productos$]');

    PRINT 'Datos importados exitosamente desde Productos_importados.xlsx';
END

*/
