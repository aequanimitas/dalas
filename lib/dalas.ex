defmodule Dalas do
  @moduledoc """
  Documentation for Dalas.

  TODO:
  - make sure that the client matches allocated frequency
  - limit a client to 3 frequencies max
  """

  # API
  def start(name) when not is_atom(name), do: :error
  def start(name) do
    # catch so no dangling processes
    case name in Process.registered() do
      true ->
        :error
      false ->
        frequencies =
          1..10
          |> Enum.to_list()

        spawn(__MODULE__, :init, [{frequencies, %{}}])
        |> Process.register(name)
    end
  end

  def terminate(loop_data)

  def init({available_frequencies, allocated_frequencies}) do
    {available_frequencies, allocated_frequencies}
    |> initialize()
    |> loop()
  end

  @doc "Do nothing"
  def initialize(args), do: args

  def allocate(name), do: call(name, :allocate)
  def deallocate(name, frequency), do: call(name, {:deallocate, frequency})

  # Message handling
  def handle_msg({from, :allocate}, {[], map}), do: {:error, :empty}
  def handle_msg({from, :allocate}, {[frequency | free], map}) do
    case Map.has_key?(map, from) do
      true ->
        case length(Map.get(map, from)) == 3 do
          true ->
            {:error, :max}
          false ->
            lst = Map.get(map, from)
            new_loop_data = {free, Map.put(map, from, [frequency | lst])}
            {frequency, new_loop_data}
        end
      false ->
        new_loop_data = {free, Map.put(map, from, [frequency])}
        {frequency, new_loop_data}
    end
  end

  def handle_msg({from, {:deallocate, frequency}}, {frequencies, map}) do
    case Map.has_key?(map, from) do
      true ->
        case frequency in Map.get(map, from) do
          true ->
            lst = map |> Map.get(from) |> Enum.reject(fn f -> f == frequency end)
            {:ok, {[frequency | frequencies], Map.put(from, lst)}}
          false ->
            {:error, :instance}
        end
      false ->
        {:error, :instance}
    end
  end

  # Server
  def call(name, request) do
    send(name, {:request, self(), request})
    receive do
      {:reply, reply} ->
        reply
    end
  end

  def loop({available_frequencies, allocated_frequencies} = state) do
    receive do
      {:request, from, request} ->
        {reply, new_state} = handle_msg(request, state)
        reply(from, reply)
        loop(new_state)
      :stop ->
        :ok
    end
  end

  def reply(from, reply), do: send(from, {:reply, reply})

  defmodule Patrick do
    @moduledoc """
    Dummy process
    """

    def start, do: spawn(__MODULE__, :loop, [])

    # API to process
    def stop
    
    # API to server
    def get_frequency do
    
    # internal
    def save_frequency(frequency), do: call({:add, frequency})

    # Server
    def call(message) do
      send(self(), {:request, message})
      receive do
        {:reply, reply} -> reply
      end
    end

    def reply(from, reply), do: send(from, {:reply, reply})
    def loop(state) do
      receive do
        {:request, message} ->
      
        :stop ->
          Process.exit(self(), :kill)
        _ ->
          loop()
      end
    end
  end
end
