%   Images = reconstruct_images(KSpace)
%   This function takes a 5D (vert, hor, cardiac phase, phase encode, coil)
%   k-space array and returns a structure containing the magnitude and
%   phase images
%
%   Inputs:
%   KSpace          - 5D k-space complex-valued array (vert, hor, cardiac
%   phase, velocity encode, coil)
%
%   Outputs:
%   Images          - Structure containing the magnitude and phase image
%   series (real valued, 3D - xyt)

function Images = reconstruct_images(Data_Properties,KSpace)

%%% Initialize output
Images = struct('Magnitude', {}, 'Phase', {});

if (strcmp(Data_Properties.DataType{2},'FULL'))
    %%% Fourier transform (the FE direction is already done)
    TempImages = fftshift(ifft(fftshift(KSpace,1),[],1),1);
    
    if strcmp(Data_Properties.DataType{1},'CINE')
        Images(1).Magnitude = abs(sqrt(squeeze(sum(TempImages(:,:,:,1,:).^2,5))));
        Images(1).Phase = angle((squeeze(sum(TempImages(:,:,:,1,:),5))));
        for i=2:size(TempImages,5)
        Images(1).Magnitude = Images(1).Magnitude +abs(sqrt(squeeze(sum(TempImages(:,:,:,:,i).^2,5))));
        Images(1).Phase = Images(1).Phase+angle(sqrt(squeeze(sum(TempImages(:,:,:,:,i).^2,5))));
        end
    elseif strcmp(Data_Properties.DataType{1},'PC')
        Images(1).Magnitude = abs(sqrt(squeeze(sum(TempImages(:,:,:,2,:).*conj(TempImages(:,:,:,1,:)),5))));
        Images(1).Phase = angle(sqrt(squeeze(sum(TempImages(:,:,:,2,:).*conj(TempImages(:,:,:,1,:)),5))));
    end
    
elseif strcmp(Data_Properties.DataType{2},'GRAPPA')
    
    if strcmp(Data_Properties.DataType{1},'CINE')
        KSpace=expand_KSpace(KSpace,Data_Properties.Sampled_Rows);
        KSpace=compute_grappa(KSpace,Data_Properties.Sampled_Rows, Data_Properties.GrappaFactor);
        TempImages = fftshift(ifft(ifftshift(KSpace,1),[],1),1);
        Images(1).Magnitude = abs(sqrt(squeeze(sum(TempImages(:,:,:,1,:).^2,5))));
        Images(1).Phase = angle(sqrt(squeeze(sum(TempImages(:,:,:,1,:).^2,5))));
        for i=2:size(TempImages,4)
         Images(1).Magnitude = Images(1).Magnitude +abs(sqrt(squeeze(sum(TempImages(:,:,:,i,:).^2,5))));
        Images(1).Phase = Images(1).Phase+angle(sqrt(squeeze(sum(TempImages(:,:,:,i,:).^2,5))));
        end
    elseif strcmp(Data_Properties.DataType{1},'PC')
        eKSpace=expand_KSpace(KSpace(:,:,:,1,:),Data_Properties.Sampled_Rows);
        KSpace_g(:,:,:,1,:)= compute_grappa(eKSpace,Data_Properties.Sampled_Rows,Data_Properties.GrappaFactor);
        eKSpace=expand_KSpace(KSpace(:,:,:,2,:),Data_Properties.Sampled_Rows);
        KSpace_g(:,:,:,2,:)= compute_grappa(eKSpace,Data_Properties.Sampled_Rows,Data_Properties.GrappaFactor);
        KSpace=KSpace_g;
        TempImages = fftshift(ifft(ifftshift(KSpace,1),[],1),1);
        Images(1).Magnitude = abs(sqrt(squeeze(sum(TempImages(:,:,:,2,:).*conj(TempImages(:,:,:,1,:)),5))));
        Images(1).Phase = angle(sqrt(squeeze(sum(TempImages(:,:,:,2,:).*conj(TempImages(:,:,:,1,:)),5))));
    end
    
elseif strcmp(Data_Properties.DataType{2},'ZEROS')
    
    if strcmp(Data_Properties.DataType{1},'CINE')
            KSpace=expand_KSpace(KSpace,Data_Properties.Sampled_Rows);
        TempImages = fftshift(ifft(ifftshift(KSpace,1),[],1),1);
        Images(1).Magnitude = abs(sqrt(squeeze(sum(TempImages(:,:,:,1,:).^2,5))));
        Images(1).Phase = angle(sqrt(squeeze(sum(TempImages(:,:,:,1,:).^2,5))));
    elseif strcmp(Data_Properties.DataType{1},'PC')
        eKSpace(:,:,:,1,:)=expand_KSpace(KSpace(:,:,:,1,:),Data_Properties.Sampled_Rows);
        eKSpace(:,:,:,2,:)=expand_KSpace(KSpace(:,:,:,2,:),Data_Properties.Sampled_Rows);
        KSpace=eKSpace;
        TempImages = fftshift(ifft(ifftshift(KSpace,1),[],1),1);
        Images(1).Magnitude = abs(sqrt(squeeze(sum(TempImages(:,:,:,2,:).*conj(TempImages(:,:,:,1,:)),5))));
        Images(1).Phase = angle(sqrt(squeeze(sum(TempImages(:,:,:,2,:).*conj(TempImages(:,:,:,1,:)),5))));
    end
    
end

end