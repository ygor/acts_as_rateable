class Rating < ActiveRecord::Base
  extend ActsAsRateable::Base

  scope :for_rater, lambda { |rater| where(["rater_id = ? AND rater_type = ?", rater.id, parent_class_name(rater)]) }
  scope :for_rateable, lambda { |rateable| where(["rateable_id = ? AND rateable_type = ?", rateable.id, parent_class_name(rateable)]) }
  scope :for_rater_type, lambda { |rater_type| where("rater_type = ?", rater_type) }
  scope :for_rateable_type, lambda { |rateable_type| where("rateable_type = ?", rateable_type) }
  scope :recent, lambda { |from| where(["created_at > ?", (from || 2.weeks.ago).to_s(:db)]) }
  scope :descending, order("ratings.created_at DESC")
  
  belongs_to :rateable, :polymorphic => true
  belongs_to :rater, :polymorphic => true

  validates_presence_of :score
  validates_numericality_of :score, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 10  
end