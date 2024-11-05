

use COM2900G01

go
-----------------------------------------------------------------------------INSERTAR

--productosImportados

CREATE OR ALTER PROCEDURE insertar.ProductosImportadosInsertar
    @id INT,
    @NombreProducto VARCHAR(100),
    @Proveedor NVARCHAR(100),
    @Categoria VARCHAR(100),
    @CantidadPorUnidad VARCHAR(50),
    @PrecioUnidad DECIMAL(10,2)
AS
BEGIN
    -- Verifica si el ID no existe en la tabla antes de realizar la inserción
    IF NOT EXISTS (SELECT 1 FROM ddbba.productosImportados WHERE IdProducto = @id)
    BEGIN
        -- Inserta el nuevo registro
        INSERT INTO ddbba.productosImportados(IdProducto, NombreProducto, Proveedor, Categoria, CantidadPorUnidad, PrecioUnidad)
        VALUES (@id, @NombreProducto, @Proveedor, @Categoria, @CantidadPorUnidad, @PrecioUnidad);

        PRINT 'Producto insertado correctamente.';
    END
    ELSE
    BEGIN
        -- Muestra un mensaje si el ID ya existe
        PRINT 'El ID especificado ya existe. No se realizó ninguna inserción.';
    END
END;




GO

--electronicAccesories


CREATE OR ALTER PROCEDURE insertar.ElectronicAccesoriesInsertar
    @Product VARCHAR(100), 
    @PrecioUnitarioUSD DECIMAL(10,2) 
AS
BEGIN
    -- Verifica si el producto no existe en la tabla antes de realizar la inserción
    IF NOT EXISTS (SELECT 1 FROM ddbba.electronicAccesories WHERE Product = @Product)
    BEGIN
        -- Inserta el nuevo registro
        INSERT INTO ddbba.electronicAccesories(Product, PrecioUnitarioUSD)
        VALUES (@Product, @PrecioUnitarioUSD);

        PRINT 'Producto insertado correctamente.';
    END
    ELSE
    BEGIN
        -- Muestra un mensaje si el producto ya existe
        PRINT 'El producto especificado ya existe. No se realizó ninguna inserción.';
    END
END;





GO

--catalogo

CREATE OR ALTER PROCEDURE insertar.CatalogoInsertar
    @id INT, -- Identificación, clave primaria
    @category VARCHAR(100), -- Categoría del producto
    @nombre VARCHAR(100), -- Nombre del producto
    @price DECIMAL(10, 2), -- Precio del producto, debe ser mayor a 0
    @reference_price DECIMAL(10, 2), -- Precio de referencia
    @reference_unit VARCHAR(50), -- Unidad de referencia
    @fecha DATE -- Fecha
AS
BEGIN
    -- Verifica si el ID no existe en la tabla y si el precio es mayor a 0
    IF NOT EXISTS (SELECT 1 FROM ddbba.catalogo WHERE id = @id) AND @price > 0
    BEGIN
        -- Inserta el nuevo registro
        INSERT INTO ddbba.catalogo(id, category, nombre, price, reference_price, reference_unit, fecha)
        VALUES (@id, @category, @nombre, @price, @reference_price, @reference_unit, @fecha);

        PRINT 'Producto insertado correctamente.';
    END
END;


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
    UPDATE ddbb.Empleados
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