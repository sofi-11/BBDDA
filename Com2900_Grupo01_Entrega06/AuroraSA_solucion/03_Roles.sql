
-- Bases de Datos Aplicadas
-- Fecha de entrega: 12 de Noviembre de 2024
-- Grupo 01
-- Comision 2900
-- 45739056 Sofia Florencia Gay
-- 44482420	Valentino Amato
-- 44396900 Joaquin Barcella
-- 44960383 Rafael David Nazareno Ruiz

--Creacion de logins, usuarios, y roles

USE master
go
-----------------------------------------------------------------------------CREACION DE LOGINS
-- Crear login 'rafael' si no existe
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'rafael')
BEGIN
    CREATE LOGIN rafael WITH PASSWORD = 'rafa', CHECK_POLICY = ON;
    PRINT 'Login "rafael" creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El login "rafael" ya existe.';
END

-- Crear login 'valentino' si no existe
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'valentino')
BEGIN
    CREATE LOGIN valentino WITH PASSWORD = 'valen', CHECK_POLICY = ON;
    PRINT 'Login "valentino" creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El login "valentino" ya existe.';
END

-- Crear login 'sofia' si no existe
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'sofia')
BEGIN
    CREATE LOGIN sofia WITH PASSWORD = 'sofi', CHECK_POLICY = ON;
    PRINT 'Login "sofia" creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El login "sofia" ya existe.';
END

-- Crear login 'joaquin' si no existe
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'joaquin')
BEGIN
    CREATE LOGIN joaquin WITH PASSWORD = 'joaco', CHECK_POLICY = ON;
    PRINT 'Login "joaquin" creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El login "joaquin" ya existe.';
END


go
USE Com2900G01
go
-----------------------------------------------------------------------------CREACION DE USUARIOS
USE COM2900G01; -- Cambia esto al nombre de tu base de datos si es diferente

-- Crear usuario 'rafael' si no existe
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'rafael')
BEGIN
    CREATE USER rafael FOR LOGIN rafael;
    PRINT 'Usuario "rafael" creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El usuario "rafael" ya existe.';
END

-- Crear usuario 'valentino' si no existe
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'valentino')
BEGIN
    CREATE USER valentino FOR LOGIN valentino;
    PRINT 'Usuario "valentino" creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El usuario "valentino" ya existe.';
END

-- Crear usuario 'sofia' si no existe
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'sofia')
BEGIN
    CREATE USER sofia FOR LOGIN sofia;
    PRINT 'Usuario "sofia" creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El usuario "sofia" ya existe.';
END

-- Crear usuario 'joaquin' si no existe
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'joaquin')
BEGIN
    CREATE USER joaquin FOR LOGIN joaquin;
    PRINT 'Usuario "joaquin" creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El usuario "joaquin" ya existe.';
END


go

-----------------------------------------------------------------------------CREACION DE ROLES

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE type = 'R' AND name = 'supervisor')
BEGIN
    CREATE ROLE supervisor;
    PRINT 'Rol "supervisor" creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El rol "supervisor" ya existe.';
END

go

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE type = 'R' AND name = 'repositor')
BEGIN
    CREATE ROLE repositor;
    PRINT 'Rol "repositor" creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El rol "repositor" ya existe.';
END

go

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE type = 'R' AND name = 'cajero')
BEGIN
    CREATE ROLE cajero;
    PRINT 'Rol "cajero" creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El rol "cajero" ya existe.';
END

go

ALTER ROLE supervisor ADD MEMBER rafael;
ALTER ROLE supervisor ADD MEMBER valentino;
ALTER ROLE repositor ADD MEMBER joaquin;
ALTER ROLE cajero ADD MEMBER sofia;

go

GRANT EXECUTE ON SCHEMA::nota TO supervisor;
GRANT EXECUTE ON SCHEMA::ddbba TO supervisor;
GRANT EXECUTE ON SCHEMA::importar TO supervisor;
GRANT EXECUTE ON SCHEMA::borrar TO supervisor;
GRANT EXECUTE ON SCHEMA::facturacion to supervisor
GRANT EXECUTE ON SCHEMA::dolar to supervisor
GRANT EXECUTE ON SCHEMA::empleados to supervisor
GRANT EXECUTE ON SCHEMA::producto to supervisor

go

GRANT EXECUTE ON SCHEMA::facturacion to cajero
DENY EXECUTE ON SCHEMA::nota TO cajero
DENY EXECUTE ON SCHEMA::ddbba TO cajero
DENY EXECUTE ON SCHEMA::importar TO cajero
DENY EXECUTE ON SCHEMA::borrar TO cajero
DENY EXECUTE ON SCHEMA::dolar to cajero
DENY EXECUTE ON SCHEMA::empleados to cajero
DENY EXECUTE ON SCHEMA::producto to cajero

go

GRANT EXECUTE ON SCHEMA::producto to repositor
DENY EXECUTE ON SCHEMA::nota TO repositor
DENY EXECUTE ON SCHEMA::ddbba TO repositor
DENY EXECUTE ON SCHEMA::importar TO repositor
DENY EXECUTE ON SCHEMA::borrar TO repositor
DENY EXECUTE ON SCHEMA::dolar to repositor
DENY EXECUTE ON SCHEMA::empleados to repositor
DENY EXECUTE ON SCHEMA::facturacion to repositor



