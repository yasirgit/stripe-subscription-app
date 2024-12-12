# frozen_string_literal: true
require "rails_helper"

RSpec.describe Subscription, type: :model do
  describe "validations" do
    it { should validate_presence_of(:stripe_id) }
    it { should validate_uniqueness_of(:stripe_id) }
    it { should validate_presence_of(:state) }
    it { should validate_inclusion_of(:state).in_array(%w[unpaid paid canceled]) }
  end

  describe "#mark_as_paid" do
    let(:subscription) { create(:subscription, state: initial_state) }

    context "when the subscription is unpaid" do
      let(:initial_state) { "unpaid" }

      it "changes the state to paid" do
        subscription.mark_as_paid
        expect(subscription.reload.state).to eq("paid")
      end
    end

    context "when the subscription is already paid" do
      let(:initial_state) { "paid" }

      it "does not change the state" do
        subscription.mark_as_paid
        expect(subscription.reload.state).to eq("paid")
      end
    end
  end

  describe "#cancel" do
    let(:subscription) { create(:subscription, state: initial_state) }

    context "when the subscription is paid" do
      let(:initial_state) { "paid" }

      it "changes the state to canceled" do
        subscription.cancel
        expect(subscription.reload.state).to eq("canceled")
      end
    end

    context "when the subscription is unpaid" do
      let(:initial_state) { "unpaid" }

      it "does not change the state" do
        subscription.cancel
        expect(subscription.reload.state).to eq("unpaid")
      end
    end
  end
end
