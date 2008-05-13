require "rubygems"
require "activerecord"

$:.unshift File.dirname(__FILE__) + "/../lib"
require File.dirname(__FILE__) + "/../init"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define do
  create_table(:houses) do |t|
    t.string :label
    t.text :options
    t.text :defined_options
  end
  create_table(:rooms) do |t|
    t.string :label
    t.text :options
    t.integer :house_id
  end
end

class House < ActiveRecord::Base
  has_many :rooms
end

class Room < ActiveRecord::Base
  belongs_to :house
end

describe 'A nice House' do
  before(:each) do
    @house = House.new(:label => 'Mulder Lane 23')
  end
  it "should be a house" do
    @house.should be_instance_of(House)
  end
  it "should be valid" do
    @house.should be_valid
  end

  describe 'with four rooms' do
    before(:each) do
      lambda do
        @house.save
        @green_room = @house.rooms.create(:label => 'green')
        @purple_room = @house.rooms.create(:label => 'purple')
        @red_room = @house.rooms.create(:label => 'red')
        @blue_room = @house.rooms.create(:label => 'blue')
      end.should change(Room, :count).by(4)
    end
    it "should find the four rooms" do
      @house.should have(4).rooms
    end
  end
end

