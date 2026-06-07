require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "validates presence of name" do
    product = Product.new
    assert_not product.save
    assert_includes product.errors[:name], "can't be blank"
  end
end
