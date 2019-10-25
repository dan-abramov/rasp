module ModelHelper
  extend ActiveSupport::Concern

  class_methods do
    def define_part_of_week(day)
      if day.on_weekday?
        'weekday'
      elsif day.saturday?
        'saturday'
      elsif day.sunday?
        'sunday'
      end
    end
  end
end
