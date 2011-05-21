require File.dirname(__FILE__) + '/test_helper'

class ActsAsRaterTest < ActiveSupport::TestCase

  context "instance methods" do
    setup do
      @sam = Factory(:sam)
    end

    should "be defined" do
      assert @sam.respond_to?(:rated?)
      assert @sam.respond_to?(:rates_count)
      assert @sam.respond_to?(:rate)
      assert @sam.respond_to?(:unrate)
      assert @sam.respond_to?(:rates_by_type)
      assert @sam.respond_to?(:all_rates)
      assert @sam.respond_to?(:all_rated)
    end
  end

  context "acts_as_rater" do
    setup do
      @sam = Factory(:sam)
      @jon = Factory(:jon)
      @beatles = Factory(:beatles)
      @sam.rate(@jon, 7)
      @sam.rate(@beatles, 5)
    end

    context "rated?" do
      should "return rating_status" do
        assert !@jon.rated?(@sam)
        assert @sam.rated?(@beatles)
      end

      should "return rates_count" do
        assert_equal 2, @sam.rates_count
        assert_equal 0, @jon.rates_count
      end
    end

    context "follow a band" do
      setup do
        @jon.rate(@beatles, 7)
      end
    
      should "set the rater" do
        assert_equal @jon, Rating.last.rater
      end
    
      should "set the rateable" do
        assert_equal @beatles, Rating.last.rateable
      end
    end
    
    context "rate yourself" do
      setup do
        @jon.rate(@jon, 6)
      end
    
      should "not change the rating count" do
        assert_equal 0, @jon.rates_count
      end
    
      should "not set the rater" do
        assert_not_equal @jon, Rating.last.rater
      end
    
      should "not set the rateable" do
        assert_not_equal @jon, Rating.last.rateable
      end
    end
    
    context "unrate" do
      setup do
        @ratings_count = Rating.count
        @rates_count = @sam.rates_count
        @sam.unrate(@beatles)
      end
      
      should "decrease the rater's rating count by one" do
        assert_equal @rates_count - 1, @sam.rates_count
      end
    
      should "decrease the rating count by one" do
        assert_equal @ratings_count - 1, Rating.count
      end
    end
    
    context "ratings" do
      setup do
        @band_rating = Rating.where("rater_id = ? and rater_type = 'User' and rateable_id = ? and rateable_type = 'Band'", @sam.id, @beatles.id).first
        @user_rating = Rating.where("rater_id = ? and rater_type = 'User' and rateable_id = ? and rateable_type = 'User'", @sam.id, @jon.id).first
      end
    
      context "rates_by_type" do
        should "only return requested rates" do
          assert_equal [@band_rating], @sam.rates_by_type('Band')
          assert_equal [@user_rating], @sam.rates_by_type('User')
        end
      end
    
      context "rated_by_type_count" do
        should "return the count of the requested type" do
          @stones = Factory(:stones)
          @sam.rate(@stones, 9)
          assert_equal 2, @sam.rated_by_type_count('Band')
          assert_equal 1, @sam.rated_by_type_count('User')
          assert_equal 0, @jon.rated_by_type_count('Band')
        end
      end
    
      context "all_rates" do
        should "return all ratings" do
          assert_equal 2, @sam.all_rates.size
          assert @sam.all_rates.include?(@band_rating)
          assert @sam.all_rates.include?(@user_rating)
          assert_equal [], @jon.all_rates
        end
      end
    end
  
    context "all_rated" do
      should "return the actual rated records" do
        assert_equal 2, @sam.all_rated.size
        assert @sam.all_rated.include?(@beatles)
        assert @sam.all_rated.include?(@jon)
        assert_equal [], @jon.all_rated
      end
    end
    
    context "rated_by_type" do
      should "return only requested records" do
        assert_equal [@beatles], @sam.rated_by_type('Band')
        assert_equal [@jon], @sam.rated_by_type('User')
      end
    end
    
    context "method_missing" do
      should "call rated_by_type" do
        assert_equal [@beatles], @sam.rated_bands
        assert_equal [@jon], @sam.rated_users
      end
    
      should "call rated_by_type_count" do
        @stones = Factory(:stones)
        @sam.rate(@stones, 5)
        assert_equal 2, @sam.rated_bands_count
        assert_equal 1, @sam.rated_users_count
        assert_equal 0, @jon.rated_bands_count
      end
    
      should "raise on no method" do
        assert_raises (NoMethodError){ @sam.foobar }
      end
    end
    
    context "destroying rater" do
      setup do
        @ratings_count = Rating.count
        @rates_count = @sam.rates_count
        @jon.destroy
      end
    
      should 'have one less rating' do
        assert_equal Rating.count, @ratings_count - 1
      end
      
      should "decreate the rater's rating count by one" do
        assert_equal @sam.rates_count, @rates_count - 1
      end
    end
  end
end