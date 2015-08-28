require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/site.db")

class Account
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :password, String
  property :email, String
end

class Recipe
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :products, String
  property :minutes, Integer
  property :recipe, Text
end

DataMapper.finalize

DataMapper.auto_upgrade!
