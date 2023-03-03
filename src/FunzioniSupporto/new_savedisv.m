%salva nella matrice i nomi dei workspace con i relativi displacement
%velocity

info = {'cog11585','cog12085','cog12585','cog13085';'a045','a082','a150',[];'f033','f010',[],[]}';
Tab = cell(1,2);
T_cut = 30;
index = 1;

for i=1:length(info(:,1))
    for j=1:length(info(:,2))
        if (~isempty(info{j,2}))
          a = strcat(info{i,1},info{j,2});
        
        
        for k =1:length(info(:,3))
            if (~isempty(info{k,3}))
                for ibreak=0:4
                    nbreak = num2str(ibreak);
                    wsname = strcat('Test_',num2str(index),'__',a,info{k,3},'B',nbreak,'.mat');
                    load(wsname)
                    DisplacementVelocity
                    
                    Tab{index,1} = strcat('Test ',num2str(index));
                    Tab{index,2} = wsname;
                    Tab{index,3} = vehicle.cog;
                    Tab{index,4} = wave_amplitude;
                    Tab{index,5} = wave_frequency;
                    Tab{index,6} = strcat('B',nbreak);
                    Tab{index,7} = vel_displacement;
                    
                    index = index+1;
                end

            end
        
        end
        end
    end
        
end

close all;

label = {'Test','workspace','COG [m]','Wave Amplitude [m]',...
    'Wave Frequency [Hz]','Brake Action','Displacement velocity [m/s]'};

xlswrite('disvel.xlsx',label,1,'B1');
xlswrite('disvel.xlsx',Tab,1,'B3');