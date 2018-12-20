defmodule Brain.TaskTest do
  use ExUnit.Case

  test :new do
    task = Brain.Task.new("Thing to do")
    assert Brain.Task.valid?(task)
    task = Brain.Task.new("Thing to do", :done)
    assert Brain.Task.valid?(task)
  end

  test :new_from_map do
    task =
      Brain.Task.new_from_map(%{
        description: "Thing to do",
        status: :todo,
        hash: "b71a8c7b-4b7d-41b7-bddf-7b26762e1881"
      })

    assert Brain.Task.valid?(task)

    assert_raise FunctionClauseError, fn ->
      Brain.Task.new_from_map(%{
        description: "Thing to do",
        status: :todo
      })
    end

    assert_raise FunctionClauseError, fn ->
      Brain.Task.new_from_map(%{
        description: "Thing to do",
        hash: "b71a8c7b-4b7d-41b7-bddf-7b26762e1881"
      })
    end

    assert_raise FunctionClauseError, fn ->
      Brain.Task.new_from_map(%{
        status: :todo,
        hash: "b71a8c7b-4b7d-41b7-bddf-7b26762e1881"
      })
    end
  end

  test :update_description do
    task =
      Brain.Task.new("Thing to do")
      |> Brain.Task.update_description("Thing I should do")

    assert task.description == "Thing I should do"
  end

  test :set_todo do
    task =
      Brain.Task.new("Thing to do", :done)
      |> Brain.Task.set_todo()

    assert task.status == :todo
  end

  test :set_done do
    task =
      Brain.Task.new("Thing already done")
      |> Brain.Task.set_done()

    assert task.status == :done
  end

  test :valid? do
    task = Brain.Task.new("Thing to do")

    assert task |> Brain.Task.valid?()

    task = Brain.Task.new("Thing already done", :done)

    assert task |> Brain.Task.valid?()

    task =
      Brain.Task.new(
        "Thing to do with invalid status",
        :invalid_status
      )

    refute task |> Brain.Task.valid?()
  end
end
