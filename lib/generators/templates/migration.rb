class ActsAsRateableMigration < ActiveRecord::Migration
  def self.up
    create_table :ratings, :force => true do |t|
      t.references :rateable, :polymorphic => true, :null => false
      t.references :rater,   :polymorphic => true, :null => false
      t.integer :score, :null => false
      t.timestamps
    end

    add_index :ratings, ["rater_id", "rater_type"], :name => "fk_raters"
    add_index :ratings, ["rateable_id", "rateable_type"], :name => "fk_rateables"
  end

  def self.down
    drop_table :ratings
  end
end
