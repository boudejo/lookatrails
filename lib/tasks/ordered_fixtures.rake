=begin
require File.expand_path(File.dirname(__FILE__) + "/../../test/ordered_fixtures")
require 'active_record/fixtures'

ENV["FIXTURE_ORDER"] ||= ""

namespace :db do
  namespace :fixtures do
    desc "Load ordered fixtures into #{ENV['RAILS_ENV']} database"
    task :loadordered => :environment do
      ordered_fixtures = Hash.new
      ENV["FIXTURE_ORDER"].split.each { |fx| ordered_fixtures[fx] = nil }
      other_fixtures = Dir.glob(File.join(RAILS_ROOT, 'test', 'fixtures', '*.{yml,csv}')).collect { |file| File.basename(file, '.*') }.reject {|fx| ordered_fixtures.key? fx }
      ActiveRecord::Base.establish_connection(ENV['RAILS_ENV'])
      (ordered_fixtures.keys + other_fixtures).each do |fixture|
        Fixtures.create_fixtures('test/fixtures',  fixture)
      end unless :environment == 'production' 
      # You really don't want to load your *fixtures* 
      # into your production database, do you?  
    end
  end'
end"
=end

require File.join("#{RAILS_ROOT}/config/environment")
require File.join("#{RAILS_ROOT}/test/ordered_fixtures")

ENV["FIXTURE_ORDER"] ||= ""

def print_separator_line(n=70)
  puts '='*n
end

desc "Load fixtures into #{ENV['RAILS_ENV']} database"

namespace :db do
  namespace :fixtures do
      task :load_ordered => :environment do

      require 'active_record/fixtures'

      print_separator_line
      puts "Collecting specified ordered fixtures"

      ordered_fixtures = ENV["FIXTURE_ORDER"].split
      fixture_files = Dir.glob(File.join(RAILS_ROOT, 'test', 'fixtures', '*.{yml,csv}'))

      other_fixtures = fixture_files.
      collect { |file| File.basename(file, '.*') }.reject {|fx| ordered_fixtures.include? fx }

      ActiveRecord::Base.establish_connection(ENV['RAILS_ENV'])

      all_fixtures = ordered_fixtures + other_fixtures
      print_separator_line
      puts "Fixtures will be loaded in this order:"

      all_fixtures.each_with_index do |fx, i|
        puts "#{i+1}. #{fx}"
      end

      print_separator_line
      puts "Actually loading fixtures to #{ENV['RAILS_ENV']} db…"

      all_fixtures.each do |fixture|
        puts "Loading #{fixture}…"
        Fixtures.create_fixtures('test/fixtures', fixture)
      end
    end
  end
end