USE Com2900G01

GO
	CREATE SYMMETRIC KEY ClaveEncriptacionEmpleados
	WITH ALGORITHM = AES_128
	ENCRYPTION BY PASSWORD = 'empleado;2024,grupo1';


go

OPEN SYMMETRIC KEY ClaveEncriptacionEmpleados DECRYPTION BY PASSWORD = 'empleado;2024,grupo1';
-- Desencriptar los valores
SELECT 
    Legajo, 
    Nombre, 
    Apellido, 
    CONVERT(NVARCHAR(500), DECRYPTBYKEY(DNI)) AS DNI,  -- Desencriptar DNI como NVARCHAR
    CONVERT(NVARCHAR(500), DECRYPTBYKEY(Direccion)) AS Direccion,  -- Desencriptar Direccion como NVARCHAR
    EmailPersonal, 
    EmailEmpresa,  
    CUIL,  -- Desencriptar CUIL como NVARCHAR
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