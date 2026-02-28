defmodule SimpleErp.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :stock, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
