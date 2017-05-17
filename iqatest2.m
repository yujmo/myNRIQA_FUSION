clear ;
clc;
close all;
warning('off'); % ����ʾwarning
                    
% ѡ�����ݿ�
dataset_names={'CID2013','LIVE','TID2013'};
dataset_name=dataset_names{1};% ѡ�����ݿ�
% load best_svr_param_tid2013;

%% ������ȡ   
% fetchFeatureAll(dataset_name);
%% ��������
load(['my_mat_' lower(dataset_name)]);
% ȥ���ο�ͼ��
%  load('..\Datasets\LIVE\dmos_realigned.mat');
%  orgs2=orgs(1:end-174);
% inx=find(orgs2==1);
%  my_mat(inx,:)=[];
%% ����ѡ��
my_mat=[my_mat(:,1) my_mat(:,25:31) my_mat(:,56:62) my_mat(:,end)]; % mn+nss
%% ȥ�������ʵ�����
my_mat(404,:)=[];
cnt_data=size(my_mat,1);
%% ��׼������ ���ԸĽ�
mu_my=mean(my_mat(:,2:end));
sigma2_my=mean((my_mat(:,2:end)-repmat(mu_my,cnt_data,1)).^2);
my_mat=[my_mat(:,1),(my_mat(:,2:end)-repmat(mu_my,cnt_data,1))./repmat((sigma2_my.^0.5),cnt_data,1)];
%% ������֤
cnt_cross=1000;% ������֤����
CC=zeros(1,cnt_cross);
SROCC=zeros(1,cnt_cross);
RMSE=zeros(1,cnt_cross);
isBestParam=0;% ��ʶ�����Ƿ�Ϊsvm���Ų���
isShow=1;  % �Ƿ���ʾ����Ա�ͼ
for ii=1:cnt_cross
    cnt_groups=10;
    cnt_train_groups=8;
    start=2; % �������
    end2=1; % �����յ�
    [train_data,test_data]=crossValidation(my_mat,cnt_groups,cnt_train_groups);
    %% svrģ��ѵ��
    % ��������������ţ���ѡ�����Ų���
    if(isBestParam==0)
        [best_C,best_gamma]=SVR_choosing_paremeter(train_data(:,start:end-end2),train_data(:,end),dataset_name);
        isBestParam=1;
    end
    model=svmtrain(train_data(:,end),train_data(:,start:end-end2),sprintf('-s %f -t %f -c %f -g %f', 3, 2, best_C, best_gamma)); % add -v ������֤�������ģ��ֵ
    %% ѵ������֤���
    [train_quality_norm,train_mse,train_decision]=svmpredict(train_data(:,end),train_data(:,start:end-end2),model);
    train_quality=train_quality_norm.*(sigma2_my(:,end)^0.5)+mu_my(:,end);
    train_mos=train_data(:,end).*(sigma2_my(:,end)^0.5)+mu_my(:,end);
    %% �����㷨�پ���
%     trainOfCluter(train_data(:,1),train_quality);
    
    %% svr Ԥ��
    [test_quality_norm,test_mse,test_decision]=svmpredict(test_data(:,end),test_data(:,start:end-end2),model);
    test_quality=test_quality_norm.*(sigma2_my(:,end)^0.5)+mu_my(:,end);
    test_mos=test_data(:,end).*(sigma2_my(:,end)^0.5)+mu_my(:,end);
    %% ��������
    [CC(ii),SROCC(ii),RMSE(ii)]=performance_eval(test_quality,test_mos,isShow);
    isShow=0;
end
mu_CC=mean(CC)
mu_SROCC=mean(SROCC)
mu_RMSE=mean(RMSE)
    