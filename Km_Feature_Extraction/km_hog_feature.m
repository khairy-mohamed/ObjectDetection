function [ feature_vector ] = km_hog_feature(img , debug,option)
% calcualte the Histogram of Oriented Gradiant to the Image 
% it is automatically detedt the type of Image 
% Img :: Is The Target Image File 
% debug :: if you want to see the Histogram 

%Constant variable Used in The Algorithm :: 
ang= 180;
cell_size = 8;
block_size = 2;
%Preprocessing Steps 
img_window = im2double(img);

% Indicate The Size of the Image if Greater Than 36 resize It 
[rows ,cols, ch] = size(img_window);
if rows > 36
    img_window = imresize(img_window,[36 36]);
end

%KM_HOG_FEATURE is Hog Feature Extractor for colored Images Implemented By : Khairy Mohammed @ Copy Right 2016 FCIS 
%***********************************************************************************************************************
%   Algorithms Steps source : Dr.Ehab Eisa Lectures Slides [adapted from Navneed Dalal paper]
%   Start The Extraction Main Steps :: 
%   Step1 :: Gama Compression 
%            Goal : Reduce Effect of strongly gradiant overly 
%            Action : replace each pixel color/density by its square root 
%   =======> Increase Performance 
%  ========= Apply Gamma =============


img_window = sqrt(img_window);
%imshow(img_window);



%************************************************************************************************************************
%   Step2 :: Gradiant Computation  
%            Goal : Compute gradiant on all chanels and take the strongest one 
%            Action: Extract The Gradiant by apply 1D centered point discreate drivative
%                    Mask ,,, But It Require filtering the grayscale of the three channel
% ===== Applying The Filter ======= 

 if(ch == 3 )  % in the case of coloured Images 
     [IRX,IRY]=Km_Filter(img_window(:,:,1),3);
     [IGX,IGY]=Km_Filter(img_window(:,:,2),3);
     [IBX,IBY]=Km_Filter(img_window(:,:,3),3);
     Gx = max(max(IRX,IGX),IBX);
     Gy = max(max(IRY,IGY),IBY);
     %R=[IRX,IRY];G =[IGX,IGY];B=[IBX,IBY];
     %show the Image after apply Filters 
     %km_RGB_Show(R,G,B,true);
     
 else    %in the case of bw Images
     [Gx,Gy] = Km_Filter(img_window,0);
 end
%Calculate the Gradiant Of the stronggest channel 
gradiant_magnitude=sqrt(Gy.^2+Gx.^2);
%Show the Image after apply the Gradiant on the three Channels 
%imshow(gradiant_magnitude);
 
%   Step3 :: Spatial and Orientation Binnings  
%            using atan2 return value between (-pi,pi] this result in
%            raduis so we will transform it to degree , the range of the
%            Output is between (-180,180]

orient_ang =atan2(Gx,Gy)*180/pi;
%imshow(orient_ang);
 
%use the Gaussian spatial weighting to calculate the Magnitude of each
%Point to use it in voting after that 
spatial = fspecial('gaussian', [cell_size cell_size], cell_size);
gradiant_magnitude=imfilter(gradiant_magnitude,spatial);
%imshow(gradiant_magnitude);

[npixels_H , npixels_V] = size(orient_ang);
num_cells_H =floor(npixels_H/cell_size);
num_cells_V = floor(npixels_V/cell_size);
orientation_bin = zeros(num_cells_H,num_cells_V,ang/block_size);


%start the defination of cells and blocks Overlapping 
for h=1 : num_cells_H
    for v=1 : num_cells_V
        for b=1 : ang/block_size
            % overlapping The cell and Block by define the boundry each
            % time 
            start_H = (h-1)*cell_size +1;
            end_H = h *cell_size;
            start_V = (v-1)*cell_size +1;
            end_V = v * cell_size;
            cell = zeros(end_H -start_H +1 ,end_V -start_V+1);
          
            %start processing the current cell 
            for c_H=start_H :end_H
                for c_V=start_V :end_V
                    if((orient_ang(c_H,c_V)>=(b-1)*block_size+1)&& (orient_ang(c_H,c_V)< b*block_size))
                        cell(c_H-start_H+1,c_V-start_V+1) = 1;
                    end
                    
                    if(b > 1)
                        if((orient_ang(c_H,c_V)>=(b-2)*block_size+1+block_size/2)&& (orient_ang(c_H,c_V)< (b-1)*block_size))
                            cell(c_H-start_H+1,c_V-start_V+1) = 1 - abs (orient_ang(c_H,c_V) - (b*block_size - block_size/2))/block_size;
                        end
                    end
                    
                    if(b<ang/block_size)
                         if((orient_ang(c_H,c_V)>=(b)*block_size+1)&& (orient_ang(c_H,c_V)< (b+1)*block_size- block_size/2))
                            cell(c_H-start_H+1,c_V-start_V+1) = 1 - abs (orient_ang(c_H,c_V) - (b*block_size - block_size/2))/block_size;
                        end
                    end
                    
                end
            end 
            %feature_vector = size(cell);
            % calculate the hist (Magnitude of the Point * Orientaion ) and
            % add it to the Orientaion bin 
            %the final result is the som os the som of the dot product of
            %the Cell in the strongest gradiant magnitude in the image 
            orientation_bin(h,v,b) = sum(sum(cell .* gradiant_magnitude(start_H:end_H,start_V:end_V)));
        end
        
        if(debug == 1)
           subplot(num_cells_H,num_cells_V, (h-1)*num_cells_V+v);
           vector= permute(orientation_bin(h,v,:),[3,2,1]);
           bar(vector);
           set(gca,'xtick',[],'ytick',[]);
        end
    end
end
% Start The Normaliztion Process Of Feature and Grouping Them In Blocks 

cellInBlock=4;
blockNumI=num_cells_H-1;
blockNumJ=num_cells_V-1;

orient_bin_Block=zeros(blockNumI,blockNumJ,cellInBlock*ang/block_size);
for blockI=1:blockNumI
    for blockJ=1:blockNumJ
        %create Block
        blockVector=zeros(1,cellInBlock*ang/block_size);
        for i=1:2
            for j=1:2
                cellI=(blockI-1)+i;
                cellJ=(blockJ-1)+j;
                vector=permute(orientation_bin(cellI,cellJ,:),[3,2,1]); 
                cellNumInBlock=((i-1)*2+j); 
                blockVector((cellNumInBlock-1)*(ang/block_size)+1:(cellNumInBlock)*(ang/block_size))=vector;
            end
        end 
        %L2%%-Hys
        normBlockVector=blockVector ./ sum(blockVector);
        normBlockVector(normBlockVector(:)>0.2)=0.2;
        normBlockVector=normBlockVector ./ sum(normBlockVector);
        orient_bin_Block(blockI,blockJ,:)=normBlockVector;   
    end
end 

if(strcmp('matrix',option))
feature_vector=orient_bin_Block;
else
    feature_vector=zeros(1,size(orient_bin_Block,1)*size(orient_bin_Block,2)*size(orient_bin_Block,3));
    for i=1:size(orient_bin_Block,1)
        for j=1:size(orient_bin_Block,2)
            for k=1:size(orient_bin_Block,3)
            
            feature_vector((i-1)*size(orient_bin_Block,2)*size(orient_bin_Block,3)+(j-1)*size(orient_bin_Block,3)+k)=orient_bin_Block(i,j,k);
            end
        end
        
    end
end
feature_vector=orient_bin_Block;
end