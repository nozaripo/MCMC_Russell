clear
% clc
close all

% Create data for mass spring damper system 

m  = 1; % mass
c  = 0.2; % damping
k1 = 3; % stiffness value for region 1
k2 = 10; % stiffness value for region 2
R  = 0.03; % threshold to switch from region 1 to region 2
y0 = [0.1;0]; % initial states (position;velocity)

theta = [m;c;k1;k2;R];

tFinal = 20;
tInit  = 0;
timestep = 0.05;
time   = tInit:timestep:tFinal;

displacement = (0:0.01:.2);
for i = 1:length(displacement)
    if abs(displacement(i)) < R
        force(i) = displacement(i)*k1;
    else
        force(i) = k1*R + k2*(displacement(i)-R);
    end
end

force_neg = flip(force*-1);

force = horzcat(force_neg(1:end-1),force);

for i = 1:length(displacement)
    if displacement(i) < R
        force2(i) = displacement(i)*k1;
    else
        force2(i) = displacement(i)*k2;
    end
end

displacement = -0.2:0.01:0.2; 

figure(99)
yline(0,'--');
hold on
xline(-R);
hold on 
xline(R);
hold on 

txt = '\leftarrow k1 \rightarrow';
text(-.025,0.9,txt,'fontsize',16);
txt2 = '\leftarrow k2 \rightarrow';
h1 =text(-0.155,-1,txt2,'fontsize',16);
h2 =text(0.10,1,txt2,'fontsize',16);
set(h1,'Rotation',25);
set(h2,'Rotation',25);

plot(displacement,force,'r','LineWidth',2)
set(gca,'fontsize',16)
xlabel('Displacement (m)')
ylabel('Force (N)')
box off
pbaspect([3 2 1])
xlim([-0.2 .2])
ylim([-3 3])

[t,y] = ode15s(@SMD_sys,time,y0,[],theta);

position = y(:,1);
velocity = y(:,2);
acceleration = deriv(velocity,.05);

figure(1)
subplot(3,1,1)
plot([0 20],[0 0],'k')
hold on 
plot(time,position,'b','LineWidth',2)
set(gca,'fontsize',10)
xlabel('time (s)')
ylabel('position (m)')
ylim([-.2 .2])
box off

subplot(3,1,2)
plot([0 20],[0 0],'k')
hold on 
plot(time,velocity,'b','LineWidth',2)
set(gca,'fontsize',10)
xlabel('time (s)')
ylabel('velocity (m/s)')
ylim([-.5 .5]);
box off

subplot(3,1,3)
plot([0 20],[0 0],'k')
hold on 
plot(time,acceleration,'b','LineWidth',2)
set(gca,'fontsize',10)
xlabel('time (s)')
ylabel('accel. (m/s/s)')
ylim([-2 2]);
box off

% add noise to position signal
noise = 0.005; % magnitude of noise/resolution of measurement to 0.xx meters
for i = 1:length(position)
    noise_series(i) = (randn())*noise;
end

for j = 1:4
    position_noise(:,j) = (randn(length(position),1)*noise) + position; % add noise to position data - need to scale by factor of 2 so that it matches the noise scaling factor
    velocity_noise(:,j) = deriv(position_noise(:,j),.05);
    acc_noise(:,j)      = deriv(velocity_noise(:,j),.05);
end

colors = [ 0    0.4470    0.7410;
    0.8500    0.3250    0.0980;
    0.9290    0.6940    0.1250;
    0.4940    0.1840    0.5560];

figure(2)
subplot(3,1,1)
h1 = plot(time,position,'r--','LineWidth',2);
hold on 
h2 = plot(time,position_noise(:,1),'color',colors(1,:),'LineWidth',2);
hold on
for j = 2:4
    plot(time,position_noise(:,j),'color',colors(j,:),'LineWidth',2);
    hold on
end
set(gca,'fontsize',10)
xlabel('time (s)')
ylabel('position (m)')
ylim([-.2 .2])
box off

subplot(3,1,2)
plot(time,velocity,'r--','LineWidth',2)
hold on 
for j = 1:4
    plot(time,velocity_noise(:,j),'color',colors(j,:),'LineWidth',2)
    hold on
end
set(gca,'fontsize',10)
legend('Ref. Position','Noise 1','Noise 2','Noise 3','Noise 4','orientation','horizontal');
legend('boxoff')
xlabel('time (s)')
ylabel('velocity (m/s)')
ylim([-.5 .5]);
box off

subplot(3,1,3)
plot(time,acceleration,'r--','LineWidth',2)
hold on 
for j = 1:4
    plot(time,acc_noise(:,j),'color',colors(j,:),'LineWidth',2)
end
set(gca,'fontsize',10)
xlabel('time (s)')
ylabel('accel. (m/s/s)')
ylim([-5 5]);
box off

figure(3)

plot(time,position_noise(:,1),'color',colors(1,:),'LineWidth',2);
hold on
for j = 2:4
    plot(time,position_noise(:,j),'color',colors(j,:),'LineWidth',2);
    hold on
end
plot(time,position,'c--','LineWidth',2);
legend('Ref. Position','Noise 1','Noise 2','Noise 3','Noise 4');
legend('boxoff')
set(gca,'fontsize',10)
xlabel('time (s)')
ylabel('position (m)')
ylim([-.2 .2])
box off

figure(4)

set(gcf,'units','centimeters','Position',[7.5935 4.2863 14 12])

subplot(2,2,2)
yline(0,'--');
hold on
xline(-R);
hold on 
xline(R);
hold on 
txt = 'k_1';
text(-.010,0.5,txt,'fontsize',10);
txt2 = '\leftarrow k_2 \rightarrow';
h1 =text(-0.175,-1.05,txt2,'fontsize',10);
h2 =text(0.08,1.1,txt2,'fontsize',10);
txt3 = 'R';
h3 = text(.04,2.3,txt3,'fontsize',10);
txt4 = '-R';
h4 = text(-.062,2.3,txt4,'fontsize',10);
set(h1,'Rotation',25);
set(h2,'Rotation',25);
plot(displacement,force,'r','LineWidth',2)
text(-0.2,1,'B','fontsize',10,'fontweight','bold','units','normalized')
set(gca,'fontsize',10)
xlabel('Displacement (m)')
ylabel('Force (N)')
box off
pbaspect([3 2 1])
xlim([-0.2 .2])
ylim([-3 3])

subplot(2,2,3:4)
plot(time,position_noise(:,1),'color',colors(1,:),'LineWidth',2);
hold on
for j = 2:4
    plot(time,position_noise(:,j),'color',colors(j,:),'LineWidth',2);
    hold on
end
plot(time,position,'c--','LineWidth',2);
legend('Trial 1','Trial 2','Trail 3','Trial 4','Ref. Position','orientation','horizontal');
legend('boxoff')
set(gca,'fontsize',10)
xlabel('time (s)')
ylabel('position (m)')
ylim([-.2 .2])
text(-0.1,1,'C','fontsize',10,'fontweight','bold','units','normalized')
box off

% uncomment to write out new files
return

save position_newnoise.mat position
save velocity_newnoise.mat velocity
% % below is going to be our "measured" input with some measurement error
save position_noise_newnoise.mat position_noise 

function ydot = SMD_sys(t,y,theta)
    % ode system function for MCMC algae example
    
    m    = theta(1);
    c   = theta(2);
    k1   = theta(3);
    k2   = theta(4);
    R    = theta(5);
        
    if (-R<y(1)) && (y(1)<R)
        A = [0 1; -k1/m -c/m];
    else 
        A = [0 1; -(((k1*R)/(abs(y(1)))-(k2*R)/(abs(y(1)))+k2))/m -c/m];
    end
    
    ydot = A*y ;

end

