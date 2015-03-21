%%Temp Variables
%Variables and code to be replaced by user input or something else...
[fileName,filePath ]= uigetfile('*.csv');
filePath = fullfile(filePath, fileName);

pres1CH=1;
pres2CH=2;
pres3CH=3;
temp1CH=4;


%% Import and Parse Test Data
%This is where data is imported from the CSV file produced by the DAQ output. 

%Import data from csv 

fileID=fopen(filePath,'r');
for i=1:6
    Header{i}=fgetl(fileID);
    %Samp count is number 4
    %Samp interval is number 6
end
sampRate=1/(str2double(Header{6}(19:(strfind(Header{6},'seconds')-1))));
fclose(fileID);

dosCmd=['More +7 ' filePath ' > Temp.csv'];
status = dos(dosCmd);
%Put something here to throw error if status ~= 0
load Temp.csv
delete Temp.csv

%Assign data to correct sensors
pres1Dat=((1+cf)*400).*Temp(:,(3+pres1CH)); %Chamber Pressure
pres2Dat=((1+cf)*400).*Temp(:,(3+pres2CH)); %Line Pressure
pres3Dat=((1+cf)*400).*Temp(:,(3+pres3CH)); %Tank Pressure
temp1Dat=((1+cf)*400).*Temp(:,(3+temp1CH)); %Surface RTD Chamber
temp2Dat=((1+cf)*400).*Temp(:,(3+temp2CH)); %Surface RTD Tank
temp3Dat=((1+cf)*400).*Temp(:,(3+temp3CH));
forceDat=((1+cf)*400).*Temp(:,(3+temp3CH)); %Load Cell Force 



%% Get Time Info From User
%Using a similar method to waterflow processing, get the user to input the
%test's start and stop times.
%This section should be supplemented fairly easily by an automatic version
%using the force curve



%% Import Pertinant User Inputs
%This is where we import important user inputs like inital/final mass,
%start/stop times, ect. 

%Get initial mass (initalMass)

%Get final mass (finalMass)

%Get nozzle throat area (nozThroatArea)

%% Find Test Data and Prune Variables
%Use the force data to find where the test is starting and stoping
%Use this data to find the other viarables data for the test

%Prune time vector to vector burnTime

%Prune press1Dat to chamberPress

%Prune press2Dat to linePress

%Prune press3Dat to tankPress

%Prune temp1Dat to chamberSurfTemp

%Prune temp2Dat to chamberSurfTemp

%Prune forceDat to forceThrust

%% Begin Calculations 
%Begin the formulasitic calculatings sequentially building in complexity.
%EX. Find force then impulse then ISP then C* not find force then C*.

%Total Burn Time
totalBurnTime=(length(burnTime)/sampRate);

%Average Force Thrust
avgForceThrust=mean(forceThrust)/totalBurnTime

%Total Impulse
totalImpulse=traps(forceThrust);

%Average Mass Flow Rate
avgMassFlow=(finalMass-initialMass)/2;

%Specific Impulse
specificImpulse=totalImpulse/(9.81*avgMassFlow*totalBurnTime);%May also be able to find a better formula for this.

%Effective Exhost Velocity
c=specificImpulse/9.81;

%Average Characteristic Velocity
cStar=(mean(chamberPress)*nozThroatArea)/avgMassFlow;%May be improved if we can more accuratly find the chamber press and throat area when mass flow is at it's average

%Approximate Peak Thrust and Chamber Pressure
smoothThrust=zeros(1,length(floor((length(forceThrust)/4))));
smoothPress=zeros(1,length(floor((length(forceThrust)/4))));
smoothChamberTemp=zeros(1,length(floor((length(forceThrust)/4))));
smoothTankTemp=zeros(1,length(floor((length(forceThrust)/4))));
for i=1:floor((length(forceThrust)/4))
    k=(i-1)*4+1
    smoothThrust(i)=sum(forceThrust(k:k+3))/4;
    smoothPress(i)=sum(chamberPress(k:k+3))/4;
    smoothChamberTemp(i)=sum(chamberSurfTemp(k:k+3))/4;
    smoothTankTemp(i)=sum(tankSurfTemp(k:k+3))/4;
end
peakThrust=max(smoothThrust);
peakChamberPress=max(smoothPress);
peakChamberSurfTemp=max(smoothChamberTemp);
minTankTemp=min(smoothTankTemp);

%Average Percent Pressure Drop
avgPressDrop=sum((tankPress-linePress)./tankPress)/length(tankPress);

%Line Pressure (approximate injector pressure) to Chamber Pressure Ratio
pressRatio=linePress./chamberPress;

%Calculate N2O Tank Temp


%Calculate min N2O Tank Temp





%% Plot and Display Calculations
%Plot the results of all the calculations. 
%This may be in a different function

