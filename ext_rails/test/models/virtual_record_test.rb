require './test/rails_helper'

class Resource < VirtualRecord::Base
  scope :even, -> { select{ |record| record.id.even? } }

  ar_attribute :name
  attribute    :date, :date,     default: ->(record) { record.id.days.from_now.to_date }
  attribute    :odd,  :boolean,  default: ->(record) { record.id.odd? }

  def self.list
    11.times.map{ |i| { id: i, name: "Name #{i}" } } << { id: -1, name: '' }
  end

  def values
    attributes.symbolize_keys
  end
end

class VirtualRecordTest < ActiveSupport::TestCase
  let(:values) do
    Resource.list.map do |r|
      r[:date] = r[:id].days.from_now.to_date
      r[:odd] = r[:id].odd?
      r[:name] = nil if r[:name].blank?
      r
    end
  end
  let(:even){ values.select{ |r| r[:id].even? } }
  let(:sorted){ values.sort_by{ |r| v = r[:name]; [v ? 0 : 1, v] }.reverse }
  let(:paginated){ values[6, 6] }

  around do |test|
    travel_to DateTime.new(2000, 1, 1, 1, 1, 1) do
      test.call
    end
  end

  test '.all' do
    assert_equal values, Resource.all.map(&:values)
  end

  test '.find' do
    assert_equal(resource(5), Resource.find(5).values)
  end

  test '.scope' do
    assert_equal even, Resource.even.map(&:values)
  end

  test '.order and .reverse_order' do
    assert_equal sorted, Resource.order(:name).reverse_order.map(&:values)
  end

  test '.limit and .offset' do
    assert_equal paginated, Resource.limit(10).offset(6).map(&:values)
  end

  test '.where' do
    assert_equal(resource(5),               Resource.where(id: 5, name: 'Name 5').take.values)
    assert_equal(resources(1, 2),           resources_for([id: [1, 2]]))
    assert_equal(resources(-1),             resources_for([name: nil]))
    assert_equal(resources(-1),             resources_for(['name IS NULL'])) # blank
    assert_equal(resources(0, 1),           resources_for(['id >= ?', 0], ['id <= ?', 1]))
    assert_equal(resources(1),              resources_for(['name = ?', 'Name 1']))
    assert_equal(resources(1, 10),          resources_for(['name ILIKE ?', 1]))
    assert_equal(values.size - 2,           resources_for(['name NOT ILIKE ?', 1]).size)
    assert_equal(resources(2, 3),           resources_for(['(name ILIKE ?) OR (name ILIKE ?)', 'Name 2', 'Name 3']))
    assert_equal(resources(*0.step(10, 2)), resources_for(['odd IS NULL OR odd = ?', false]))
    assert_equal(resources(*0.step(10, 2)), resources_for(['odd IS NULL OR odd != ?', true]))
    assert_equal(resources(1, 2),           resources_for(['id IN (?,?)', 1, 2]))
    assert_equal(resources(1, 2),           resources_for(['date BETWEEN ? AND ?', '2000-01-02', DateTime.new(2000, 1, 3)]))
  end

  private

  def resources_for(*sqls)
    sqls.reduce(Resource){ |scope, (sql, *values)| scope.where(sql, *values) }.map(&:values)
  end

  def resources(*ids)
    ids.map{ |id| resource(id) }
  end

  def resource(id)
    values.find{ |r| r[:id] == id }
  end
end
