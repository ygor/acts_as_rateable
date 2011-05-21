require File.dirname(__FILE__) + '/test_helper'

class ActsAsRateableTest < ActiveSupport::TestCase

  context "instance methods" do
    setup do
      @beatles = Factory(:beatles)
    end

    should "be defined" do
      assert @beatles.respond_to?(:raters_count)
      assert @beatles.respond_to?(:raters)
      assert @beatles.respond_to?(:rated_by?)
    end
  end

  context "acts_as_rateable" do
    setup do
      @sam = Factory(:sam)
      @jon = Factory(:jon)
      @beatles = Factory(:beatles)
      @stones = Factory(:stones)
      @sam.rate(@jon, 5)
    end

    context "raters_count" do
      should "return the number of raters" do
        assert_equal 0, @sam.raters_count
        assert_equal 1, @jon.raters_count
      end

      should "return the proper number of multiple raters" do
        @bob = Factory(:bob)
        @sam.rate(@bob, 5)
        assert_equal 0, @sam.raters_count
        assert_equal 1, @jon.raters_count
        assert_equal 1, @bob.raters_count
      end
    end

    context "raters" do
      should "return users" do
        assert_equal [], @sam.raters
        assert_equal [@sam], @jon.raters
      end
  
      should "return users (multiple followers)" do
        @bob = Factory(:bob)
        @sam.rate(@bob, 7)
        assert_equal [], @sam.raters
        assert_equal [@sam], @jon.raters
        assert_equal [@sam], @bob.raters
      end
  
      should "return users (multiple raters, complex)" do
        @bob = Factory(:bob)
        @sam.rate(@bob, 8)
        @jon.rate(@bob, 9)
        assert_equal [], @sam.raters
        assert_equal [@sam], @jon.raters
        assert_equal [@sam, @jon], @bob.raters
      end
    end
    
    context "rated_by" do
      should "return_rater_status" do
        assert_equal true, @jon.rated_by?(@sam)
        assert_equal false, @sam.rated_by?(@jon)
      end
    end

    context "destroying a rater" do
      setup do
        @ratings_count = Rating.count
        @raters_count = @jon.raters_count
        @sam.destroy
      end

      should 'decrease rater count by one' do
        assert_equal @ratings_count -1, Rating.count
        assert_equal @raters_count -1, @jon.raters_count
      end
    end
    
    context "raters_by_type" do
      setup do
        @sam.rate(@stones, 7)
        @jon.rate(@stones, 8)
      end
    
      should "return the raters for given type" do
        assert_equal [@sam], @jon.raters_by_type('User')
        assert_equal [@sam, @jon], @stones.raters_by_type('User')
      end
    
      should "return the count for raters_by_type_count for a given type" do
        assert_equal 1, @jon.raters_by_type_count('User')
        assert_equal 2, @stones.raters_by_type_count('User')
      end
    end
    
    context "method_missing" do
      setup do
        @sam.rate(@stones, 7)
        @jon.rate(@stones, 8)
      end
    
      should "return the raters for given type" do
        assert_equal [@sam], @jon.user_raters
        assert_equal [@sam, @jon], @stones.user_raters
      end
    
      should "return the count for raters_by_type_count for a given type" do
        assert_equal 1, @jon.count_user_raters
        assert_equal 2, @stones.count_user_raters
      end
    end

    context "rating averages" do
      setup do
        @sam.rate(@stones, 6)
        @jon.rate(@stones, 8)
        @bob = Factory(:bob)
      end
    
      should "return the average rating" do
        assert_equal 7, @stones.average_rating
        assert_equal 0, @bob.average_rating
      end
    end
  end
end