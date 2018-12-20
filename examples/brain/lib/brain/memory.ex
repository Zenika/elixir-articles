defmodule Brain.Memory do
  use GenServer

  def start_link do
    task_list = Brain.Persistence.read()
    start_link(task_list)
  end

  def start_link(initial_task_list)
      when is_list(initial_task_list) do
    GenServer.start_link(__MODULE__, initial_task_list)
  end

  def get(memory) do
    memory |> GenServer.call({:get})
  end

  def add(memory, task) do
    if Brain.Task.valid?(task) do
      memory |> GenServer.cast({:add, task})
    else
      raise "You are trying to add an invalid task to the memory."
    end
  end

  def remove(memory, %Brain.Task{} = task) do
    remove(memory, task.hash)
  end

  def remove(memory, task_hash) when is_binary(task_hash) do
    memory |> GenServer.cast({:remove, task_hash})
  end

  def save(memory) do
    {:ok, task_list} = get(memory)
    Brain.Persistence.write(task_list)
  end

  def valid?(memory) when is_pid(memory) do
    {:ok, task_list} = get(memory)
    valid?(task_list)
  end

  def valid?(task_list) when is_list(task_list) do
    Enum.all?([
      is_list(task_list),
      task_list |> Enum.all?(fn task -> Brain.Task.valid?(task) end)
    ])
  end

  def init(initial_task_list) do
    {:ok, initial_task_list}
  end

  def handle_call({:get}, _from, task_list) do
    {:reply, {:ok, task_list}, task_list}
  end

  def handle_cast({:add, task}, task_list) do
    {:noreply, [task | task_list]}
  end

  def handle_cast({:remove, task_hash}, task_list) do
    new_task_list =
      task_list
      |> Enum.reject(fn task -> task.hash == task_hash end)

    {:noreply, new_task_list}
  end
end
