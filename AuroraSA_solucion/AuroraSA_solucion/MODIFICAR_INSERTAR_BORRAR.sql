

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
        PRINT 'El producto ya existe en la clasificaci�n';
    END
    ELSE
    BEGIN
        -- Inserta el registro en la tabla si no existe uno con el mismo Producto
        INSERT INTO ddbba.ClasificacionProductos (LineaDeProducto, Producto)
        VALUES (@LineaDeProducto, @Producto);

        PRINT 'Clasificaci�n del producto insertada exitosamente';
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

--SUCURSAL

CREATE OR ALTER PROCEDURE sucursal.sucursalActualizar
    @Ciudad VARCHAR(20),
    @Direccion VARCHAR(100),
    @Horario VARCHAR(50),
    @Telefono VARCHAR(20)
AS
BEGIN
    -- Verifica si existe una sucursal en la ciudad especificada
    IF EXISTS (SELECT 1 FROM ddbba.sucursal WHERE Ciudad = @Ciudad)
    BEGIN
        -- Si existe una sucursal en la ciudad, actualiza sus datos
        UPDATE ddbba.sucursal
        SET Direccion = @Direccion,
            Horario = @Horario,
            Telefono = @Telefono
        WHERE Ciudad = @Ciudad;

        PRINT 'Sucursal actualizada exitosamente';
    END
    ELSE
    BEGIN
        -- Si no existe una sucursal en esa ciudad, muestra un mensaje
        PRINT 'No existe una sucursal en esa ciudad';
    END
END;


go
--------------------------------------------------------------------Borrado
-- Stored procedure para borrado logico tabla Clasificacion Productos
CREATE OR ALTER PROCEDURE borrar.ClasificacionProductosBorradoLogico
    @Producto VARCHAR(70)
AS
BEGIN
    UPDATE ddbba.ClasificacionProductos
    SET Activo = 0
    WHERE Producto = @Producto;
END;
GO

--PRODUCTOS

CREATE OR ALTER PROCEDURE borrar.ProductoBorradoLogico
    @Nombre VARCHAR(100)
AS
BEGIN
    -- Verifica si existe un producto con el nombre especificado
    IF EXISTS (SELECT 1 FROM ddbba.productos WHERE Nombre = @Nombre)
    BEGIN
        -- Si el producto existe, realiza el borrado l�gico (pone activo en 0)
        UPDATE ddbba.productos
        SET activo = 0
        WHERE Nombre = @Nombre;

        PRINT 'Producto desactivado exitosamente';
    END
    ELSE
    BEGIN
        -- Si el producto no existe, muestra un mensaje
        PRINT 'No existe un producto con ese nombre';
    END
END;




-- Stored procedure para borrado logico tabla Empleados

CREATE OR ALTER PROCEDURE borrar.EmpleadosBorradoLogico
    @Legajo INT
AS
BEGIN
    UPDATE ddbba.Empleados
    SET Activo = 0
    WHERE Legajo = @Legajo;
END;
GO

--SUCURSAL

CREATE OR ALTER PROCEDURE borrar.SucursalBorradoLogico
    @Ciudad VARCHAR(20)
AS
BEGIN
    -- Verifica si existe una sucursal en la ciudad especificada
    IF EXISTS (SELECT 1 FROM ddbba.sucursal WHERE Ciudad = @Ciudad)
    BEGIN
        -- Si existe una sucursal en la ciudad, realiza el borrado l�gico (pone activo en 0)
        UPDATE ddbba.sucursal
        SET activo = 0
        WHERE Ciudad = @Ciudad;

        PRINT 'Sucursal desactivada exitosamente';
    END
    ELSE
    BEGIN
        -- Si no existe una sucursal en esa ciudad, muestra un mensaje
        PRINT 'No existe una sucursal en esa ciudad';
    END
END;


GO



----------------------EMITIR

--EMITIR FACTURA

CREATE OR ALTER PROCEDURE facturacion.facturaEmitir
    @numeroFactura VARCHAR(50), 
    @tipoFactura VARCHAR(50),
    @tipoDeCliente VARCHAR(50),
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
			update ddbba.factura set montoTotal=montoTotal + @montoTotal where numeroFactura=@numeroFactura
		END
	ELSE
		BEGIN
			insert ddbba.Factura(numeroFactura,tipoFactura,tipoDeCliente,fecha,hora,medioDePago,empleado,identificadorDePago,
			montoTotal,puntoDeVenta,estado) values (@numeroFactura,@tipoFactura,@tipoDeCliente,@fecha,@hora,@medioDePago,@empleado,@identificadorDePago,
			@montoTotal,@puntoDeVenta,@estado)
		END
END

go

--DETALLE DE VENTA

CREATE OR ALTER PROCEDURE facturacion.DetalleVentaEmitir
    @nroFactura INT,
    @producto VARCHAR(100),
    @cantidad INT
AS
BEGIN
    -- Verifica si el n�mero de factura existe en la tabla ddbba.factura
    IF NOT EXISTS (SELECT 1 FROM ddbba.factura WHERE numeroFactura = @nroFactura)
    BEGIN
        -- Si no existe la factura, muestra un mensaje de error
        PRINT 'Error: El n�mero de factura no existe.';
    END
    ELSE
    BEGIN
        -- Verifica si el producto existe en la tabla ddbba.productos
        DECLARE @precio_unitario DECIMAL(10,2);
        DECLARE @categoria VARCHAR(100);

        SELECT @precio_unitario = precio, @categoria = clasificacion
        FROM ddbba.productos
        WHERE nombre = @producto;

        -- Si el producto no existe, muestra un mensaje de error
        IF @precio_unitario IS NULL
        BEGIN
            PRINT 'Error: El producto no existe.';
        END
        ELSE
        BEGIN
            -- Si el producto existe, inserta el detalle de la venta
            INSERT INTO ddbba.detalleVenta (nroFactura, producto, categoria, cantidad, precio_unitario, monto)
            VALUES (@nroFactura, @producto, @categoria, @cantidad, @precio_unitario, @cantidad * @precio_unitario);

            PRINT 'Detalle de venta emitido exitosamente';
        END
    END
END;




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
    WHERE numeroFactura = @idFactura;

    -- Validar si la factura existe y esta pagada
    IF @estado = 'pagada'
    BEGIN
        -- Insertar la nota de cr�dito
        INSERT INTO ddbba.notaDeCredito (nroFactura, fechaEmision, monto)
        VALUES (@idFactura, GETDATE(), @monto);

        PRINT 'Nota de cr�dito emitida correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'No se puede emitir la nota de credito: la factura no est� en estado "pagado" o no existe.';
    END
END;



