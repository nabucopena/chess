defmodule Chess do
  @moduledoc """
  Chess keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def move(board, piece_tile, final_tile) do
    if legal_move?(board, piece_tile, final_tile) do
      new_board = List.replace_at(
        List.replace_at(board, piece_tile, "_"),
        final_tile,
        Enum.at(board, piece_tile)
      )
      {:ok, new_board}
    else
      {:error}
    end
  end

  def empty_tiles?(board, tiles) do
    Enum.all?(tiles, fn x -> Enum.at(board, x) == "_" end)
  end

  def legal_move?(board, piece_tile, final_tile) do
    {_, player} = Enum.at(board, piece_tile)
    {_, target_player} = Enum.at(board, final_tile)
    if {:ok, tiles} == possible_move?(board, piece_tile, final_tile) do
      if player == target_player do
        {:error, :same_player_piece}
      else
        if Empty_tiles?(
          List.delete(List.delete(tiles, piece_tile), final_tile)
        ) do
          if check?(board, piece_tile, final_tile) do
            {:error, :check}
          else
            {:ok}
          end
        else
          {:error, :blocked_route}
        end
      end
    else
      {:error, :impossible_move}
    end
  end

  def possible_move?(board, piece_tile, final_tile) do
    piece = Enum.at(board, piece_tile)
    case piece do
      {:pawn, :white} ->
        if final_tile == piece_tile + 8 ||
          final_tile == piece_tile + 16 &&
            piece_tile < 16 do
          {:ok, [piece_tile + 8, final_tile]}
        end

      {:pawn, :black} ->
        if final_tile == piece_tile - 8 ||
          final_tile == piece_tile - 16 &&
            piece_tile > 47 do
          {:ok, [piece_tile + 8, final_tile]}
        end

      {:knight, player} ->
        tiles = [
          [16, 1],
          [16, -1],
          [-16, 1],
          [-16, -1],
          [8, 2],
          [8, -2],
          [-8, 2],
          [-8, -2]
        ]
        if Enum.any?(tiles, fn x ->
          rem(final_tile, 8) + Enum.at(x, 1) == rem(piece_tile, 8) &&
            final_tile + Enum.at(x, 1) == piece_tile + Enum.at(x, 0)
        end) do
          {:ok, [final_tile]}
        end

      {:bishop, player} ->
        if rem(final_tile, 8) - div(final_tile, 8) ==
          rem(piece_tile, 8) - div(piece_tile, 8) do
          {:ok,
            Enum.filter(
              piece_tile..final_tile,
              fn x ->
                rem(x, 8) - div(x, 8) == rem(piece_tile, 8) - div(piece_tile, 8)
              end
            )
          } 
        else if rem(piece_tile, 8) + div(piece_tile, 8) ==
          rem(final_tile, 8) + div(final_tile, 8) do
            {:ok,
              Enum.filter(piece_tile..final_tile,
                fn x ->
                  rem(x, 8) + div(x, 8) == rem(piece_tile, 8) + div(piece_tile, 8)
                end
              )
            } 
          end
        end

      {:rook, player} ->
        if rem(final_tile, 8) == rem(piece_tile, 8) do
          {:ok,
            Enum.filter(
              piece_tile..final_tile,
              fn x -> rem(x, 8) == rem(piece_tile, 8) end
            )
          }
        else
          if div(final_tile, 8) == div(piece_tile, 8) do
            {:ok,
              Enum.filter(
                piece_tile..final_tile,
                fn x -> div(x, 8) == div(piece_tile, 8) end
              )
            }
          end
        end

      {:queen, player} ->
        cond do
          rem(final_tile, 8) == rem(piece_tile, 8) ->
            {:ok,
              Enum.filter(
                piece_tile..final_tile,
                fn x -> rem(x, 8) == rem(piece_tile, 8) end
              )
            }

          div(final_tile, 8) == div(piece_tile, 8) ->
            {:ok,
              Enum.filter(
                piece_tile..final_tile,
                fn x -> div(x, 8) == div(piece_tile, 8) end
              )
            }

          rem(final_tile, 8) - div(final_tile, 8) ==
            rem(piece_tile, 8) - div(piece_tile, 8) ->
            {:ok,
              Enum.filter(
                piece_tile..final_tile,
                fn x ->
                  rem(x, 8) - div(x, 8) ==
                    rem(piece_tile, 8) - div(piece_tile, 8)
                end)
            }

          rem(piece_tile, 8) + div(piece_tile, 8) ==
            rem(final_tile, 8) + div(final_tile, 8) ->
            {:ok,
              Enum.filter(piece_tile..final_tile,
                fn x ->
                  rem(x, 8) + div(x, 8) ==
                    rem(piece_tile, 8) + div(piece_tile, 8)
                end)
            }

          true ->
            nil
        end

      {:king, player} ->
        if rem(final_tile, 8) > rem(piece_tile, 8) - 2 &&
          rem(final_tile, 8) < rem(piece_tile, 8) + 2 &&
            div(final_tile, 8) > div(piece_tile, 8) - 2 &&
              div(final_tile, 8) < div(piece_tile, 8) + 2 do
          {:ok, [final_tile]}
        end
    end
  end



end
