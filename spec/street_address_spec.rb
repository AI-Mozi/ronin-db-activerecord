require 'spec_helper'
require 'ronin/db/street_address'

describe Ronin::DB::StreetAddress do
  it "must use the 'ronin_street_addresses' table" do
    expect(described_class.table_name).to eq('ronin_street_addresses')
  end

  let(:address) { '123 Fake St.' }
  let(:city)    { 'Smallville' }
  let(:state)   { 'KS' }
  let(:zipcode) { '1234' }
  let(:country) { 'USA' }

  describe "validations" do
    it "must limit #address to 46 characters maximum" do
      street_address = described_class.new(
        address: 'A' * 47,
        city:    city,
        state:   state,
        zipcode: zipcode,
        country: country
      )

      expect(street_address).to_not be_valid
      expect(street_address.errors[:address]).to eq(
        ['is too long (maximum is 46 characters)']
      )
    end

    it "must limit #city to 59 characters maximum" do
      street_address = described_class.new(
        address: address,
        city:    'A' * 59,
        state:   state,
        zipcode: zipcode,
        country: country
      )

      expect(street_address).to_not be_valid
      expect(street_address.errors[:city]).to include(
        'is too long (maximum is 58 characters)'
      )
    end

    %w[` ~ ! @ # $ % ^ & * ( ) - _ = + [ ] { } \\ | ; ; " , . < > / ?].each do |bad_char|
      it "must not allow #{bad_char.inspect} in #city" do
        street_address = described_class.new(
          address: address,
          city:    "#{city}#{bad_char}",
          state:   state,
          zipcode: zipcode,
          country: country
        )

        expect(street_address).to_not be_valid
        expect(street_address.errors[:city]).to eq(
          ['Must be a valid capitalized city name']
        )
      end
    end

    it "must allow #city to contain spaces, but each word must be capitalized" do
      street_address = described_class.new(
        address: address,
        city:    "New place",
        state:   state,
        zipcode: zipcode,
        country: country
      )

      expect(street_address).to_not be_valid
      expect(street_address.errors[:city]).to eq(
        ['Must be a valid capitalized city name']
      )

      street_address = described_class.new(
        address: address,
        city:    "New Place",
        state:   state,
        zipcode: zipcode,
        country: country
      )

      expect(street_address).to be_valid
    end

    it "must allow #city to contain apostrophes" do
      street_address = described_class.new(
        address: address,
        city:    "O'Brians Landing",
        state:   state,
        zipcode: zipcode,
        country: country
      )

      expect(street_address).to be_valid
    end

    it "must limit #state to 13 characters maximum" do
      street_address = described_class.new(
        address: address,
        city:    city,
        state:   'Alaskaaaaaaaaa',
        zipcode: zipcode,
        country: country
      )

      expect(street_address).to_not be_valid
      expect(street_address.errors[:state]).to eq(
        ['is too long (maximum is 13 characters)']
      )
    end

    it "must require #state start with a capital letter followed by lowercase letters" do
      street_address = described_class.new(
        address: address,
        city:    city,
        state:   'alaska',
        zipcode: zipcode,
        country: country
      )

      expect(street_address).to_not be_valid
      expect(street_address.errors[:state]).to eq(
        ['Must be a valid capitalized state or province name']
      )

      street_address = described_class.new(
        address: address,
        city:    city,
        state:   'aLASKA',
        zipcode: zipcode,
        country: country
      )

      expect(street_address).to_not be_valid
      expect(street_address.errors[:state]).to eq(
        ['Must be a valid capitalized state or province name']
      )

      street_address = described_class.new(
        address: address,
        city:    city,
        state:   'Alaska',
        zipcode: zipcode,
        country: country
      )

      expect(street_address).to be_valid
    end

    it "must allow #state to contain spaces, but each word must be capitalized" do
      street_address = described_class.new(
        address: address,
        city:    city,
        state:   'New york',
        zipcode: zipcode,
        country: country
      )

      expect(street_address).to_not be_valid
      expect(street_address.errors[:state]).to eq(
        ['Must be a valid capitalized state or province name']
      )

      street_address = described_class.new(
        address: address,
        city:    city,
        state:   'New York',
        zipcode: zipcode,
        country: country
      )

      expect(street_address).to be_valid
    end

    it "must accept two letter abbreviations for #state" do
      street_address = described_class.new(
        address: address,
        city:    city,
        state:   'NY',
        zipcode: zipcode,
        country: country
      )

      expect(street_address).to be_valid
    end

    it "must limit #zipcode to 10 characters maximum" do
      street_address = described_class.new(
        address: address,
        city:    city,
        state:   state,
        zipcode: '1' * 11,
        country: country
      )

      expect(street_address).to_not be_valid
      expect(street_address.errors[:zipcode]).to eq(
        ['is too long (maximum is 10 characters)']
      )
    end

    it "must limit #country to 56 characters maximum" do
      street_address = described_class.new(
        address: address,
        city:    city,
        state:   state,
        zipcode: zipcode,
        country: "A#{'a' * 56}"
      )

      expect(street_address).to_not be_valid
      expect(street_address.errors[:country]).to eq(
        ['is too long (maximum is 56 characters)']
      )
    end

    it "must allow #country to contain spaces, but each word must be capitalized" do
      street_address = described_class.new(
        address: address,
        city:    city,
        state:   state,
        zipcode: zipcode,
        country: 'United states'
      )

      expect(street_address).to_not be_valid
      expect(street_address.errors[:country]).to eq(
        ['Must be a valid capitalized country name']
      )

      street_address = described_class.new(
        address: address,
        city:    city,
        state:   state,
        zipcode: zipcode,
        country: 'United States'
      )

      expect(street_address).to be_valid
    end

    it "must accept two letter abbreviations for #country" do
      street_address = described_class.new(
        address: address,
        city:    city,
        state:   state,
        zipcode: zipcode,
        country: 'US'
      )

      expect(street_address).to be_valid
    end

    it "must accept three letter abbreviations for #country" do
      street_address = described_class.new(
        address: address,
        city:    city,
        state:   state,
        zipcode: zipcode,
        country: 'USA'
      )

      expect(street_address).to be_valid
    end
  end

  subject do
    described_class.new(
      address: address,
      city:    city,
      zipcode: zipcode,
      state:   state,
      country: country
    )
  end

  describe "#province" do
    it "must return #state" do
      expect(subject.province).to eq(subject.state)
    end
  end

  describe "#province=" do
    let(:new_province) { 'New Province' }

    before { subject.province = new_province }

    it "must set #state" do
      expect(subject.state).to eq(new_province)
    end
  end

  describe "#postal_code" do
    it "must return #zipcode" do
      expect(subject.postal_code).to eq(subject.zipcode)
    end
  end

  describe "#postal_code=" do
    let(:new_postal_code) { '56789' }

    before { subject.postal_code = new_postal_code }

    it "must set #zipcode" do
      expect(subject.zipcode).to eq(new_postal_code)
    end
  end

  describe "#to_s" do
    it "must return a three-line mailing address" do
      expect(subject.to_s).to eq(
        [
          address,
          "#{city}, #{state} #{zipcode}",
          country
        ].join($/)
      )
    end

    context "when #state is nil" do
      let(:state) { nil }

      it "must omit #state from the second line" do
        expect(subject.to_s).to eq(
          [
            address,
            "#{city} #{zipcode}",
            country
          ].join($/)
        )
      end
    end

    context "when #zipcode is nil" do
      let(:zipcode) { nil }

      it "must omit #zipcode from the second line" do
        expect(subject.to_s).to eq(
          [
            address,
            "#{city}, #{state}",
            country
          ].join($/)
        )
      end
    end
  end
end
