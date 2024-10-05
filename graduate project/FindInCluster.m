function [f, MCC] = FindInCluster(MCC)

% f = FindInCluster(MCC)
%
% INPUTS
%     MCC - a MCCluster
%
% OUTPUTS
%     f - indices of all points in the cluster
%
% ADR 1999
% version 1.2
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

% Modified ncst 02 March 03, removed xlbls and ylbls, added cowen's mod for
%   ForbiddenPoints, and to use the MClust_FDdn if the current directory is
%   changed.

if MCC.recalc == 0
   f = MCC.myPoints; 
   return
end

MCCFields = fields(MCC);

% Older versions of MClust don't use ForbiddenPoints, so add the field if
% it is absent.
if ~strmatch('ForbiddenPoints',MCCFields)  
	MCC.ForbiddenPoints = [];
end
nBounds = length(MCC.xdimNames);
if nBounds ~= length(MCC.ydimNames)
   error('Unaligned data in FindInCluster');
end
if nBounds ~= length(MCC.cx)
   error('Unaligned data in FindInCluster');
end
if nBounds ~= length(MCC.cy)
   error('Unaligned data in FindInCluster');
end

%[nSamps, nDims] = size(data);

if ~strmatch('myOrigPoints',MCCFields)
	MCC.myOrigPoints = [];
end

if nBounds == 0
   f = MCC.myOrigPoints;
else
   f = MCC.myOrigPoints;
   for iB = 1:nBounds

	   % X
       try       
	   temp = load(strrep(MCC.xdimSources{iB,1}, 'V:\Rats', 'Z:\Rats'),'-mat');
       catch e % Odds are someone created the fd file on thei rlocal desktop, and mclust being the genius it is saves absolute paths
           where = strfind(MCC.xdimSources{iB,1}, '\FD\');
           try
               if ~isempty(where)
                   temp = load([pwd MCC.xdimSources{iB,1}(where:end)], '-mat');
               else % Try to load it by inserting the FD in the path
                   where = find( MCC.xdimSources{iB,1} == '\', 1, 'last');
                   temp = load([pwd '\FD'  MCC.xdimSources{iB,1}(where:end)], '-mat');
               end
           catch e % if the fd files are unavailable to recalculate resort back to oldmemberships
               f = MCC.myPoints; 
               return
           end                                  
       end
	   data(:,1) = temp.FeatureData(:,MCC.xdimSources{iB,2});

	   % Y
       try
	   temp = load(strrep(MCC.ydimSources{iB,1}, 'V:\Rats', 'Z:\Rats'),'-mat');
       catch e % Odds are someone created the fd file on thei rlocal desktop, and mclust being the genius it is saves absolute paths
           where = strfind(MCC.ydimSources{iB,1}, '\FD\');
           if ~isempty(where)
               temp = load([pwd MCC.ydimSources{iB,1}(where:end)], '-mat');
           else
               where = find( MCC.ydimSources{iB,1} == '\', 1, 'last');
               temp = load([pwd '\FD'  MCC.ydimSources{iB,1}(where:end)], '-mat');
           end
       end
	   data(:,2) = temp.FeatureData(:,MCC.ydimSources{iB,2});

	   if exist('f', 'var')
		   f0 = InPolygon(data(f,1), data(f,2), MCC.cx{iB}, MCC.cy{iB});
		   f = f(logical(f0));
	   else
		   f = find(InPolygon(data(:,1), data(:,2), MCC.cx{iB}, MCC.cy{iB}));
	   end
	   if isempty(f)
		   break;
	   end
   end
end

% mccluster always has forbidden points now
if ~isempty(f) && ~isempty(MCC.ForbiddenPoints)
	[goodf, goodidx] = setdiff(f,MCC.ForbiddenPoints);
	f =  f(goodidx);
end

if MCC.recalc == 1
	MCC.myPoints = f;
	MCC.recalc = 0;
end

f = sort(f);