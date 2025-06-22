function [image_OK,DATA]=image_converter(currentfilename)
  try
    pkg load image
  end
  DATA=[];
  image_OK=0;
  close all
  packets=0;
  [a,map]=imread(currentfilename);
  if not(isempty(map));%dealing with indexed images
    a=ind2gray(a,map);
  end
  [height, width, layers]=size(a);
  a=a(:,:,1);
  C=unique(a);

  if height==112 && width==128
    disp([currentfilename, ' is a legit image without borders, converting...'])
    image_OK=1;
  end

  if height==144 && width==160
    disp([currentfilename, ' is a legit image with borders, extracting...'])
    a=a(17:17+111,17:17+127);
    image_OK=1;
  end

  if image_OK==0
    if rem(width,128)==0 && rem(height,112)==0
      disp([currentfilename, ' is an upscaled image without borders, downscaling...'])
      a=imresize(a,128/width,'nearest');
      image_OK=1;
    end

    if rem(width,160)==0 && rem(height,144)==0
      disp([currentfilename, ' is an upscaled image with borders, downscaling and extracting...'])
      a=imresize(a,160/width,'nearest');
      a=a(17:17+111,17:17+127);
      image_OK=1;
    end
  end

  C=unique(a);
  if length(C)==1 || length(C)>4
    image_OK=0;
  end

  if  image_OK==1
    [height, width, layers]=size(a);
    C=unique(a);

    switch length(C)
      case 4;%4 colors, OK
        Black=C(1);
        Dgray=C(2);
        Lgray=C(3);
        White=C(4);
      case 3;%3 colors, sacrify LG (not well printed)
        Black=C(1);
        Dgray=C(2);
        Lgray=[];
        White=C(3);
      case 2;%2 colors, sacrify LG and DG
        Black=C(1)
        Dgray=[];
        Lgray=[];
        White=C(2);
      end

      hor_tile=width/8;
      vert_tile=height/8;
      tile=0;
      H=1;
      L=1;
      H_tile=1;
      L_tile=1;
      DATA=[];
      y_graph=0;
      total_tiles=hor_tile*vert_tile;
      for x=1:1:hor_tile
        for y=1:1:vert_tile
          tile=tile+1;
          b=a((H:H+7),(L:L+7));
          for i = 1:8
            V1 = repmat('0', 1, 8);  % Initialize binary string V1
            V2 = repmat('0', 1, 8);  % Initialize binary string V2
            for j = 1:8
              if b(i,j) == Lgray
                V1(j) = '1'; V2(j) = '0';
              elseif b(i,j) == Dgray
                V1(j) = '0'; V2(j) = '1';
              elseif b(i,j) == White
                V1(j) = '0'; V2(j) = '0';
              elseif b(i,j) == Black
                V1(j) = '1'; V2(j) = '1';
              end
            end
            DATA = [DATA, bin2dec(V1), bin2dec(V2)];
          end
        end
        L=L+8;
        L_tile=L_tile+1;
        if L>=width
          L=1;
          L_tile=1;
          H=H+8;
          H_tile=H_tile+1;
        end
      end
    else
      disp([currentfilename,' is rejected !'])
      end
