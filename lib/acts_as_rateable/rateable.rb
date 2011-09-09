module ActsAsRateable #:nodoc:
  module Rateable

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def acts_as_rateable
        has_many :ratings, :as => :rateable, :dependent => :destroy, :class_name => 'Rating'
        include ActsAsRateable::Rateable::InstanceMethods
        include ActsAsRateable::Base
      end
    end

    module InstanceMethods

      # Returns the number of raters a record has.
      def ratings_count
        self.ratings.count
      end

      # Returns the raters by a given type
      def raters_by_type(rater_type)
        raters = rater_type.constantize.
          includes(:rates).
          where(
            "ratings.rateable_id = ? AND ratings.rateable_type = ? AND ratings.rater_type = ?", 
            self.id, parent_class_name(self), rater_type
          )
        raters
      end

      def raters_by_type_count(rater_type)
        self.ratings.for_rater_type(rater_type).count
      end

      # Allows magic names on raters_by_type
      # e.g. user_raters == raters_by_type('User')
      # Allows magic names on raters_by_type_count
      # e.g. count_user_raters == raters_by_type_count('User')
      def method_missing(m, *args)
        if m.to_s[/count_(.+)_raters/]
          raters_by_type_count($1.singularize.classify)
        elsif m.to_s[/(.+)_raters/]
          raters_by_type($1.singularize.classify)
        else
          super
        end
      end

      # Returns the raters records.
      def raters
        self.ratings.includes(:rater).all.collect{|r| r.rater}
      end

      # Returns true if the current instance is rated by the passed record
      def rated_by?(rater)
        get_rating_for(rater).present?
      end
      
      # Calculates the average rating. Calculation based on the already given scores.
      def average_rating
        return 0 if self.ratings.empty?
        (self.ratings.inject(0){|total, rating| total += rating.score }.to_f / self.ratings.size )
      end

      # Rounds the average rating value.
      def average_rating_round
        average_rating.round
      end

      # Returns the average rating in percent. The maximal score must be provided or the default value (10) will be used.
      def average_rating_percent(maximum_rating = 10)
        f = 100 / maximum_rating.to_f
        average_rating * f
      end

      private

      def get_rating_for(rater)
        self.ratings.for_rater(rater).first
      end
    end
  end
end