defmodule CinemaApi.Repo.Migrations.CreateMoviesTable do
  use Ecto.Migration

  def change do
    create table(:movies, primary_key: false) do
      add(:id, :integer, primary_key: true)
      add(:imdb_id, :string)
      add(:title, :string)
      add(:year, :string)
      add(:release_date, :date)
      add(:runtime, :string)
      add(:genre, :string)
      add(:director, :string)
      add(:actors, :string)
      add(:plot, :string)
      add(:poster, :string)
      add(:language, :string)
      add(:country, :string)
      add(:awards, :string)
      add(:imdb_rating, :string)
      # TODO: Add this ratings later
      # field(:rooten_tomatoes_rating, :string)
      # field(:metacritic_rating, :string)
      add(:media_type, :string)
      add(:box_office, :string)
      add(:production, :string)
      add(:website, :string)

      timestamps()
    end
  end
end
