require File.expand_path(File.dirname(__FILE__) + '/../test_helper.rb')

class TestModel < ActiveRecord::Base
  include ::CassandraArchive
end

class CassandraArchiveTest < Test::Unit::TestCase
  context 'archived' do
    setup do
      @record = TestModel.create(:title => "title", :description => "description")
      @record.destroy
    end

    should 'archive record to cassandra after record destroying' do
      assert_archived(@record)
    end

    should 'return the number of archived records' do
      assert_equal 1, TestModel.archived.size

      record_two = TestModel.create(:title => "title", :description => "description")
      record_two.destroy

      assert_equal 2, TestModel.archived.size
    end

    should 'return records archived after specified date if :after option is passed as timestamp' do
      assert_equal 1, TestModel.archived(:after => @record.created_at.to_i).size
    end

    should 'return records archived after specified date if :after option is passed via rails helper' do
      assert_equal 1, TestModel.archived(:after => 10.seconds.ago).size
      assert_equal 0, TestModel.archived(:after => 10.seconds.since(DateTime.current)).size
    end

    should 'go through each archived record if block passed' do
      TestModel.archived do |timestamp, attributes|
        assert_equal attributes['id'], @record.id.to_s
        assert_equal attributes['title'], @record.title
        assert_equal attributes['description'], @record.description
      end
    end
  end

  def assert_archived(record)
    # find archived record, it returns array with two elements
    # first element is key, second is hash with attributes
    archived_record = record.class.archived.find do |key, value|
      value['id'] == record.id.to_s
    end

    # verify that attributes in archived record and active record are the same
    record.attributes.each do |key, value|
      assert_equal archived_record.last[key], value.to_s
    end
  end
end
