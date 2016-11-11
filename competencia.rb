class Competencia
  def initialize(personas)
    @competidores = personas.shuffle.take(5)
  end

  def ganador
    @competidores.first
  end

  def perdedores
    @competidores[1..-1]
  end
end