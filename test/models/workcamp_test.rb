require 'test_helper'


# TODO - move import tests to different file
class WorkcampTest < ActiveSupport::TestCase

  fixtures :all

  setup do
    @wc = Factory.create(:workcamp, :begin => 1.day.from_now, :end => 10.days.from_now)
  end

  test "have term" do
    @wc.begin = @wc.end = nil
    assert_equal '? - ?', @wc.term
    @wc.begin = Date.new(2002, 3, 27)
    @wc.end = Date.new(2002, 3, 28)

    # TODO: 03.2002 - 28.03.2002' - for the Czech locale
    I18n.locale = :en
    assert_equal "2002-03-27 - 2002-03-28", @wc.term

    I18n.locale = :cz
    assert_equal "27.03.2002 - 28.03.2002", @wc.term
  end

  test "validate based on schema rules" do
    wc = workcamps(:kytlice)
    assert_validates_presence_of wc, :name, :code, :places, :country
  end

  test "workcamps with intentions deletion" do
    wc = workcamps(:xaverov)
    agri = workcamp_intentions(:agri)
    assert wc.intentions.include?(agri)

    assert_nothing_raised do
      wc.destroy
      WorkcampIntention.find(agri.id)
    end
  end

  test 'have scope by year' do
    wc = Factory(:outgoing_workcamp,
                 :begin => Date.new(1848,1,1),
                 :end => Date.new(1848,2,2))
    assert_equal wc, Workcamp.by_year(1848).first
  end

  test 'find first_duplicate' do
    wc = Factory(:outgoing_workcamp,
                 :begin => Date.new(1848,1,1),
                 :end => Date.new(1848,2,2))
    assert_equal wc, Workcamp.find_duplicate(wc)
  end

  test "add intentions" do
    Workcamp.find_each do |wc|
      wc.intentions << WorkcampIntention.first
      assert_nothing_raised {  wc.save! }
    end
  end

  test "conversion to XML" do
    assert_not_nil Workcamp.first.to_xml
  end

  test "csv export" do
    skip 'CSV export not implemented for workcamps'
    assert_not_nil Workcamp.first.to_csv
  end

  # TODO - uncomment when AS is removed
  # should 'ignore temporary workcamps' do
  #   before =  Workcamp.count
  #   2.times { Factory.create(:workcamp, :state => 'imported') }
  #   assert_equal before, Workcamp.count
  # end

end