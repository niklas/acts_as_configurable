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
  acts_as_custom_configurable :using => :options
end

class Room < ActiveRecord::Base
  belongs_to :house
  acts_as_custom_configurable :using => :options, :defined_in => :house
end

describe 'A nice House' do
  before(:each) do
    @house = House.new(:label => 'Mulder Lane 23')
    @house.defined_options = {
      :story_count => [:integer, 1],
      :address => [:string, 'no Address'],
      :inhabited => [:boolean, false]
    }
  end
  it "should be a house" do
    @house.should be_instance_of(House)
  end
  it "should be valid" do
    @house.should be_valid
  end

  it "should respond to #options" do
    @house.should respond_to(:options)
  end

  it "should return options" do
    @house.options.should_not be_nil
  end

  it "should have default story_count" do
    @house.options.story_count.should == 1
  end
  it "should have default address" do
    @house.options.address.should == 'no Address'
  end
  it "should have default inhabited_state" do
    @house.options.inhabited.should be_false
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

