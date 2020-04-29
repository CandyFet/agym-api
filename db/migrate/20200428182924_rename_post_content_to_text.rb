class RenamePostContentToText < ActiveRecord::Migration[6.0]
  def change
    rename_column :posts, :content, :text
  end
end
