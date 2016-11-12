class Categoria
  include ID

  class << self

    def all
      %w( Peliculas Deportes Programacion Trompas Autos Politica).map do |detalle|
        new(detalle)
      end
    end

  end

  def initialize(id, nombre)
    @id = id
    @nombre = nombre
  end

  def to_sql
    "INSERT INTO Parcial.Categorias (Detalle)\n"\
    "VALUES ('#{@nombre}')\n"\
    "GO\n\n"
  end
end