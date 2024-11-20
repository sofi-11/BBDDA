
--PRUEBAS INSERTAR,MODIFICAR,BORRAR Y IMPORTAR
 

--*************************************************--
--                                                 --
--   PRUEBAS DE INSERTAR, MODIFICAR, BORRAR Y      --
--                 IMPORTAR                        --
--                                                 --
--*************************************************--

USE Com2900G01

GO

exec dolar.cotizacionDolarInsertar @tipo= 'dolarBlue',@valor=1100

go

CREATE SYMMETRIC KEY ClaveEncriptacionEmpleados
WITH ALGORITHM = AES_128
ENCRYPTION BY PASSWORD = 'empleado;2024,grupo1';

go

OPEN SYMMETRIC KEY ClaveEncriptacionEmpleados DECRYPTION BY PASSWORD = 'empleado;2024,grupo1';
SELECT 
    Legajo, 
    Nombre, 
    Apellido, 
    CONVERT(NVARCHAR(500), DECRYPTBYKEY(DNI)) AS DNI,  -- Desencriptar DNI como NVARCHAR
    CONVERT(NVARCHAR(500), DECRYPTBYKEY(Direccion)) AS Direccion ,  -- Desencriptar Direccion como NVARCHAR
    EmailPersonal, 
    EmailEmpresa,  
    CONVERT(NVARCHAR(500), DECRYPTBYKEY(CUIL)) AS CUIL,  -- Desencriptar CUIL como NVARCHAR
    Cargo, 
    Sucursal, 
    Turno
FROM ddbba.Empleados;

-- Cerrar la clave simétrica
CLOSE SYMMETRIC KEY ClaveEncriptacionEmpleados;

OPEN SYMMETRIC KEY ClaveEncriptacionFactura DECRYPTION BY PASSWORD = 'factura;2024,grupo1';
-- Desencriptar los valores
SELECT 
    numeroFactura , 
    tipoFactura ,
    tipoDeCliente ,
    fecha ,
    hora ,
    medioDePago,
    empleado,
    CONVERT(NVARCHAR(500), DECRYPTBYKEY(identificadorDePago)) AS identificadorDePago ,
    montoTotal ,
    puntoDeVenta ,
	estado
FROM ddbba.factura;

-- Cerrar la clave simétrica
CLOSE SYMMETRIC KEY ClaveEncriptacionFactura;






--IMPORTAR ARCHIVOS

select * from ddbba.ClasificacionProductos
exec importar.ClasificacionProductosImportar @ruta='C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA';


select * from ddbba.productos
exec importar.ProductosImportadosImportar @ruta = 'C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA'
exec importar.CatalogoImportar @ruta='C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA';
exec importar.ElectronicAccessoriesImportar @ruta='C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA';
--
select * from ddbba.sucursal
exec importar.SucursalImportar @ruta= 'C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA';

select * from ddbba.Empleados
exec importar.EmpleadosImportar @ruta='C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA';

select * from  ddbba.factura
select * from ddbba.ventaRegistrada
select*from ddbba.detalleVenta
exec importar.VentasRegistradasImportar @ruta='C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA';





--REPORTES
EXEC reporte.TotalAcumuladoPorFechaYSucursal @fecha = '01-01-2019', @sucursal = 'San Justo';

EXEC reporte.ProductosMenosVendidosPorMes @mes = 1, @anio = 2019;

EXEC reporte.ProductosMasVendidosPorSemana @mes = 1, @anio = 2019;

EXEC reporte.VentasPorSucursalPorRangoFechas @fecha_inicio = '2019-01-01', @fecha_fin = '2024-11-12';

EXEC reporte.VentasPorRangoFechas @fecha_inicio = '2019-01-01', @fecha_fin = '2019-06-29';

EXEC reporte.FacturacionTrimestralPorTurnosPorMes @turno = 'Mañana', @trimestre = 1, @anio = 2019;

EXEC reporte.FacturacionMensualPorDiaDeSemana @mes = 1, @anio = 2019;


--INSERTAR

--producto funciona
exec producto.ProductoInsertar @nombre = 'zanahoria', @precio = 500, @clasificacion = 'verdura' ;
--producto no funciona 
exec producto.ProductoInsertar @nombre = 'zapallito', @precio = -2, @clasificacion = 'verdura' ;
select*from ddbba.productos

--empleado funciona
exec empleados.EmpleadoInsertar  @Nombre= 'valeria', @Apellido = 'valeria' , @DNI ='51014441', 
	@Direccion= 'avenida siempreviva', @EmailPersonal='milhouse@gmail.com',@EmailEmpresa='VanHouten@unlam.com',@CUIL='00-44960383-0',@Cargo='Cajero',
	@Sucursal= 'San Justo',@Turno='TM';
--empleado no funciona
exec empleados.EmpleadoInsertar  @Nombre= 'rafa', @Apellido = 'ruiz' , @DNI ='51014442221', 
	@Direccion= 'avenida siempreviva', @EmailPersonal='milhouse@gmail.com',@EmailEmpresa='VanHouten@unlam.com',@CUIL='00-44960383-0',@Cargo='Cajero',
	@Sucursal= 'San Justo',@Turno='TM';
select*from ddbba.Empleados

exec producto.ClasificacionProductoInsertar @LineaDeProducto= 'Almacen',@Producto= 'choclo_cremoso';
select *from ddbba.ClasificacionProductos

exec sucursal.SucursalInsertar @Ciudad= 'Cañuelas',@Direccion='av siempreviva',@Horario='9 a 13', @Telefono='2226090901';
select*from ddbba.sucursal


--MODIFICAR

--producto funciona
exec producto.ProductoModificar @nombre='Acelgas',@precio=2000,@clasificacion='verdura';
--producto no existe
exec producto.ProductoModificar @nombre='homero',@precio=2000,@clasificacion='verdura';
select*from ddbba.productos

--empleado existe
exec empleados.EmpleadoActualizar
    @Legajo = 257030,@Nombre = 'Juan', @Apellido = 'Pérez',@DNI = '123456789',@Direccion = 'Calle Falsa 123',@EmailPersonal = 'juan.perez@gmail.com',
    @EmailEmpresa = 'juan.perez@empresa.com',@CUIL = '20-12345678-9',@Cargo = 'Cajero', @Sucursal = 'San Justo',@Turno = 'TM';
--empleado no existe
exec empleados.EmpleadoActualizar
    @Legajo = 57030,@Nombre = 'Juan', @Apellido = 'Pérez',@DNI = '23456789',@Direccion = 'Calle Falsa 123',@EmailPersonal = 'juan.perez@gmail.com',
    @EmailEmpresa = 'juan.perez@empresa.com',@CUIL = '20-12345678-9',@Cargo = 'Cajero', @Sucursal = 'San Justo',@Turno = 'TM';
select*from ddbba.Empleados

--SUCURSAL EXISTE
exec sucursal.sucursalActualizar @Ciudad = 'San Justo',@Direccion = 'Av. Corrientes 1234',@Horario = 'Lunes a Viernes 8:00 - 17:00',
    @Telefono = '011-9876-5432';
--SUCURSAL NO EXISTE
exec sucursal.sucursalActualizar @Ciudad = 'BSAS',@Direccion = 'Av. Corrientes 1234',@Horario = 'Lunes a Viernes 8:00 - 17:00',
    @Telefono = '011-9876-5432';
select*from ddbba.sucursal

--BORRADO LOGICO

--empleado existe
exec borrar.EmpleadosBorradoLogico @Legajo= 257020;
--empleado no existe
exec borrar.EmpleadosBorradoLogico @Legajo= 12345;
select*from ddbba.Empleados

--clasificacionProducto existe
exec borrar.ClasificacionProductosBorradoLogico @Producto='chocolate';
--clasificacionProducto no existe
exec borrar.ClasificacionProductosBorradoLogico @Producto='homero';
select*from ddbba.ClasificacionProductos

--producto existe
exec borrar.ProductoBorradoLogico @Nombre= 'Sirope de regaliz';
--producto no existe
exec borrar.ProductoBorradoLogico @Nombre= 'bart';
select*from ddbba.productos

--sucursal existe
exec borrar.SucursalBorradoLogico @Ciudad = 'San Justo';
--sucursal no existe
exec borrar.SucursalBorradoLogico @Ciudad = 'BSAS';
select*from ddbba.sucursal


--FACTURACION


EXEC RegistrarVentaConCadena3
    @ciudad = 'San Justo',
    @tipoCliente = 'Normal',
    @genero = 'Male',
    @empleado = 257019,
    @cadenaProductos = 'Café de Malasia x2, Tallarines de Singapur x1',
	@metodoPago = 'Cash',
	@puntoVenta = 'caja 1'



	select*from ddbba.ventaRegistrada
	select*from ddbba.detalleVenta
	select*from ddbba.factura
	select*from ddbba.pago

	truncate table ddbba.detalleVenta
	select*from ddbba.productos

	select*from ddbba.detalleVenta d join ddbba.productos p on d.idProducto=p.idProducto


select*from ddbba.factura
select*from ddbba.detalleVenta


--detalle

EXEC facturacion.DetalleVentaEmitir @nroFactura = 12300123, @producto = 3,
@cantidad = 1;


--detalle venta factura existe
EXEC facturacion.DetalleVentaEmitir @nroFactura = 750678428, @producto = 'Regaliz',
@cantidad = 2;
--detalle venta factura no existe
EXEC facturacion.DetalleVentaEmitir @nroFactura = 750678, @producto = 'Regaliz',
@cantidad = 2;
select*from ddbba.detalleVenta

--nota de credito

execute as login= 'sofia'
exec nota.EmitirNotaCredito @idFactura = 750678428,@monto=10;

revert
execute as login= 'rafael'
exec nota.EmitirNotaCredito @idVenta = 2, @monto=10;
