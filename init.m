% clear all;
% close all;
% clc;
if (choice == 1)
InputDataSet = IntializeDataSet;
end
if (choice == 2)
net = trainSVM(InputDataSet);
end
if (choice == 3)
pause(0.01);
[file_name file_path] = uigetfile ('*.jpg');
if file_path ~= 0
    im = imread ([file_path,file_name]);
    try 
        im = rgb2gray(im);
    end 
    tic
    im_out = imscan (net,im);
    toc
    figure;imshow(im_out,'notruesize');
end
end
if (choice == 4)
clear all;
clc;
close all;
return;
end    
% end