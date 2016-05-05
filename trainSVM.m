function [ trainedSVMnet ] = trainSVM( InputDataSet )
        
%options = optimset('maxiter',100000);

%T = cell2mat(InputDataSet(2,:));
% [x,b,c] = InputDataSet(3,:);
% P = [b,c]; 
net = svmtrain(InputDataSet(3,:),'showplot',true);
%net = svmtrain(P,T,'Kernel_Function','linear','Polyorder',2,'quadprog_opts',options);
% %net = svmtrain(P',T','Kernel_Function','quadratic','Polyorder',4,'quadprog_opts',options);
% %fprintf('done. \n');
% classes = svmclassify(net,P');
% save net net 
trainedSVMnet =net;
end

