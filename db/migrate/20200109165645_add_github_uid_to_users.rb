class AddGithubUidToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :github_uid, :string
  end
end
