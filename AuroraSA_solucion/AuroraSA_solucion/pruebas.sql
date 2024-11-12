--PRUEBAS INSERTAR,MODIFICAR,BORRAR Y IMPORTAR
 

USE Com2900G01

GO

--IMPORTAR ARCHIVOS
select * from ddbba.productos
exec importar.productosImportadosImportar @ruta = 'C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA'

exec importar.CatalogoImportar @ruta='C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA';

exec importar.ElectronicAccessoriesImportar @ruta='C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA';
--
select * from ddbba.ClasificacionProductos
exec importar.ClasificacionProductosImportar @ruta='C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA';

select * from ddbba.Empleados
exec importar.EmpleadosImportar @ruta='C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA';
truncate table ddbba.empleados


select* from ddbba.factura
exec importar.VentasRegistradasImportar @ruta='C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA';

exec importar.SucursalImportar @ruta= 'C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA';


--REPORTES
EXEC reporte.TotalAcumuladoPorFechaYSucursal @fecha = '01-01-2019', @sucursal = 'San Justo';

EXEC reporte.ProductosMenosVendidosPorMes @mes = 1, @anio = 2019;

EXEC reporte.ProductosMasVendidosPorSemana @mes = 1, @anio = 2019;

EXEC reporte.VentasPorSucursalPorRangoFechas @fecha_inicio = '2019-01-01', @fecha_fin = '2019-06-29';

EXEC reporte.VentasPorRangoFechas @fecha_inicio = '2019-01-01', @fecha_fin = '2019-06-29';

EXEC reporte.FacturacionTrimestralPorTurnosPorMes @turno = 'Mañana', @trimestre = 1, @anio = 2019;

EXEC reporte.FacturacionMensualPorDiaDeSemana @mes = 1, @anio = 2019;

--INSERTAR

exec producto.productoInsertar @nombre = 'zanahoria', @precio = 500, @clasificacion = 'verdura'

exec empleados.empleadoInsertar @legajo= 1234, @Nombre= 'rafa', @apellido = 'ruiz' , @dni = 44114444, 
	@direccion= 'avenida siempreviva', @emailpersonal='milhouse@gmail.com',@emailempresa='VanHouten@unlam.com',@cuil=1212,@cargo='Cajero',
	@sucursal= 'San Justo',@turno='TM'

exec producto.ClasificacionProductoInsertar @LineadeProducto= 'Almacen',@producto= 'choclo_cremoso'

exec sucursal.sucursalInsertar @ciudad= 'Cañuelas',@direccion='av siempreviva',@horario='9 a 13', @telefono='2226090901'



--MODIFICAR

exec producto.productoModificar @nombre='Acelgas',@precio=2000,@clasificacion='verdura'
exec producto.productoModificar @nombre='homero',@precio=2000,@clasificacion='verdura'

exec empleados.EmpleadoActualizar
    @Legajo = 1234,@Nombre = 'Juan', @Apellido = 'Pérez',@DNI = '123456789',@Direccion = 'Calle Falsa 123',@EmailPersonal = 'juan.perez@gmail.com',
    @EmailEmpresa = 'juan.perez@empresa.com',@CUIL = '20-12345678-9',@Cargo = 'Cajero', @Sucursal = 'San Justo',@Turno = 'TM';

--SUCURSAL EXISTE
exec sucursal.sucursalActualizar @ciudad = 'San Justo',@Direccion = 'Av. Corrientes 1234',@Horario = 'Lunes a Viernes 8:00 - 17:00',
    @Telefono = '011-9876-5432';

--SUCURSAL NO EXISTE
exec sucursal.sucursalActualizar @ciudad = 'BSAS',@Direccion = 'Av. Corrientes 1234',@Horario = 'Lunes a Viernes 8:00 - 17:00',
    @Telefono = '011-9876-5432';


--BORRADO LOGICO

--empleado existe
exec borrar.EmpleadosBorradoLogico @legajo= 1234
--empleado no existe
exec borrar.EmpleadosBorradoLogico @legajo= 12345

--clasificacionProducto existe
exec borrar.ClasificacionProductosBorradoLogico @producto='chocolate'
--clasificacionProducto no existe
exec borrar.ClasificacionProductosBorradoLogico @producto='homero'

--producto existe
exec borrar.productoBorradoLogico @nombre= 'Sirope de regaliz'
--producto no existe
exec borrar.productoBorradoLogico @nombre= 'bart'

--sucursal existe
exec borrar.SucursalBorradoLogico @Ciudad = 'San Justo';
--sucursal no existe
exec borrar.SucursalBorradoLogico @Ciudad = 'BSAS';


--FACTURACION

--factura
EXEC facturacion.facturaEmitir @numeroFactura = 12300123,@tipoFactura = 'A',@tipoDeCliente = 'Member',
	@fecha = '2024-11-11', @hora = '15:30:00',@medioDePago = 'Credit Card', @empleado = '257024',
    @identificadorDePago = '123456',@montoTotal = 5000.00, @puntoDeVenta = '1', @estado = 'pagada';

--detalle venta factura existe
EXEC facturacion.DetalleVentaEmitir @nroFactura = 750678428, @producto = 'Regaliz',
@cantidad = 2;
--detalle venta factura no existe
EXEC facturacion.DetalleVentaEmitir @nroFactura = 750678, @producto = 'Regaliz',
@cantidad = 2;

--nota de credito

execute as login= 'sofia'
exec nota.EmitirNotaCredito @idFactura = 750678428,@monto=10

revert
execute as login= 'rafael'
exec nota.EmitirNotaCredito @idFactura = 226313081, @monto=10

select * from ddbba.empleados