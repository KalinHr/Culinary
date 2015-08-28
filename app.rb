require 'sinatra'
require 'sinatra/reloader' if development?
require 'slim'
require 'sass'
require './models/models.rb'


get('/styles.css'){ scss :styles }

enable :sessions

set :sessions => true

['/', '/index', '/login'].each do |path|
  get path do
    if session[:username].nil?
      slim :login
  else 
    redirect '/search'
  end
  end
end

['/','/index','/login'].each do |path|
  post path do  
    if session[:username].nil?
      slim :login
  else
    redirect '/search'
  end
  end
end

get '/login' do
  slim :login
end

post '/log' do
  begin
    user = Account.first(name: params[:username], password: params[:password])
    if not user.nil?
      session[:username], session[:user_id] = user.name, user.id
      redirect "/search"
    else
      redirect "/login"
    end
  end
end

get '/register' do
  slim :register
end

post '/createUser' do
  if params[:username] != "" && params[:password] != "" && params[:email] != ""
    begin
      query_result_username = Account.first(name: params[:username])
      query_result_email = Account.first(email: params[:email])
      if not query_result_username.nil?
        "Username already taken or email not accurate! <a href='/register'> Return to register</a>"
      elsif not query_result_email.nil?
        "Username already taken or email not accurate! <a href='/register'> Return to register</a>"
      else
        user = Account.create(name: params[:username], password: params[:password], email: params[:email])
        session[:username], session[:user_id] = user.name, user.id
        slim :search
      end
    rescue Exception => msg
      "Exception : Username already taken or email not accurate!"\
      " <a href='/register'> Return to register</a>"
    end
  else
    redirect "/register"
  end
end

get '/logout' do
  session[:username] = nil
  session[:id] = nil
  redirect "/login"
end

get '/new_recipe' do
  if session[:username].nil?
    redirect '/login'
  else
    slim :new_recipe
  end
end

get '/new_recipe/new' do
  @recipe = Recipe.new
  slim :search
end

post '/new_recipe/new' do
  products = params[:product] ? params[:product].join(",") : ""
  if params[:title] != "" && params[:cookingTime] != "" && params[:recipe] != "" && products != ""
    Recipe.create(title: params[:title], products: products, minutes: params[:cookingTime].to_i, recipe: params[:recipe])
    slim :search
  else
    slim :new_recipe
  end
end

def recipes_search(products, my_products, cooking_time, my_time)
  if (cooking_time > my_time)
    return false
  end
  products = products.split(",")
  products.each do |item|
    if (!(my_products.include? item))
      return false
    end
  end
  return true
end

get '/search' do
  if session[:username].nil?
    redirect '/login'
  else
    slim :search
  end
end

post '/search' do
  all_recipes = Recipe.all()
  my_products = params[:product] ? params[:product].join(",") : []
  my_time = params[:myTime] == "" ? 10000 : params[:myTime].to_i
  @recipes = all_recipes.select { |item| recipes_search(item.products, my_products, item.minutes, my_time) }
  slim :recipes_list
end

get '/recipes/:id' do
  @recipe = Recipe.get(params[:id])
  slim :recipes
end