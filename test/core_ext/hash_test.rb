require 'test/test_helper'
class HashTest < ActiveSupport::TestCase

  def setup
    @hash = {:root => {:child1 => 'val1', :child2 => 'val2'}}
  end

  test 'should find key' do
    value = @hash.deep_find(:child1)
    assert_not_nil value
    assert value == 'val1'
  end

  test 'should fetch key' do
    assert_nothing_raised do
      value = @hash.deep_fetch(:child1)
      assert_not_nil value
      assert value == 'val1'
    end
  end

  test 'should fetch key with default' do
    assert_nothing_raised do
      value = @hash.deep_fetch(:non_exiting_key, 'Default value')
      assert_not_nil value
      assert value == 'Default value'
    end
  end

  test 'fetch should raise error if no default' do
    assert_raise KeyError do
      @hash.deep_fetch(:non_exiting_key)
    end
  end
end