class Log
  include ID

  def initialize(id, jugador, respuesta, competicion)
    @id = id
    @id_pregunta = competicion.id_pregunta
    @id_respuesta = respuesta.id
    @id_jugador = jugador.id
    @id_competicion = competicion.id
    @fecha = competicion.fecha
  end

  def to_sql
    "INSERT INTO Parcial.Logs (Pregunta, Respuesta, Jugador, Competicion, FechaHora)\n"\
    "VALUES (#{@id_pregunta}, #{@id_respuesta}, #{@id_jugador}, #{@id_competicion}, '#{@fecha.isodate}')\n"\
    "GO\n\n"
  end
end