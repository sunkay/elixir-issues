defmodule Issues.CLI do

  @default_count 4

  @doc """
    'argv' can be -h or --help which returns :help
  """
  def run(argv) do
    argv
    |> parse_args
    |> process
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean],
                                     aliases: [h: :help])
    case parse do
      {[help: true], _, _}
        -> :help
      {_, [user, project, count], _}
        -> {user, project, String.to_integer(count) }
      {_, [user, project], _}
        -> {user, project, @default_count}
      _
        ->  :help
    end
  end

  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [count | #{@default_count}]
    """

    System.halt(0)
  end

  def process({user, project, count}) do
    Issues.GithubIssues.fetch(user,project)
    |> decode_response
    |> print_header
    |> Enum.each(fn x -> get_issue_info(x) end)
  end

  def print_header(body) do
    IO.puts "# | created_at          |  title"
    IO.puts "--------------------------------"
    body
  end

  def get_issue_info(%{"title" => title, "number" => num, "created_at" => created_at}) do
    IO.puts Integer.to_string(num) <> " | " <> created_at <> " | " <> title
  end


  def decode_response({:ok, body}),  do: body
  def decode_response({:error, error}) do
    {_, message} = List.keyfind(error, "message", 0)
    IO.puts "Error fetching from github: #{message}"
    System.halt(2)
  end
end
