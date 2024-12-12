# frozen_string_literal: true
class Subscription < ApplicationRecord
  validates :stripe_id, presence: true, uniqueness: true
  validates :state, presence: true, inclusion: { in: %w[unpaid paid canceled] }

  def mark_as_paid
    update(state: "paid") if state == "unpaid"
  end

  def cancel
    update(state: "canceled") if state == "paid"
  end
end
