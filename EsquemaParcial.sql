USE ParcialPreguntados
GO

SET DATEFORMAT dmy
GO

--Crear el esquema
BEGIN
	IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Parcial')
	BEGIN
		EXEC ('CREATE SCHEMA Parcial AUTHORIZATION dbo')
	END
END
GO

--Eliminar tablas
BEGIN
	IF OBJECT_ID('Parcial.Logs') IS NOT NULL
	DROP TABLE Parcial.Logs

	IF OBJECT_ID('Parcial.Competiciones') IS NOT NULL
	DROP TABLE Parcial.Competiciones

	IF OBJECT_ID('Parcial.Jugadores') IS NOT NULL
	DROP TABLE Parcial.Jugadores

	IF OBJECT_ID('Parcial.Respuestas') IS NOT NULL
	DROP TABLE Parcial.Respuestas

	IF OBJECT_ID('Parcial.Preguntas') IS NOT NULL
	DROP TABLE Parcial.Preguntas

	IF OBJECT_ID('Parcial.Categorias') IS NOT NULL
	DROP TABLE Parcial.Categorias

END
GO

--Crear tablas
BEGIN
	CREATE TABLE Parcial.Jugadores
	(
		Id NUMERIC(18,0) IDENTITY(1,1),
		Nombre NVARCHAR(45),	
		Nick NVARCHAR(45),
		TotalJugados NUMERIC(18,0),
		TotalGanados NUMERIC (18,0),
		FechaAlta DATE
		PRIMARY KEY (Id),
		CONSTRAINT ct_Unique_Nombre UNIQUE(Nombre)
	)

	CREATE TABLE Parcial.Categorias
	(
		Id NUMERIC (18,0) IDENTITY (1,1),
		Detalle NVARCHAR(45)
		PRIMARY KEY (Id),
	)	
	
	CREATE TABLE Parcial.Preguntas
	(
		Id NUMERIC (18,0) IDENTITY (1,1),
		Detalle NVARCHAR(45),
		Categoria NUMERIC (18,0),
		FechaInicio DATE,
		FechaFin DATE,
		PRIMARY KEY (Id),
		FOREIGN KEY (Categoria) REFERENCES Parcial.Categorias(Id),
	)
	
	CREATE TABLE Parcial.Respuestas
	(
		Id NUMERIC (18,0) IDENTITY (1,1),
		Pregunta NUMERIC (18,0),
		Letra NVARCHAR(1),
		Detalle NVARCHAR(45),
		EsCorrecta NVARCHAR(1),
		Porcentaje NUMERIC (3,0),
		PRIMARY KEY (Id),
		FOREIGN KEY (Pregunta) REFERENCES Parcial.Preguntas(Id),
	)
	
	CREATE TABLE Parcial.Competiciones
	(
		Id NUMERIC (18,0) IDENTITY (1,1),
		Jugador1 NUMERIC(18,0),
		Jugador2 NUMERIC(18,0),
		Jugador3 NUMERIC(18,0),
		Jugador4 NUMERIC(18,0),
		Jugador5 NUMERIC(18,0),
		Ganador NUMERIC (18,0),
		PRIMARY KEY (Id),
		FOREIGN KEY (Jugador1) REFERENCES Parcial.Jugadores(Id),
		FOREIGN KEY (Jugador2) REFERENCES Parcial.Jugadores(Id),
		FOREIGN KEY (Jugador3) REFERENCES Parcial.Jugadores(Id),
		FOREIGN KEY (Jugador4) REFERENCES Parcial.Jugadores(Id),
		FOREIGN KEY (Jugador5) REFERENCES Parcial.Jugadores(Id),
	)
	
	CREATE TABLE Parcial.Logs
	(
		Id NUMERIC (18,0) IDENTITY (1,1),
		Pregunta NUMERIC (18,0),
		Respuesta NUMERIC (18,0),
		Jugador NUMERIC (18,0),
		Competicion NUMERIC (18,0),
		FechaHora DATE
		PRIMARY KEY (Id),
		FOREIGN KEY (Pregunta) REFERENCES Parcial.Preguntas(Id),
		FOREIGN KEY (Respuesta) REFERENCES Parcial.Respuestas(Id),
		FOREIGN KEY (Jugador) REFERENCES Parcial.Jugadores(Id),
		FOREIGN KEY (Competicion) REFERENCES Parcial.Competiciones(Id),
	)
END
GO

--Crear stored procedures

IF OBJECT_ID('Parcial.eliminar_constraints') IS NOT NULL
DROP PROCEDURE Parcial.eliminar_constraints
GO

CREATE PROCEDURE Parcial.eliminar_constraints
AS 
BEGIN
	IF OBJECT_ID('Parcial.Jugadores') IS NOT NULL
		ALTER TABLE Parcial.Jugadores NOCHECK CONSTRAINT ALL		

	IF OBJECT_ID('Parcial.Competiciones') IS NOT NULL
		ALTER TABLE Parcial.Competiciones NOCHECK CONSTRAINT ALL

	IF OBJECT_ID('Parcial.Logs') IS NOT NULL
		ALTER TABLE Parcial.Logs NOCHECK CONSTRAINT ALL

	IF OBJECT_ID('Parcial.Preguntas') IS NOT NULL
		ALTER TABLE Parcial.Preguntas NOCHECK CONSTRAINT ALL

	IF OBJECT_ID('Parcial.Respuestas') IS NOT NULL
		ALTER TABLE Parcial.Respuestas NOCHECK CONSTRAINT ALL

	IF OBJECT_ID('Parcial.Categorias') IS NOT NULL
		ALTER TABLE Parcial.Categorias NOCHECK CONSTRAINT ALL	
END
GO

IF OBJECT_ID('Parcial.cargar_jugador') IS NOT NULL
DROP PROCEDURE Parcial.cargar_jugador
GO

CREATE PROCEDURE Parcial.cargar_jugador
	@Nombre NVARCHAR(45),
	@Nick NVARCHAR(45),	
	@FechaAlta DATE
	
AS BEGIN
	INSERT INTO Parcial.Jugadores
		(Nombre, Nick, TotalGanados, TotalJugados, FechaAlta)
	VALUES
		(@Nombre, @Nick,0,0, @FechaAlta)
END
GO

IF OBJECT_ID('Parcial.cargar_categoria') IS NOT NULL
DROP PROCEDURE Parcial.cargar_categoria
GO

CREATE PROCEDURE Parcial.cargar_categoria
	@Detalle NVARCHAR(100)

AS BEGIN
	INSERT INTO Parcial.Categorias
		(Detalle)
	VALUES
		(@Detalle)
END
GO

IF OBJECT_ID('Parcial.actualizar_jugador_partidos_jugados') IS NOT NULL
DROP PROCEDURE Parcial.actualizar_jugador_partidos_jugados
GO

CREATE PROCEDURE Parcial.actualizar_jugador_partidos_jugados
	@IdJugador NUMERIC(18,0)
AS
BEGIN
	IF @IdJugador IS NOT NULL
	BEGIN
		UPDATE Jugadores
		SET TotalJugados = TotalJugados + 1
		WHERE Jugadores.Id = @IdJugador
	END
END
GO

IF OBJECT_ID('Parcial.actualizar_jugador_partidos_ganados') IS NOT NULL
DROP PROCEDURE Parcial.actualizar_jugador_partidos_ganados
GO

CREATE PROCEDURE Parcial.actualizar_jugador_partidos_ganados
	@IdJugador NUMERIC(18,0)
AS
BEGIN
	IF @IdJugador IS NOT NULL 
	BEGIN
		UPDATE Jugadores
		SET TotalGanados = TotalGanados + 1
		WHERE Jugadores.Id = @IdJugador
	END
END
GO

--Triggers

IF OBJECT_ID('Parcial.Trigger_ActualizarJugadasYGanadas') IS NOT NULL
DROP TRIGGER Parcial.Trigger_ActualizarJugadasYGanadas
GO

CREATE TRIGGER Parcial.Trigger_ActualizarJugadasYGanadas ON Parcial.Competiciones
AFTER INSERT  
AS  
BEGIN
	DECLARE @Jugador NUMERIC(18,0)

	SET @Jugador = (SELECT Jugador1 FROM inserted)
	EXECUTE	Parcial.actualizar_jugador_partidos_jugados @Jugador

	SET @Jugador = (SELECT Jugador2 FROM inserted)
	EXECUTE	Parcial.actualizar_jugador_partidos_jugados @Jugador

	SET @Jugador = (SELECT Jugador3 FROM inserted)
	EXECUTE	Parcial.actualizar_jugador_partidos_jugados @Jugador

	SET @Jugador = (SELECT Jugador4 FROM inserted)
	EXECUTE	Parcial.actualizar_jugador_partidos_jugados @Jugador

	SET @Jugador = (SELECT Jugador5 FROM inserted)
	EXECUTE	Parcial.actualizar_jugador_partidos_jugados @Jugador


	-- Ganados

	DECLARE @Ganador NUMERIC(18,0)
	DECLARE @Numero NUMERIC(1,0)

	SET @Numero = (SELECT ganador FROM inserted)

	SET @Ganador = (SELECT CASE @Numero 
								WHEN 1 THEN (SELECT Jugador1 FROM inserted) 			
								WHEN 2 THEN (SELECT Jugador2 FROM inserted)
								WHEN 3 THEN (SELECT Jugador3 FROM inserted)
								WHEN 4 THEN (SELECT Jugador4 FROM inserted)
								WHEN 5 THEN (SELECT Jugador5 FROM inserted)
							END 
					FROM inserted )	
			
	EXECUTE	Parcial.actualizar_jugador_partidos_ganados @Ganador
END 
GO  

IF OBJECT_ID('Parcial.Trigger_ActualizarPorcentajeRespuestas') IS NOT NULL
DROP TRIGGER Parcial.Trigger_ActualizarPorcentajeRespuestas
GO

CREATE TRIGGER Parcial.Trigger_ActualizarPorcentajeRespuestas ON Parcial.Logs
AFTER INSERT  
AS  
BEGIN
	DECLARE @id_pregunta NUMERIC(18,0)
	SET @id_pregunta = (SELECT Pregunta FROM Inserted)
	
	
	-- Lo tuve que hacer en dos updates porque se cagaba la división, wtf!
	
	UPDATE Parcial.Respuestas
	SET Porcentaje = (SELECT COUNT(*) FROM Parcial.Logs WHERE Logs.Respuesta = Respuestas.Id )
	WHERE Pregunta = @id_pregunta
	
	UPDATE Parcial.Respuestas
	SET Porcentaje = (Porcentaje / (SELECT COUNT(*) FROM Parcial.Logs WHERE Logs.Pregunta = @id_pregunta))*100
	WHERE Pregunta = @id_pregunta
	
END 
GO  