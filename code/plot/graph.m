%% Test Accuracy plot
clear all;
nosielevel=[0,2,10,20,100,200,500];
%% EM-5693
em5693_valstage3= [100,100,100,100,100,100,100];
em5693_valstage2= [99.7,100,100,100,95.1,77.2,62.42];
em5693_valstage1= [99.8,93.6,61,58,57.3,54.4,59];

em5693_teststage3= [99.4,99.95,99,99.5,98,96,91];
em5693_teststage2= [99.4,99.3,99.7,99.3,86.3,53.7,21];
em5693_teststage1= [99.3,88.1,20,20.5,20.5,20.5,20.5];

%% EM-2211
em2211_valstage3= [100  ,100   ,100   ,100  ,100    ,100   ,100];
em2211_valstage2= [100  ,100   ,100   ,100  ,100    ,99    ,100];
em2211_valstage1= [100  ,100   ,100   ,100  ,100    ,93    ,87.1];

em2211_teststage3= [99.9 ,100  ,99.0   ,99   ,99.7  ,99.4  ,98.4];
em2211_teststage2= [99.8 ,100  ,99.0   ,99   ,99.7  ,99.2  ,98.3];
em2211_teststage1= [99.6 ,99.0 ,99.1   ,98   ,92.0  ,86.1  ,71.0];
%% EM-5689
em5689_valstage3= [100  ,100   ,100   ,100   ,100   ,100   ,100];
em5689_valstage2= [100  ,100   ,100   ,100   ,99    ,99    ,100];
em5689_valstage1= [100  ,100   ,100   ,89.9  ,59    ,61    ,57];

em5689_teststage3= [100  ,100  ,100    ,100  ,99  ,99  ,99];
em5689_teststage2= [99.0 ,99.9 ,99.0   ,99   ,97  ,94  ,86];
em5689_teststage1= [99.0 ,99.0 ,96.1   ,79.  ,20  ,20  ,20];
%% validate plot
%valstage3=em2211_valstage3;
%valstage2=em2211_valstage2;
%valstage1=em2211_valstage1;

valstage3=em5689_valstage3;
valstage2=em5689_valstage2;
valstage1=em5689_valstage1;

figure;
plot(nosielevel,valstage3),hold on,
plot(nosielevel,valstage2),hold on,
plot(nosielevel,valstage1),hold on,
legend('stage-3 classifier','stage-2 classifier','stage-1 classifier'),
grid on,
xlabel('Total intensity division factor');
ylabel('Prediction accuracy in percent');
title('\fontsize{10}{\color{magenta}EM-5689 Valdiate set (20% of train) accuracy}');
set(gca,'XTick',nosielevel );

%% Test plot

teststage3=em5693_teststage3;
teststage2=em5693_teststage2;
teststage1=em5693_teststage1;

%teststage3=em2211_teststage3;
%teststage2=em2211_teststage2;
%teststage1=em2211_teststage1;

%teststage3=em5689_teststage3;
%teststage2=em5689_teststage2;
%teststage1=em5689_teststage1;

figure;
plot(nosielevel,teststage3),hold on,
plot(nosielevel,teststage2),hold on,
plot(nosielevel,teststage1),hold on,
lgd=legend('stage-3 classifier','stage-2 classifier','stage-1 classifier','Location','best'),
grid on,
xlabel('Total intensity division factor','FontSize',24);
ylabel('Prediction accuracy in percent','FontSize',24);
title('\fontsize{16}{\color{magenta}EM-5693 Test set accuracy}');
set(gca,'XTick',nosielevel );
set(findall(gca, 'Type', 'Line'),'LineWidth',3);
lgd.FontSize = 24;
set(gca,'FontSize',20);
