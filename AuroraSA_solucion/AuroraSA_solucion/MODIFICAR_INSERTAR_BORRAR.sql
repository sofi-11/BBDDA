

use COM2900G01

go
-----------------------------------------------------------------------------INSERTAR

--PRODUCTOS


CREATE OR ALTER PROCEDURE producto.ProductoInsertar
    @nombre VARCHAR(100),
    @precio DECIMAL(15, 2),
    @clasificacion VARCHAR(50)
AS
BEGIN
    -- Verifica si ya existe un producto con el mismo nombre
    IF EXISTS (SELECT 1 FROM ddbba.productos WHERE nombre = @nombre)
    BEGIN
        PRINT 'El producto con ese nombre ya existe';
    END
    ELSE
    BEGIN
        -- Inserta el producto en la tabla si no existe uno con el mismo nombre
        INSERT INTO ddbba.productos (nombre, precio, clasificacion)
        VALUES (@nombre, @precio, @clasificacion);

        PRINT 'Producto insertado exitosamente';
    END
END;

GO

-- INSERTAR EMPLEADO

CREATE OR ALTER PROCEDURE empleados.EmpleadoInsertar
    @Legajo INT,
    @Nombre VARCHAR(50),
    @Apellido VARCHAR(50),
    @DNI CHAR(9),
    @Direccion VARCHAR(150),
    @EmailPersonal NVARCHAR(100),
    @EmailEmpresa NVARCHAR(100),
    @CUIL VARCHAR(20),
    @Cargo VARCHAR(50),
    @Sucursal VARCHAR(50),
    @Turno VARCHAR(50)
AS
BEGIN
    -- Verifica si ya existe un empleado con el mismo Legajo
    IF EXISTS (SELECT 1 FROM ddbba.empleados WHERE Legajo = @Legajo)
    BEGIN
        PRINT 'El empleado con ese legajo ya existe';
    END
    ELSE
    BEGIN
        -- Inserta el empleado en la tabla si no existe uno con el mismo Legajo
        INSERT INTO ddbba.empleados (Legajo, Nombre, Apellido, DNI, Direccion, EmailPersonal, EmailEmpresa, CUIL, Cargo, Sucursal, Turno)
        VALUES (@Legajo, @Nombre, @Apellido, @DNI, @Direccion, @EmailPersonal, @EmailEmpresa, @CUIL, @Cargo, @Sucursal, @Turno);

        PRINT 'Empleado insertado exitosamente';
    END
END;



GO

CREATE OR ALTER PROCEDURE dolar.cotizacionDolarInsertar
@tipo varchar(10),
@valor decimal(10,2)
AS
BEGIN
	if exists(select 1 from ddbba.cotizacionDolar c where c.tipo = @tipo)
		print('ya existe')
	else
	begin
		insert ddbba.cotizacionDolar(tipo,valor) values (@tipo,@valor)
	end
END

GO

CREATE OR ALTER PROCEDURE producto.ClasificacionProductoInsertar
    @LineaDeProducto VARCHAR(30),
    @Producto VARCHAR(100)
AS
BEGIN
    -- Verifica si ya existe un registro con el mismo Producto
    IF EXISTS (SELECT 1 FROM ddbba.ClasificacionProductos WHERE Producto = @Producto)
    BEGIN
        PRINT 'El producto ya existe en la clasificación';
    END
    ELSE
    BEGIN
        -- Inserta el registro en la tabla si no existe uno con el mismo Producto
        INSERT INTO ddbba.ClasificacionProductos (LineaDeProducto, Producto)
        VALUES (@LineaDeProducto, @Producto);

        PRINT 'Clasificación del producto insertada exitosamente';
    END
END;

--SUCURSAL

CREATE OR ALTER PROCEDURE sucursal.SucursalInsertar
    @Ciudad VARCHAR(20),
    @Direccion VARCHAR(100),
    @Horario VARCHAR(50),
    @Telefono VARCHAR(20)
AS
BEGIN
    -- Verifica si ya existe una sucursal en la misma ciudad
    IF EXISTS (SELECT 1 FROM ddbba.sucursal WHERE Ciudad = @Ciudad)
    BEGIN
        PRINT 'Ya existe una sucursal en esta ciudad';
    END
    ELSE
    BEGIN
        -- Inserta la sucursal en la tabla si no existe una en la misma ciudad
        INSERT INTO ddbba.sucursal (Ciudad, Direccion, Horario, Telefono)
        VALUES (@Ciudad, @Direccion, @Horario, @Telefono);

        PRINT 'Sucursal insertada exitosamente';
    END
END;




-----------------------------------------------------------------------------------------------------MODIFICAR
GO
--productos

CREATE OR ALTER PROCEDURE producto.ProductoModificar
    @nombre VARCHAR(100),
    @precio DECIMAL(15, 2),
    @clasificacion VARCHAR(50)
AS
BEGIN
    -- Verifica si existe un producto con el nombre especificado
    IF EXISTS (SELECT 1 FROM ddbba.Productos WHERE nombre = @nombre)
    BEGIN
        -- Si el producto existe, actualiza sus datos
        UPDATE ddbba.Productos
        SET precio = @precio,
            clasificacion = @clasificacion
        WHERE nombre = @nombre;

        PRINT 'Producto actualizado exitosamente';
    END
    ELSE
    BEGIN
        -- Si el producto no existe, muestra un mensaje
        PRINT 'No existe un producto con ese nombre';
    END
END;

GO

--ACTUALIZAR EMPLEADO

CREATE OR ALTER PROCEDURE empleados.EmpleadoActualizar
    @Legajo INT,
    @Nombre VARCHAR(50),
    @Apellido VARCHAR(50),
    @DNI CHAR(9),
    @Direccion VARCHAR(150),
    @EmailPersonal NVARCHAR(100),
    @EmailEmpresa NVARCHAR(100),
    @CUIL VARCHAR(20),
    @Cargo VARCHAR(50),
    @Sucursal VARCHAR(50),
    @Turno VARCHAR(50)
AS
BEGIN
    -- Verifica si existe un empleado con el legajo especificado
    IF EXISTS (SELECT 1 FROM ddbba.empleados WHERE Legajo = @Legajo)
    BEGIN
        -- Si el empleado existe, actualiza sus datos
        UPDATE ddbba.empleados
        SET Nombre = @Nombre,
            Apellido = @Apellido,
            DNI = @DNI,
            Direccion = @Direccion,
            EmailPersonal = @EmailPersonal,
            EmailEmpresa = @EmailEmpresa,
            CUIL = @CUIL,
            Cargo = @Cargo,
            Sucursal = @Sucursal,
            Turno = @Turno
        WHERE Legajo = @Legajo;

        PRINT 'Empleado actualizado exitosamente';
    END
    ELSE
    BEGIN
        -- Si el empleado no existe, muestra un mensaje
        PRINT 'No existe un empleado con ese legajo';
    END
END;


GO

--ACTUALIZAR COTIZACIONES DEL DOLAR

CREATE OR ALTER PROCEDURE dolar.cotizacionDolarModificar
@tipo varchar(10),
@valor decimal(10,2)
AS
BEGIN
	if not exists(select 1 from ddbba.cotizacionDolar c where c.tipo = @tipo)
		print('no existe tipo de dolar')
	else
	begin
		update ddbba.cotizacionDolar set valor=@valor where tipo=@tipo
		print('valor actualizado')
	end
END


go
--------------------------------------------------------------------Borrado
-- Stored procedure para borrado logico tabla Clasificacion Productos
CREATE OR ALTER PROCEDURE borrar.BorradoLogicoClasificacionProductos
    @Producto VARCHAR(70)
AS
BEGIN
    UPDATE ddbb.ClasificacionProductos
    SET Activo = 0
    WHERE Producto = @Producto;
END;
GO




-- Stored procedure para borrado logico tabla Catalogo
CREATE OR ALTER PROCEDURE borrar.BorradoLogicoCatalogo
    @ID INT
AS
BEGIN
    UPDATE ddbb.catalogo
    SET Activo = 0
    WHERE id = @ID;
END;
GO


-- Stored procedure para borrado logico tabla Empleados

CREATE OR ALTER PROCEDURE borrar.BorradoLogicoEmpleados
    @Legajo INT
AS
BEGIN
    UPDATE ddbba.Empleados
    SET Activo = 0
    WHERE Legajo = @Legajo;
END;
GO


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

go



----------------------EMITIR

--EMITIR FACTURA

CREATE OR ALTER PROCEDURE facturacion.facturaEmitir
	@idFactura INT,
    @numeroFactura VARCHAR(50), 
    @tipoFactura VARCHAR(50),
    @ciudad VARCHAR(50),
    @tipoDeCliente VARCHAR(50),
    @genero VARCHAR(10),
    @fecha DATE,
    @hora TIME,
    @medioDePago VARCHAR(50),
    @empleado VARCHAR(100),
    @identificadorDePago VARCHAR(100),
    @montoTotal DECIMAL(10, 2),
    @puntoDeVenta VARCHAR(50),
	@estado VARCHAR(20)
AS
BEGIN
	if exists(select 1 from ddbba.Factura where idFactura=@idFactura)
		BEGIN
			update ddbba.Factura set montoTotal=montoTotal + @montoTotal
		END
	ELSE
		BEGIN
			insert ddbba.Factura values (@numeroFactura,@tipoFactura,@ciudad,@tipoDeCliente,@fecha,@hora,@medioDePago,@empleado,@identificadorDePago,
			@montoTotal,@puntoDeVenta,@estado)
		END
END

go

CREATE OR ALTER PROCEDURE facturacion.detalleVentaEmitir
    @numeroFactura VARCHAR(50), 
    @tipoFactura VARCHAR(50),
    @ciudad VARCHAR(50),
    @tipoDeCliente VARCHAR(50),
    @genero VARCHAR(10),
    @fecha DATE,
    @hora TIME,
    @medioDePago VARCHAR(50),
    @empleado VARCHAR(100),
    @identificadorDePago VARCHAR(100),
    @montoTotal DECIMAL(10, 2),
    @puntoDeVenta VARCHAR(50),
	@estado VARCHAR(20)
AS
BEGIN
	if exists(select 1 from ddbba.Factura where numeroFactura=@numeroFactura)
		BEGIN
			update ddbba.Factura set montoTotal=montoTotal + @montoTotal
		END
	ELSE
		BEGIN
			insert ddbba.Factura values (@numeroFactura,@tipoFactura,@ciudad,@tipoDeCliente,@fecha,@hora,@medioDePago,@empleado,@identificadorDePago,
			@montoTotal,@puntoDeVenta,@estado)
		END
END

go



--EMITIR NOTA DE CREDITO

CREATE OR ALTER PROCEDURE nota.EmitirNotaCredito
    @idFactura INT,
    @monto DECIMAL(10,2)
AS
BEGIN
    DECLARE @estado NVARCHAR(50);

    -- Comprobar el estado de la factura
    SELECT @estado = estado 
    FROM ddbba.factura 
    WHERE idFactura = @idFactura;

    -- Validar si la factura existe y esta pagada
    IF @estado = 'pagado'
    BEGIN
        -- Insertar la nota de crédito
        INSERT INTO ddbba.notaDeCredito (nroFactura, fechaEmision, monto)
        VALUES (@idFactura, GETDATE(), @monto);

        PRINT 'Nota de crédito emitida correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'No se puede emitir la nota de credito: la factura no está en estado "pagado" o no existe.';
    END
END;



