defmodule Brain.Persistence do
  @persistence_file "./brain.json"

  def read do
    if File.exists?(@persistence_file) do
      task_list =
        File.read!(@persistence_file)
        |> Poison.decode!()
        |> convert_string_keys_to_atom()
        |> Enum.map(fn task -> Brain.Task.new_from_map(task) end)
        |> convert_status_string_to_atom()

      unless Brain.Memory.valid?(task_list) do
        raise "Invalid task format from #{@persistence_file}."
      end

      task_list
    else
      IO.puts("No file found")
      []
    end
  end

  def write(memory) when is_pid(memory) do
    {:ok, task_list} = Brain.Memory.get(memory)
    write(task_list)
  end

  def write(task_list) when is_list(task_list) do
    unless Brain.Memory.valid?(task_list) do
      raise "Invalid task from the memory."
    end

    File.touch!(@persistence_file)
    File.write!(@persistence_file, task_list |> Poison.encode!())
  end

  defp convert_string_keys_to_atom(task_list) do
    task_list
    |> Enum.map(fn task ->
      for {key, val} <- task, into: %{} do
        {String.to_atom(key), val}
      end
    end)
  end

  defp convert_status_string_to_atom(task_list) do
    task_list
    |> Enum.map(fn task ->
      %Brain.Task{task | status: String.to_atom(task.status)}
    end)
  end
end
