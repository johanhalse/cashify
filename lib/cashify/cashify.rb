class Cash
  module Cashify
    extend ActiveSupport::Concern

    included do
      def self.cashify(*fields)
        fields.each do |field_name|
          cents_field = "#{field_name}_cents"
          currency_field = "#{field_name}_currency"

          define_method(field_name) do
            return nil if read_attribute(currency_field).nil? || read_attribute(cents_field).nil?

            Cash.new(read_attribute(currency_field) => read_attribute(cents_field))
          end

          define_method("#{field_name}=") do |cash|
            write_attribute(cents_field, cash.value)
            write_attribute(currency_field, cash.currency)
          end
        end
      end
    end
  end
end
