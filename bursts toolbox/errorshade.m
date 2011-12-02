function varargout = errorshade(x,y,err,color,Opts)
%ERRORSHADE Semi-transparent errorbar (patch) plot.
%  H = ERRORSHADE(X,Y,E,Color,Opts) plots the graph of vector X vs. vector Y
%    with semi-transparent fill area to mark the error bars specified, as
%    specified by the vector E.  Vector E is a 2*m or n*2 vector, where 
%    the first column/row indicates the upper and the second column/row 
%    indicated the lower error ranges for each point in Y.  If E is a  
%    single column/row vector, the error limits are assumed to be 
%    symmetrical.  The vectors X,Y,L and U must all be the same length.
%    
%    Input arguments Color and Opts are optional. Color sets the color for
%    both the mean plot line, and the shaded area, which is set default
%    to alpha=0.33 transparency level. Opts is a structure that controls
%    the patch object (the shaded area). 
%
%    Optional output argument H is a vector of the handles to the graphics
%    objects, such that H = [handle_line handle_shade_area].

%    Amanda Sorribes, 2010

% (Rudimentary) Input Control
if ~isempty(x) && size(x,2)>size(x,1), x=x'; end
if ~isempty(y) && size(y,2)>size(y,1), y=y'; end
if ~isempty(err) && size(err,2)>size(err,1), err=err'; end
if size(err,2)==1, err=[err err]; end
if nargin<4, 
  color='b';
end
if nargin<5
  Opts=struct('EdgeColor','none','FaceAlpha',0.33,'LineWidth',2);
end
if ~isfield(Opts,'EdgeColor')
  Opts.EdgeColor='none';
end
if ~isfield(Opts,'FaceAlpha')
  Opts.FaceAlpha=0.33;
end
if ~isfield(Opts,'FaceAlpha')
  Opts.LineWidth=2;
end
if ~isfield(Opts,'Parent')
  Opts.Parent=gca;
end

% Calculate Patch Edges
x_patch=[x ; x(end:-1:1)];
y_patch=[y + err(:,1) ; y(end:-1:1) - err(end:-1:1,2)];

% Plot
holdstate=ishold(Opts.Parent);
h_shade=patch(x_patch,y_patch,color);
set(h_shade,Opts)
set(get(get(h_shade,'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
set(Opts.Parent,'NextPlot','add')
h_mean=plot(x,y,'Parent',Opts.Parent,'Color',color,'LineWidth',Opts.LineWidth);
if ~holdstate, set(Opts.Parent,'NextPlot','replace'); end

%Output
varargout={[h_mean h_shade]};
end
