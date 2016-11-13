defmodule Issues.GithubIssues do

  def fetch(user, project) do
    url(user, project)
    |> HTTPoison.get
    |> handle_response
  end

  def url(user, project) do
    "https://api.github.com/repos/#{user}/#{project}/issues"
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    {:ok, Poison.Parser.parse!(body)}
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: code, body: body}}) do
    IO.puts "URL Not found...#{code}"
    {:error, Poison.Parser.parse!(body)}
  end

  def handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    IO.inspect reason
    {:error, Poison.Parser.parse!(reason)}
  end
end
