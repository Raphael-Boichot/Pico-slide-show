function GB_pixels = ram_decode(GB_tile, PACKET_image_width, PACKET_image_height)

  tiles_x = PACKET_image_width / 8;
  tiles_y = PACKET_image_height / 8;
  total_tiles = tiles_x * tiles_y;

  % Reshape GB_tile into [2, 8, total_tiles] → [row, byte_pair, tile]
  tile_bytes = reshape(GB_tile, 2, 8, total_tiles);
  tile_bytes = permute(tile_bytes, [2, 1, 3]);  % [8, 2, N]

  tile_pixels = zeros(8, 8, total_tiles, 'uint8');

  for row = 1:8
    byte1 = squeeze(tile_bytes(row, 1, :));  % LSB
    byte2 = squeeze(tile_bytes(row, 2, :));  % MSB

    for bit = 1:8
      bit_index = 9 - bit;
      low  = uint8(bitget(byte1, bit_index));
      high = uint8(bitget(byte2, bit_index));
      pixel = bitor(low, bitshift(high, 1));

      tile_pixels(row, bit, :) = pixel;
    end
  end

  % Assemble full image
  GB_pixels = zeros(PACKET_image_height, PACKET_image_width, 'uint8');
  tile_idx = 1;

  for ty = 0 : tiles_y - 1
    for tx = 0 : tiles_x - 1
      x = tx * 8 + 1;
      y = ty * 8 + 1;
      GB_pixels(y:y+7, x:x+7) = tile_pixels(:, :, tile_idx);
      tile_idx = tile_idx + 1;
    end
  end

  % Convert Game Boy values (0 = white, 3 = black)
  GB_pixels = 3 - GB_pixels;
end

