class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :content
      t.boolean :public, default: true, null: false
      t.integer :reports_count, default: 0, null: false
      t.boolean :archived, default: false, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
