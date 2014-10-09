class PaymentSerializer < ActiveModel::Serializer
  attributes :id, :amount, :received, :description, :account, :mean, :returned_date, :returned_amount, :return_reason, :bank_code, :spec_symbol, :var_symbol, :const_symbol
  has_one :apply_form
end
