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



-- Verifica si la base de datos 'Com2900G01' ya existe, si no, la crea.
IF NOT EXISTS (
    SELECT name 
    FROM sys.databases 
    WHERE name = N'Com2900G01')
BEGIN
    CREATE DATABASE Com2900G01;
    PRINT 'Base de datos Com2900G01 creada.';
END
ELSE
BEGIN
    PRINT 'La base de datos Com2900G01 ya existe';
END;

GO
USE Com2900G01;
GO

-- Cambia la intercalación (collation) de la base de datos a 'Latin1_General_CS_AS' (sensible a mayúsculas y acentos)
ALTER DATABASE Com2900G01 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
ALTER DATABASE Com2900G01
COLLATE Latin1_General_CS_AS;
GO
ALTER DATABASE Com2900G01 SET MULTI_USER;
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

IF NOT EXISTS (
    SELECT name 
    FROM sys.schemas 
    WHERE name = N'reporte')
BEGIN
    EXEC('CREATE SCHEMA reporte');
    PRINT 'Esquema reporte creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El esquema reporte ya existe.';
END;

GO

IF NOT EXISTS (
    SELECT name 
    FROM sys.schemas 
    WHERE name = N'sucursal')
BEGIN
    EXEC('CREATE SCHEMA sucursal');
    PRINT 'Esquema sucursal creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El esquema sucursal ya existe.';
END;

GO

IF NOT EXISTS (
    SELECT name 
    FROM sys.schemas 
    WHERE name = N'producto')
BEGIN
    EXEC('CREATE SCHEMA producto');
    PRINT 'Esquema producto creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El esquema producto ya existe.';
END;


GO

IF NOT EXISTS (
    SELECT name 
    FROM sys.schemas 
    WHERE name = N'facturacion')
BEGIN
    EXEC('CREATE SCHEMA facturacion');
    PRINT 'Esquema facturacion creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El esquema facturacion ya existe.';
END;

go


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

IF NOT EXISTS (
    SELECT name 
    FROM sys.schemas 
    WHERE name = N'dolar')
BEGIN
    EXEC('CREATE SCHEMA dolar');
    PRINT 'Esquema dolar creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El esquema dolar ya existe.';
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


IF NOT EXISTS (
    SELECT name 
    FROM sys.schemas 
    WHERE name = N'ventas')
BEGIN
    EXEC('CREATE SCHEMA ventas');
    PRINT 'Esquema ventas creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El esquema ventas ya existe.';
END;
GO

IF NOT EXISTS (
    SELECT name 
    FROM sys.schemas 
    WHERE name = N'nota')
BEGIN
    EXEC('CREATE SCHEMA nota');
    PRINT 'Esquema nota creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El esquema nota ya existe.';
END;
GO

IF NOT EXISTS (
    SELECT name 
    FROM sys.schemas 
    WHERE name = N'empleados')
BEGIN
    EXEC('CREATE SCHEMA empleados');
    PRINT 'Esquema empleados creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El esquema empleados ya existe.';
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

GO
-- Verifica si la tabla 'Empleados' ya existe, si no, la crea.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.Empleados') AND type in (N'U'))
BEGIN
    CREATE TABLE ddbba.Empleados (
        Legajo INT PRIMARY KEY,                   -- Número único que representa a cada Empleado
        Nombre VARCHAR(50),                       -- Nombre del Empleado
        Apellido VARCHAR(50),                     -- Apellido del Empleado
        DNI VARBINARY(500),                       -- DNI del Empleado, almacenado encriptado
        Direccion VARBINARY(500),                 -- Dirección del Empleado, almacenada encriptada
        EmailPersonal VARCHAR(100),              -- Email Personal del Empleado
        EmailEmpresa VARCHAR(100),               -- Email Empresarial del Empleado
        CUIL VARCHAR(15),                      -- CUIL del Empleado, almacenado encriptado
        Cargo VARCHAR(50) CHECK (Cargo IN ('Cajero', 'Supervisor', 'Gerente de sucursal')), -- Cargo del Empleado
        Sucursal VARCHAR(50),                     -- Sucursal donde trabaja el Empleado
        Turno VARCHAR(50) CHECK (Turno IN ('TM', 'TT', 'Jornada completa')), -- Turno del Empleado
        Activo BIT DEFAULT 1                      -- Campo para borrado lógico
    );
END;


go
-- Verifica si la tabla 'ClasificacionProductos' ya existe, si no, la crea.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.ClasificacionProductos') AND type in (N'U'))
BEGIN
    CREATE TABLE ddbba.ClasificacionProductos (
		IdClasificacion int identity(1,1) primary key,
        LineaDeProducto VARCHAR(30) CHECK (LineaDeProducto IN ('Electronica','Almacen', 'Perfumeria', 'Hogar', 'Frescos', 'Bazar', 'Limpieza', 'Otros', 'Congelados', 'Bebidas', 'Mascota', 'Comida','Importado')), -- Categoria a la cual pertenece
		Producto VARCHAR(100) unique, --Descripcion del producto (Ej. Arroz)
		Activo BIT DEFAULT 1 --Campo para borrado logico
    );
END;


GO


-- Verifica si la tabla 'catalogo' ya existe, si no, la crea.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.catalogo') AND type in (N'U'))
BEGIN
    CREATE TABLE ddbba.catalogo (
        id int PRIMARY KEY, -- Clave primaria 
        category VARCHAR(100),-- constraint fk_clasificacion foreign key (category) references ddbba.ClasificacionProductos(Producto), -- Categoría del producto
        nombre VARCHAR(100),-- UNIQUE, -- Nombre del producto
        price DECIMAL(10, 2) CHECK (price > 0), -- Precio del producto, debe ser mayor a 0
        reference_price DECIMAL(10, 2), -- Precio de referencia
        reference_unit VARCHAR(10), -- Unidad de referencia
        fecha DATETIME, -- Fecha
		Activo BIT DEFAULT 1 --Campo para borrado logico
    );
END;


GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.factura') AND type in (N'U'))
BEGIN
CREATE TABLE ddbba.factura (
    idFactura INT IDENTITY (1,1) PRIMARY KEY,
    numeroFactura int UNIQUE, 
    tipoFactura VARCHAR(50) CHECK (tipoFactura IN ('A', 'B', 'C')),
    tipoDeCliente VARCHAR(50) check (tipoDeCliente in ('Normal','Member')),
    fecha DATE,
    hora TIME,
    medioDePago VARCHAR(50) check (medioDePago in ('Credit Card','Cash','Ewallet')),
    empleado VARCHAR(100),
    identificadorDePago varbinary(256),
    montoTotal DECIMAL(10, 2),
    puntoDeVenta VARCHAR(50),
	estado VARCHAR(20) check (estado in ('pagada','pendiente','anulada','vencida','reembolsada'))
);
END




IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.productos') AND type in (N'U'))
BEGIN
CREATE TABLE ddbba.productos (
    idProducto int identity(1,1) primary key,
	nombre varchar(100) unique,
	precio decimal(15,2),
	clasificacion varchar(100),
	activo int
	CONSTRAINT FK_ClasificacionProducto FOREIGN KEY (clasificacion) 
    REFERENCES ddbba.ClasificacionProductos(Producto)
);
END



GO




IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.sucursal') AND type in (N'U'))
BEGIN
CREATE TABLE ddbba.sucursal (
    idSucursal int identity (1,1) primary key,
	ciudad varchar(20),
	direccion varchar(100),
	horario varchar(50),
	telefono varchar(20),
	activo int
)
END


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.notaDeCredito') AND type in (N'U'))
BEGIN
CREATE TABLE ddbba.notaDeCredito (
    notaID int identity(1,1) primary key,
	nroFactura int foreign key references ddbba.factura(numeroFactura),
	fechaEmision date,
	monto decimal(10,2)
)
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.detalleVenta') AND type in (N'U'))
BEGIN
CREATE TABLE ddbba.detalleVenta (
    detalleID int identity(1,1) primary key,
	nroFactura int foreign key references ddbba.factura(numeroFactura),
	producto varchar(100) foreign key references ddbba.productos(nombre),
	categoria varchar(100) foreign key references ddbba.ClasificacionProductos(Producto),
	cantidad int,
	precio_unitario decimal (10,2),
	monto decimal(10,2)
)
END


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.cotizacionDolar') AND type in (N'U'))
BEGIN
CREATE TABLE ddbba.cotizacionDolar (
	idCotizacion int identity(1,1) primary key,
    tipo varchar(50),
	valor decimal(10,2)
)
END

go
insert ddbba.cotizacionDolar values ('dolarBlue',1200)

