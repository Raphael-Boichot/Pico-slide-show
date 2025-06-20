function GB_pixels = ram_decode(GB_tile, PACKET_image_width, PACKET_image_height)

  % Preallocate output image
  PACKET_image = zeros(PACKET_image_height, PACKET_image_width, 'uint8');

  % Number of tiles
  tiles_x = PACKET_image_width / 8;
  tiles_y = PACKET_image_height / 8;

  % Current byte position
  pos = 1;

  for ty = 0 : tiles_y - 1
    for tx = 0 : tiles_x - 1
      tile = zeros(8, 8, 'uint8');
      for row = 1 : 8
        byte1 = GB_tile(pos);
        pos = pos + 1;
        byte2 = GB_tile(pos);
        pos = pos + 1;

        % Vectorized bit extraction: fast 2-bit pixel values
        for col = 1 : 8
          bit_index = 9 - col;  % From MSB to LSB (bit 8 to bit 1)
          low_bit = uint8(bitget(byte1, bit_index));
          high_bit = uint8(bitget(byte2, bit_index));
          tile(row, col) = bitor(bitshift(high_bit, 1), low_bit);
        end
      end

      % Calculate image position
      x = tx * 8 + 1;
      y = ty * 8 + 1;
      PACKET_image(y:y+7, x:x+7) = tile;
    end
  end

  % Convert Game Boy pixel values (0=white, 3=black)
  GB_pixels = 3 - PACKET_image;
