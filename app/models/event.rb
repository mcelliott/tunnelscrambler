class Event < ActiveRecord::Base
  has_paper_trail
  has_many :participants, dependent: :destroy
  has_many :rounds, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :teams

  has_enumeration_for :category_type, with: CategoryType, create_helpers: { prefix: true }

  validates :event_date, presence: true
  validates :name,       presence: true, length: { maximum: 50 }
  validates :team_size,  presence: true, numericality: true
  validates :num_rounds,     presence: true, numericality: true
  validates_numericality_of :team_size, greater_than_or_equal_to: 2

  monetize :participant_cost, allow_nil: false,
    numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 10000
  }

  monetize :rate_per_minute, allow_nil: false,
    numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 10000
  }

  def title
    "#{name} - #{event_date}"
  end

  def categories_participants
    participants.group_by { |p| p.category }
  end

  def number_of_teams
    (participants.count / team_size.to_f).ceil
  end

  def number_of_teams_by_category(category_id)
    (participants.where(category_id: category_id).count / team_size.to_f).ceil
  end
end
