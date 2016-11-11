class Persona
  def initialize(csv)
    @nombre = csv[0..1].join(' ')
    @fecha_inscripcion = Date.parse(csv[12])
    @nick = csv[10][/^\w+/]
  end

  def to_sql_sp
    "EXEC Parcial.cargar_jugador '#{@nombre}', '#{@nick}', '#{@fecha_inscripcion.strftime('%F')}'"
  end
end
