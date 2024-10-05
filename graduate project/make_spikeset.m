
function spikeset = make_spikeset(filename,verbose)

%spikeset = make_spikeset( filename )

if(nargin<2)
    verbose = 1;
end
if(verbose==1)
    %filename;
end
%
%   Makes a spikeset structure out of a .clusters and .ntt file pair.
%
%   Created: Bernard Willers, Sept 01, 2011
%
%   Updated: Sept 6, 2012
%   Now loads either .ntt or .spike clusters
    [path, file, extension] = fileparts(filename);
    if strcmp(extension, '.clusters')
        extension = '.ntt';
    elseif strcmp(extension, '.bounds')
        extension = '.spike';
    end
            
    % If the extension isn't given, see what files exist
    if strcmp(extension, '')
        if exist(fullfile(path, strcat(file, '.spike')), 'file')
            extension = '.spike';
        elseif exist(fullfile(path, strcat(file, '_neo.ntt')), 'file')
            extension = '.ntt';
            if length(file) < 4 || ~strcmp(file(end-3:end), '_neo')
                file = strcat(file, '_neo');
            end
        end
    end
    
    % Handle Ntt files
    if strcmp(extension, '.ntt')
        clusters_file = fullfile(path, strcat(file, '.clusters'));
        ntt_file = fullfile(path, strcat(file, '.ntt'));

        spikeset = struct;

        % Screw loading from MClust, lets see if we can load out of Nlx
        [spikeset.primary.times, spikeset.waveforms, header] = Nlx2MatSpike(ntt_file, [1, 0, 0, 0, 1], 1,1);
        expr = '-ADBitVolts (?<d2a1>[0-9,\.]*) (?<d2a2>[0-9,\.]*) (?<d2a3>[0-9,\.]*) (?<d2a4>[0-9,\.]*)';
        
        a2d_set = false;
        for iH = 1 : length(header)        
            
            temp = uint8(header{iH});
            temp(temp == 9) = 32; % replace tabs by spaces, damn the mice data
            temp = char(temp);
            
            line = regexp(temp, expr, 'names');
            
            if ~isempty(line)
                spikeset.waveforms(:,1,:) = spikeset.waveforms(:,1,:) * str2double(line.d2a1) * 1e6;
                spikeset.waveforms(:,2,:) = spikeset.waveforms(:,2,:) * str2double(line.d2a2) * 1e6;
                spikeset.waveforms(:,3,:) = spikeset.waveforms(:,3,:) * str2double(line.d2a3) * 1e6;
                spikeset.waveforms(:,4,:) = spikeset.waveforms(:,4,:) * str2double(line.d2a4) * 1e6;
                a2d_set = true;
                break                
            end
        end
        
        if ~a2d_set
            error('Could not find d2a conversion factor in .ntt header');
        end

        % Find the sampling frequency in the header (this is more future proof
        % than just forcing 32556
        expr = '-SamplingFrequency (?<fs>[0-9\.]*)';
        for i = 1 : length(header)
            temp = uint8(header{i});
            temp(temp == 9) = 32; % replace tabs by spaces, damn the mice data
            temp = char(temp);

            line = regexp(temp, expr, 'names');
            if ~isempty(line)
                spikeset.params.sampling_frequency = str2double(line.fs);
            end        
        end

        % these parameters dont vary much if at all for ntt files
        spikeset.params.extraction.peak_alignment_frac = 0.25;    
        spikeset.params.extraction.spike_length_ms = 32 * 1e3 /spikeset.params.sampling_frequency;
        spikeset.params.censor_period_ms = spikeset.params.extraction.spike_length_ms;    

        %%% Read the cluster IDS
        if (exist(clusters_file, 'file'))
            temp = load(clusters_file, '-mat');
            nClusters = length(temp.MClust_Clusters);

            spikeset.cluster.membership = false(length(spikeset.primary.times), nClusters);

            for iC = 1:nClusters
                if ~isempty(temp.MClust_Clusters{iC})
                    f = FindInCluster(temp.MClust_Clusters{iC});
                    spikeset.cluster.membership(f,iC) = true;
                end
            end

            if size(spikeset.cluster.membership, 1) ~= length(spikeset.primary.times)
                error(sprintf('Spike count and cluster member size dont match up. Possibly a misplaced cluster file: %s', ...
                    clusters_file));
            end
            
            % produce a 32 point mean spike waveform
            u = zeros(32,4,size(spikeset.cluster.membership,2));

            for iU = 1 : size(u,3)
                u(:,:,iU) = mean(spikeset.waveforms(:,:,spikeset.cluster.membership(:,iU)), 3); 
            end
            spikeset.u = u;
        else
            spikeset.cluster.membership = false(length(spikeset.primary.times), 0);
        end
        
    % Dotspike files
    elseif strcmp(extension, '.spike')
        if ~isempty(strfind(file, '.spike'))
            spikeset = loadDotspike(fullfile(path, file));
        else
            tic;spikeset = loadDotspike(fullfile(path, strcat(file, '.spike')));            toc;
        end
        
        params = makedefaultparams();
        spikeset.params.censor_period_ms = params.detection.censor_period_ms;
        
        % now load up the clusters, if they exist
        fullfile(path, strcat(file, '.mat'));
        if exist(fullfile(path, strcat(file, '.mat')), 'file')
            temp = load(fullfile(path, strcat(file, '.mat')));
            spikeset.cluster.membership = logical(temp.cluster_id);
        elseif exist(fullfile(path, strcat(file, '.spike', '.mat')), 'file')
            temp = load(fullfile(path, strcat(file, '.spike', '.mat')));
            spikeset.cluster.membership = logical(temp.cluster_id);
        else
            spikeset.cluster.membership = false(length(spikeset.primary.times), 0);
        end
        
        % produce a 32 point mean spike waveform, by interpolating or
        % subsampling, etc. this is so we can do waveform comparisons of
        % different length waveforms
        rel_time = spikeset.params.extraction.spike_length_ms * ((1:size(spikeset.waveforms,1)) / ...
            size(spikeset.waveforms,1)) - spikeset.params.extraction.peak_alignment_frac * spikeset.params.extraction.spike_length_ms;
        des_time = (-7:24)/32;
        
        u = zeros(32,4,size(spikeset.cluster.membership,2));
        for iU = 1 : size(u,3)
            u(:,:,iU) = interp1(rel_time, mean(spikeset.waveforms(:,:,spikeset.cluster.membership(:,iU)), 3), des_time);
        end
        spikeset.u = u;
    end
    
    % k is really a bit of legacy nonsense i should get rid of at some point
    if isfield(spikeset, 'u')
        spikeset.u = spikeset.u(:,:,any(spikeset.cluster.membership, 1));
    end
    spikeset.cluster.membership = spikeset.cluster.membership(:,any(spikeset.cluster.membership, 1));
    spikeset.cluster.k = 1:size(spikeset.cluster.membership,2);
end

