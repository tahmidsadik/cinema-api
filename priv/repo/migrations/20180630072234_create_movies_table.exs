defmodule CinemaApi.Repo.Migrations.CreateMoviesTable do
  use Ecto.Migration

  def change do
    create table(:movies, primary_key: false) do
      add(:id, :serial, primary_key: true)
      add(:imdb_id, :string)
      add(:title, :string)
      add(:year, :string)
      add(:release_date, :date)
      add(:runtime, :string)
      add(:genre, :string)
      add(:director, :string)
      add(:actors, :string)
      add(:plot, :text)
      add(:poster, :string)
      add(:language, :string)
      add(:country, :string)
      add(:awards, :string)
      add(:imdb_rating, :string)
      add(:media_type, :string)
      add(:box_office, :string)
      add(:production, :string)
      add(:website, :string)
      add(:o_actors, :string)
      add(:o_plot, :text)
      add(:o_director, :string)
      add(:o_release_date, :string)
      add(:o_runtime, :string)
      add(:o_genre, :string)

      timestamps()
    end
  end
end
