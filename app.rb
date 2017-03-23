require "sinatra"
require "sinatra/reloader" if development?
require "pry-byebug"
require "better_errors"
require 'sqlite3'



configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

get '/' do
  @db = SQLite3::Database.new("db/jukebox.sqlite").execute("SELECT id, name FROM artists")
  # @results = {id: db[0], name: db[1]}
  erb :index
end

get '/artists/:id' do
  id = params[:id]
  @db = SQLite3::Database.new("db/jukebox.sqlite").execute("SELECT al.id, al.title FROM albums al
                                                            JOIN artists a ON al.artist_id = a.id
                                                            WHERE a.id =#{id}")
  erb :artists
end

get '/albums/:id' do
  id = params[:id]
  @db = SQLite3::Database.new("db/jukebox.sqlite").execute("SELECT t.id, t.name FROM tracks t
                                                            JOIN albums a ON t.album_id = a.id
                                                            WHERE a.id =#{params[:id]}")
  erb :albums
end

get '/tracks/:id' do
  id = params[:id]
  @db = SQLite3::Database.new("db/jukebox.sqlite").execute("SELECT t.id, t.name, al.title, g.name, a.name, t.composer,
                                                            ROUND(t.milliseconds / 60000.0,2) AS minutes, t.unit_price  FROM tracks t
                                                            JOIN albums al ON t.album_id = al.id
                                                            JOIN genres g ON t.genre_id = g.id
                                                            JOIN artists a ON al.artist_id = a.id
                                                            WHERE t.id = #{params[:id]}").flatten
  erb :tracks
end
