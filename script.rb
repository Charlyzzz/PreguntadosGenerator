require_relative './persona'


def personas_del_csv
  personas = []
  CSV.foreach('us-500.csv', headers: :first_row) do |row|
    personas << Persona.new(row)
  end
  personas
end

def cantidad_competidores
  [2,3,4,5].sample
end

def nueva_competencia(personas)
  Competencia.new(personas)
end



