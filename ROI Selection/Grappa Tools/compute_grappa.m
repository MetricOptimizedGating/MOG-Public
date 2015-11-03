function KSpace = compute_grappa(eKSpace,sampled_rows,GrappaFactor)
% sample_vector(sampled_rows-1)=1;
% sample_vector(length(sample_vector)+1)=0;
sample_vector(sampled_rows)=1;
acc_vector=mod(1:size(eKSpace,1),GrappaFactor);
KSpace=zeros(size(eKSpace,1),size(eKSpace,2),size(eKSpace,3),size(eKSpace,5));
for iFrame=1:size(eKSpace,3);
ACC=squeeze(eKSpace(:,:,iFrame,:));
G=pmri_grappa_prep('obs',ACC,'sample_vector',sample_vector,'acc_vector',acc_vector);
ACC=pmri_grappa_core2('obs',ACC,'sample_vector',sample_vector,'acc_vector',acc_vector,'G',G);
KSpace(:,:,iFrame,:)=ACC;
clear G ACC
end
end