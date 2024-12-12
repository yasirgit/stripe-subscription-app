FactoryBot.define do
    factory :subscription do
        stripe_id { "sub_#{SecureRandom.hex(8)}" }
        state { 'unpaid' }
    end
end