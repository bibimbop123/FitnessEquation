
desc "Fill the database tables with some sample data"
task({ :sample_data => :environment }) do
  current_user = User.first

  25.times do 
    user = User.new
    user.email = Faker::Name.first_name + "@example.com"
    user.password = "password"
    user.save

    puts "Created user with email: #{user.email}"
  end
  25.times do
    snapshot = Snapshot.new
    snapshot.user_id = current_user.id
    snapshot.height_cm = rand(150..200)
    snapshot.weight_kg = rand(50..150)
    snapshot.activity_level = ["sedentary", "lightly active", "moderately active", "very active"].sample
    snapshot.goal_weight_kg = rand(50..100)
    snapshot.predicted_time_weeks = rand(1..52)
    snapshot.calorie_deficit_per_day = rand(500..1000)  

    snapshot.save 

    puts "Created snapshot with user_id: #{snapshot.user_id}"

  end

end
