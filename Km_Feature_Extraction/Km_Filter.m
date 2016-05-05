function [Fx,Fy] = Km_Filter( img_channel , n_channels )
%KM_GRADIANT Summary of this function goes here
% simple finite differen filter to each dimention of the image 
%correctig gradient on edges
% if  n_channels ~= 0
%     img_channel =imadjust(img_channel);  %  increases the contrast of the image
% end
[hcol,hrow]=size(img_channel);
temp= ones(hcol+2,hrow+2);
temp(2:1+hcol,2:1+hrow)=img_channel(:,:);

Fx=filter2([1;0;-1],temp);
Fx=Fx(3:hcol,3:hrow);
Fy=filter2([1;0;-1]',temp);
Fy=Fy(3:hcol,3:hrow);

end

