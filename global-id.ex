defmodule GlobalId do
	@moduledoc """
	GlobalId module contains an implementation of a guaranteed globally unique id system.

	Assumption:
		Assumption is that there won't be more than 100 ids issued in a single milli second.
		Thus, timestamp itself can give uniqueness to the id but you can reinforce it with a 3 digits number
		Also, for 20 digits number is the 64 bits long id you were talking about (I am little unsure)
	ID structure:
		Id is a number that consist of 20 digits;
		In a nut shell: [timestamp(), node_id(with magic), 3digits_number(with magic)]
		
		First 13 digits are timestamp generated with the given timestamp function;
		next 4 is a node id, however, if the node id is smaller than 1000, lacking digits will be filled up with 0
		(Example: node_id(1) -> 0001, node_id(522) -> 0552)
		Last 3 digits are there to give uniqueness to the id in order to avoid conflict;
		it is basically a counter that ranges between 000..999
	"""

	@doc """
		get_id
	"""
	@spec get_id(non_neg_integer) :: non_neg_integer
	def get_id(last_id) do
		case make_id(last_id) do
		 	{num, _} when num != last_id ->
				num
			 x ->
				# tuple with an atom of error pops out when an error happens
				IO.inspect {:error, x}
				get_id(last_id)
		end
	end

	def make_id(last_id) do
		[
			timestamp(),
			fill_zero(node_id(), 4),
		 	unique(last_id)
		]
		|> Enum.join("")
		|> Integer.parse()
	end

	def unique(last_id) do
		Integer.digits(last_id+1)
		|> Enum.slice(-3..-1)
		|> Integer.undigits()
		|> fill_zero(3)
	end

	defp fill_zero(num, needed) do
		digits =
			Integer.digits(num)
		len =
			length(digits)
		outcome =
			cond do
				len < needed ->
					joined =
						for _ <- 1..(needed-len) do
								0
						end
					joined++digits
				true -> digits
			end
		Enum.join(outcome, "")
	end

	@spec node_id() :: non_neg_integer
	def node_id

	@doc """
	Returns timestamp since the epoch in milliseconds.
	"""
	@spec timestamp() :: non_neg_integer
	def timestamp
	
end

defmodule X do
	@moduledoc """
		This is for testing.
		Call X.x to see how it will turn out!
		c("./lib/globalid.ex");
		X.x();
	"""

	def x() do
		{last_id, _} = GlobalId.make_id(:erlang.system_time)
		GlobalId.get_id(last_id)
		|> GlobalId.get_id()
		|> X.x()
	end
	def x(last_id) do
		len = (Integer.digits(last_id) |> length())
		IO.inspect {len, last_id}
		:timer.sleep(750)
		GlobalId.get_id(last_id)
		|> X.x()
	end
end
