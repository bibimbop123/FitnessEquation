# frozen_string_literal: true

desc 'Fill the database tables with some sample data'
task({ sample_data: :environment }) do
  current_user = User.first

  25.times do
    user = User.new
    user.email = "#{Faker::Name.first_name}@example.com"
    user.password = 'password'
    user.dob = Date.today - rand(18..65).years # Add a random dob to satisfy the presence validation

    if user.save
      puts "Created user with email: #{user.email}"
    else
      puts "Failed to create user: #{user.errors.full_messages.join(', ')}"
    end
  end

  25.times do
    snapshot = Snapshot.new
    snapshot.user_id = current_user.id
    snapshot.height_cm = rand(150..200)
    snapshot.weight_kg = rand(50..150)
    snapshot.activity_level = [
      'Sedentary (Little to no physical activity)', 'Lightly Active (Light exercise or sports 1-3 days per week or moderate physical activity)',
      'Moderately Active (Moderate exercise or sports 3-5 days per week)', 'Very Active (Hard exercise or sports 6-7 days per week or a physically demanding job)',
      'Super Active (Very intense exercise physical training twice daily or an extremely physically demanding job)'
    ].sample
    snapshot.goal_weight_kg = rand(50..100)
    snapshot.predicted_time_weeks = rand(1..52)
    snapshot.calorie_deficit_per_day = rand(500..1000)

    if snapshot.save
      puts "Created snapshot with user_id: #{snapshot.user_id}"
    else
      puts "Failed to create snapshot: #{snapshot.errors.full_messages.join(', ')}"
    end
  end
end
