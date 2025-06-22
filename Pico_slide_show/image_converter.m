function [image_OK, DATA] = image_converter(currentfilename)
  try
    pkg load image
  end

  DATA = [];
  image_OK = 0;
  close all;

  %% --- Load Image ---
  [a, map] = imread(currentfilename);
  if ~isempty(map)
    a = ind2gray(a, map);
  end
  a = a(:,:,1);  % Only 1 channel

  [height, width] = size(a);

  %% --- Format Detection and Adjustment ---
  if height == 112 && width == 128
    disp([currentfilename, ' is a legit image without borders, converting...']);
    image_OK = 1;

  elseif height == 144 && width == 160
    disp([currentfilename, ' is a legit image with borders, extracting...']);
    a = a(17:17+111, 17:17+127);
    image_OK = 1;

  elseif mod(width,128) == 0 && mod(height,112) == 0
    disp([currentfilename, ' is an upscaled image without borders, downscaling...']);
    a = imresize(a, [112, 128], 'nearest');
    image_OK = 1;

  elseif mod(width,160) == 0 && mod(height,144) == 0
    disp([currentfilename, ' is an upscaled image with borders, downscaling and extracting...']);
    a = imresize(a, [144, 160], 'nearest');
    a = a(17:17+111, 17:17+127);
    image_OK = 1;

  else
    disp([currentfilename, ' has unsupported dimensions and is rejected.']);
    return;
  end

  %% --- Validate Color Palette ---
  C = unique(a);
  if length(C) == 1 || length(C) > 4
    disp([currentfilename, ' rejected due to invalid color count.']);
    image_OK = 0;
    return;
  end

  %% --- Map Colors to Levels ---
  switch length(C)
    case 4
      Black = C(1); Dgray = C(2); Lgray = C(3); White = C(4);
    case 3
      Black = C(1); Dgray = C(2); Lgray = [];   White = C(3);
    case 2
      Black = C(1); Dgray = [];   Lgray = [];   White = C(2);
  end

  %% --- Tile Conversion ---
  [height, width] = size(a);
  hor_tile = width / 8;
  vert_tile = height / 8;
  total_tiles = hor_tile * vert_tile;

  DATA = zeros(1, total_tiles * 16, 'uint8');  % Preallocate
  data_index = 1;
  pow2 = uint8(2.^(7:-1:0));  % Reuse

  for y_tile = 1:vert_tile
    for x_tile = 1:hor_tile
      H = (y_tile - 1) * 8 + 1;
      L = (x_tile - 1) * 8 + 1;
      block = a(H:H+7, L:L+7);

      for i = 1:8
        row = block(i, :);

        V1 = uint8((~isempty(Lgray) & (row == Lgray)) | (row == Black));
        V2 = uint8((~isempty(Dgray) & (row == Dgray)) | (row == Black));

        DATA(data_index)     = sum(V1 .* pow2);
        DATA(data_index + 1) = sum(V2 .* pow2);
        data_index = data_index + 2;
      end
    end
  end
end

