defmodule Brain.MemoryTest do
  use ExUnit.Case

  test "memory creation and get" do
    {:ok, memory} = Brain.Memory.start_link([])
    assert {:ok, []} == memory |> Brain.Memory.get()
    {:ok, memory} = Brain.Memory.start_link([1, 2, 3])
    assert {:ok, [1, 2, 3]} == memory |> Brain.Memory.get()
  end

  test "adding an item to the memory" do
    {:ok, memory} = Brain.Memory.start_link([])
    today_task = Brain.Task.new("Today task mock")
    tomorrow_task = Brain.Task.new("Tomorrow task mock")
    memory |> Brain.Memory.add(today_task)
    assert {:ok, [today_task]} == memory |> Brain.Memory.get()
    memory |> Brain.Memory.add(tomorrow_task)
    assert {:ok, [tomorrow_task, today_task]} == memory |> Brain.Memory.get()
  end

  test "removing an item from the memory" do
    {:ok, memory} = Brain.Memory.start_link([])
    task_1 = Brain.Task.new("1")
    task_2 = Brain.Task.new("2")
    memory |> Brain.Memory.add(task_1)
    memory |> Brain.Memory.add(task_2)
    memory |> Brain.Memory.remove(task_2)
    assert {:ok, [task_1]} == memory |> Brain.Memory.get()
    memory |> Brain.Memory.add(task_2)
    memory |> Brain.Memory.remove(task_1.hash)
    assert {:ok, [task_2]} == memory |> Brain.Memory.get()
  end

  test "validate the memory" do
    {:ok, memory} = Brain.Memory.start_link([])
    assert memory |> Brain.Memory.valid?()
    task_1 = Brain.Task.new("Task 1")
    task_2 = Brain.Task.new("Task 2")
    memory |> Brain.Memory.add(task_1)
    memory |> Brain.Memory.add(task_2)
    assert memory |> Brain.Memory.valid?()
    memory |> Brain.Memory.remove(task_2)
    assert memory |> Brain.Memory.valid?()

    assert_raise RuntimeError, fn ->
      memory |> Brain.Memory.add("Not a task")
    end
  end
end
