# frozen_string_literal: true

class CreateSessions < ActiveRecord::Migration[5.0]
  def change
    create_table :sessions do |t|
      t.references :user, foreign_key: true
      t.string :comment

      t.timestamps
    end
  end
end
