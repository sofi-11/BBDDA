
-- Bases de Datos Aplicadas
-- Fecha de entrega: 12 de Noviembre de 2024
-- Grupo 01
-- Comision 2900
-- 45739056 Sofia Florencia Gay
-- 44482420	Valentino Amato
-- 44396900 Joaquin Barcella
-- 44960383 Rafael David Nazareno Ruiz

--Store procedures de insercion, modificacion, borrado logico, emitir venta y emitir nota de credito
--En este script se importan cifrados los datos de empledados.

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
@tipo varchar(50),
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
@tipo varchar(50),
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

exec dolar.cotizacionDolarInsertar @tipo= 'dolarOficial',@valor=950

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




--EMITIR NOTA DE CREDITO


/*
El procedimiento emitirNotaCredito registra una nota de crédito para productos específicos de una venta. 
Recibe una lista de IDs de detalle de venta separados por comas, valida que todos los detalles pertenezcan a la misma venta
y que la factura asociada a esa venta esté pagada. Luego, por cada detalle indicado, extrae el producto, la cantidad y el
monto desde la tabla detalleVenta y los inserta en la tabla notaDeCredito. Finalmente, registra la nota de crédito con la 
fecha de emisión actual y los datos correspondientes, permitiendo gestionar devoluciones parciales de una venta específica.
*/

CREATE OR ALTER PROCEDURE nota.EmitirNotaCredito
    @detalleIDs NVARCHAR(MAX) -- Cadena de IDs de detalleVenta separados por comas
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Validar que todos los IDs de detalle pertenezcan a la misma venta y que la factura esté pagada
    DECLARE @idVenta INT, @estadoFactura VARCHAR(20);
    SELECT @idVenta = idVenta
    FROM ddbba.detalleVenta
    WHERE detalleID in (
        SELECT *
        FROM dbo.SplitString(@detalleIDs, ',')
    );

    -- Validar que todos los detalles pertenezcan al mismo idVenta
    IF EXISTS (
        SELECT 1
        FROM ddbba.detalleVenta
        WHERE detalleID IN (SELECT * FROM dbo.SplitString(@detalleIDs, ','))
        AND idVenta <> @idVenta
    )
    BEGIN
        print('Los detalles de venta no pertenecen a la misma venta.');
    END;

    -- Validar que la factura asociada esté en estado "pagada"
    SELECT @estadoFactura = estado
    FROM ddbba.factura
    WHERE idVenta = @idVenta;

    IF @estadoFactura <> 'pagada'
    BEGIN
        print('La factura asociada no está en estado "pagada".');
    END;
	ELSE
	BEGIN

    -- 2. Obtener la fecha de emisión de la nota de crédito
    DECLARE @fechaEmision DATE;
    SET @fechaEmision = CONVERT(DATE, GETDATE());

    -- 3. Registrar los productos en la tabla notaDeCredito
    INSERT INTO ddbba.notaDeCredito (idVenta, fechaEmision, producto, cantidad, monto)
    SELECT 
        dv.idVenta,
        @fechaEmision,
        p.nombre AS producto,
        dv.cantidad,
        dv.cantidad * dv.precio_unitario AS monto
    FROM 
        ddbba.detalleVenta AS dv
    INNER JOIN 
        ddbba.productos AS p ON dv.idProducto = p.idProducto
    WHERE 
        dv.detalleID IN (SELECT * FROM dbo.SplitString(@detalleIDs, ','));

    -- Mensaje de éxito
    PRINT 'Nota de crédito emitida con éxito.';
	END
END;

go


------------------------VENTA

--funcion para cortar cadenas

    CREATE OR ALTER FUNCTION SplitString (@string NVARCHAR(MAX), @delimiter CHAR(1))
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
	END



go


--PROCEDURE PARA REGISTRAR UNA VENTA

/*RECIBE UNA CADENA 'producto1 x2,producto2 x3' Y PROCESA VENTA, DETALLES, FACTURA Y PAGO */

/*Primero, se crea un registro de la venta con un monto inicial de cero en la tabla ventaRegistrada, 
y luego se procesan los productos vendidos, que se reciben como una cadena de texto que incluye nombres de productos y 
cantidades. Esta cadena se divide y se inserta en una tabla temporal, desde la cual se obtiene el precio y monto de cada
producto para luego almacenarlos en la tabla detalleVenta. El monto total de la venta se calcula y se actualiza en la tabla 
ventaRegistrada. Luego genera una factura para la venta, calculando el monto con y sin IVA, 
almacenando estos valores en la tabla factura. También se registra el pago correspondiente en la tabla pago y, finalmente, 
se actualiza el estado de la factura a "pagada" con la información del pago. */


CREATE OR ALTER PROCEDURE facturacion.RegistrarVentaConCodigos
    @ciudad VARCHAR(20),
    @tipoCliente VARCHAR(10),
    @genero VARCHAR(10),
    @empleado INT,
    @cadenaProductos NVARCHAR(MAX), -- Cadena con códigos de productos y cantidades
    @metodoPago VARCHAR(50), -- Método de pago para registrar el pago
    @puntoVenta VARCHAR(50)
AS
BEGIN
    BEGIN TRY
        -- Declarar variables necesarias
        DECLARE @fecha DATE;
        SET @fecha = CONVERT(DATE, GETDATE());
        DECLARE @hora TIME;
        SET @hora = CONVERT(TIME, GETDATE());
        DECLARE @idVenta INT, @montoTotal DECIMAL(10, 2) = 0;
        DECLARE @idFactura INT, @idPago INT;
        DECLARE @montoConIVA DECIMAL(10, 2), @IVA DECIMAL(10, 2) = 0.21;

        -- Dividir la cadena de productos en partes y cargarla en una tabla temporal
        DECLARE @productoDetalle TABLE (codigoProducto INT, cantidad INT);

        INSERT INTO @productoDetalle (codigoProducto, cantidad)
        SELECT 
            CAST(RTRIM(LTRIM(SUBSTRING(data, 1, CHARINDEX('x', data) - 2))) AS INT) AS codigoProducto,
            CAST(RTRIM(LTRIM(SUBSTRING(data, CHARINDEX('x', data) + 1, LEN(data)))) AS INT) AS cantidad
        FROM 
            dbo.SplitString(@cadenaProductos, ',');

        -- Validar que todos los códigos de producto existen en la tabla `productos`
        IF EXISTS (
            SELECT 1
            FROM @productoDetalle AS pd
            LEFT JOIN ddbba.productos AS p ON pd.codigoProducto = p.idProducto
            WHERE p.idProducto IS NULL
        )
        BEGIN
            THROW 50001, 'Error: Uno o más códigos de producto no existen.', 1;
        END;

        -- Crear la venta con monto inicial en cero
        INSERT INTO ddbba.ventaRegistrada (ciudad, tipoCliente, genero, monto, fecha, hora, empleado)
        VALUES (@ciudad, @tipoCliente, @genero, 0, @fecha, @hora, @empleado);

        SET @idVenta = SCOPE_IDENTITY();

        -- Insertar en `detalleVenta` usando la tabla temporal
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
            ddbba.productos AS p ON pd.codigoProducto = p.idProducto;

        -- Calcular el monto total de la venta
        SELECT @montoTotal = SUM(pd.cantidad * p.precio)
        FROM 
            @productoDetalle AS pd
        INNER JOIN 
            ddbba.productos AS p ON pd.codigoProducto = p.idProducto;

        -- Actualizar el monto total en la tabla ventasRegistradas
        UPDATE ddbba.ventaRegistrada
        SET monto = @montoTotal
        WHERE idVenta = @idVenta;

        -- Generar la factura para la venta
        DECLARE @tipoFactura VARCHAR(50) = 'A', @estadoFactura VARCHAR(20) = 'pendiente';
        SET @montoConIVA = @montoTotal * (1 + @IVA);

        INSERT INTO ddbba.factura (idVenta, tipoFactura, tipoDeCliente, fecha, hora, medioDePago, empleado, 
                                   montoSinIVA, montoConIVA, IVA, estado, puntoDeVenta, cuit)
        VALUES (@idVenta, @tipoFactura, @tipoCliente, @fecha, @hora, 'Cash', @empleado, 
                @montoTotal, @montoConIVA, @montoTotal * @IVA, @estadoFactura, @puntoVenta, '20-22222222-3');

        SET @idFactura = SCOPE_IDENTITY();

        -- Registrar el pago
        INSERT INTO ddbba.pago (idFactura, fecha, monto, metodoPago)
        VALUES (@idFactura, GETDATE(), @montoConIVA, @metodoPago);

        SET @idPago = SCOPE_IDENTITY();

        -- Actualizar el estado de la factura a "pagada"
        UPDATE ddbba.factura
        SET estado = 'pagada'
        WHERE idFactura = @idFactura;
    END TRY
    BEGIN CATCH
        -- Manejo del error: re-lanzar el mensaje capturado
        THROW;
    END CATCH
END;
