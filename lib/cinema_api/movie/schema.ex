defmodule CinemaApi.Movie.Schema do
  use Ecto.Schema

  schema "movies" do
    field(:imdb_id, :id)
    field(:title, :string)
    field(:year, :string)
    field(:release_date, :date)
    field(:runtime, :time)
    field(:genre, :string)
    field(:director, :string)
    field(:actors, {:array, :string})
    field(:plot, :string)
    field(:poster, :string)
    field(:language, :string)
    field(:country, :string)
    field(:awards, :string)
    field(:imdb_rating, :string)
    # TODO: Add this ratings later
    # field(:rooten_tomatoes_rating, :string)
    # field(:metacritic_rating, :string)
    field(:media_type, :string)
    field(:box_office, :string)
    field(:production, :string)
    field(:website, :string)
  end
end
