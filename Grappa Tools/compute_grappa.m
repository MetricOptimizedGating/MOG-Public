function KSpace = compute_grappa(eKSpace,sampled_rows)
sample_vector(sampled_rows)=1;
acc_vector=mod(1:size(eKSpace,1),2);
KSpace=zeros(size(eKSpace,1),size(eKSpace,2),size(eKSpace,3),size(eKSpace,5));
for iFrame=1:size(eKSpace,3);
ACC=squeeze(eKSpace(:,:,iFrame,:));
G=pmri_grappa_prep('obs',ACC,'sample_vector',sample_vector,'acc_vector',acc_vector);
ACC=pmri_grappa_core2('obs',ACC,'sample_vector',sample_vector,'acc_vector',acc_vector,'G',G);
KSpace(:,:,iFrame,:)=ACC;
clear G ACC
end
end