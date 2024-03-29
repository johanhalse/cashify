require_relative "cashify/version"
require_relative "cashify/arithmetic"
require_relative "cashify/errors"

if defined?(::Rails::Railtie)
  require_relative "cashify/cashify"

  class CashifyRailtie < Rails::Railtie
    initializer "cashify.configure_rails_initialization" do
      ActiveSupport.on_load(:active_record) do
        ::ActiveRecord::Base.include(Cash::Cashify)
      end
    end
  end
end

class Cash
  include Cash::Arithmetic
  include Cash::Errors
  include Comparable

  attr_accessor :currencies

  def self.zero
    new(USD: 0)
  end

  def initialize(**currencies)
    @currencies = currencies
                  .transform_keys(&:to_sym)
                  .transform_values(&:to_i)
                  .sort.to_h
  end

  def ==(other)
    return currencies == other.currencies || (zero? && other.zero?) if other.is_a?(Cash)

    zero? && (other.respond_to?(:zero?) && other.zero?)
  end

  def zero?
    currencies.values.all?(&:zero?)
  end

  def positive?
    currencies.values.all?(&:positive?)
  end

  def negative?
    currencies.values.all?(&:negative?)
  end

  def <=>(other)
    other_sum = other if other.is_a?(Integer) || other.is_a?(Float)
    other_sum = other.currencies.values.sum if other.is_a?(Cash)

    currencies.values.sum <=> other_sum
  end

  def to_a
    currencies.map { |k, v| Cash.new(k => v) }
  end

  def to_s
    currencies.map { |k, v| "#{(v * 0.01).round} #{k}" }.join(", ")
  end

  def to_delimited_s
    currencies.map { |k, v| "#{(v * 0.01).round.to_formatted_s(:delimited, delimiter: " ")} #{k}" }.join(", ")
  end

  def currency
    currencies.keys.first
  end

  def value
    currencies.values.first
  end

  def empty?
    currencies.empty?
  end

  def abs
    Cash.new(**currencies.transform_values(&:abs))
  end

  def round(interval = 100)
    Cash.new(**currencies.transform_values { |v| (v / interval.to_f).round * interval })
  end
end
