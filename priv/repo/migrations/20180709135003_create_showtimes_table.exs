defmodule CinemaApi.Repo.Migrations.CreateShowtimesTable do
  use Ecto.Migration

  def change do
    create table(:showtimes, primary_key: false) do
      add(:id, :serial, primary_key: true)
      add(:imdb_id, :string)
      add(:title, :string, null: false)
      add(:showtime, :utc_datetime, null: false)
      add(:cinemahall, :string, null: false)
    end
  end
end
