class Pregunta
  include ID

  class << self
    def all
      @preguntas ||= randomizar_preguntas
    end

    private

    # Son 1000 preguntas, 200 vencidas, 700 vigentes y 100 sin activar
    def randomizar_preguntas
      preguntas = []

      200.times do |_|
        preguntas << Pregunta.new(:finalizada)
      end

      699.times do |_|
        preguntas << Pregunta.new()
      end

      p = Pregunta.new()
      p.fecha_inscripcion = Date.parse('2016-01-01')

      preguntas << p

      100.times do |_|
        preguntas << Pregunta.new(:pendiente)
      end

      preguntas.define_singleton_method(:validas) do
        self[0..899]
      end
      preguntas
    end
  end

  attr_reader :rango_competencia

  def initialize(id, status = 'vigente'.to_sym)
    @id = id
    @pregunta = "Como se llama la capital de Argentina#{@id}?"
    @respuestas = generar_respuestas
    fecha_segun_status(status)
    @categoria = (1..6).to_a.sample
  end

  def fecha_inscripcion=(fecha)
    @fecha_inicio = fecha
  end

  def posterior_a(fecha)
    return false if @fecha_inicio.nil?
    return false if @fecha_inicio < fecha
    return true if @fecha_fin.nil?
    fecha.between?(@fecha_inicio, @fecha_fin) unless @fecha_fin.nil?
  end

  def respuesta_correcta
    @respuestas.first
  end

  def respuesta_incorrecta
    @respuestas[1..-1].sample
  end

  def to_sql
    "INSERT INTO Parcial.Preguntas (Detalle, Categoria, FechaInicio, FechaFin)\n"\
    "VALUES ('#{@pregunta}', #{@categoria}, #{fecha_inicio_sql}, #{fecha_fin_sql})\n"\
    "GO\n\n" + @respuestas.map(&:to_sql).reduce(:+)
  end

  def fecha_inicio_sql
    case @fecha_inicio
      when nil
        return 'NULL'
      else
        return "'#{@fecha_inicio}'"
    end
  end

  def fecha_fin_sql
    case @fecha_fin
      when nil
        return 'NULL'
      else
        return "'#{@fecha_fin}'"
    end
  end

  private

  def generar_respuestas
    %w(a b c d).zip(%w( BsAs China Seul Mayonesa)).map do |letra, detalle|
      Respuesta.new(@id, letra, detalle)
    end
  end

  def fecha_segun_status(status)
    fecha_inicio = Date.parse('1990-01-01')
    fecha_fin = Date.parse('2015-12-31')
    case status
      when :vigente
        @fecha_inicio = (fecha_inicio .. fecha_fin).to_a.sample
        @rango_competencia = (@fecha_inicio .. fecha_fin).to_a
      when :finalizada
        @fecha_inicio = (fecha_inicio ... fecha_fin).to_a.sample
        @fecha_fin = (@fecha_inicio .. fecha_fin).to_a.sample
        @rango_competencia = (@fecha_inicio .. @fecha_fin).to_a
      when :pendiente
      else
        raise 'Status de pregunta invalido'
    end
  end
end
