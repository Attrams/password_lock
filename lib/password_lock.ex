defmodule PasswordLock do
  use GenServer

  def start_link(password) do
    GenServer.start_link(__MODULE__, password, [])
  end

  def unlock(pid, password) do
    GenServer.call(pid, {:unlock, password})
  end

  def reset(pid, {old_password, new_password}) do
    GenServer.call(pid, {:reset, {old_password, new_password}})
  end

  def init(password) do
    {:ok, [password]}
  end

  def handle_call({:unlock, password}, _from, passwords) do
    if password in passwords do
      {:reply, :ok, passwords}
    else
      write_to_logfile(password)
      {:reply, {:error, "wrong password"}, passwords}
    end
  end

  def handle_call({:reset, {old_password, new_password}}, _from, passwords) do
    if old_password in passwords do
      new_state = List.delete(passwords, old_password)
      {:reply, :ok, [new_password | new_state]}
    else
      write_to_logfile(new_password)
      {:reply, {:error, "wrong_password"}, passwords}
    end
  end

  defp write_to_logfile(text) do
    {:ok, pid} = PasswordLogger.start_link()
    PasswordLogger.log_incorrect(pid, "wrong password #{text}")
  end
end
