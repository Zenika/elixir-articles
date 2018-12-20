defmodule Brain.Task do
  @moduledoc """
  Define a task.
  """

  defstruct [:hash, :description, :status]

  @doc """
  Build a new task.
  """
  def new(description, status \\ :todo, hash \\ generate_uuid()) do
    %__MODULE__{
      hash: hash,
      description: description,
      status: status
    }
  end

  @doc """
  Build a new task from a map.
  """
  def new_from_map(%{description: _, status: _, hash: _} = map) do
    new(map.description, map.status, map.hash)
  end

  @doc """
  Update the description of a task.
  """
  def update_description(task, description) do
    %{task | description: description}
  end

  @doc """
  Set to `:todo` the status of a task.
  """
  def set_todo(task) do
    %{task | status: :todo}
  end

  @doc """
  Set to `:done` the status of a task.
  """
  def set_done(task) do
    %{task | status: :done}
  end

  @doc """
  Get the valid task status.
  """
  def valid_task_status do
    [:todo, :done]
  end

  @doc """
  Check if a task is valid.
  """
  def valid?(%Brain.Task{} = task) do
    Enum.all?([
      valid_hash?(task.hash),
      Enum.member?(valid_task_status(), task.status)
    ])
  end

  def valid?(_not_a_task) do
    false
  end

  def valid_status?(%Brain.Task{} = task) do
    valid_status?(task.status)
  end

  def valid_status?(status) do
    Enum.member?(valid_task_status(), status)
  end

  def valid_hash?(hash) do
    # Maybe enough right now.
    String.length(hash) == 36
  end

  defp generate_uuid do
    # This is dirty because the Ecto dependency is used only for this right now.
    Ecto.UUID.generate()
  end
end
