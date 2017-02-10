defmodule NeuralNode do

  def add_inbound_connection(from_node_pid, weight) do
    add_inbound_connection(Map.new(), from_node_pid, weight)
  end

  def add_inbound_connection(inbound_connections, from_node_pid, weight) do
    connections_from_node_pid = Map.get(inbound_connections, from_node_pid, Map.new())
    new_connection_id = Enum.count(connections_from_node_pid) + 1
    updated_connections_from_node_pid =
      Map.put(connections_from_node_pid, new_connection_id, weight)
    updated_inbound_connections =
      Map.put(inbound_connections, from_node_pid, updated_connections_from_node_pid)
    {updated_inbound_connections, new_connection_id}
  end

  def is_barrier_full?(barrier, inbound_connections) do
    connection_is_in_barrier? =
      (fn {from_node_id, connections_from_node} ->
        find_connection_in_barrier =
          (fn {connection_id, _weight} ->
            Map.has_key?(barrier, {from_node_id, connection_id})
          end)
        Enum.all?(connections_from_node, find_connection_in_barrier)
      end)
    Enum.all?(inbound_connections, connection_is_in_barrier?)
  end

  def remove_inbound_connection(inbound_connections, from_node_id, connection_id) do
    connections_from_node_pid = Map.get(inbound_connections, from_node_id)
    updated_connections_from_node_pid =
      Map.delete(connections_from_node_pid, connection_id)

    case Enum.count(updated_connections_from_node_pid) == 0 do
      true ->
        Map.delete(inbound_connections, from_node_id)
      false ->
        Map.put(inbound_connections, from_node_id, updated_connections_from_node_pid)
    end
  end

  def find_neuron_layer(from_neuron_id, {layer, neuron_structs}) do
    case Map.has_key?(neuron_structs, from_neuron_id) do
      true -> layer
      false -> nil
    end
  end

  def find_neuron_layer(neuron_id, neurons) do
    Enum.find_value(neurons, nil, &find_neuron_layer(neuron_id, &1))
  end

end
