require File.dirname(__FILE__) + '/acts_as_rateable/rater'
require File.dirname(__FILE__) + '/acts_as_rateable/rateable'
require File.dirname(__FILE__) + '/acts_as_rateable/base'

ActiveRecord::Base.send(:include, ActsAsRateable::Rater)
ActiveRecord::Base.send(:include, ActsAsRateable::Rateable)
