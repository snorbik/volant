class ApplyFormSerializer < ActiveModel::Serializer
  attributes :id, :fee, :general_remarks, :motivation, :confirmed, :created_at
  has_one :volunteer, embed: :ids, include: true
  has_many :workcamp_assignments, embed: :ids, include: true
end
