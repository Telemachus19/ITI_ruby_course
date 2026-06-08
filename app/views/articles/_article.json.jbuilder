json.extract! article, :id, :title, :content, :public, :reports_count, :archived, :user_id, :created_at, :updated_at
json.url article_url(article, format: :json)
