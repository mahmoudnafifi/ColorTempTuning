%% Reference code for the paper:
% Mahmoud Afifi, Abhijith Punnappurath, Abdelrahman Abdelhamed, 
% Hakki Can Karaimer, Abdullah Abuolaim, and Michael S. Brown. Color 
% Temperature Tuning: Allowing Accurate Post-Capture White-Balance Editing.
% In the 27th Color and Imaging Conference, pp. 1-6(6), 2019.
%%

function varargout = Wb2wb_gui(varargin)
warning off
clc
addpath(fullfile('mappingFuncs'));
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Wb2wb_gui_OpeningFcn, ...
    'gui_OutputFcn',  @Wb2wb_gui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function Wb2wb_gui_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

function varargout = Wb2wb_gui_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


function BrowseBtn_Callback(hObject, eventdata, handles)
global I %for JPEG
global M %M for JPEG
global sz_ %for rendering intialization
global type %.dng or .jpg
global fileName %file name
global temps %temprature list
global curr_temp %current temperature
global I_temps %for JPEG
global I_original %for JPEG
global  preset
sz_ = 150; % tiny image size 
temps = [2500, 4000, 5500, 7000, 8500]; %our target color temps
[filename, pathname] = uigetfile(... % brwose 
    {'*.dng','Raw image';'*.jpg','Rendered image'},'File Selector');
if isequal(filename,0) || isequal(pathname,0) % if no file was selected
    return;
end
fileName = strcat(pathname, filename); 
handles.status.String = 'Processing...';
pause(0.001);
[~,~,ext] = fileparts(filename);
switch lower(ext) % check image format
    case '.dng' % raw DNG image
        handles.fullPipeline.Enable = 'On';
        handles.lightPipeline.Enable = 'On';
        handles.helpbtn.Enable = 'On';
        handles.RenderBtn.Enable = 'On';
        handles.tungstenWB.Enable = 'On';
        handles.fluorescentWB.Enable = 'On';
        handles.daylightWB.Enable = 'On';
        handles.cloudyWB.Enable = 'On';
        handles.shadeWB.Enable = 'On';
        handles.customWB.Enable = 'On';
        axes(handles.image);
        imshow(ones(14,20) * 32/255);
        type = lower(ext);
        preset = 0;
    case '.jpg' % JPG image
        I = im2double(imread(fileName));
        I_original = I; % take a copy
        I = imresize(I,0.3); % to speed up the processing in our interactive gui
        handles.fullPipeline.Enable = 'Off';
        handles.lightPipeline.Enable = 'Off';
        handles.helpbtn.Enable = 'Off';
        handles.RenderBtn.Enable = 'Off';
        axes(handles.image);
        handles.image.Visible = 'On';
        imshow(I); % show image
        handles.temp.Enable = 'On';
        handles.temp_string.Enable = 'On';
        handles.tungstenWB.Enable = 'On';
        handles.fluorescentWB.Enable = 'On';
        handles.daylightWB.Enable = 'On';
        handles.cloudyWB.Enable = 'On';
        handles.shadeWB.Enable = 'On';
        handles.customWB.Enable = 'On';     
        %get metadata
        metadata = imfinfo(fileName);
        JPEG_comment = metadata.Comment;
        try % extract embedded metadata
            curr_temp = double(typecast(...
                matlab.net.base64decode(JPEG_comment{1}),'single'));
            M = zeros(length(JPEG_comment)-1,34*3);
            I_temps = zeros(size(I,1),size(I,2),size(I,3),size(M,1));
            for i = 2 : length(JPEG_comment)
                M(i-1,:) = double(reshape(...
                    typecast(matlab.net.base64decode(...
                    JPEG_comment{i}),'single'),[1,34*3]));
                I_temps (:,:,:,i-1) = applyCorrection(I,...
                    reshape(M(i-1,:),[34,3]));
            end
            handles.temp_string.String = num2str(curr_temp);
            handles.temp.Value = curr_temp;
        catch % emebedded data is not found
            errormsg = msgbox(...
                'The selected file was not rendered using our pipeline!');
            set(gcf,'color',[38 38 38]/255);
            set(errormsg, 'position', ...
                [errormsg.Position(1) ...
                errormsg.Position(2) 300 80]); %makes box bigger
            th = findall(errormsg, 'Type', 'Text');
            th.FontSize = 12;
            th.Color = [1 1 1];
        end
        type = lower(ext);
        preset = 0;
        handles.SaveBtn.Enable = 'On';
end
handles.status.String = 'Done!'; pause(0.1); handles.status.String = '';
handles.temp.Enable = 'On';
handles.temp_string.Enable = 'On';
handles.temp_string.String = num2str(handles.temp.Value);


function temp_Callback(hObject, eventdata, handles)
global curr_temp type preset I temps I_temps
curr_temp = handles.temp.Value;
handles.temp_string.String = num2str(handles.temp.Value);
if preset == 0
    handles.customWB.Value = 1;
end
switch type
    case '.dng' % for dng, no processing is needed
        return
    case '.jpg' % for jpg, process the image to get the current color temp
        handles.temp.Enable = 'Off';
        handles.temp_string.Enable = 'Off';
        handles.tungstenWB.Enable = 'Off';
        handles.fluorescentWB.Enable = 'Off';
        handles.daylightWB.Enable = 'Off';
        handles.cloudyWB.Enable = 'Off';
        handles.shadeWB.Enable = 'Off';
        handles.customWB.Enable = 'Off';
        handles.status.String = 'processing...';
        pause(0.1);
        diff = temps - curr_temp; % diff color temp
        % find nearest color temps of our pre-defined set
        inds = find(diff<=0); ind1 = inds(end); 
        inds = find(diff>=0); ind2 = inds(1);
        cct1 = temps(ind1);
        cct2 = temps(ind2);
        % interpolation weight
        cct1inv = 1 / cct1;
        cct2inv = 1 / cct2;
        tempinv = 1 / curr_temp;
        if ind1 == ind2
            g = 0;
        else
            g = (tempinv - cct2inv) / (cct1inv - cct2inv);
        end
        % blend between the corresponding images using the computed
        % weight, g -- this is equivalent to, but faster than, blend the 
        % mapping funcs, then apply the new mapping function to the input 
        % image.
        I = g .* I_temps(:,:,:,ind1) + (1-g) .* I_temps(:,:,:,ind2);
        imshow(I);
        handles.status.String = 'Done!'; 
        pause(0.1); handles.status.String = '';
        handles.temp.Enable = 'On';
        handles.temp_string.Enable = 'On';
        handles.tungstenWB.Enable = 'On';
        handles.fluorescentWB.Enable = 'On';
        handles.daylightWB.Enable = 'On';
        handles.cloudyWB.Enable = 'On';
        handles.shadeWB.Enable = 'On';
        handles.customWB.Enable = 'On';        
end
preset = 0;


function temp_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function SaveBtn_Callback(hObject, eventdata, handles)
global I M curr_temp I_original sz_ 
curr_temp = handles.temp.Value;
filter = {'*.jpg','JPEG'};
[file, path] = uiputfile(filter);
if isequal(file,0) || isequal(path,0)
    return;
else
    handles.status.String = 'Saving...'; pause(0.01);
    I_temp = imresize(I_original,[sz_,sz_]);
    %recomputing M
    for i  = 1 : size(M,1)
        M(i,:) = reshape(phi(reshape(imresize(I,[sz_,sz_]),[],3))\...
            reshape(applyCorrection(I_temp,reshape(M(i,:),[34,3])),[],3),...
            1,[]);
    end
    m = phi(reshape(imresize(I_original,[size(I,1),size(I,2)]),[],3))\...
            reshape(I,[],3); 
	% apply it to the original image size
    I_original = applyCorrection(I_original,m);
    % encode the metadata
    encoded_M = cell(size(M,1));
    for i = 1 : size(M,1)
        encoded_M{i} = matlab.net.base64encode(...
            typecast(single(M(i,:)),'uint8'));
    end
    encoded_current_Temp = matlab.net.base64encode(...
        typecast(single(curr_temp),'uint8'));
    command_str = 'JPEG_comment = {encoded_current_Temp';
    for i = 1 : length(encoded_M)
        command_str = [command_str ';' sprintf('encoded_M{%d}',i)];
    end
    command_str = [command_str '};'];
    eval(command_str);
    % write the image with our metadata
    imwrite(I_original,fullfile(path,file),'Comment',JPEG_comment);
    handles.status.String = 'Done!'; pause(0.1); handles.status.String = '';
end



function temp_string_Callback(hObject, eventdata, handles)
global curr_temp temps
handles.customWB.Value = 1;
new_temp = str2double(handles.temp_string.String);
if new_temp <temps(1) || new_temp > temps(end)
    errormsg = msgbox('Please, select a temperature between 2,500 - 8,500');
    set(gcf,'color',[38 38 38]/255);
    set(errormsg, 'position', ...
        [errormsg.Position(1) errormsg.Position(2) 320 80]); %makes box bigger
    th = findall(errormsg, 'Type', 'Text');
    th.FontSize = 12;
    th.Color = [1 1 1];
    return;
end
handles.temp.Value = new_temp;
curr_temp = handles.temp.Value;
temp_Callback(hObject, eventdata, handles)

function temp_string_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function lightPipeline_Callback(hObject, eventdata, handles)

function fullPipeline_Callback(hObject, eventdata, handles)
helpmsg = msgbox(sprintf('%s',...
        'This option is not implemented in the current version.'),...
        'Rendering version');
        set(gcf,'color',[38 38 38]/255);
        set(helpmsg, 'position', ...
        [helpmsg.Position(1) helpmsg.Position(2) 295 55]); %makes box bigger
        th = findall(helpmsg, 'Type', 'Text');
        th.FontSize = 12;
        th.Color = [1 1 1];
handles.lightPipeline.Value = 1;


function helpbtn_Callback(hObject, eventdata, handles)
helpmsg = msgbox(sprintf('%s.\n%s.',...
    'This is a light version of the camera pipeline',...
    'Add your own custom pipeline under "Full" option.'),...
    'Rendering version');
set(gcf,'color',[38 38 38]/255);
set(helpmsg, 'position', ...
    [helpmsg.Position(1) helpmsg.Position(2) 280 80]); %makes box bigger
th = findall(helpmsg, 'Type', 'Text');
th.FontSize = 12;
th.Color = [1 1 1];

function RenderBtn_Callback(hObject, eventdata, handles)
global M fileName sz_ I type I_original I_temps temps
handles.fullPipeline.Enable = 'Off';
handles.lightPipeline.Enable = 'Off';
handles.helpbtn.Enable = 'Off';
handles.RenderBtn.Enable = 'Off';
temp_files = dir(fullfile('temp_dir','*.dng'));
for i  = 1 : length(temp_files)
    delete(fullfile('temp_dir',temp_files(i).name));
end
handles.status.String = 'Rendering...';

if  system(['DNGConv.exe -d temp_dir -u -o temp.dng ' fileName]) == 0
    fileName_ = fullfile('temp_dir','temp.dng'); 
    pause(0.001);
    if handles.fullPipeline.Value == 1
        helpmsg = msgbox(sprintf('%s',...
        'This option is not implemented in the current version.'),...
        'Rendering version');
        set(gcf,'color',[38 38 38]/255);
        set(helpmsg, 'position', ...
        [helpmsg.Position(1) helpmsg.Position(2) 280 80]); %makes box bigger
        th = findall(helpmsg, 'Type', 'Text');
        th.FontSize = 12;
        th.Color = [1 1 1];
    else
        addpath('camera_pipeline_light');
        try
            [I, resizedSrgbImages] = camera_pipeline_light(...
                fileName_, handles.temp.Value, sz_, temps);
        catch
            errormsg = msgbox('Error: cannot render the image!');
            set(gcf,'color',[38 38 38]/255);
            set(errormsg, 'position', ...
                [errormsg.Position(1) ...
                errormsg.Position(2) 280 80]); %makes box bigger
            th = findall(errormsg, 'Type', 'Text');
            th.FontSize = 12;
            th.Color = [1 1 1];
            handles.SaveBtn.Enable = 'Off';
            return;
        end
        I = double(I)./255;
        resizedSrgbImages = double(resizedSrgbImages)./255;
        I_original = I;
        I = imresize(I,0.3);
    end
    delete(fileName_);
    I_temp = imresize(I,[sz_,sz_]);
    
    %computing M
    M = zeros(size(resizedSrgbImages,4),34*3);
    I_temps = zeros(size(I,1),size(I,2),size(I,3),size(M,1));
    try
        for i  = 1 : size(resizedSrgbImages,4)
            M(i,:) = reshape(phi(reshape(I_temp,[],3))\...
                reshape(resizedSrgbImages(:,:,:,i),[],3),1,[]);
            I_temps (:,:,:,i) = applyCorrection(I,reshape(M(i,:),[34,3]));
        end
    catch
        errormsg =  msgbox('Error: Unable to compute mapping functions!');
        set(gcf,'color',[38 38 38]/255);
        set(errormsg, 'position', [errormsg.Position(1) ...
            errormsg.Position(2) 280 80]); %makes box bigger
        th = findall(errormsg, 'Type', 'Text');
        th.FontSize = 12;
        th.Color = [1 1 1];
        handles.SaveBtn.Enable = 'Off';
        return;
    end
    axes(handles.image);
    handles.image.Visible = 'On';
    imshow(I);
    handles.status.String = 'Done!'; pause(0.1); handles.status.String = '';
    handles.SaveBtn.Enable = 'On';
    handles.fullPipeline.Enable = 'Off';
    handles.lightPipeline.Enable = 'Off';
    handles.helpbtn.Enable = 'Off';
    handles.RenderBtn.Enable = 'Off';
    type = '.jpg';
    handles.SaveBtn.Enable = 'On';
else
    errormsg = msgbox('Error: please rename the DNG file or change the current file path!');
    set(gcf,'color',[38 38 38]/255);
    set(errormsg, 'position', [errormsg.Position(1) errormsg.Position(2) 280 80]); %makes box bigger
    th = findall(errormsg, 'Type', 'Text');
    th.FontSize = 12;
    th.Color = [1 1 1];
    handles.SaveBtn.Enable = 'Off';
    return;
end

function tungstenWB_Callback(hObject, eventdata, handles)
global curr_temp preset
handles.temp.Value  = 2850;
curr_temp = handles.temp.Value;
handles.temp_string.String  = num2str(curr_temp);
preset = 1;
temp_Callback(hObject, eventdata, handles)

function fluorescentWB_Callback(hObject, eventdata, handles)
global curr_temp preset
handles.temp.Value  = 3800;
curr_temp = handles.temp.Value;
handles.temp_string.String  = num2str(curr_temp);
preset = 1;
temp_Callback(hObject, eventdata, handles)

function daylightWB_Callback(hObject, eventdata, handles)
global curr_temp preset
handles.temp.Value  = 5500;
curr_temp = handles.temp.Value;
handles.temp_string.String  = num2str(curr_temp);
preset = 1;
temp_Callback(hObject, eventdata, handles)

function cloudyWB_Callback(hObject, eventdata, handles)
global curr_temp preset
handles.temp.Value  = 6500;
curr_temp = handles.temp.Value;
handles.temp_string.String  = num2str(curr_temp);
preset = 1;
temp_Callback(hObject, eventdata, handles)

function shadeWB_Callback(hObject, eventdata, handles)
global curr_temp preset
handles.temp.Value  = 7500;
curr_temp = handles.temp.Value;
handles.temp_string.String  = num2str(curr_temp);
preset = 1;
temp_Callback(hObject, eventdata, handles)


function UpdateBtn_Callback(hObject, eventdata, handles)
