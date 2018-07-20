defmodule CinemaApi.Repo.Migrations.CreateShowtimesTable do
  use Ecto.Migration

  def change do
    create table(:showtimes, primary_key: false) do
      add(:id, :bigserial, primary_key: true)
      add(:movie_id, references(:movies))
      add(:imdb_id, :string)
      add(:title, :string, null: false)
      add(:showtime, :utc_datetime, null: false)
      add(:cinemahall, :string, null: false)

      timestamps()
    end

    create(
      unique_index(
        :showtimes,
        [:movie_id, :showtime, :cinemahall],
        name: "mid-showtime-cinemahall-comp-key"
      )
    )
  end
end
