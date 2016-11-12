class Competencia
  include ID

  class << self

    def all
      Array.new(500) { new }
    end

  end

  attr_reader :fecha

  def initialize(id)
    @id = id
    @competidores = Jugador.all.shuffle.take(cantidad_competidores)
    fecha_limite_inferior = @competidores
                                .map(&:fecha_inscripcion)
                                .max_by { |fecha| fecha }
    @pregunta = Pregunta.all
                    .select { |pregunta| pregunta.posterior_a(fecha_limite_inferior) }
                    .sample

    @fecha = @pregunta.rango_competencia.sample
  end

  def to_sql
    "INSERT INTO Parcial.Competiciones (Jugador1, Jugador2, Jugador3, Jugador4, Jugador5, Ganador)\n"\
    "VALUES (#{maybe_id(@competidores[0])}, #{maybe_id(@competidores[1])}, #{maybe_id(@competidores[2])}, #{maybe_id(@competidores[3])}, #{maybe_id(@competidores[4])}, 1)\n"\
    "GO\n\n"
  end

  def jugar
    resultados = [true] + Array.new(@competidores.size) { false }
    @competidores.zip(resultados).map do |competidor, acerto|
      respuesta = acerto ? @pregunta.respuesta_correcta : @pregunta.respuesta_incorrecta
      Log.new(competidor, respuesta, self)
    end
  end

  def id_pregunta
    @pregunta.id
  end

  private

  def cantidad_competidores
    [2, 3, 4, 5].sample
  end

  def maybe_id(jugador)
    return 'NULL' if jugador.nil?
    jugador.id
  end

end