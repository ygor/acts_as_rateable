module ActsAsRateable #:nodoc:
  module Rater

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def acts_as_rater
        has_many :rates, :as => :rater, :dependent => :destroy, :class_name => 'Rating'
        include ActsAsRateable::Rater::InstanceMethods
        include ActsAsRateable::Base
      end
    end

    module InstanceMethods

      # Returns true if this instance has rated the object passed as an argument.
      def rated?(rateable)
        self.rates.for_rateable(rateable).count > 0
      end

      # Returns the number of objects this instance has rated
      def rates_count
        self.rates.count
      end

      # Creates a new rating record for this instance.
      # Does not allow duplicate records to be created.
      def rate(rateable, score)
        rate = get_rate(rateable)
        if rate.blank? && self != rateable
          self.rates.create(:rateable => rateable, :score => score)
        end
      end

      # Deletes the rating record if it exists.
      def unrate(rateable)
        if rate = get_rate(rateable)
          rate.destroy
          reload
        end
      end

      # Returns the rating records related to this instance by type.
      def rates_by_type(rateable_type)
        self.rates.includes(:rateable).for_rateable_type(rateable_type).all
      end

      # Returns the rating records related to this instance with the rateables included.
      def all_rates
        self.rates.includes(:rateable).all
      end

      # Returns the actual records which this instance has rated.
      def all_rated
        all_rates.collect{ |r| r.rateable }
      end

      # Returns the actual records of a particular type which this record has rated.
      def rated_by_type(rateable_type)
        rateable_type.constantize.
          includes(:ratings).
          where(
            "ratings.rater_id = ? AND ratings.rater_type = ? AND ratings.rateable_type = ?", 
            self.id, parent_class_name(self), rateable_type
          )
      end

      def rated_by_type_count(rateable_type)
        self.rates.for_rateable_type(rateable_type).count
      end

      # Allows magic names on rated_by_type
      # e.g. rated_users == rated_by_type('User')
      # Allows magic names on rated_by_type_count
      # e.g. rated_users_count == rated_by_type_count('User')
      def method_missing(m, *args)
        if m.to_s[/rated_(.+)_count/]
          rated_by_type_count($1.singularize.classify)
        elsif m.to_s[/rated_(.+)/]
          rated_by_type($1.singularize.classify)
        else
          super
        end
      end

      # Returns a rating record for the current instance and rateable object.
      def get_rate(rateable)
        self.rates.for_rateable(rateable).first
      end
    end
  end
end