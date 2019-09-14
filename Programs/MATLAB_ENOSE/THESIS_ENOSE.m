function varargout = THESIS_ENOSE(varargin)
% THESIS_ENOSE MATLAB code for THESIS_ENOSE.fig
%      THESIS_ENOSE, by itself, creates a new THESIS_ENOSE or raises the existing
%      singleton*.
%
%      H = THESIS_ENOSE returns the handle to a new THESIS_ENOSE or the handle to
%      the existing singleton*.
%
%      THESIS_ENOSE('CALLBACK',hObject, eventData,handles,...) calls the local
%      function named CALLBACK in THESIS_ENOSE.M with the given input arguments.
%
%      THESIS_ENOSE('Property','Value',...) creates a new THESIS_ENOSE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before THESIS_ENOSE_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to THESIS_ENOSE_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help THESIS_ENOSE

% Last Modified by GUIDE v2.5 26-Mar-2019 22:26:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @THESIS_ENOSE_OpeningFcn, ...
                   'gui_OutputFcn',  @THESIS_ENOSE_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before THESIS_ENOSE is made visible.
function THESIS_ENOSE_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to THESIS_ENOSE (see VARARGIN)

% Choose default command line output for THESIS_ENOSE
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes THESIS_ENOSE wait for user response (see UIRESUME)
% uiwait(handles.figure1);
init(handles)

function init(handles)

global portPresent
global s;
global connected;

movegui(gcf,'center');

portPresent=false;
s="";
connected=false;

if ~isequal(size(seriallist,2),0)
    set(handles.portListCB,'String',seriallist)
    portPresent=true;
end

set(handles.connectButton,'enable','on')
set(handles.disconnectButton,'enable','off')
set(handles.serial_status,'String','Disconnected');
set(handles.serial_status,'ForegroundColor','red');

set(handles.graphDataButton,'enable','on')
set(handles.clearDataButton,'enable','on')

% --- Outputs from this function are returned to the command line.
function varargout = THESIS_ENOSE_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in connectButton.
function connectButton_Callback(hObject, eventdata, handles)
% hObject    handle to connectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global portPresent;
global s;
global connected;
global fileID;

if ~connected
    if portPresent
        disp("Connecting...");
        index = get(handles.portListCB,'Value');
        items = get(handles.portListCB,'String');

        if isequal(size(items,2),2)
            %disp(items{index});
            s=serial(items{index});  
        else
            %disp(items);
            s=serial(items);
        end
        
        fopen(s);
        set(s,'DataBits',8);
        set(s,'StopBits',1);
        set(s,'BaudRate', 9600);
        set(s,'Parity','none');
        set(s,'Timeout',5);
        
        connected=true;
        
        set(handles.serial_status,'String','Connected');
        set(handles.serial_status,'ForegroundColor','green');
        set(handles.connectButton,'enable','off');
        set(handles.disconnectButton,'enable','on');
    
        set(handles.graphDataButton,'enable','off')
        set(handles.clearDataButton,'enable','off')

        drawnow;
        fileID = fopen('data.txt','a');
        
        while connected
            try
                data=fgets(s);
                disp(data);
                data=data(1:end-2);
                
                fuzzyClassification(handles,data);
                
                fprintf(fileID,'%s\r\n', data)
                data = strsplit(data,',');  
                disp(data);
                
                set(handles.mq2Label,"String",data(1));
                set(handles.mq135Label,"String",data(2));
                set(handles.mq3Label,"String",data(3));
                set(handles.mq8Label,"String",data(4));
                
                set(handles.tgs882Label,"String",data(5));
                set(handles.mq136Label,"String",data(6));
                set(handles.tgs2600Label,"String",data(7));
                set(handles.tempLabel,"String",data(8));
                
            catch ME
                disp(ME.identifier);
                msgbox('An error has occured from reading serial device, invalid format.');
                fclose(s);
                fclose(fileID)
                init(handles);
            end
            
            drawnow;
        end
        
    else
        msgbox('No port selected');
    end
else
    msgbox('Already connected');

end
% --- Executes on button press in disconnectButton.
function disconnectButton_Callback(hObject, eventdata, handles)
% hObject    handle to disconnectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global connected;
global s;   
global fileID;

if connected
    connected=false;
    fclose(s);
    fclose(fileID)
    init(handles);

end

% --- Executes on selection change in portListCB.
function portListCB_Callback(hObject, eventdata, handles)
% hObject    handle to portListCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns portListCB contents as cell array
%        contents{get(hObject,'Value')} returns selected item from portListCB


% --- Executes during object creation, after setting all properties.
function portListCB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to portListCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mq2Label_Callback(hObject, eventdata, handles)
% hObject    handle to mq2Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mq2Label as text
%        str2double(get(hObject,'String')) returns contents of mq2Label as a double


% --- Executes during object creation, after setting all properties.
function mq2Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mq2Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mq135Label_Callback(hObject, eventdata, handles)
% hObject    handle to mq135Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mq135Label as text
%        str2double(get(hObject,'String')) returns contents of mq135Label as a double


% --- Executes during object creation, after setting all properties.
function mq135Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mq135Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mq3Label_Callback(hObject, eventdata, handles)
% hObject    handle to mq3Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mq3Label as text
%        str2double(get(hObject,'String')) returns contents of mq3Label as a double


% --- Executes during object creation, after setting all properties.
function mq3Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mq3Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gasLabel4_Callback(hObject, eventdata, handles)
% hObject    handle to gasLabel4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gasLabel4 as text
%        str2double(get(hObject,'String')) returns contents of gasLabel4 as a double


% --- Executes during object creation, after setting all properties.
function gasLabel4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gasLabel4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mq8Label_Callback(hObject, eventdata, handles)
% hObject    handle to mq8Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mq8Label as text
%        str2double(get(hObject,'String')) returns contents of mq8Label as a double


% --- Executes during object creation, after setting all properties.
function mq8Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mq8Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tgs882Label_Callback(hObject, eventdata, handles)
% hObject    handle to tgs882Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tgs882Label as text
%        str2double(get(hObject,'String')) returns contents of tgs882Label as a double


% --- Executes during object creation, after setting all properties.
function tgs882Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tgs882Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tgs2600Label_Callback(hObject, eventdata, handles)
% hObject    handle to tgs2600Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tgs2600Label as text
%        str2double(get(hObject,'String')) returns contents of tgs2600Label as a double


% --- Executes during object creation, after setting all properties.
function tgs2600Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tgs2600Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mq136Label_Callback(hObject, eventdata, handles)
% hObject    handle to mq136Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mq136Label as text
%        str2double(get(hObject,'String')) returns contents of mq136Label as a double


% --- Executes during object creation, after setting all properties.
function mq136Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mq136Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ripeningLabel_Callback(hObject, eventdata, handles)
% hObject    handle to ripeningLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ripeningLabel as text
%        str2double(get(hObject,'String')) returns contents of ripeningLabel as a double


% --- Executes during object creation, after setting all properties.
function ripeningLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ripeningLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in shutdownButton.
function shutdownButton_Callback(hObject, eventdata, handles)
% hObject    handle to shutdownButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = questdlg('Are you sure you want to shutdown the RPi?', ...
	'Shutdown', ...
	'YES','NO','NO');
% Handle response
switch answer
    case 'YES'
        disp('YES')
    case 'NO'
        disp('NO')
end

function fuzzyClassification(handles,gasReadingArray)

% fuzzification
% value>= 0 and value<1.67 = LOW
% value>=1.67 and value<3.34 = MEDIUM
% value>=3.34 = HIGH

% array arrangement: mq2,mq135, mq3, mq8, tgs882, mq136, tgs2600
%                  : gasReadingArray(1), gasReadingArray(2), .....
%                  gasReadingArray(7)

% Index 8 is not included since it is temperature. We loop below from 1-7.

% Cell of gas readings.
gasReadingArray = strsplit(gasReadingArray,','); 
 
% Convert all cells to double.
gasReadingArray=str2double(gasReadingArray);


TGS813Fuzz="";         % TGS813 mq2
TGS826Fuzz="";         % TGS826 mq135
TGS2620Fuzz="";        % TGS2620 mq3
TGS821Fuzz="";         % TGS821 mq8
TGS822Fuzz="";         % as is
TGS825Fuzz="";         % TGS825 mq136
TGS2600Fuzz="";        % as is
ripeStage="";

% Loop through the the fuzzification index.
for i=1:7
    tempFuzz="";
    
    if (gasReadingArray(i))>=0 && (gasReadingArray(i))<1.67
        tempFuzz="LOW";
    elseif (gasReadingArray(i))>=1.67 && (gasReadingArray(i))<3.34
        tempFuzz="MEDIUM";
    elseif (gasReadingArray(i))>=3.34
        tempFuzz="HIGH";
    end    
    
    if i==1
        TGS813Fuzz=tempFuzz;
    elseif i==2
        TGS826Fuzz=tempFuzz;
    elseif i==3
        TGS2620Fuzz=tempFuzz;
    elseif i==4
        TGS821Fuzz=tempFuzz;
    elseif i==5
        TGS822Fuzz=tempFuzz;
    elseif i==6
        TGS825Fuzz=tempFuzz;
    elseif i==7
        TGS2600Fuzz=tempFuzz;
    end  
end

% disp(TGS813Fuzz);
% disp(TGS826Fuzz);
% disp(TGS2620Fuzz);
% disp(TGS821Fuzz);
% disp(tgs882Fuzz);
% disp(TGS825Fuzz);
% disp(TGS2600Fuzz);  

% Fuzzy logic rules.


if TGS826Fuzz=="LOW" && TGS2600Fuzz=="LOW" && TGS813Fuzz=="LOW" && TGS2620Fuzz=="LOW" && TGS822Fuzz=="LOW" && TGS813Fuzz=="LOW"
    ripeStage="UNRIPE";
elseif TGS826Fuzz=="LOW" && TGS2600Fuzz=="LOW" && TGS813Fuzz=="MEDIUM" && TGS2620Fuzz=="LOW" && TGS822Fuzz=="LOW" && TGS813Fuzz=="LOW"
    ripeStage="RIPE";
elseif TGS826Fuzz=="MEDIUM" && TGS2600Fuzz=="MEDIUM" && TGS813Fuzz=="MEDIUM" && TGS2620Fuzz=="MEDIUM" && TGS822Fuzz=="LOW" && TGS813Fuzz=="LOW"
    ripeStage="OVERRIPE";
elseif TGS826Fuzz=="MEDIUM" && TGS2600Fuzz=="MEDIUM" && TGS813Fuzz=="MEDIUM" && TGS2620Fuzz=="MEDIUM" && TGS822Fuzz=="MEDIUM" && TGS813Fuzz=="MEDIUM"
    ripeStage="OVERRIPE";
elseif TGS826Fuzz=="MEDIUM" && TGS2600Fuzz=="MEDIUM" && TGS813Fuzz=="MEDIUM" && TGS2620Fuzz=="MEDIUM" && TGS822Fuzz=="LOW" && TGS813Fuzz=="LOW"
    ripeStage="OVERRIPE";
else
    ripeStage="RIPE";
end


disp("Ripe Stage:");
disp(ripeStage);

set(handles.ripeningLabel,'String',ripeStage);



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global connected;
global s;   
global fileID;

if connected
    connected=false;
    fclose(s);
    fclose(fileID);
    init(handles);

end
% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in clearDataButton.
function clearDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to clearDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fileID;

answer = questdlg('Are you sure you want to clear all data?', ...
	'Shutdown', ...
	'YES','NO','NO');
% Handle response
switch answer
    case 'YES'
        disp('YES')
        fileID = fopen('data.txt','w');
        fclose(fileID);
    case 'NO'
        disp('NO')
end

% --- Executes on button press in graphDataButton.
function graphDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to graphDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Read CSV file.

try
    csvFile=csvread('data.txt');

    if (size(csvFile,1)~=0)
        % Remove temperature.
        csvFile=csvFile(:,1:end-1);

        % Plot it.
        figure('units','normalized','outerposition',[0 0 1 1])
        plot(csvFile);
        title('Gas Voltage Readings')
        xlabel('Number')
        ylabel('Voltage')
        legend('TGS813','TGS826','TGS2620','TGS821','TGS822','TGS825','TGS2600')
    else
        msgbox("Data is empty!");
    end
catch
    msgbox("Data is not in not in proper format or it is empty!");
end
function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tempLabel_Callback(hObject, eventdata, handles)
% hObject    handle to tempLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tempLabel as text
%        str2double(get(hObject,'String')) returns contents of tempLabel as a double


% --- Executes during object creation, after setting all properties.
function tempLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tempLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
