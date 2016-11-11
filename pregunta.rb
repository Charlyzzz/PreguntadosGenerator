class Pregunta

  class << self
    def new
      super(siguiente)
    end

    def siguiente
      @numero ||= 0
      @numero += 1
    end
  end

  def initialize(numero)
    @pregunta = "Como se llama la capital de Argentina#{numero}?"
    @respuestas = ['Buenos aires', 'Corea', 'China', 'Escocia']
  end

  def correcta
    @respuestas.first
  end

  def incorrecta
    @respuestas[1..-1].sample
  end
end
