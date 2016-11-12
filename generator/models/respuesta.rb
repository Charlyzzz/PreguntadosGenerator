class Respuesta
  include ID

  def initialize(id, id_pregunta, letra, detalle)
    @id = id
    @pregunta = id_pregunta
    @letra = letra
    @detalle = detalle
    @correcta = letra_correcta(letra)
  end

  def to_sql
    "INSERT INTO Parcial.Respuestas (Pregunta, Letra, Detalle, EsCorrecta)\n"\
    "VALUES (#{@pregunta}, '#{@letra}', '#{@detalle}', '#{@correcta}')\n"\
    "GO\n\n"
  end

  private

  def letra_correcta(letra)
    case letra
      when 'a' then
        'S'
      else
        'N'
    end
  end
end