inputStr="1,4,5,3,2,4,5";
gasReadingArray = strsplit(inputStr,',');  
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