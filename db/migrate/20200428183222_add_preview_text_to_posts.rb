class AddPreviewTextToPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :preview_text, :text
  end
end
