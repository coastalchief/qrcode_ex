defmodule EQRCode do
  @moduledoc """
  Simple QR Code Generator written in Elixir with no other dependencies.

  To generate the SVG QR code:

  ```elixir
  qr_code_content = "your_qr_code_content"

  qr_code_content
  |> EQRCode.encode()
  |> EQRCode.svg()
  ```
  """

  alias EQRCode.{Encode, ReedSolomon, Matrix}

  @doc """
  Encode the binary.
  """
  @spec encode(binary) :: Matrix.t()
  def encode(bin) when byte_size(bin) <= 154 do
    data =
      Encode.encode(bin)
      |> ReedSolomon.encode()

    Encode.version(bin)
    |> Matrix.new()
    |> Matrix.draw_finder_patterns()
    |> Matrix.draw_seperators()
    |> Matrix.draw_alignment_patterns()
    |> Matrix.draw_timing_patterns()
    |> Matrix.draw_dark_module()
    |> Matrix.draw_reserved_format_areas()
    |> Matrix.draw_reserved_version_areas()
    |> Matrix.draw_data_with_mask(data)
    |> Matrix.draw_format_areas()
    |> Matrix.draw_version_areas()
    |> Matrix.draw_quite_zone()
  end

  def encode(bin) when is_nil(bin) do
    raise(ArgumentError, message: "you must pass in some input")
  end

  def encode(_),
    do: raise(ArgumentError, message: "your input is too long. keep it under 155 characters")

  @doc """
  Encode the binary with custom pattern bits. Only supports version 5.
  """
  @spec encode(binary, bitstring) :: Matrix.t()
  def encode(bin, bits) when byte_size(bin) <= 106 do
    data =
      Encode.encode(bin, bits)
      |> ReedSolomon.encode()

    Matrix.new(5)
    |> Matrix.draw_finder_patterns()
    |> Matrix.draw_seperators()
    |> Matrix.draw_alignment_patterns()
    |> Matrix.draw_timing_patterns()
    |> Matrix.draw_dark_module()
    |> Matrix.draw_reserved_format_areas()
    |> Matrix.draw_data_with_mask0(data)
    |> Matrix.draw_format_areas()
    |> Matrix.draw_quite_zone()
  end

  def encode(_, _), do: IO.puts("Binary too long.")

  @doc """
  ```elixir
  qr_code_content
  |> EQRCode.encode()
  |> EQRCode.svg(%{color: "#cc6600", shape: "circle", width: 300})
  ```

  You can specify the following attributes of the QR code:

  * `color`: In hexadecimal format. The default is `#000`
  * `shape`: Only `square` or `circle`. The default is `square`
  * `width`: The width of the QR code in pixel. Without the width attribute, the QR code size will be dynamically generated based on the input string.
  * `viewbox`: When set to `true`, the SVG element will specify its height and width using `viewBox`, instead of explicit `height` and `width` tags.

  Default options are `%{color: "#000", shape: "square"}`.
  """
  defdelegate svg(matrix, options \\ %{}), to: EQRCode.SVG
end
