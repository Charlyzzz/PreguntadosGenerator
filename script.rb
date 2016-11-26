require_relative './generator/generator'

filename = 'data.sql'

contenido = Categoria.all
contenido += Jugador.all
contenido += Pregunta.all
contenido += Competencia.all
contenido += Competencia.all.map(&:jugar).flatten

File.write(filename, contenido.map(&:to_sql).reduce(:+))
