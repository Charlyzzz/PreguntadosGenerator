require_relative './generator/generator'

filename = 'data.sql'

contenido = Categoria.all
contenido += Jugador.all
contenido += Pregunta.all

competencias = Competencia.all

contenido += competencias


File.delete(filename)
File.write(filename, contenido.map(&:to_sql).reduce(:+))
