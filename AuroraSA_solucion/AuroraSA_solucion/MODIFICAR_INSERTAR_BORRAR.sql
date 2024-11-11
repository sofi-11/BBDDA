

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

--ventasRegistradas

CREATE OR ALTER PROCEDURE ventas.VentasRegistradasInsertar
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
    -- Verifica si el IDFactura no existe en la tabla antes de realizar la inserción
    IF NOT EXISTS (SELECT 1 FROM ddbba.ventasRegistradas WHERE IDFactura = @IDFactura)
    BEGIN
        -- Inserta el nuevo registro
        INSERT INTO ddbba.ventasRegistradas(IDFactura, TipoFactura, Ciudad, TipoCliente, Genero, Producto, PrecioUnitario, Cantidad, Fecha, Hora, MedioPago, Empleado, IdentificadorPago)
        VALUES (@IDFactura, @TipoFactura, @Ciudad, @TipoCliente, @Genero, @Producto, @PrecioUnitario, @Cantidad, @Fecha, @Hora, @MedioPago, @Empleado, @IdentificadorPago);

        PRINT 'Venta registrada correctamente.';
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



-----------------------------------------------------------------------------------------------------MODIFICAR
GO
--productosImportados
 
CREATE OR ALTER PROCEDURE producto.ProductosImportadosModificar
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

CREATE OR ALTER PROCEDURE producto.ElectronicAccesoriesModificar
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

CREATE OR ALTER PROCEDURE producto.CatalogoModificar
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

CREATE OR ALTER PROCEDURE ventas.VentasRegistradasModificar
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



