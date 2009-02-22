require 'active_support/inflector'
require File.expand_path(File.dirname(__FILE__) + "/../../test/ordered_fixtures")

ENV["FIXTURE_ORDER"] ||= ""

namespace :db do
  namespace :fixtures do
    desc "Import fixtures with instantiating core objects from yml" 
    task :import => :environment do
      print 'starting . . .'

      ordered_fixtures = Hash.new
      ENV["FIXTURE_ORDER"].split.each { |fx| ordered_fixtures[fx] = nil }
      other_fixtures = Dir.glob(File.join(RAILS_ROOT, 'test', 'fixtures', '*.{yml,csv}')).collect { |file| File.basename(file, '.*') }.reject {|fx| ordered_fixtures.key? fx }
      ordered_fixtures = (ordered_fixtures.keys + other_fixtures)
      
      #truncate existing tables
      ordered_fixtures.reverse.each { |model| ActiveRecord::Base.connection.execute("truncate table #{model.underscore}") }
      puts 'done truncating tables'
  
      ordered_fixtures.each do |model| 
        table_name = model.underscore
        path = "test/fixtures/#{table_name}.yml"
        puts 'loading '+path
        model_data = YAML::load_file(path)
    
        if model_data 
          puts "creating #{model_data.size.to_s} #{model} . . . "
          klass=eval(Inflector.singularize(model))
          model_data.each do |data|
            klass.create(data[1])
          end 
          puts ". . .done creating "+model
        end
  
      end  
    end
  end
end