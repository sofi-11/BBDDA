

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
    -- Verifica la longitud de los parámetros
    IF LEN(@nombre) > 100
    BEGIN
        PRINT 'Error: El nombre del producto supera el límite de 100 caracteres.';
    END
    ELSE IF LEN(@clasificacion) > 50
    BEGIN
        PRINT 'Error: La clasificación del producto supera el límite de 50 caracteres.';
    END
	ELSE IF @precio < 0
    BEGIN
        PRINT 'Error: precio menor a cero.';
    END
    ELSE IF EXISTS (SELECT 1 FROM ddbba.productos WHERE nombre = @nombre)
    BEGIN
        -- Verifica si ya existe un producto con el mismo nombre
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
    @Nombre VARCHAR(50),
    @Apellido VARCHAR(50),
    @DNI VARCHAR(20),
    @Direccion VARCHAR(150),
    @EmailPersonal NVARCHAR(100),
    @EmailEmpresa NVARCHAR(100),
    @CUIL VARCHAR(20),
    @Cargo VARCHAR(50),
    @Sucursal VARCHAR(50),
    @Turno VARCHAR(50)
AS
BEGIN
    OPEN SYMMETRIC KEY ClaveEncriptacionEmpleados DECRYPTION BY PASSWORD = 'empleado;2024,grupo1';

    -- Validación de longitud y formato de DNI (solo dígitos)
    IF LEN(@DNI) < 7 OR LEN(@DNI) > 8 
    BEGIN
        PRINT 'Error: El DNI debe contener 7 u 8 dígitos numéricos.';
    END
    -- Validación de presencia de "@" en los correos electrónicos
    ELSE IF CHARINDEX('@', @EmailPersonal) = 0
    BEGIN
        PRINT 'Error: El EmailPersonal debe contener un símbolo "@".';
    END
    ELSE IF CHARINDEX('@', @EmailEmpresa) = 0
    BEGIN
        PRINT 'Error: El EmailEmpresa debe contener un símbolo "@".';
    END
    -- Verifica si ya existe un empleado con el mismo DNI
    ELSE IF EXISTS (SELECT 1 FROM ddbba.Empleados WHERE CONVERT(NVARCHAR(500), DECRYPTBYKEY(DNI)) = @DNI)
    BEGIN
        PRINT 'El empleado con ese DNI ya existe';
    END
    ELSE
    BEGIN
        -- Inserta el empleado en la tabla si no existe uno con el mismo DNI
        INSERT INTO ddbba.Empleados (Nombre, Apellido, DNI, Direccion, EmailPersonal, EmailEmpresa, CUIL, Cargo, Sucursal, Turno)
        VALUES (@Nombre, @Apellido, ENCRYPTBYKEY(KEY_GUID('ClaveEncriptacionEmpleados'), CONVERT(NVARCHAR(500), @DNI)), 
                ENCRYPTBYKEY(KEY_GUID('ClaveEncriptacionEmpleados'), CONVERT(NVARCHAR(500), @Direccion)), 
                @EmailPersonal, @EmailEmpresa, 
                ENCRYPTBYKEY(KEY_GUID('ClaveEncriptacionEmpleados'), CONVERT(NVARCHAR(500),@CUIL)), 
                @Cargo, @Sucursal, @Turno);

        PRINT 'Empleado insertado exitosamente';
    END

    CLOSE SYMMETRIC KEY ClaveEncriptacionEmpleados;
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

go
--SUCURSAL

CREATE OR ALTER PROCEDURE sucursal.SucursalInsertar
    @Ciudad VARCHAR(20),
    @Direccion VARCHAR(100),
    @Horario VARCHAR(50),
    @Telefono VARCHAR(20)
AS
BEGIN
    -- Verifica si ya existe una sucursal en la misma ciudad
    IF EXISTS (SELECT 1 FROM ddbba.sucursal WHERE ciudad = @Ciudad)
    BEGIN
        PRINT 'Ya existe una sucursal en esta ciudad';
    END
    ELSE
    BEGIN
        -- Inserta la sucursal en la tabla si no existe una en la misma ciudad
        INSERT INTO ddbba.sucursal (ciudad, direccion, horario, telefono)
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
    IF EXISTS (SELECT 1 FROM ddbba.productos WHERE nombre = @nombre)
    BEGIN
        -- Si el producto existe, actualiza sus datos
        UPDATE ddbba.productos
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
    @DNI VARCHAR(20),
    @Direccion VARCHAR(150),
    @EmailPersonal NVARCHAR(100),
    @EmailEmpresa NVARCHAR(100),
    @CUIL VARCHAR(20),
    @Cargo VARCHAR(50),
    @Sucursal VARCHAR(50),
    @Turno VARCHAR(50)
AS
BEGIN
	OPEN SYMMETRIC KEY ClaveEncriptacionEmpleados DECRYPTION BY PASSWORD = 'empleado;2024,grupo1';
    -- Verifica si existe un empleado con el legajo especificado
    IF EXISTS (SELECT 1 FROM ddbba.Empleados WHERE Legajo = @Legajo)
    BEGIN
        -- Si el empleado existe, actualiza sus datos
        UPDATE ddbba.Empleados
        SET Nombre = @Nombre,
            Apellido = @Apellido,
            DNI = ENCRYPTBYKEY(KEY_GUID('ClaveEncriptacionEmpleados'), CONVERT(NVARCHAR(500), @DNI)),
            Direccion = ENCRYPTBYKEY(KEY_GUID('ClaveEncriptacionEmpleados'), CONVERT(NVARCHAR(500), @Direccion)),
            EmailPersonal = @EmailPersonal,
            EmailEmpresa = @EmailEmpresa,
            CUIL = ENCRYPTBYKEY(KEY_GUID('ClaveEncriptacionEmpleados'), CONVERT(NVARCHAR(500), @Cuil)),
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
	CLOSE SYMMETRIC KEY ClaveEncriptacionEmpleados
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
go

CREATE OR ALTER PROCEDURE sucursal.sucursalActualizar
    @Ciudad VARCHAR(20),
    @Direccion VARCHAR(100),
    @Horario VARCHAR(50),
    @Telefono VARCHAR(20)
AS
BEGIN
    -- Verifica si existe una sucursal en la ciudad especificada
    IF EXISTS (SELECT 1 FROM ddbba.sucursal WHERE ciudad = @Ciudad)
    BEGIN
        -- Si existe una sucursal en la ciudad, actualiza sus datos
        UPDATE ddbba.sucursal
        SET direccion = @Direccion,
            horario = @Horario,
            telefono = @Telefono
        WHERE ciudad = @Ciudad;

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
	SET FechaBaja = GETDATE()
    WHERE Producto = @Producto
END;
GO

--PRODUCTOS

CREATE OR ALTER PROCEDURE borrar.ProductoBorradoLogico
    @Nombre VARCHAR(100)
AS
BEGIN
    -- Verifica si existe un producto con el nombre especificado
    IF EXISTS (SELECT 1 FROM ddbba.productos WHERE nombre = @Nombre)
    BEGIN
        -- Si el producto existe, realiza el borrado lógico (Inserta la Fecha de baja)
        UPDATE ddbba.productos
		SET FechaBaja = GETDATE()
        WHERE nombre = @Nombre;

        PRINT 'Producto desactivado exitosamente';
    END
    ELSE
    BEGIN
        -- Si el producto no existe, muestra un mensaje
        PRINT 'No existe un producto con ese nombre';
    END
END;


go

-- Stored procedure para borrado logico tabla Empleados

CREATE OR ALTER PROCEDURE borrar.EmpleadosBorradoLogico
    @Legajo INT
AS
BEGIN
    UPDATE ddbba.Empleados
	SET FechaBaja = GETDATE()
    WHERE Legajo = @Legajo;
END;
GO

--SUCURSAL

CREATE OR ALTER PROCEDURE borrar.SucursalBorradoLogico
    @Ciudad VARCHAR(20)
AS
BEGIN
    -- Verifica si existe una sucursal en la ciudad especificada
    IF EXISTS (SELECT 1 FROM ddbba.sucursal WHERE ciudad = @Ciudad)
    BEGIN
        -- Si existe una sucursal en la ciudad, realiza el borrado lógico (Cambia la fecha de baja, de NULL a la fecha )
        UPDATE ddbba.sucursal
		SET FechaBaja = GETDATE()
        WHERE ciudad = @Ciudad;

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
    @idVenta int, 
    @tipoFactura VARCHAR(50),
    @tipoDeCliente VARCHAR(50),
    @medioDePago VARCHAR(50),
    @empleado VARCHAR(100),
    @identificadorDePago VARCHAR(100),
    @montoTotal DECIMAL(10, 2),
    @puntoDeVenta VARCHAR(50),
	@estado VARCHAR(20),
	@cuit varchar(20)
AS
BEGIN
	if exists(select 1 from ddbba.ventaRegistrada where idVenta=@idVenta)
		BEGIN
			insert ddbba.factura(idVenta,tipoFactura,tipoDeCliente,fecha,hora,medioDePago,empleado,identificadorDePago,
			montoSinIVA,puntoDeVenta,estado,cuit,montoConIVA,IVA) values (@idVenta,@tipoFactura,@tipoDeCliente,CAST(GETDATE() AS DATE),CAST(GETDATE() AS TIME),@medioDePago,@empleado,@identificadorDePago,
			@montoTotal,@puntoDeVenta,@estado,@cuit,@montoTotal * 1.21,@montoTotal * 0.21)
			
		END
	ELSE
		PRINT 'Error numero venta'
END

go

--DETALLE DE VENTA

CREATE OR ALTER PROCEDURE facturacion.DetalleVentaEmitir
    @idVenta INT,
    @idProducto int,
    @cantidad INT
AS
BEGIN
    -- Verifica si el número de factura existe en la tabla ddbba.factura
    IF NOT EXISTS (SELECT 1 FROM ddbba.factura WHERE idVenta = @idVenta)
    BEGIN
        -- Si no existe la factura, muestra un mensaje de error
        PRINT 'Error: El número de factura no existe.';
    END
    ELSE
    BEGIN
        -- Verifica si el producto existe en la tabla ddbba.productos
        DECLARE @precio_unitario DECIMAL(10,2);
        DECLARE @categoria VARCHAR(100);

        SELECT @precio_unitario = precio, @categoria = clasificacion
        FROM ddbba.productos
        WHERE idProducto = @idProducto;

        -- Si el producto no existe, muestra un mensaje de error
        IF @precio_unitario IS NULL
        BEGIN
            PRINT 'Error: El producto no existe.';
        END
        ELSE
        BEGIN
            -- Si el producto existe, inserta el detalle de la venta
            INSERT INTO ddbba.detalleVenta (idVenta, idProducto, categoria, cantidad, precio_unitario, monto)
            VALUES (@idVenta, @idProducto, @categoria, @cantidad, @precio_unitario, @cantidad * @precio_unitario);

            PRINT 'Detalle de venta emitido exitosamente';
        END
    END
END;




go




--EMITIR NOTA DE CREDITO

CREATE OR ALTER PROCEDURE nota.EmitirNotaCredito
    @idVenta INT,
    @monto DECIMAL(10,2)
AS
BEGIN
    DECLARE @estado NVARCHAR(50);

    -- Comprobar el estado de la factura
    SELECT @estado = estado 
    FROM ddbba.factura 
    WHERE idVenta = @idVenta;

    -- Validar si la factura existe y esta pagada
    IF @estado = 'pagada'
    BEGIN
        -- Insertar la nota de crédito
        INSERT INTO ddbba.notaDeCredito (idVenta, fechaEmision, monto)
        VALUES (@idVenta, GETDATE(), @monto);

        PRINT 'Nota de crédito emitida correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'No se puede emitir la nota de credito: la factura no está en estado "pagado" o no existe.';
    END
END;


GO
--registrar una venta

CREATE OR ALTER PROCEDURE facturacion.ventaEmitir
@ciudad varchar(20),
@tipoCliente varchar(10),
@genero varchar(10),
@monto decimal(10,2),
@empleado int
AS
BEGIN
	insert into ddbba.ventaRegistrada(ciudad,tipoCliente,genero,monto,fecha,hora,empleado) 
	values (@ciudad,@tipoCliente,@genero,@monto,CAST(GETDATE() AS DATE),CAST(GETDATE() AS TIME),@empleado)
END





------------------------

CREATE FUNCTION SplitString (@string NVARCHAR(MAX), @delimiter CHAR(1))
RETURNS @output TABLE (data NVARCHAR(MAX))
AS
BEGIN
    DECLARE @start INT, @end INT
    SET @start = 1
    SET @end = CHARINDEX(@delimiter, @string)

    WHILE @end > 0
    BEGIN
        INSERT INTO @output (data) VALUES(SUBSTRING(@string, @start, @end - @start))
        SET @start = @end + 1
        SET @end = CHARINDEX(@delimiter, @string, @start)
    END

    INSERT INTO @output (data) VALUES(SUBSTRING(@string, @start, LEN(@string) - @start + 1))
    RETURN
END;

/*
CREATE OR ALTER PROCEDURE RegistrarVentaConCadena
    @ciudad VARCHAR(20),
    @tipoCliente VARCHAR(10),
    @genero VARCHAR(10),
    @empleado INT,
    @fecha DATE,
    @hora TIME,
    @cadenaProductos NVARCHAR(MAX) -- Cadena con productos y cantidades
AS
BEGIN
    DECLARE @idVenta INT, @montoTotal DECIMAL(10, 2) = 0;

    -- 1. Crear la venta con monto inicial en cero
    INSERT INTO ddbba.ventaRegistrada (ciudad, tipoCliente, genero, monto, fecha, hora, empleado)
    VALUES (@ciudad, @tipoCliente, @genero, 0, @fecha, @hora, @empleado);

    SET @idVenta = SCOPE_IDENTITY();

    -- 2. Dividir la cadena de productos en partes
    DECLARE @productoDetalle TABLE (nombreProducto NVARCHAR(100), cantidad INT);

    INSERT INTO @productoDetalle (nombreProducto, cantidad)
    SELECT 
        LEFT(data, CHARINDEX('x', data) - 2) AS nombreProducto, 
        CAST(RIGHT(data, LEN(data) - CHARINDEX('x', data)) AS INT) AS cantidad
    FROM 
        dbo.SplitString(@cadenaProductos, ',');

    -- 3. Insertar en detalleVenta usando la tabla temporal y calculando el monto de cada producto
    INSERT INTO ddbba.detalleVenta (idVenta, idProducto, categoria, cantidad, precio_unitario, monto)
    SELECT 
        @idVenta,
        p.idProducto,
        p.clasificacion AS categoria,
        pd.cantidad,
        p.precio AS precio_unitario,
        pd.cantidad * p.precio AS monto
    FROM 
        @productoDetalle AS pd
    INNER JOIN 
        ddbba.productos AS p ON pd.nombreProducto = p.nombre;

    -- 4. Calcular el monto total de la venta
    SELECT @montoTotal = SUM(pd.cantidad * p.precio)
    FROM 
        @productoDetalle AS pd
    INNER JOIN 
        ddbba.productos AS p ON pd.nombreProducto = p.nombre;

    -- Actualizar el monto total en la tabla ventasRegistradas
    UPDATE ddbba.ventaRegistrada
    SET monto = @montoTotal
    WHERE idVenta = @idVenta;

    -- 5. Generar la factura para la venta
    DECLARE @tipoFactura VARCHAR(50) = 'A', @medioDePago VARCHAR(50) = 'Cash', @estado VARCHAR(20) = 'pendiente';
    DECLARE @montoConIVA DECIMAL(10, 2), @IVA DECIMAL(10, 2) = 0.21;

    SET @montoConIVA = @montoTotal * (1 + @IVA);

    INSERT INTO ddbba.factura (idVenta, tipoFactura, tipoDeCliente, fecha, hora, medioDePago, empleado, 
                               montoSinIVA, montoConIVA, IVA, estado)
    VALUES (@idVenta, @tipoFactura, @tipoCliente, @fecha, @hora, @medioDePago, @empleado, 
            @montoTotal, @montoConIVA, @montoTotal * @IVA, @estado);
END;
*/


/*
CREATE PROCEDURE RegistrarVentaConCadena2
    @ciudad VARCHAR(20),
    @tipoCliente VARCHAR(10),
    @genero VARCHAR(10),
    @empleado INT,
    @fecha DATE,
    @hora TIME,
    @cadenaProductos NVARCHAR(MAX) -- Cadena con productos y cantidades
AS
BEGIN
    DECLARE @idVenta INT, @montoTotal DECIMAL(10, 2) = 0;

    -- 1. Crear la venta con monto inicial en cero
    INSERT INTO ddbba.ventaRegistrada (ciudad, tipoCliente, genero, monto, fecha, hora, empleado)
    VALUES (@ciudad, @tipoCliente, @genero, 0, @fecha, @hora, @empleado);

    SET @idVenta = SCOPE_IDENTITY();

    -- 2. Dividir la cadena de productos en partes
    DECLARE @productoDetalle TABLE (nombreProducto NVARCHAR(100), cantidad INT);

    -- Insertar cada producto y su cantidad en la tabla temporal @productoDetalle
    INSERT INTO @productoDetalle (nombreProducto, cantidad)
    SELECT 
        RTRIM(LTRIM(SUBSTRING(data, 1, CHARINDEX('x', data) - 2))) AS nombreProducto,
        CAST(RTRIM(LTRIM(SUBSTRING(data, CHARINDEX('x', data) + 1, LEN(data)))) AS INT) AS cantidad
    FROM 
        dbo.SplitString(@cadenaProductos, ',');

    -- 3. Insertar en detalleVenta usando la tabla temporal y calculando el monto de cada producto
    INSERT INTO ddbba.detalleVenta (idVenta, idProducto, categoria, cantidad, precio_unitario, monto)
    SELECT 
        @idVenta,
        p.idProducto,
        p.clasificacion AS categoria,
        pd.cantidad,
        p.precio AS precio_unitario,
        pd.cantidad * p.precio AS monto
    FROM 
        @productoDetalle AS pd
    INNER JOIN 
        ddbba.productos AS p ON pd.nombreProducto = p.nombre;

    -- 4. Calcular el monto total de la venta
    SELECT @montoTotal = SUM(pd.cantidad * p.precio)
    FROM 
        @productoDetalle AS pd
    INNER JOIN 
        ddbba.productos AS p ON pd.nombreProducto = p.nombre;

    -- Actualizar el monto total en la tabla ventasRegistradas
    UPDATE ddbba.ventaRegistrada
    SET monto = @montoTotal
    WHERE idVenta = @idVenta;

    -- 5. Generar la factura para la venta
    DECLARE @tipoFactura VARCHAR(50) = 'A', @medioDePago VARCHAR(50) = 'Cash', @estado VARCHAR(20) = 'pendiente';
    DECLARE @montoConIVA DECIMAL(10, 2), @IVA DECIMAL(10, 2) = 0.21;

    SET @montoConIVA = @montoTotal * (1 + @IVA);

    INSERT INTO ddbba.factura (idVenta, tipoFactura, tipoDeCliente, fecha, hora, medioDePago, empleado, 
                               montoSinIVA, montoConIVA, IVA, estado)
    VALUES (@idVenta, @tipoFactura, @tipoCliente, @fecha, @hora, @medioDePago, @empleado, 
            @montoTotal, @montoConIVA, @montoTotal * @IVA, @estado);
END;
*/

CREATE PROCEDURE RegistrarVentaConCadena3
    @ciudad VARCHAR(20),
    @tipoCliente VARCHAR(10),
    @genero VARCHAR(10),
    @empleado INT,
    @fecha DATE,
    @hora TIME,
    @cadenaProductos NVARCHAR(MAX), -- Cadena con productos y cantidades
    @metodoPago VARCHAR(50) -- Método de pago para registrar el pago
AS
BEGIN
    DECLARE @idVenta INT, @montoTotal DECIMAL(10, 2) = 0;
    DECLARE @idFactura INT, @idPago INT;
    DECLARE @montoConIVA DECIMAL(10, 2), @IVA DECIMAL(10, 2) = 0.21;

    -- 1. Crear la venta con monto inicial en cero
    INSERT INTO ddbba.ventaRegistrada (ciudad, tipoCliente, genero, monto, fecha, hora, empleado)
    VALUES (@ciudad, @tipoCliente, @genero, 0, @fecha, @hora, @empleado);

    SET @idVenta = SCOPE_IDENTITY();

    -- 2. Dividir la cadena de productos en partes
    DECLARE @productoDetalle TABLE (nombreProducto NVARCHAR(100), cantidad INT);

    -- Insertar cada producto y su cantidad en la tabla temporal @productoDetalle
    INSERT INTO @productoDetalle (nombreProducto, cantidad)
    SELECT 
        RTRIM(LTRIM(SUBSTRING(data, 1, CHARINDEX('x', data) - 2))) AS nombreProducto,
        CAST(RTRIM(LTRIM(SUBSTRING(data, CHARINDEX('x', data) + 1, LEN(data)))) AS INT) AS cantidad
    FROM 
        dbo.SplitString(@cadenaProductos, ',');

    -- 3. Insertar en detalleVenta usando la tabla temporal y calculando el monto de cada producto
    INSERT INTO ddbba.detalleVenta (idVenta, idProducto, categoria, cantidad, precio_unitario, monto)
    SELECT 
        @idVenta,
        p.idProducto,
        p.clasificacion AS categoria,
        pd.cantidad,
        p.precio AS precio_unitario,
        pd.cantidad * p.precio AS monto
    FROM 
        @productoDetalle AS pd
    INNER JOIN 
        ddbba.productos AS p ON pd.nombreProducto = p.nombre;

    -- 4. Calcular el monto total de la venta
    SELECT @montoTotal = SUM(pd.cantidad * p.precio)
    FROM 
        @productoDetalle AS pd
    INNER JOIN 
        ddbba.productos AS p ON pd.nombreProducto = p.nombre;

    -- Actualizar el monto total en la tabla ventasRegistradas
    UPDATE ddbba.ventaRegistrada
    SET monto = @montoTotal
    WHERE idVenta = @idVenta;

    -- 5. Generar la factura para la venta
    DECLARE @tipoFactura VARCHAR(50) = 'A', @estadoFactura VARCHAR(20) = 'pendiente';
    SET @montoConIVA = @montoTotal * (1 + @IVA);

    INSERT INTO ddbba.factura (idVenta, tipoFactura, tipoDeCliente, fecha, hora, medioDePago, empleado, 
                               montoSinIVA, montoConIVA, IVA, estado)
    VALUES (@idVenta, @tipoFactura, @tipoCliente, @fecha, @hora, 'Cash', @empleado, 
            @montoTotal, @montoConIVA, @montoTotal * @IVA, @estadoFactura);

    SET @idFactura = SCOPE_IDENTITY();

    -- 6. Registrar el pago
    INSERT INTO ddbba.pago (idFactura, fecha, monto, metodoPago)
    VALUES (@idFactura, GETDATE(), @montoConIVA, @metodoPago);

    SET @idPago = SCOPE_IDENTITY();

    -- 7. Actualizar el estado de la factura a "pagada" y el identificadorDePago
    UPDATE ddbba.factura
    SET estado = 'pagada', identificadorDePago = @idPago
    WHERE idFactura = @idFactura;
END;
