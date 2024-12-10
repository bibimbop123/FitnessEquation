json.extract! snapshot, :id, :user_id, :height_cm, :weight_kg, :activity_level, :goal_weight_kg, :predicted_time_weeks, :calorie_deficit_per_day, :created_at, :updated_at
json.url snapshot_url(snapshot, format: :json)
