defmodule CinemaApi.Repo.Migrations.CreateShowtimesTable do
  use Ecto.Migration

  def change do
    create table(:showtimes, primary_key: false) do
      add(:id, :integer, primary_key: true)
      add(:movie_title, :string, primary_key: true)
      add(:showdate, :date, null: false)
      add(:showtime, :time, null: false)
      add(:cinema_hall, :string, null: false)
    end
  end
end
