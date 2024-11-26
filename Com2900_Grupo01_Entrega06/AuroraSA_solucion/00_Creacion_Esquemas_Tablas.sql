
/*Luego de decidirse por un motor de base de datos relacional, llegó el momento de generar la
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
MIEL. Solo uno de los miembros del grupo debe hacer la entrega.*/


-- Bases de Datos Aplicadas
-- Fecha de entrega: 12 de Noviembre de 2024
-- Grupo 01
-- Comision 2900
-- 45739056 Sofia Florencia Gay
-- 44482420	Valentino Amato
-- 44396900 Joaquin Barcella
-- 44960383 Rafael David Nazareno Ruiz

---------------Creacion de esquemas y tablas


----------------------------------------- BASE DE DATOS -----------------------------------------------------

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

--VERIFICA SI EXISTE EL ESQUEMA DDBBA, Y SINO LO CREA
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
--VERIFICA SI EXISTE EL ESQUEMA REPORTE, Y SINO LO CREA
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

--VERIFICA SI EXISTE EL ESQUEMA SUCURSAL, Y SINO LO CREA
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

--VERIFICA SI EXISTE EL ESQUEMA PRODUCTO, Y SINO LO CREA
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
--VERIFICA SI EXISTE EL ESQUEMA FACTURACION, Y SINO LO CREA
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


GO
--VERIFICA SI EXISTE EL ESQUEMA DOLAR, Y SINO LO CREA
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

--VERIFICA SI EXISTE EL ESQUEMA BORRAR, Y SINO LO CREA
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

--VERIFICA SI EXISTE EL ESQUEMA IMPORTAR, Y SINO LO CREA
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


--VERIFICA SI EXISTE EL ESQUEMA NOTA, Y SINO LO CREA
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

--VERIFICA SI EXISTE EL ESQUEMA EMPLEADOS, Y SINO LO CREA
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

--------------CLAVE PARA CIFRAR EMPLEADOS
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'ClaveEncriptacionEmpleados')
BEGIN
    CREATE SYMMETRIC KEY ClaveEncriptacionEmpleados
    WITH ALGORITHM = AES_128
    ENCRYPTION BY PASSWORD = 'empleado;2024,grupo1';
END;




GO

---------------------------------------------CREACION DE TABLAS

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.sucursal') AND type in (N'U'))
BEGIN
CREATE TABLE ddbba.sucursal (
    idSucursal int identity (1,1) primary key,
	ciudad varchar(20) unique,
	direccion varchar(100),
	horario varchar(50),
	telefono varchar(20),
    FechaBaja DATE DEFAULT NULL                     -- Campo para borrado lógico
)
END
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.Empleados') AND type in (N'U'))
BEGIN
    CREATE TABLE ddbba.Empleados (
        Legajo INT identity(257019,1) PRIMARY KEY,                  
        Nombre VARCHAR(50),                      
        Apellido VARCHAR(50),                     
        DNI VARBINARY(500) NOT NULL,                      -- DNI del Empleado, almacenado encriptado
        Direccion VARBINARY(500),                -- Dirección del Empleado, almacenada encriptada
        EmailPersonal VARCHAR(100),              
        EmailEmpresa VARCHAR(100),             
        CUIL VARBINARY(500) NOT NULL,                      -- CUIL del Empleado, almacenado encriptado
        Cargo VARCHAR(50) CHECK (Cargo IN ('Cajero', 'Supervisor', 'Gerente de sucursal')), -- Cargo del Empleado
        Sucursal VARCHAR(20) foreign key references ddbba.sucursal(ciudad),                     -- Sucursal donde trabaja el Empleado
        Turno VARCHAR(50) CHECK (Turno IN ('TM', 'TT', 'JC')), 
        FechaBaja DATE DEFAULT NULL                     -- Campo para borrado lógico
    );
END;





go
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.ClasificacionProductos') AND type in (N'U'))
BEGIN
    CREATE TABLE ddbba.ClasificacionProductos (
		IdClasificacion int identity(1,1) primary key,
        LineaDeProducto VARCHAR(30) CHECK (LineaDeProducto IN ('Electronica','Almacen', 'Perfumeria', 'Hogar', 'Frescos', 'Bazar', 'Limpieza', 'Otros', 'Congelados', 'Bebidas', 'Mascota', 'Comida','Importado')), -- Categoria a la cual pertenece
		Producto VARCHAR(100) unique, --Descripcion del producto (Ej. Arroz)
        FechaBaja DATE DEFAULT NULL                     -- Campo para borrado lógico

    );
END;






GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.productos') AND type in (N'U'))
BEGIN
CREATE TABLE ddbba.productos (
    idProducto int identity(1,1) primary key,
	nombre varchar(100) unique,
	precio decimal(15,2),
	clasificacion varchar(100),
    FechaBaja DATE DEFAULT NULL                     -- Campo para borrado lógico
	CONSTRAINT FK_ClasificacionProducto FOREIGN KEY (clasificacion) 
    REFERENCES ddbba.ClasificacionProductos(Producto)
);
END


GO




IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.cotizacionDolar') AND type in (N'U'))
BEGIN
CREATE TABLE ddbba.cotizacionDolar (
	idCotizacion int identity(1,1) primary key,
    tipo varchar(50),
	valor decimal(10,2)
)
END

GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.ventaRegistrada') AND type in (N'U'))
BEGIN
CREATE TABLE ddbba.ventaRegistrada (
	idVenta int identity(1,1) primary key,
	ciudad varchar(20),
	tipoCliente varchar(10),
	genero varchar(10),
	monto decimal(10,2),
	fecha date,
	hora time,
	empleado int
)
END

GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.factura') AND type in (N'U'))
BEGIN
CREATE TABLE ddbba.factura (
    idFactura INT IDENTITY (1,1) PRIMARY KEY,
    idVenta int foreign key references ddbba.ventaRegistrada(idVenta), 
    tipoFactura VARCHAR(50) CHECK (tipoFactura IN ('A', 'B', 'C')),
    tipoDeCliente VARCHAR(50) check (tipoDeCliente in ('Normal','Member')),
    fecha DATE,
    hora TIME,
    medioDePago VARCHAR(50) CHECK (medioDePago in ('Credit card','Cash','Ewallet')),
    empleado int foreign key references ddbba.Empleados(Legajo),
    montoSinIVA DECIMAL(10, 2),
	montoConIVA DECIMAL(10,2),
	IVA DECIMAL(10,2),
    puntoDeVenta VARCHAR(50),
	cuit varchar(20),
	estado VARCHAR(20) CHECK (estado in ('pagada','pendiente','anulada','vencida','reembolsada'))
);
END


GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.detalleVenta') AND type in (N'U'))
BEGIN
CREATE TABLE ddbba.detalleVenta (
    detalleID int identity(1,1) primary key,
	idVenta int foreign key references ddbba.ventaRegistrada(idVenta),
	idProducto int foreign key references ddbba.productos(idProducto),
	categoria varchar(100),
	cantidad int,
	precio_unitario decimal (10,2),
	monto decimal(10,2)
)
END

GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.notaDeCredito') AND type in (N'U'))
BEGIN
CREATE TABLE ddbba.notaDeCredito (
    notaID int identity(1,1) primary key,
	idVenta int foreign key references ddbba.ventaRegistrada(idVenta),
	fechaEmision date,
	producto varchar(100),
	cantidad int,
	monto decimal(10,2)
)
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ddbba.pago') AND type in (N'U'))
BEGIN
	CREATE TABLE ddbba.pago (
    idPago INT IDENTITY(1,1) PRIMARY KEY,       -- Identificador único del pago
    idFactura INT,                               -- Identificador de la factura asociada (FK)
    fecha DATETIME NOT NULL,                 -- Fecha y hora del pago
    monto DECIMAL(10, 2) NOT NULL,                -- Monto pagado
    metodoPago VARCHAR(50) NOT NULL,  
	CONSTRAINT fk_factura FOREIGN KEY (idFactura) REFERENCES ddbba.factura(idFactura) 
)
END




