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
      fprintf('i=%d\n',i);
      for j=1:range
          a=sqrt(i+j);
      end
  end
toc
%%
a=zeros(100,100);
A = 100;
tic
%ticBytes(gcp);
parfor i = 1:100
    for j = 1:100
        a(i,j) = max(abs(eig(rand(A))));
    end
end
%tocBytes(gcp)
toc