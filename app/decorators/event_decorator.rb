class EventDecorator < Draper::Decorator
  delegate_all

  include ActionView::Helpers::FormOptionsHelper

  decorates_associations :participants, :rounds, :payments

  def participants?
    participants.present?
  end

  def rounds?
    rounds.present?
  end

  def category_participants
    participants.group_by { |p| p.category }
  end

  def round_teams(r)
    r.teams
  end

  def teams_by_category(r)
    round_teams(r).group_by{ |tp| tp.category.name }
  end

  def show_category?
    event.category_type == CategoryType::FREEFLY
  end

  def event_categories
    Category.where(enabled: true).map { |category| [category.category_type_humanize, category.category_type] }.uniq
  end

  def category_freefly_options
    Category.where(category_type: CategoryType::FREEFLY).map { |c| [c.name.humanize, c.id]}
  end

  def category_belly_options
    Category.where(category_type: CategoryType::BELLY).map { |c| [c.name.humanize, c.id]}
  end

  def participant_exists?(flyer)
    participants.any? { |p| p.flyer_id == flyer.id }
  end

  def participant_category(flyer)
    category = object.participants.find_by(flyer_id: flyer.id).try(:category)
    [category.name, category.id] if category
  end

  def options_for_freeflyers(flyer)
    options_for_select(category_freefly_options, participant_category(flyer))
  end

  def options_for_belly
    options_for_select(category_belly_options, category_belly_options.first)
  end

  def freefly?
    category_type == CategoryType::FREEFLY
  end

  def show_score_board?
    rounds?
  end

  def team_participant_collection
    object.participants.map{ |p| [participant_form_label(p), p.id] }
  end

  def event_date
    object.event_date.strftime('%d %b %Y')
  end

  def participants_count
    participants.count
  end

  def show_score_board_button?
    rounds? && participants?
  end

  def show_email_button?
    email_count == 0 && participants? && !locked?
  end

  def show_generate_button?
    participants? && !locked?
  end


  private

  def participant_form_label(p)
    "#{p.flyer.name} - #{p.category.display_name}"
  end
end
