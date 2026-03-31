# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrderItem, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:delivery_order) }
  end

  describe "enums" do
    it {
      is_expected.to define_enum_for(:size)
        .with_values(small: 0, medium: 1, large: 2, bulk: 3)
        .with_prefix(:size)
    }
  end

  describe "validations" do
    subject { build(:order_item) }

    it { is_expected.to validate_presence_of(:delivery_order) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:quantity) }
    it { is_expected.to validate_presence_of(:size) }

    it "validates name minimum length" do
      item = build(:order_item, name: "")
      expect(item).not_to be_valid
      expect(item.errors[:name]).to be_present
    end

    it "validates name maximum length" do
      item = build(:order_item, name: "a" * 101)
      expect(item).not_to be_valid
      expect(item.errors[:name]).to include("is too long (maximum is 100 characters)")
    end

    it "allows name up to 100 characters" do
      item = build(:order_item, name: "a" * 100)
      expect(item).to be_valid
    end

    it "validates quantity is greater than 0" do
      item = build(:order_item, quantity: 0)
      expect(item).not_to be_valid
      expect(item.errors[:quantity]).to be_present
    end

    it "validates quantity is less than or equal to 999" do
      item = build(:order_item, quantity: 1000)
      expect(item).not_to be_valid
      expect(item.errors[:quantity]).to be_present
    end

    it "validates quantity is an integer" do
      item = build(:order_item)
      item.quantity = 1.5
      expect(item).not_to be_valid
    end

    it "allows valid quantities" do
      item = build(:order_item, quantity: 50)
      expect(item).to be_valid
    end
  end

  describe "size enum" do
    it "allows small size" do
      item = build(:order_item, size: :small)
      expect(item).to be_valid
      expect(item.size_small?).to be true
    end

    it "allows medium size" do
      item = build(:order_item, size: :medium)
      expect(item).to be_valid
      expect(item.size_medium?).to be true
    end

    it "allows large size" do
      item = build(:order_item, size: :large)
      expect(item).to be_valid
      expect(item.size_large?).to be true
    end

    it "allows bulk size" do
      item = build(:order_item, size: :bulk)
      expect(item).to be_valid
      expect(item.size_bulk?).to be true
    end
  end
end
