defmodule Brain.CLI do
  @switches [
    list: :boolean,
    only: :string,
    add: :string,
    status: :string,
    remove: :string
  ]

  @aliases [
    l: :list,
    o: :only,
    a: :add,
    s: :status,
    r: :remove
  ]

  def main(argv) do
    {parsed, _rest} = parse!(argv)
    do_operation(parsed)
  end

  def parse!(argv) do
    OptionParser.parse!(
      argv,
      strict: @switches,
      aliases: @aliases
    )
  end

  def do_operation(parsed) do
    cond do
      add_operation?(parsed) -> add_operation(parsed[:add], parsed[:status])
      remove_operation?(parsed) -> remove_operation(parsed[:remove])
      list_operation?(parsed) -> list_operation(parsed[:only])
      true -> raise "No operation specified."
    end
  end

  def add_operation(task_description, nil = _task_status) do
    add_operation(task_description, :todo)
  end

  def add_operation(task_description, task_status)
  when is_binary(task_status) do
    task_status = String.to_atom(task_status)
    check_task_status!(task_status)
    add_operation(task_description, task_status)
  end

  def add_operation(task_description, task_status) do
    memory = load_memory()
    new_task = Brain.Task.new(task_description, task_status)
    memory |> Brain.Memory.add(new_task)
    save_memory(memory)
  end

  def remove_operation(task_hash) do
    memory = load_memory()
    Brain.Memory.remove(memory, task_hash)
    save_memory(memory)
  end

  def list_operation(only) do
    memory = load_memory()
    {:ok, task_list} = Brain.Memory.get(memory)

    task_list =
      if only do
        only = String.to_atom(only)
        task_list |> Enum.filter(fn task -> task.status == only end)
      else
        task_list
      end

    IO.inspect(task_list)
  end

  def load_memory do
    persisted_memory = Brain.Persistence.read()
    {:ok, memory} = Brain.Memory.start_link(persisted_memory)
    memory
  end

  def save_memory(memory) do
    Brain.Persistence.write(memory)
  end

  defp add_operation?(parsed) do
    parsed[:add] != nil
  end

  defp remove_operation?(parsed) do
    parsed[:remove] != nil
  end

  defp list_operation?(parsed) do
    parsed[:list] != nil
  end

  defp check_task_status!(task_status) do
    unless Brain.Task.valid_status?(task_status) do
      valid_status =
        Brain.Task.valid_task_status
        |> Enum.map(fn status -> Atom.to_string(status) end)
        |> Enum.join(", ")
      IO.puts("Invalid status #{task_status} (could be: #{valid_status}).")
      System.halt()
    end
  end
end
