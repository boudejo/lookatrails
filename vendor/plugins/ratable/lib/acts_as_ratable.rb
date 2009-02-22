module CodeFluency #:nodoc:
  module Acts #:nodoc:
    module Ratable #:nodoc:
    
      class RatingError < RuntimeError; end
    
      def self.included(base)
        base.extend(ClassMethods)  
      end
      
      module ClassMethods
        def acts_as_ratable(options = {})
          write_inheritable_attribute(:acts_as_ratable_options, {
            :ratable_type => ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s,
            :by => options[:by],
            :within => options[:within] || (1..5)
          })
          
          class_inheritable_reader :acts_as_ratable_options

          has_many :ratings, :foreign_key => 'ratable_id', :dependent => true
          
          include CodeFluency::Acts::Ratable::InstanceMethods
        end
      end
      
      module InstanceMethods
      
        def average_rating
          return 0 if ratings.empty?
          (ratings.inject(0){|total,rating| total += rating.rating } / ratings.size.to_f)
        end
        
        def raters
          ratings.collect{|r| r.rater}
        end
      
        def rating_by( by_opt )
          raise RatingError, "Ratings for this model are not made by anyone" unless acts_as_ratable_options[:by]
          unless by_opt.kind_of? acts_as_ratable_options[:by]  
            raise RatingError, "An instance of #{acts_as_ratable_options[:by]} must be passed"
          end
          Rating.find(:first, 
              :conditions=>['ratable_type = ? and ratable_id = ? and rater_type = ? and rater_id = ?', self.class.name, self.id, by_opt.class.name, by_opt.id] )
        end
        
        def rate_as(rating, opts={})
          unless acts_as_ratable_options[:within].include? rating
            raise RatingError, "Rating must be within #{acts_as_ratable_options[:within].inspect}"
          end
          Rating.transaction do
            if acts_as_ratable_options[:by]
              existing_rating = rating_by(opts[:by]) 
              if existing_rating
                existing_rating.rating = rating
                existing_rating.save
              else
                Rating.create(:rating=>rating,:ratable_type => self.class.name, :ratable_id => self.id, :rater_type => opts[:by].class.name, :rater_id => opts[:by].id)
              end
            else
              existing_rating = Rating.find(:first, 
                :conditions=>['ratable_type = ? and ratable_id = ?', self.class.name, self.id] )
              if existing_rating
                existing_rating.rating = rating
                existing_rating.save
              else
                Rating.create(:rating=>rating,:ratable_type => self.class.name, :ratable_id => self.id)
              end
            end
          end
        end
        
      end
      
    end
    
  end
  
end