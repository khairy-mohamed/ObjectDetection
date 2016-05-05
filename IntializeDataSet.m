function [ InputDataSet ] = IntializeDataSet( )
%INTIALIZEDATASET Initialize thefeature frome the date set and load them
%into a matrix 
%   Extract the Feature from the Images

face_folder = 'DataSet/training_base/faces/';
non_face_folder = 'DataSet/training_base/non_faces/';
if exist('InputDataSet.mat','file')
    load InputDataSet;
else
    InputDataSet = cell (3,zeros());
end
%extract the feature from the faces classes 
image_files = dir(fullfile(strcat(face_folder ,'*.jpg')) );    
num_images = length(image_files);
for k =1:num_images
    string = [face_folder,image_files(k,1).name];
    image = imread(strcat(face_folder,image_files(k,1).name));    
    features = km_hog_feature(image,0,'matrix');
    InputDataSet {1,k} = string;
    InputDataSet {2,k} = 1;
    InputDataSet {3,k} = features;
    fprintf(strcat( image_files(k,1).name,'\n'));
end

%extract the feature from the non-faces classes 
image_files = dir(fullfile(strcat(non_face_folder,'*.jpg')) ); 
num_images = length(image_files);
for k=1:num_images
    string = [non_face_folder,image_files(k,1).name];
    image = imread(strcat(non_face_folder,image_files(k,1).name));    
    features = km_hog_feature(image,0,'matrix');
    InputDataSet  {1,k}= string;
    InputDataSet  {2,k} = 0;
    InputDataSet  {3,k} = features;
    fprintf(strcat( image_files(k,1).name,'\n'));
end
save InputDataSet InputDataSet;
end

