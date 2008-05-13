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
  acts_as_custom_configurable :using => :options, :defined_by => :house
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
  it "should throw exception if accessing undefined fields?" do
    lambda do
      @house.options.drill_instructor
    end.should raise_error(NoMethodError)
  end

  describe ", set the story_count to 5" do
    before(:each) do
      @house.options.story_count = 5
    end
    it "should have the new story_count" do
      @house.options.story_count.should == 5
    end
    it "should have default address" do
      @house.options.address.should == 'no Address'
    end
    it "should have default inhabited_state" do
      @house.options.inhabited.should be_false
    end
  end

  describe ", set the story_count to 5 and address to 'Clark Avenue'" do
    before(:each) do
      @house.options.story_count = 5
      @house.options.address = 'Clark Avenue'
    end
    it "should have the new story_count" do
      @house.options.story_count.should == 5
    end
    it "should have default address" do
      @house.options.address.should == 'Clark Avenue'
    end
    it "should have default inhabited_state" do
      @house.options.inhabited.should be_false
    end

    describe ", saving and reloading" do
      before(:each) do
        @house.save
        @house = House.find(@house.id)
      end
      it "should have the new story_count" do
        @house.options.story_count.should == 5
      end
      it "should have default address" do
        @house.options.address.should == 'Clark Avenue'
      end
      it "should have default inhabited_state" do
        @house.options.inhabited.should be_false
      end
    end
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

    describe ". The Green room" do
      it "should know about options" do
        @green_room.should respond_to(:options)
      end
      it "should have options" do
        @green_room.options.should_not be_nil
      end
      it "should have default (house) story_count" do
        @green_room.options.story_count.should == 1
      end
      it "should have default (house) address" do
        @green_room.options.address.should == 'no Address'
      end
      it "should have default (house) inhabited_state" do
        @green_room.options.inhabited.should be_false
      end
    end

    describe ". The Purple room in a 7 Story House" do
      before(:each) do
        @house.options.story_count = 7
        @house.save
      end
      it "should find the new stroy_count in the house" do
        @purple_room.house.options.story_count.should == 7
      end
      it "should have the house's story_count" do
        @purple_room.options.story_count.should == 7
      end
      it "should have default (house) address" do
        @purple_room.options.address.should == 'no Address'
      end
      it "should have default (house) inhabited_state" do
        @purple_room.options.inhabited.should be_false
      end
    end

    describe ". The Red room being inhabited" do
      before(:each) do
        @red_room.options.inhabited = true
      end
      it "should have the house's story_count" do
        @red_room.options.story_count.should == 1
      end
      it "should have default (house) address" do
        @red_room.options.address.should == 'no Address'
      end
      it "should have default (house) inhabited_state" do
        @red_room.options.inhabited.should be_true
      end
    end

    describe ". The Blue room beeing inhabited in space" do
      before(:each) do
        @house.options.story_count = 2342
        @house.options.address = 'Open Space'
        @house.save
        @blue_room.options.inhabited = true
        @blue_room.save
      end
      it "should have the house's story_count" do
        @blue_room.options.story_count.should == 2342
      end
      it "should have default (house) address" do
        @blue_room.options.address.should == 'Open Space'
      end
      it "should have default (house) inhabited_state" do
        @blue_room.options.inhabited.should be_true
      end

      describe ", reloaded" do
        before(:each) do
          @house = House.find(@house.id)
          @blue_room = Room.find(@blue_room.id)
        end
        it "should have the house's story_count" do
          @blue_room.options.story_count.should == 2342
        end
        it "should have default (house) address" do
          @blue_room.options.address.should == 'Open Space'
        end
        it "should have default (house) inhabited_state" do
          @blue_room.options.inhabited.should be_true
        end
      end

    end
  end
end


