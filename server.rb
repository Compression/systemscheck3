require 'sinatra'
require 'sinatra/reloader'
require 'pg'
set :port, 9000

get '/' do
  redirect '/recipes'
end

get '/recipes' do

  sql =
  'SELECT * FROM recipes ORDER BY name ASC;'

  @recipes = db_connection do |conn|
      conn.exec_params(sql).to_a
    end
  erb :index
end

get '/recipes/:id' do

  sql =
    'SELECT recipes.name AS name, recipes.instructions AS instructions, recipes.description AS description, ingredients.name AS ingredients
    FROM recipes
    JOIN ingredients
    ON ingredients.recipe_id = recipes.id
    WHERE recipes.id = $1;'


  @recipes_page = display_selected_data(sql, params[:id])
  erb :show


end

def display_selected_data (command, selector)
  data = db_connection do |conn|
    conn.exec_params(command, [selector])
  end
  data.to_a
end


def db_connection
  begin
    connection = PG.connect(dbname: 'recipes')

    yield(connection)
  ensure
    connection.close
  end
end
