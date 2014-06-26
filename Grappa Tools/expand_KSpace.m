function eKSpace=expand_KSpace(KSpace,sampled_rows)
%eKSpace=zeros(nRows,size(KSpace,2),size(KSpace,3),size(KSpace,4),size(KSpace,5),'single');
eKSpace(sampled_rows,:,:,:,:)=KSpace;
% 
% for loop = 1:length(sampled_rows)
%     eKSpace(sampled_rows(loop),:,:,:,:)=KSpace(loop,:,:,:,:,:);
%     KSpace(loop,:,:,:,:)=0;
% end
end
