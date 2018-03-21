% Test Sample
range=1e4;
%% Normal loop
% Range= 1e4 Elapsed time is 5.000052 seconds.
tic
  for i=1:range
      for j=1:range
          a=sqrt(i+j);
      end
  end
toc
%% Parallel loop
%   Range= 1e4 Elapsed time is 4.856775 seconds.
tic
  parfor i=1:range
      %fprintf('i=%d\n',i);
      for j=1:range
          a=sqrt(i+j);
      end
  end
toc
%% Parallel fun call

%{
p = gcp();
% To request multiple evaluations, use a loop.
for idx = 1:10
  f(idx) = parfeval(p,@sqrt,1,idx); % Square size determined by idx
end
% Collect the results as they become available.
magicResults = cell(1,10);
for idx = 1:10
  % fetchNext blocks until next results are available.
  [completedIdx,value] = fetchNext(f);
  magicResults{completedIdx} = value;
  fprintf('Got result with index: %d.\n', completedIdx);
end
%}
%% ARRAY
fprintf('CU-Parfor-Array');
mat=zeros(range,range);
patch=200;
tic
  parfor i=1:range-patch-1
      %fprintf('i=%d\n',i);
      for j=1:range-patch-1
          a=mat(i,j);
      end
  end
toc
%% 
fprintf('GPU-Array');
%range=5000;
range=10;
mat= gpuArray.zeros(range,range);
patch=200;
tic
  for i=1:range-patch-1
      %fprintf('i=%d\n',i);
      for j=1:range-patch-1
          a=mat(i,j);
      end
  end
toc


