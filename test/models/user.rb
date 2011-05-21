class User < ActiveRecord::Base
  validates_presence_of :name
  acts_as_rater
  acts_as_rateable
end
