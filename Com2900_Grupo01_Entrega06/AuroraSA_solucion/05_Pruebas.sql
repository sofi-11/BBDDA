
-- Bases de Datos Aplicadas
-- Fecha de entrega: 12 de Noviembre de 2024
-- Grupo 01
-- Comision 2900
-- 45739056 Sofia Florencia Gay
-- 44482420	Valentino Amato
-- 44396900 Joaquin Barcella
-- 44960383 Rafael David Nazareno Ruiz

--Lotes de prueba para todos los store procedures


--PRUEBAS INSERTAR,MODIFICAR,BORRAR Y IMPORTAR
 

--*************************************************--
--                                                 --
--   PRUEBAS DE INSERTAR, MODIFICAR, BORRAR Y      --
--                 IMPORTAR                        --
--                                                 --
--*************************************************--

USE Com2900G01


go

--PARA VER LOS CAMPOS DESCIFRADOS (primero ejecutar el procedure para importar los archivos)

OPEN SYMMETRIC KEY ClaveEncriptacionEmpleados DECRYPTION BY PASSWORD = 'empleado;2024,grupo1';
SELECT 
    Legajo, 
    Nombre, 
    Apellido, 
    CONVERT(NVARCHAR(500), DECRYPTBYKEY(DNI)) AS DNI,  
    CONVERT(NVARCHAR(500), DECRYPTBYKEY(Direccion)) AS Direccion ,  
    EmailPersonal, 
    EmailEmpresa,  
    CONVERT(NVARCHAR(500), DECRYPTBYKEY(CUIL)) AS CUIL,  
    Cargo, 
    Sucursal, 
    Turno
FROM ddbba.Empleados;

-- Cerrar la clave sim�trica
CLOSE SYMMETRIC KEY ClaveEncriptacionEmpleados;


select*from ddbba.Empleados


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

select * from ddbba.ventaRegistrada
exec importar.VentasRegistradasImportar @ruta='C:\Users\rafae\OneDrive\Escritorio\unlam\6 sexto cuatrimestre\BASES DE DATOS APLICADAS\TP\entrega 3\TP_3\BBDDA';





--REPORTES
EXEC reporte.TotalAcumuladoPorFechaYSucursal @fecha = '01-01-2019', @sucursal = 'San Justo';

EXEC reporte.ProductosMenosVendidosPorMes @mes = 1, @anio = 2019;

EXEC reporte.ProductosMasVendidosPorSemana @mes = 1, @anio = 2019;

EXEC reporte.VentasPorSucursalPorRangoFechas @fecha_inicio = '2019-01-01', @fecha_fin = '2024-11-12';

EXEC reporte.VentasPorRangoFechas @fecha_inicio = '2019-01-01', @fecha_fin = '2019-06-29';

EXEC reporte.FacturacionTrimestralPorTurnosPorMes @turno = 'Ma�ana', @trimestre = 1, @anio = 2019;

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

--clasificacion de productos
exec producto.ClasificacionProductoInsertar @LineaDeProducto= 'Almacen',@Producto= 'choclo_cremoso';
select *from ddbba.ClasificacionProductos

--sucursal
exec sucursal.SucursalInsertar @Ciudad= 'Ca�uelas',@Direccion='av siempreviva',@Horario='9 a 13', @Telefono='2226090901';
select*from ddbba.sucursal


--MODIFICAR

--producto funciona
exec producto.ProductoModificar @nombre='Acelgas',@precio=2000,@clasificacion='verdura';
--producto no existe
exec producto.ProductoModificar @nombre='homero',@precio=2000,@clasificacion='verdura';
select*from ddbba.productos

--empleado existe
exec empleados.EmpleadoActualizar
    @Legajo = 257030,@Nombre = 'Juan', @Apellido = 'P�rez',@DNI = '123456789',@Direccion = 'Calle Falsa 123',@EmailPersonal = 'juan.perez@gmail.com',
    @EmailEmpresa = 'juan.perez@empresa.com',@CUIL = '20-12345678-9',@Cargo = 'Cajero', @Sucursal = 'San Justo',@Turno = 'TM';
--empleado no existe
exec empleados.EmpleadoActualizar
    @Legajo = 57030,@Nombre = 'Juan', @Apellido = 'P�rez',@DNI = '23456789',@Direccion = 'Calle Falsa 123',@EmailPersonal = 'juan.perez@gmail.com',
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

---------------------------------------------------REGISTRAR UNA VENTA-----------------------------------------------------------
--procedure explicado en 01_SP_Insertar_Modificar_Borrado_Logico.sql



EXEC facturacion.RegistrarVentaConCodigos
    @ciudad = 'San Justo',
    @tipoCliente = 'Normal',
    @genero = 'Male',
    @empleado = 257020,
    @cadenaProductos = '5531 x2,5332 x1',
	@metodoPago = 'Cash',
	@puntoVenta = 'caja 1'

	select*from ddbba.ventaRegistrada
	select*from ddbba.detalleVenta
	select*from ddbba.factura
	select*from ddbba.pago

	truncate table ddbba.detalleVenta
	select*from ddbba.productos

	select*from ddbba.detalleVenta d join ddbba.productos p on d.idProducto=p.idProducto



--nota de credito
--procedure explicado en 01_SP_Insertar_Modificar_Borrado_Logico.sql

--en este caso el rol "cajero" no tiene permiso
execute as login= 'sofia'
exec nota.EmitirNotaCredito @detalleIDs =  '7'

revert
--el rol "supervisor" si
execute as login= 'rafael'
exec nota.EmitirNotaCredito @detalleIDs =  '7'
select*from ddbba.detalleVenta

revert
select * from ddbba.notaDeCredito