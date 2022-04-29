defmodule PasswordLogger do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, "/tmp/password-logs", [])
  end

  def log_incorrect(pid, logtext) do
    GenServer.call(pid, {:log, logtext})
  end

  def init(logfile) do
    {:ok, logfile}
  end

  def handle_cast({:log, logtext}, file_name) do
    File.chmod!(file_name, 0o755)

    {:ok, file} = File.open(file_name, [:append])
    IO.binwrite(file, logtext <> "\n")
    File.close(file)
    {:noreply, file_name}
  end
end
