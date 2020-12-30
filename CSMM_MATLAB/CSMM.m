n=1; % bin width parameter m/z_bin=1/n
lowm=0; % low m/z
highm=2000; % high m/z
selected_regions=[-1]; %select regions to visualize; -1 -- for all regions
width=1.5; % FWHM for Gaussian function for convolution
sigma=width/2/sqrt(log(2));
ex=exp(-((-3*width:1/n:3*width)/sigma).^2);

histology_image_path=''; %specify the full path to the histology image
if histology_image_path~=''
    histology_image=imread(histology_image_path);
else
    histology_image=zeros(1,1);
end

[FileDat, PathDat]=uigetfile('cd/*; *','Open DATA');
if FileDat
    FileName=FileDat;
    Path=PathDat;
end
fn=FileName;
filename=[Path, FileName];
load(filename); %load mat file

low=lowm*n+1; % low mass index
high=highm*n; % high mass index

regions_id=[];
for i=1:length(selected_regions)
    regions_id=[regions_id;find(data.R'==selected_regions(i))];
end
if selected_regions==-1 || isempty(regions_id)
    regions_id=1:length(data.R');
end
x_coords=data.X(regions_id)';
y_coords=data.Y(regions_id)';
spectra=cell(length(regions_id),1);

for i=1:length(regions_id)
    spectra{i}=data.peaks{regions_id(i)};
end

min_pixx=min(x_coords);
max_pixx=max(x_coords);
min_pixy=min(y_coords);
max_pixy=max(y_coords);
sz=[max_pixy-min_pixy+1, max_pixx-min_pixx+1];

max_size_of_image=500; % max size for resizing visualized images
if max(sz)<max_size_of_image
    rsz=ceil(max_size_of_image/max(sz));
else
    rsz=1; % scale factor for resize image
end

x_coords_img=x_coords-min_pixx+1;
y_coords_img=y_coords-min_pixy+1;

zone_labels=0*x_coords;

img=zeros(sz);
set(groot, 'defaultFigureWindowState', 'maximized');
figure(2);
fig2=gcf;

% frame_h = get(handle(fig2),'JavaFrame');
% set(frame_h,'Maximized',1);
h1=subplot(2,2,1);
h2=subplot(2,2,2);
h3=subplot(2,2,3);
h4=subplot(2,2,4);


figure(1);
fig = gcf;
h0=get(fig,'CurrentAxes');
if isempty(h0)
    h0 = axes('parent',fig);
end
imshow(imresize(img,sz*rsz, 'nearest'),'Parent',h0);
c = uicontrol(fig2, 'Style', 'edit', 'Position', [10 10 60 20]);
c.String = '1';

regions=data.R(regions_id)';
k=1;
subdir_name=fn(1:end-4);
[~,~,~]=mkdir('../output_files');
[~,~,~]=mkdir(Path,subdir_name);
[~,~,~]=mkdir([Path,'/',subdir_name],'mat_files');
[~,~,~]=mkdir([Path,'/',subdir_name],'figure_maps_only');
[~,~,~]=mkdir([Path,'/',subdir_name],'figure_maps');
[~,~,~]=mkdir([Path,'/',subdir_name],'png_maps_only');
[~,~,~]=mkdir([Path,'/',subdir_name],'png_maps');
while true
    figure(fig);
    [X, Y]=my_ginput(1);
    if isempty(X)
        return;
    end
    if X/rsz>sz(2)
        break;
    end
    x=round(X/rsz)+min_pixx-1;
    y=round(Y/rsz)+min_pixy-1;
    if x>max_pixx x=max_pixx; end
    if y>max_pixy y=max_pixy; end
    [~,m1]=min(abs(x_coords-x));
    idx=find(x_coords==x_coords(m1));
    [~,m1]=min(abs(y_coords(idx)-y));
    j=find(y_coords(idx)==y_coords(idx(m1)));
    if isempty(j)
        j=size(x_coords,1);
    else
        j=idx(j);
    end
    reg=regions(j);
    spectr1=mat_peaks2spectr(spectra{j}, low, high, n);
%     spectr1=conv(mat_peaks2spectr(spectra{j}, low, high, n),ex,'same'); % uncomment for convolution
    spectr1=spectr1/sqrt(spectr1*spectr1');
    plot(linspace(low/n, high/n, high-low+1),spectr1*100/max(spectr1),'Parent',h4);
    title(h4, sprintf('Selected spectrum, X=%d, Y=%d, basepeak intensity = %d a.u.',x,y,round(max(mat_peaks2spectr(spectra{j}, low, high, n)))));
    xlabel(h4,'m/z'); ylabel(h4,'intensity, a.u.')
    
    for i=1:size(x_coords,1)
        spectr2=mat_peaks2spectr(spectra{i}, low, high, n);
%         spectr2=conv(mat_peaks2spectr(spectra{i}, low, high, n),ex,'same');% uncomment for convolution
        img(y_coords_img(i),x_coords_img(i))=spectr1*spectr2'/sqrt(spectr2*spectr2');
    end
    img(isnan(img))=0;
    
    % cosine map of MS imaging
    imshow(imresize(img,sz*rsz, 'nearest'),'Parent',h1);
    hold(h1, 'on');
    line([0,sz(2)*rsz],[Y, Y], 'Color','black','Parent',h1);
    line([X, X],[0,sz(1)*rsz], 'Color','black','Parent',h1);
    hold(h1, 'off');
    title(h1,'Cosine map of MS imaging');
    colormap(h1,jet);
    colorbar(h1);
    
    % median filtering
    img_filtered=median2D(img);
    imshow(imresize(histology_image,sz*rsz, 'nearest'),'Parent',h2);
    % imshow(histolgy_image,'Parent',h2);

    %borders detection in median-filtered image
    pow=4;
    img_div=div_simple(img_filtered, pow);
    img_div4show=imresize(1-img_div,sz*rsz, 'nearest');
    img_div4show=-log2(img_div4show).*img_div4show;
    img_div4show(isnan(img_div4show))=0;
    imshow(1-img_div4show/max(img_div4show(:)),'Parent',h3);
    hold(h3, 'on');
    line([0,sz(2)*rsz],[Y, Y], 'Color','black','Parent',h3);
    line([X, X],[0,sz(1)*rsz], 'Color','black','Parent',h3);
    hold(h3, 'off');
    title(h3,'Borders');
    colorbar(h3,'Ticks',0:0.1:1,'TickLabels',{'1','0.9','0.8','0.7','0.6','0.5','0.4','0.3','0.2','0.1','0'});
    
    
    % cosine map
    imshow(imresize(img,sz*rsz, 'nearest'),'Parent',h0);
    title(h0,sprintf('Cosine map of MS imaging for X=%d, Y=%d', x,y));
    colormap(h0,jet);
    colorbar(h0);
    
end
