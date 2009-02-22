require 'acts_as_ratable'
ActiveRecord::Base.send(:include, CodeFluency::Acts::Ratable)

require File.dirname(__FILE__) + '/lib/rating'