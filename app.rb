require 'rubygems'
require 'sinatra'
require 'haml'
require 'mongoid'
require 'json'

# Helpers
require './lib/render_partial'

# Persistence
Mongoid.load!('mongoid.yml')

class Survey
  include Mongoid::Document

  field :link_title, type: String
  field :is_neutral, type: Boolean
  field :is_positive, type: Boolean
  field :is_negative, type: Boolean
end

# Set Sinatra variables
set :app_file, __FILE__
set :root, File.dirname(__FILE__)
set :views, 'views'
set :public_folder, 'public'
set :haml, {:format => :html5} # default Haml format is :xhtml

# Application routes
get '/index/:linkbait_title?' do
  @linkbait_title = params[:linkbait_title]
  haml :index, :layout => :'layouts/application'
end

get '/results' do
  content_type :json

  surveys = Survey.all
  negative = surveys.where(is_negative: true).count
  positive = surveys.where(is_positive: true).count
  neutral = surveys.where(is_neutral: true).count

  [
    ['Emotion', 'Count'],
    ['Negative', negative],
    ['Positive', positive],
    ['Neutral', neutral]
  ].to_json
end

post '/vote' do
  content_type :json
  survey = Survey.where(surveyid: params[:surveyid])

  if survey.present?
    survey[0].update_attributes(params)
    msg = {success: true, text: "Answer updated"}
  else
    Survey.create(params)
    msg = {success: true, text: "New survey created"}
  end

  msg.to_json
end
