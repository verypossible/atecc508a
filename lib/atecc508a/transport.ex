defmodule ATECC508A.Transport do
  @moduledoc """
  ATECC508A transport behaviour
  """

  @typedoc """
  This is a raw request payload. Do not include a CRC.
  """
  @type payload :: binary()

  @type t :: {module(), any()}

  @callback init(args :: any()) :: {:ok, t()} | {:error, atom()}

  @callback request(
              id :: any(),
              payload(),
              timeout :: non_neg_integer(),
              response_payload_len :: non_neg_integer()
            ) :: {:ok, binary()} | {:error, atom()}

  @callback request_all(id :: any(), [
              {payload(), timeout :: non_neg_integer(), response_payload_len :: non_neg_integer()}
            ]) :: {:ok, {[{:ok, binary()}], [{:error, atom()}]}} | {:error, atom()}

  @callback detected?(arg :: any) :: boolean()

  @callback info(id :: any()) :: map()

  @doc """
  Send a request to the ATECC508A and wait for a response

  ## Sleep/Wake Cycle

  The ATECC508A is assumed to be sleeping. The request order of this function is:

  1. wake flag
  2. provided request
  3. sleep flag

  Sleeping the ATECC508A impacts its state, clearing TempKey and Message Digest
  Buffer for example. If you want to make a request that depends on state from
  a previous request, use `request_all/2` instead.
  """
  @spec request(t(), payload(), non_neg_integer(), non_neg_integer()) ::
          {:ok, binary()} | {:error, atom()}
  def request({mod, arg}, payload, timeout, response_payload_len) do
    mod.request(arg, payload, timeout, response_payload_len)
  end

  @doc """
  Send a series of requests to the ATECC508A and wait for their responses

  ## Sleep/Wake Cycle

  The ATECC508A is assumed to be sleeping. The request order of this function is:

  1. wake flag
  2. all provided requests
  3. sleep flag

  Sleeping the ATECC508A impacts its state, clearing TempKey and Message Digest
  Buffer in SRAM for example.
  """
  @spec request_all(t(), [{payload(), non_neg_integer(), non_neg_integer()}]) ::
          {:ok, {[{:ok, binary()}], [{:error, atom()}]}} | {:error, atom()}
  def request_all({mod, arg}, requests) do
    mod.request_all(arg, requests)
  end

  @doc """
  Check whether the ATECC508A is present

  The transport implementation should do the minimum work to figure out whether
  an ATECC508A is actually present. This is called by users who are unsure
  whether the device has an ATECC508A and want to check before sending requests
  to it.
  """
  @spec detected?(t()) :: boolean()
  def detected?({mod, arg}) do
    mod.detected?(arg)
  end

  @doc """
  Return information about this transport

  This information is specific to this transport. No fields are required.
  """
  @spec info(t()) :: map()
  def info({mod, arg}) do
    mod.info(arg)
  end
end
