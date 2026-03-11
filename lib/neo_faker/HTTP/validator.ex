defmodule NeoFaker.HTTP.Validator do
  @moduledoc false

  alias NeoFaker.Helpers.Options

  @user_agent_types [:all, :browser, :crawler]
  @status_code_types [:detailed, :simple]
  @status_code_groups [:information, :success, :redirection, :client_error, :server_error]

  @doc """
  Validates the user agent type option.

  Raises `ArgumentError` if the type is not one of `#{inspect([:all, :browser, :crawler])}`.
  """
  @spec validate_user_agent_type!(atom()) :: :ok
  def validate_user_agent_type!(type) do
    case Options.validate_enum(:type, type, @user_agent_types) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @doc """
  Validates the status code type option.

  Raises `ArgumentError` if the type is not one of `#{inspect([:detailed, :simple])}`.
  """
  @spec validate_status_code_type!(atom()) :: :ok
  def validate_status_code_type!(type) do
    case Options.validate_enum(:type, type, @status_code_types) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @doc """
  Validates the status code group option.

  Accepts `nil` (no group filter) or one of
  `#{inspect([:information, :success, :redirection, :client_error, :server_error])}`.
  Raises `ArgumentError` for any other value.
  """
  @spec validate_status_code_group!(atom() | nil) :: :ok
  def validate_status_code_group!(nil), do: :ok

  def validate_status_code_group!(group) do
    valid_groups = [nil | @status_code_groups]

    case Options.validate_enum(:group, group, valid_groups) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end
end
