%% Compute the optimal arming/disarming of agents from the adjacency matrix
%% of alliances and conflicts from the ACLED database. Group specific fixed
%% effects are included.

clear all
close all

%% Parameters.
beta  = 0.11401761;
gamma = 0.083189711;
V = 1;
we_cost = 10; % Increase in marginal cost of fighting for groups that are subject to weapons embargo.
remove_FARDC_drc = false;
ignore_FARDC_drc = true;
rwa_1_2_jointly = true; % Jointly target RWA-I and RWA-II when both are eligible.

tic

%% Load shifters (groups are sorted according to their ids).
fid = fopen(char(strcat('./Data/shifters.csv'))); % name,name_short,group,beta,gamma,TotFight,TotFight_Enemy,TotFight_Allied,OBS_SHIFTER,E
C = textscan(fid, '%s %s %s %s %s %s %s %s %s %s', 'delimiter', ',','headerlines',1);
fclose(fid);
names = strtrim(C{1});
names_short = strtrim(C{2});
index = str2double(strtrim(C{3}));
obs_effort = str2double(strtrim(C{6}));
z = str2double(strtrim(C{9})) + str2double(strtrim(C{10}));
clear('C')

n = max(index);
u = ones(n,1);

%% Load edges list.
fid = fopen(char(strcat('./Data/adjacency_matrix.csv'))); % group_a,group_b,enemy,allied,value
C = textscan(fid, '%s %s %s %s %s', 'delimiter', ',','headerlines',1);
fclose(fid);
group_a = str2double(strtrim(C{1}));
group_b = str2double(strtrim(C{2}));
alliance_indicator = str2double(strtrim(C{4}));
enemy_indicator = str2double(strtrim(C{3}));
link_indicator = max(alliance_indicator,enemy_indicator);
clear('C')

ind = find(link_indicator==0);
group_a(ind) = [];
group_b(ind) = [];
alliance_indicator(ind) = [];
enemy_indicator(ind) = [];
link_indicator(ind) = [];

%% Create adjaceny matrix for alliances.
A_plus = zeros(n,n);
for i=1:length(group_a)
    A_plus(group_a(i),group_b(i)) = alliance_indicator(i);
end
d_plus = sum(A_plus); % degrees.

%% Create adjaceny matrix for conflicts.
A_minus = zeros(n,n);
for i=1:length(group_a)
    A_minus(group_a(i),group_b(i)) = enemy_indicator(i);
end
d_minus = sum(A_minus); % degrees.

A = A_plus - A_minus;

%% Remove FARDC and DRC.
if(remove_FARDC_drc)
    ind = find(strcmp(names_short,'FARDC'));
    ind = [ind find(strcmp(names_short,'DRC'))];
    %     ind = [ind find(strcmp(names_short,'DRC-B'))];
    %     ind = [ind find(strcmp(names_short,'DRC-E'))];
    %     ind = [ind find(strcmp(names_short,'DRC-M'))];
    %     ind = [ind find(strcmp(names_short,'DRC-MB'))];
    %     ind = [ind find(strcmp(names_short,'DRC-P'))];
    %     ind = [ind find(strcmp(names_short,'DRC-PY'))];
    names(ind) = [];
    names_short(ind) = [];
    obs_effort(ind) = [];
    z(ind) = [];
    index(ind) = [];
    for j=1:length(ind)
        A_plus(ind(j),:) = [];
        A_plus(:,ind(j)) = [];
        A_minus(ind(j),:) = [];
        A_minus(:,ind(j)) = [];
        A(ind(j),:) = [];
        A(:,ind(j)) = [];
    end
    d_plus(ind) = [];
    d_minus(ind) = [];
    n = length(A);
end

%% Sort the agents according to the observed fighting effort.
[obs_effort_sorted ind] = sort(obs_effort,'descend');
names = names(ind);
names_short = names_short(ind);
obs_effort = obs_effort(ind);
z = z(ind);
A = A(ind,ind);
A_plus = A_plus(ind,ind);
A_minus = A_minus(ind,ind);
index = index(ind);
d_plus = d_plus(ind);
d_minus = d_minus(ind);

%% Compute Gamma.
Gamma = zeros(n,1);
for i=1:n
    Gamma(i) = 1/(1 + beta*d_plus(i) - gamma*d_minus(i));
end

%% Compute Lambda.
Lambda = 1-1/sum(Gamma);

%% Compute centralities.
M = inv(eye(n)+beta*A_plus-gamma*A_minus);
centrality = V.*Lambda.*(1-Lambda).*M*Gamma;
zeta = M*z;
rent_diss_bench = sum(centrality-zeta);

%% Iterate over groups.
marginal_cost = [];
rent_diss = [];
for i=1:n
    
    %disp(['Target group:' names_short(i)])
    
    %% Increase in cost of fighting of target groups.
    marginal_cost_prime = ones(n,1);
    marginal_cost_prime(i) = we_cost;
    
    %% Jointly target RWA-I and RWA-II when both are eligible.
    if(rwa_1_2_jointly)
        ind_rwa_1 = find(strcmp(names_short,'RWA-I'));
        ind_rwa_2 = find(strcmp(names_short,'RWA-II'));
        if( (i==ind_rwa_1) || (i==ind_rwa_2) )
            marginal_cost_prime(ind_rwa_1) = we_cost;
            marginal_cost_prime(ind_rwa_2) = we_cost;
        end
    end
    
    %% Evaluate objective function (rent dissipation).
    u = ones(n,1);
    D_inv = diag(marginal_cost_prime);
    Lambda_tilde = (u'*Gamma-1)/(u'*D_inv*Gamma);
    y = u'*M*(V*Lambda_tilde*(eye(n)-Lambda_tilde*D_inv)*Gamma - z);
    %y = V*u'*M*Lambda_tilde*(eye(n)-Lambda_tilde*D_inv)*Gamma;
    
    %% Do not consider FARDC or DRC as selectable groups.
    if(ignore_FARDC_drc)
        
        ind_FARDC = find(strcmp(names_short,'FARDC'));
        ind_drc = find(strcmp(names_short,'DRC'));
        if((i==ind_FARDC) || (i==ind_drc))
            
            marginal_cost = [marginal_cost; ones(1,n)];
            rent_diss = [rent_diss; rent_diss_bench];
            
        else
            
            marginal_cost = [marginal_cost; marginal_cost_prime'];
            rent_diss = [rent_diss; y];
            
        end
        
    end
    
end

ind = find(strcmp(names_short,'RWA-II'));
names_short(ind) = [];
rent_diss(ind) = [];
d_minus(ind) = [];
d_plus(ind) = [];
ind = find(strcmp(names_short,'RWA-I'));
names_short{ind} = 'RWA';

ind = find(strcmp(names_short,'DRC'));
names_short(ind) = [];
rent_diss(ind) = [];
d_minus(ind) = [];
d_plus(ind) = [];

ind = find(strcmp(names_short,'FADRC'));
names_short(ind) = [];
rent_diss(ind) = [];
d_minus(ind) = [];
d_plus(ind) = [];

%% Get agents' name identifiers according to the change in the policy.
[key_players_delta_rent_diss key_players] = sort(rent_diss_bench-rent_diss,'descend');

names_short(key_players)

%% Search for the name identifiers.
key_players_names = cell(length(key_players),1);
for i=1:length(key_players)
    ind = key_players(i);
    if(~isempty(ind))
        key_players_names{i} = names_short{ind};
    end
end

%% Plot the key player ranking with names.
figure();
set(gca,'Layer','top')
set(0, 'defaultTextInterpreter', 'latex');
set(findall(gcf,'type','axes'),'fontsize',20)
box on
x = [1:1:n-2];
y = 100*key_players_delta_rent_diss./rent_diss_bench;
%h = scatter(x,y,'filled');
h = plot(x,y,'-ok','LineWidth', 1.5);
hChildren = get(h, 'Children');
set(hChildren, 'Markersize', 5)
hold on
axis([min(x)-1, max(x)+1, min(y)-1, max(y)+1])
for k=1:7%length(x)
    if(~isempty(key_players_names{k}))
        %if(strcmp(key_players_names{k},'RWA-I') || strcmp(key_players_names{k},'RWA-II'))
        %    text(x(k),y(k),'RWA','FontSize',15)
        %else
        text(x(k),y(k),key_players_names{k},'FontSize',15)
        %end
    end
end
%set(gca,'YScale','log');
xlabel('group');
ylabel('$-\Delta \mathrm{RD}^{\beta,\gamma}$ $[\%]$');
box on
ylim([-1.5 3.5])
plot([1:1:n],zeros(n,1),'--r','LineWidth',1.5)
set(gca, 'XTickLabel', '')
set(findall(gcf,'type','axes'),'fontsize',20)
set(gcf,'PaperPositionMode','auto')
print('-depsc',['Figures/ranking_weapons_embargo_we_cost_' num2str(we_cost) '_single_group.eps'])
print('-dpdf',['Figures/ranking_weapons_embargo_we_cost_' num2str(we_cost) '_single_group.pdf'])

% Plot the key player ranking with names.
figure();
set(gca,'Layer','top')
set(0, 'defaultTextInterpreter', 'latex');
set(findall(gcf,'type','axes'),'fontsize',20)
box on
x = [1:1:n-2];
y = 100*key_players_delta_rent_diss./rent_diss_bench;
plot(x,y,'-ok','LineWidth', 1.5);
hold on
%set(gca,'YScale','log');
box on
ax = gca;
ax.XTick = [1:2:78];
ax.XTickLabel = { ...
    key_players_names{1}, key_players_names{3}, key_players_names{5}, ...
    key_players_names{7}, key_players_names{9}, ...
    key_players_names{11}, key_players_names{13}, key_players_names{15}, ...
    key_players_names{17}, key_players_names{19}, ...
    key_players_names{21}, key_players_names{23}, key_players_names{25}, ...
    key_players_names{27}, key_players_names{29}, ...
    key_players_names{31}, key_players_names{33}, key_players_names{35}, ...
    key_players_names{37}, key_players_names{39}, ...
    key_players_names{41}, key_players_names{43}, key_players_names{45}, ...
    key_players_names{47}, key_players_names{49}, ...
    key_players_names{51}, key_players_names{53}, key_players_names{55}, ...
    key_players_names{57}, key_players_names{59}, ...
    key_players_names{61}, key_players_names{63}, key_players_names{65}, ...
    key_players_names{67}, key_players_names{69},  ...
    key_players_names{71}, key_players_names{73}, key_players_names{75} ...
    key_players_names{77} ...
    };
ax.XTickLabelRotation=45;
set(0, 'defaultTextInterpreter', 'latex');
set(findall(gcf,'type','axes'),'fontsize',20)
ax.FontSize = 10;
ylabel('$-\Delta \mathrm{RD}^{\beta,\gamma}$ $[\%]$','fontsize',20);
%ylim([-1 1])
hold on
plot([1:1:n-2],zeros(n-2,1),'--r','LineWidth',1.5)
print('-depsc',['Figures/ranking_weapons_embargo_we_cost_' num2str(we_cost) '_single_group_2.eps'])
print('-dpdf',['Figures/ranking_weapons_embargo_we_cost_' num2str(we_cost) '_single_group_2.pdf'])

%% Write the key player ranking to a file.
permission = 'w'; % Replace.
filename = ['./Data/ranking_weapons_embargo_we_cost_' num2str(we_cost) '_single_group.dat'];
fid = fopen(filename,permission);
for i=1:length(key_players)
    ind = key_players(i);
    fprintf(fid,'%s \t & %i \t & %i \t & %f \t & %i \\\\ \n', key_players_names{i}, d_minus(ind), d_plus(ind), 100*key_players_delta_rent_diss(i)./rent_diss_bench, i);
end
fclose(fid);

t=toc; % Stopping the timer.
disp(datestr(datenum(0,0,0,0,0,t),'HH:MM:SS'))





