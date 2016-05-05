function [ I ] = km_RGB_Show( R , G , B ,show)
%km_RGB_Show  function to create Image from the three Color Channel R,G,B
%   return Image 
I= zeros([size(R) 3]);
I(:,:,1) = R;
I(:,:,2) = G;
I(:,:,3) = B;

if show
    imshow(I)
end

end

