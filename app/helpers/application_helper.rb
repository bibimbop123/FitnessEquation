# frozen_string_literal: true

module ApplicationHelper
  def calculate_age(dob)
    now = Time.now.utc.to_date
    age = now.year - dob.year
    age -= 1 if now < dob + age.years # Adjust if the birthday hasn't occurred yet this year
    age
  end
end
