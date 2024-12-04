class AddSpokenLanguageToProposal < ActiveRecord::Migration[6.1]
  def change
    add_column :proposals, :spoken_language, :string
  end
end
