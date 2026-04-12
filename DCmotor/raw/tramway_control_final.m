% =========================================================================
%  TRAMWAY "CARELLI 1928" — DC Motor Speed Control
%  Course : Dynamics of Electrical Machines and Drives
%  Author : Matteo Cavalleri  |  ID: 10768765
%  Prof.  : Francesco Castelli Dezza
% =========================================================================

clc; clear; close all;

% -------------------------------------------------------------------------
%  CONSISTENCY CHECK (pre-verification, run mentally before simulation)
%
%    En_motor  = Ks * Ie * omega_n  =  1.06 * 5 * 101.6  ≈  539 V
%    En_KVL    = V  - Ra * Ia       =  600  - 0.39 * 156  ≈  539 V
%    Tn_motor  = Ks * Ie * Ia       =  1.06 * 5 * 156     ≈  827 Nm
%    Tn_mech   = 4 * Pn / omega_n   =  84000 / 101.6      ≈  827 Nm
% -------------------------------------------------------------------------


%% ========================================================================
%  1.  UNIVERSAL CONSTANTS
% =========================================================================

g = 9.81;           % Gravitational acceleration          [m/s^2]


%% ========================================================================
%  2.  MOTOR PARAMETERS  (equivalent model for 4 motors in parallel)
% =========================================================================

% --- DC line supply --------------------------------------------------
V      = 600;       % DC line voltage                     [V]

% --- Armature circuit ------------------------------------------------
Pn     = 21e3;      % Rated power per motor               [W]
Imaxn  = 156;       % Total rated armature current        [A]
Ra     = 0.39;      % Equivalent armature resistance      [Ohm]
ta     = 10e-3;     % Armature circuit time constant      [s]
La     = ta * Ra;   % Equivalent armature inductance      [H]

% --- Excitation circuit (same for every motor) -----------------------
Ve     = 60;        % Rated excitation voltage            [V]
Ie     = 5;         % Rated excitation current            [A]
Re     = 12;        % Excitation resistance               [Ohm]
te     = 0.1;       % Excitation time constant            [s]
Le     = te * Re;   % Excitation inductance               [H]

% --- Machine constant ------------------------------------------------
%  Kt is interpreted as the TOTAL machine constant Ks (see Section 3
%  of the report for the KVL-based justification).
Kt     = 1.06;      % Machine constant from datasheet     [Nm/A^2]
Ks     = Kt;        % Total machine constant  Ks = Kt     [Nm/A^2]

% --- Rated speed -----------------------------------------------------
omen   = 970;                   % Rated speed              [rpm]
ome    = omen * 2 * pi / 60;    % Rated speed              [rad/s]

% --- Maximum vehicle speed -------------------------------------------
v_max_ms = 42 / 3.6;            % Maximum vehicle speed    [m/s]


%% ========================================================================
%  3.  PARAMETER CONSISTENCY VERIFICATION
% =========================================================================

En_motor   = Ks * Ie * ome;             % Back-EMF from machine constant    [V]
En_KVL     = V  - Ra * Imaxn;           % Back-EMF from Kirchhoff's law     [V]
Tn_motor   = Ks * Ie * Imaxn;          % Rated torque — machine equation   [Nm]
Tn_mech    = 4  * Pn / ome;            % Rated torque — power balance      [Nm]
eta        = (4 * Pn) / (V * Imaxn);   % Nominal efficiency                [-]
En         = En_motor;                  % Nominal back-EMF used hereafter   [V]

fprintf('=== PARAMETER CONSISTENCY CHECK ===\n');
fprintf('  En  (Ks·Ie·ωn)  : %8.2f V\n',  En_motor);
fprintf('  En  (V - Ra·Ia) : %8.2f V\n',  En_KVL);
fprintf('  Relative error  : %8.3f %%\n', abs(En_motor - En_KVL) / En_KVL * 100);
fprintf('  ---\n');
fprintf('  Tn  (Ks·Ie·Ia)  : %8.1f Nm\n', Tn_motor);
fprintf('  Tn  (4·Pn/ω)    : %8.1f Nm\n', Tn_mech);
fprintf('  Relative error  : %8.3f %%\n', abs(Tn_motor - Tn_mech) / Tn_mech * 100);
fprintf('  ---\n');
fprintf('  Nominal efficiency : %.3f\n',   eta);
fprintf('====================================\n\n');


%% ========================================================================
%  4.  MECHANICAL PARAMETERS  (referred to the motor shaft)
% =========================================================================

mt     = 15e3;          % Vehicle mass — unloaded                    [kg]
mp     = 80;            % Average passenger mass                     [kg]
np     = 130;           % Maximum number of passengers               [-]
m      = mt + mp * np;  % Total vehicle mass  (= 25 400 kg)          [kg]

d      = 680e-3;        % Wheel diameter                             [m]
rho    = 13 / 74;       % Gearbox ratio  (motor shaft → wheel)       [-]
beta   = 0.81;          % Viscous friction coefficient               [Nms]

% Equivalent moment of inertia referred to the motor shaft.
% Assumption: rigid transmission; rotor / gear inertia neglected.
J = m * (rho * d / 2)^2;   % Equivalent inertia                     [kg·m^2]

fprintf('=== MECHANICAL PARAMETERS ===\n');
fprintf('  Total mass  m : %8.0f kg\n',     m);
fprintf('  Equiv. inertia J : %8.4f kg·m^2\n', J);
fprintf('=============================\n\n');


%% ========================================================================
%  5.  TRANSFER FUNCTION PARAMETERS
%      Each plant is first-order:  G(s) = G_dc / (1 + s·tau)
% =========================================================================

tG_a = ta;       G_a = 1 / Ra;    % Armature :   Ga(s) = G_a / (1 + s·tG_a)
tG_e = te;       G_e = 1 / Re;    % Excitation : Ge(s) = G_e / (1 + s·tG_e)
tGm  = J / beta; Gm  = 1 / beta;  % Mechanical : Gm(s) = Gm  / (1 + s·tGm )

fprintf('=== PLANT TIME CONSTANTS ===\n');
fprintf('  tau_armature    : %8.4f s\n', tG_a);
fprintf('  tau_excitation  : %8.4f s\n', tG_e);
fprintf('  tau_mechanical  : %8.2f s\n', tGm);
fprintf('============================\n\n');


%% ========================================================================
%  6.  PI CONTROLLER DESIGN  —  pole-zero cancellation method
% =========================================================================
%
%  The PI zero cancels the plant pole:   C(s) = Kp · (1 + 1/(tau·s))
%  The resulting open-loop function is:  L(s) = omega_i / s
%  This gives Phase Margin = 90° exactly.
%
%  Bandwidth hierarchy (loop separation ≥ factor 10):
%    omega_e  >>  omega_i  >>  omega_m
%       40    >>     20    >>      2    [rad/s]
% -------------------------------------------------------------------------

wi = 20;    % Armature current loop bandwidth    [rad/s]
we = 40;    % Excitation current loop bandwidth  [rad/s]
wm =  2;    % Angular speed loop bandwidth       [rad/s]

% PI gains:  Kp = omega_i · L,   Ki = omega_i · R
KpA = wi * La;      KiA = wi * Ra;      % Armature current controller
KpE = we * Le;      KiE = we * Re;      % Excitation current controller
KpM = wm * J;       KiM = wm * beta;    % Speed controller

fprintf('=== PI CONTROLLER GAINS ===\n');
fprintf('  Armature    — Kp = %8.4f   Ki = %8.4f\n', KpA, KiA);
fprintf('  Excitation  — Kp = %8.4f   Ki = %8.4f\n', KpE, KiE);
fprintf('  Speed       — Kp = %8.4f   Ki = %8.6f\n', KpM, KiM);
fprintf('===========================\n\n');


%% ========================================================================
%  7.  ANTI-WINDUP — back-calculation gains
% =========================================================================
%
%  Back-calculation gain:  Kb = 1 / tau
%  The gain is set equal to the inverse of the corresponding time constant.
%  This ensures fast and smooth recovery from saturation.
%
%  Implementation in Simulink:
%    - Set "Anti-windup method" = back-calculation inside each PI block.
%    - Enter Kb in the "Back-calculation coefficient" field.
%    - No external Subtract or Gain blocks are needed.
% -------------------------------------------------------------------------

Kb_a = 1 / ta;      % Armature  anti-windup gain  =  100    [1/s]
Kb_e = 1 / te;      % Excitation anti-windup gain =   10    [1/s]
Kb_m = 1 / tGm;     % Speed     anti-windup gain  ≈ 0.0089  [1/s]

fprintf('=== ANTI-WINDUP GAINS (back-calculation) ===\n');
fprintf('  Kb_armature    : %8.4f   (tau = %.4f s)\n', Kb_a, ta);
fprintf('  Kb_excitation  : %8.4f   (tau = %.4f s)\n', Kb_e, te);
fprintf('  Kb_speed       : %8.6f   (tau = %.2f  s)\n', Kb_m, tGm);
fprintf('=============================================\n\n');

% Saturation limits for each loop
Te_max    =  Ks * Ie * Imaxn;  % Torque saturation on Speed PI output    [Nm]
Te_min    = -Te_max;            %                                          [Nm]
Ia_max    =  Imaxn;             % Current saturation on Ia PI output      [A]
Ia_min    = -Imaxn;             %                                          [A]
Va_max    =  V;                 % Voltage saturation on Va                [V]
Va_min    = -V;                 %                                          [V]

fprintf('=== SATURATION LIMITS ===\n');
fprintf('  Speed PI output  (Te) : [%+.1f , %+.1f] Nm\n', Te_min, Te_max);
fprintf('  Armature PI output (Va): [%+.1f , %+.1f] V\n',  Va_min, Va_max);
fprintf('=========================\n\n');


%% ========================================================================
%  8.  FIELD WEAKENING  —  constant-power operating region
% =========================================================================
%
%  Above base speed the excitation current is reduced as:
%    Ie_ref(omega) = Ie_rated * omega_base / omega
%  This keeps the back-EMF below the 600 V line limit.
% -------------------------------------------------------------------------

ome_base   = En / (Ks * Ie);           % Base speed (start of FW region)  [rad/s]
ome_max    = v_max_ms / (rho * d / 2); % Maximum motor shaft speed         [rad/s]
Ie_at_vmax = Ie * ome_base / ome_max;  % Excitation current at v_max       [A]

fprintf('=== FIELD WEAKENING ===\n');
fprintf('  omega_rated      : %8.3f rad/s  (%5.1f rpm)\n', ome,       omen);
fprintf('  omega_base (FW)  : %8.3f rad/s  (= omega_rated — check)\n', ome_base);
fprintf('  omega_max        : %8.3f rad/s  (%5.1f rpm)\n', ome_max,   ome_max * 60 / (2*pi));
fprintf('  FW speed ratio   : %8.3f  (v_max / v_base)\n', ome_max / ome_base);
fprintf('  Ie at v_max      : %8.3f A\n', Ie_at_vmax);
fprintf('=======================\n\n');


%% ========================================================================
%  9.  SLOPE DISTURBANCE VERIFICATION
% =========================================================================

gamma_5 = atan(0.05);   % Slope angle for ±5 % grade              [rad]

% Disturbance torque referred to the motor shaft
T_dist_up   =  m * g * sin(gamma_5) * rho * (d/2);  % Uphill   [Nm]
T_dist_down = -T_dist_up;                             % Downhill [Nm]

fprintf('=== SLOPE DISTURBANCE TORQUE ===\n');
fprintf('  T_dist  (+5 %% uphill)   : %8.1f Nm\n',  T_dist_up);
fprintf('  T_dist  (-5 %% downhill) : %8.1f Nm\n',  T_dist_down);
fprintf('  Rated torque  Tn        : %8.1f Nm\n',  Tn_motor);
fprintf('  Disturbance / Tn ratio  : %8.3f\n',     T_dist_up / Tn_motor);
fprintf('================================\n\n');


%% ========================================================================
%  10.  RATE LIMITER — speed reference profiling
% =========================================================================
%
%  A Rate Limiter block on the speed reference prevents instantaneous step
%  changes, replacing them with smooth ramps (constant-acceleration phases).
%  Insert it in Simulink on the omega_ref wire, BEFORE the Speed PI summer.
%
%  Settings:
%    Rising  slew rate =  alpha_max   [rad/s^2]
%    Falling slew rate = -alpha_max   [rad/s^2]
% -------------------------------------------------------------------------

a_max_comfort = 1.0;                    % Max acceleration (passenger comfort) [m/s^2]
alpha_max     = a_max_comfort / (rho * d / 2);  % Motor shaft acceleration     [rad/s^2]

fprintf('=== RATE LIMITER (speed reference) ===\n');
fprintf('  Max linear acceleration  : %.2f m/s^2\n', a_max_comfort);
fprintf('  Max angular acceleration : %.4f rad/s^2  → use as slew rate\n', alpha_max);
fprintf('=======================================\n\n');


%% ========================================================================
%  11.  SIMULINK VARIABLE SUMMARY
% =========================================================================

fprintf('=== WORKSPACE VARIABLES FOR SIMULINK ===\n');
fprintf('  Ks          = %.4f    Nm/A^2\n',  Ks);
fprintf('  En          = %.2f    V\n',        En);
fprintf('  La          = %.6f   H\n',        La);
fprintf('  Ra          = %.4f    Ohm\n',      Ra);
fprintf('  Le          = %.4f    H\n',        Le);
fprintf('  Re          = %.4f    Ohm\n',      Re);
fprintf('  J           = %.4f    kg·m^2\n',  J);
fprintf('  beta        = %.4f    Nms\n',      beta);
fprintf('  KpA         = %.6f\n',             KpA);
fprintf('  KiA         = %.4f\n',             KiA);
fprintf('  KpE         = %.4f\n',             KpE);
fprintf('  KiE         = %.4f\n',             KiE);
fprintf('  KpM         = %.4f\n',             KpM);
fprintf('  KiM         = %.6f\n',             KiM);
fprintf('  Kb_a        = %.4f\n',             Kb_a);
fprintf('  Kb_e        = %.4f\n',             Kb_e);
fprintf('  Kb_m        = %.8f\n',             Kb_m);
fprintf('  Te_max      = %.1f   Nm\n',        Te_max);
fprintf('  Ia_max      = %.1f   A\n',         Ia_max);
fprintf('  ome_base    = %.4f    rad/s\n',    ome_base);
fprintf('  ome_max     = %.4f    rad/s\n',    ome_max);
fprintf('  alpha_max   = %.4f    rad/s^2\n',  alpha_max);
fprintf('=========================================\n\n');

