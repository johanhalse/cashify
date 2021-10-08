require_relative "test_helper"
require "pry"

class CashifyTest < Minitest::Test # rubocop:disable Metrics/ClassLength
  def test_that_it_has_a_version_number
    refute_nil ::Cashify::VERSION
  end

  def test_can_be_initialized_with_both_keyword_and_hash
    currency = "SEK"
    amount = 100

    assert_equal(Cash.new(SEK: 100), Cash.new(currency => amount))
  end

  def test_raises_an_error_if_you_add_something_weird
    cash = Cash.new(SEK: 100)
    assert_raises(Cash::Errors::AdditionError) { cash + :something }
  end

  def test_can_add_cash_with_the_same_currency
    cash1 = Cash.new(SEK: 100)
    cash2 = Cash.new(SEK: 100)

    assert_equal(cash1 + cash2, Cash.new(SEK: 200))
  end

  def test_can_add_scalar_to_currencies
    cash = Cash.new(SEK: 100, USD: 100)

    assert_equal(cash + 50, Cash.new(SEK: 150, USD: 150))
  end

  def test_correctly_identifies_a_zero
    clean_zero = Cash.zero
    other_currency_zero = Cash.new(SEK: 0)
    multiple_currency_zero = Cash.new(SEK: 0, USD: 0)

    assert clean_zero.zero?
    assert other_currency_zero.zero?
    assert multiple_currency_zero.zero?
  end

  def test_can_add_cash_on_a_cash_zero
    cash = Cash.new(SEK: 100)
    zero = Cash.zero

    assert_equal(cash + zero, Cash.new(SEK: 100))
    assert_equal(zero + cash, Cash.new(SEK: 100))
  end

  def test_can_combine_different_currencies
    cash1 = Cash.new(SEK: 100)
    cash2 = Cash.new(USD: 100)

    assert_equal(cash1 + cash2, Cash.new(SEK: 100, USD: 100))
    assert_equal(cash2 + cash1, Cash.new(USD: 100, SEK: 100))
  end

  def test_uses_zero_like_you_expect_it_to
    cash1 = Cash.new(SEK: 0)
    cash2 = Cash.new(USD: 100)
    zero = Cash.zero

    assert_equal(cash1 + zero + cash2, Cash.new(USD: 100))
    assert_equal(zero + cash2 + cash1, Cash.new(USD: 100))
    assert_equal(cash2 + cash1 + zero, Cash.new(USD: 100))
  end

  def test_addition_returns_a_cash_zero_from_two_cash_zero
    a = Cash.zero
    b = Cash.zero

    assert_equal(a + b, Cash.zero)
  end

  def test_raises_an_error_if_you_subtract_something_weird
    cash = Cash.new(SEK: 100)
    assert_raises(Cash::Errors::SubtractionError) { cash - :something }
  end

  def test_can_subtract_cash_with_the_same_currency
    cash1 = Cash.new(SEK: 100)
    cash2 = Cash.new(SEK: 100)

    assert_equal(cash1 - cash2, Cash.new(SEK: 0))
  end

  def test_can_subtract_scalar_from_currencies
    cash = Cash.new(SEK: 100, USD: 100)

    assert_equal(cash - 50, Cash.new(SEK: 50, USD: 50))
  end

  def test_can_subtract_cash_from_cash_zero
    cash = Cash.new(SEK: 100)
    zero = Cash.zero

    assert_equal(cash - zero, Cash.new(SEK: 100))
    assert_equal(zero - cash, Cash.new(SEK: -100))
  end

  def test_treats_missing_currencies_as_zero_when_subtracting
    cash1 = Cash.new(SEK: 100)
    cash2 = Cash.new(USD: 100)

    assert_equal(cash1 - cash2, Cash.new(SEK: 100, USD: -100))
    assert_equal(cash2 - cash1, Cash.new(USD: 100, SEK: -100))
  end

  def test_subtracts_with_zero_kind_of_like_you_expect
    cash1 = Cash.new(SEK: 0)
    cash2 = Cash.new(USD: 100)
    zero = Cash.zero

    assert_equal(cash1 - zero - cash2, Cash.new(USD: -100))
    assert_equal(zero - cash2 - cash1, Cash.new(USD: -100))
    assert_equal(cash2 - cash1 - zero, Cash.new(USD: 100))
  end

  def test_subtraction_returns_a_cash_zero_from_two_cash_zero
    a = Cash.zero
    b = Cash.zero

    assert_equal(a - b, Cash.zero)
  end

  def test_can_compare_cash_with_the_same_currency
    cash1 = Cash.new(SEK: 100)
    cash2 = Cash.new(SEK: 100)
    cash3 = Cash.new(SEK: 200)
    cash4 = Cash.new(SEK: -100)

    assert_equal(cash1 <=> cash3, -1)
    assert_equal(cash1 <=> cash2, 0)
    assert_equal(cash3 <=> cash1, 1)
    assert_equal(cash4 <=> cash1, -1)
  end

  def test_can_compare_cash_with_cash_zero
    cash1 = Cash.new(SEK: 100)
    cash2 = Cash.new(SEK: -100)
    zero1 = Cash.zero
    zero2 = Cash.zero

    assert_equal(cash1 <=> zero1, 1)
    assert_equal(cash2 <=> zero1, -1)
    assert_equal(zero1 <=> zero2, 0)
  end

  def test_returns_nil_when_comparing_different_currencies
    cash1 = Cash.new(SEK: 100)
    cash2 = Cash.new(USD: 200)

    assert_equal(cash1 <=> cash2, -1)
  end

  def test_can_compare_against_integers
    cash = Cash.new(SEK: 100)
    higher = 120
    lower = 80

    assert_equal(cash <=> higher, -1)
    assert_equal(cash <=> lower, 1)
  end

  def test_raises_an_error_if_you_multiply_with_something_weird
    cash = Cash.new(SEK: 100)
    assert_raises(Cash::Errors::MultiplicationError) { cash * "wat" }
  end

  def test_can_multiply_cash_with_an_integer
    cash = Cash.new(SEK: 100, USD: 100)

    assert_equal(cash * 2, Cash.new(SEK: 200, USD: 200))
  end

  def test_can_multiply_cash_with_a_float
    cash = Cash.new(SEK: 100, USD: 100)

    assert_equal(cash * 1.25, Cash.new(SEK: 125, USD: 125))
  end

  def test_can_multiply_cash_with_cash
    cash1 = Cash.new(SEK: 100, USD: 100, NOK: 100)
    cash2 = Cash.new(SEK: 2, USD: 2, DKK: 100)

    assert_equal(cash1 * cash2, Cash.new(SEK: 200, USD: 200, DKK: 100, NOK: 100))
  end

  def test_raises_an_error_if_you_divide_with_something_weird
    cash = Cash.new(SEK: 100)
    assert_raises(Cash::Errors::DivisionError) { cash / "wat" }
  end

  def test_can_divide_cash_with_an_integer
    cash = Cash.new(SEK: 100, USD: 100)

    assert_equal(cash / 2, Cash.new(SEK: 50, USD: 50))
  end

  def test_can_divide_cash_with_a_float
    cash = Cash.new(SEK: 100, USD: 100)

    assert_equal(cash / 1.25, Cash.new(SEK: 80, USD: 80))
  end

  def test_can_divide_cash_with_cash
    cash1 = Cash.new(SEK: 100, USD: 100, NOK: 100)
    cash2 = Cash.new(SEK: 2, USD: 2, DKK: 100)

    assert_equal(cash1 / cash2, Cash.new(SEK: 50, USD: 50, DKK: 100, NOK: 100))
  end

  def test_can_directly_compare_two_cash_objects
    cash1 = Cash.new(SEK: 100, USD: 100)
    cash2 = Cash.new(SEK: 100, USD: 100)

    assert(cash1 == cash2)
  end

  def test_can_compare_two_cash_objects_with_different_order
    cash1 = Cash.new(SEK: 100, USD: 100)
    cash2 = Cash.new(USD: 100, SEK: 100)

    assert(cash1 == cash2)
  end

  def test_needs_to_match_all_currencies
    cash1 = Cash.new(SEK: 100)
    cash2 = Cash.new(USD: 100, SEK: 100)

    refute(cash1 == cash2)
  end

  def test_takes_currency_into_account
    cash1 = Cash.new(SEK: 100)
    cash2 = Cash.new(USD: 100)

    refute(cash1 == cash2)
  end

  def test_identifies_positive_numbers
    positive_number = Cash.new(SEK: 100)
    zero_number = Cash.zero
    negative_number = Cash.new(SEK: -100)

    assert(positive_number.positive?)
    refute(zero_number.positive?)
    refute(negative_number.positive?)
  end

  def test_identifies_negative_numbers
    positive_number = Cash.new(SEK: 100)
    zero_number = Cash.zero
    negative_number = Cash.new(SEK: -100)

    refute(positive_number.negative?)
    refute(zero_number.negative?)
    assert(negative_number.negative?)
  end

  def test_correctly_shows_as_greater_or_lower_than_another_cash_with_same_currency
    lower = Cash.new(SEK: 100)
    higher = Cash.new(SEK: 120)

    refute(lower > higher)
    assert(higher > lower)
  end

  def test_naively_shows_as_greater_or_lower_than_another_cash_with_different_currency
    lower = Cash.new(SEK: 100)
    higher = Cash.new(USD: 120)

    refute(lower > higher)
    assert(higher > lower)
  end

  def test_correctly_shows_as_lower_or_greater_than_another_cash_with_same_currency
    lower = Cash.new(SEK: 100)
    higher = Cash.new(SEK: 120)

    assert(lower < higher)
    refute(higher < lower)
  end

  def test_naively_shows_as_lower_or_greater_than_another_cash_with_different_currency
    lower = Cash.new(SEK: 100)
    higher = Cash.new(USD: 120)

    assert(lower < higher)
    refute(higher < lower)
  end

  def test_grabs_the_first_currency_as_its_currency_value
    cash = Cash.new(SEK: 100, USD: 80)
    assert_equal(cash.currency, :SEK)
  end

  def test_grabs_the_first_value
    cash = Cash.new(SEK: 100, USD: 80)
    assert_equal(cash.value, 100)
  end

  def test_transforms_all_currencies_to_a_positive_value
    cash = Cash.new(SEK: -100, USD: -80)
    assert_equal(cash.abs, Cash.new(SEK: 100, USD: 80))
  end

  def test_rounds_values_to_a_power_interval
    cash = Cash.new(SEK: 100_20, USD: 80_75)
    assert_equal(cash.round(100), Cash.new(SEK: 100_00, USD: 81_00))
  end

  def test_returns_an_array_of_cashes
    cash = Cash.new(SEK: 150_00, USD: 100)

    assert_equal(cash.to_a, [Cash.new(SEK: 150_00), Cash.new(USD: 100)])
  end

  def test_can_sum_an_array_of_cashes
    cashes = [Cash.new(SEK: 100), Cash.new(SEK: 100), Cash.new(USD: 100)]

    assert_equal(Cash.sum(cashes), Cash.new(SEK: 200, USD: 100))
  end
end
