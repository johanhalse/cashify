class Cash
  module Arithmetic
    def coerce(other)
      [self, other]
    end

    def +(other)
      raise Cash::Errors::AdditionError unless other.respond_to?(:zero?)
      return self unless present?(other)
      return self if other.zero?
      return other if zero?

      return Cash.new(**add_currencies(other)) if other.is_a?(Cash)

      Cash.new(**add_number(other)) if other.is_a?(Integer) || other.is_a?(Float)
    end

    def -(other)
      raise Cash::Errors::SubtractionError unless other.respond_to?(:zero?)
      return self unless present?(other)
      return Cash.new(**subtract_currencies(other)) if other.is_a?(Cash) || other.zero?

      Cash.new(**subtract_number(other)) if other.is_a?(Integer) || other.is_a?(Float)
    end

    def *(other)
      return Cash.new(**multiply_number(other)) if other.is_a?(Integer) || other.is_a?(Float)
      return Cash.new(**multiply_currencies(other)) if other.is_a?(Cash)

      raise Cash::Errors::MultiplicationError
    end

    def /(other)
      return Cash.new(**divide_number(other)) if other.is_a?(Integer) || other.is_a?(Float)
      return Cash.new(**divide_currencies(other)) if other.is_a?(Cash)

      raise Cash::Errors::DivisionError
    end

    private

    def present?(other)
      !(other.nil? || other == "" || other == false)
    end

    def multiply_number(other)
      currencies.transform_values { |v| v * other }
    end

    def multiply_currencies(other)
      currencies.merge(other.currencies) { |_k, a, b| a * b }
    end

    def divide_number(other)
      currencies.transform_values { |v| v / other }
    end

    def divide_currencies(other)
      currencies.merge(other.currencies) { |_k, a, b| a / b }
    end

    def add_currencies(other)
      currencies.merge(other.currencies) { |_k, a, b| a + b }
    end

    def add_number(other)
      currencies.transform_values { |v| v + other }
    end

    def subtract_number(other)
      currencies.transform_values { |v| v - other }
    end

    def subtract_currencies(other) # rubocop:disable Metrics/AbcSize
      return currencies unless other.respond_to?(:zero?)
      return currencies if other.zero?
      return other.currencies.transform_values { |v| 0 - v } if zero?

      (@currencies.keys + other.currencies.keys).uniq.to_h do |k|
        minuend = @currencies[k] || 0
        subtrahend = other.currencies[k] || 0

        [k, minuend - subtrahend]
      end
    end
  end
end
