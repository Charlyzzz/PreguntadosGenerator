require 'CSV'

class Jugador
  include ID

  class << self
    def all
      @personas ||= parse_csv
    end

    private

    def parse_csv
      personas = []
      CSV.foreach('generator/data/us-500.csv', headers: :first_row) do |row|
        personas << Jugador.new(row)
      end
      personas
    end
  end

  attr_reader :fecha_inscripcion

  def initialize(id, csv)
    @id = id
    @nombre = csv[0..1].join(' ')
    @fecha_inscripcion = Date.parse(csv[12])
    @nick = csv[10][/^\w+/]
  end

  def to_sql
    "INSERT INTO Parcial.Jugadores (Nombre, Nick, TotalJugados, TotalGanados, FechaAlta)\n"\
    "VALUES ('#{@nombre}', '#{@nick}', 0, 0, '#{@fecha_inscripcion.isodate}')\n"\
    "GO\n\n"
  end
end
