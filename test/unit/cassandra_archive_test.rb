# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../test_helper.rb')

class TestModel < ActiveRecord::Base
  include ::CassandraArchive

  def cassandra_archive_attributes
    [:id, :firstname, :lastname, :fullname]
  end

  def fullname
    "#{firstname} #{lastname}"
  end
end

class CassandraArchiveTest < Test::Unit::TestCase
  context 'archived' do
    setup do
      @record = TestModel.create(:firstname => "firstname", :lastname => "lastname")
      @record.destroy
    end

    should 'archive record to cassandra after record destroying' do
      archived_record = find_archived_record(@record)

      assert_equal @record.id.to_s, archived_record['id']
      assert_equal @record.firstname, archived_record['firstname']
      assert_equal @record.lastname, archived_record['lastname']
      assert_equal @record.fullname, archived_record['fullname']

      # we didn't list created_at attribute in cassandra_archive_attributes method, so it should not be archived
      assert_equal nil, archived_record['created_at']
    end

    should 'archive record if attributes contain not ASCII chars' do
      @record = TestModel.create(:firstname => "Иван", :lastname => "Иванов")
      @record.destroy

      archived_record = find_archived_record(@record)

      assert_equal @record.id.to_s, archived_record['id']
      assert_equal @record.firstname, archived_record['firstname']
      assert_equal @record.lastname, archived_record['lastname']
      assert_equal @record.fullname, archived_record['fullname']

      # we didn't list created_at attribute in cassandra_archive_attributes method, so it should not be archived
      assert_equal nil, archived_record['created_at']
    end

    should 'set archived_at attribute' do
      time = DateTime.current
      DateTime.stubs(:current).returns(time)

      archived_at = time.to_i.to_s

      record = TestModel.create(:firstname => "firstname", :lastname => "lastname")
      record.destroy

      archived_record = find_archived_record(@record)
      assert_equal archived_at, archived_record['archived_at']
    end

    should 'return the number of archived records' do
      assert_equal 1, TestModel.archived.size

      another_record = TestModel.create(:firstname => "firstname", :lastname => "lastname")
      another_record.destroy

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
        assert_equal @record.id.to_s, attributes['id']
        assert_equal @record.firstname, attributes['firstname']
        assert_equal @record.lastname, attributes['lastname']
        assert_equal @record.fullname, attributes['fullname']

        # we didn't list created_at attribute in cassandra_archive_attributes method, so it should not be archived
        assert_equal nil, attributes['created_at']
      end
    end
  end

  def find_archived_record(record)
    # find archived record, it returns array with two elements
    # first element is key, second is hash with attributes
    archived_record = record.class.archived.find do |key, value|
      value['id'] == record.id.to_s
    end

    # return record attributes
    archived_record.last
  end
end
