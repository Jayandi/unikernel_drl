{*==============================
Main Program for Training DRL by DQN
by JP

===================================*}

program DQNController;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, CustApp, UnitNetworks, unitVars, unitDCDC, unitPVArray,
  { you can add units after this }
  Noe, Noe.NeuralNet, Noe.Optimizer, Numerik, Multiarray;

type

  { DQNMPPTController }

  DQNMPPTController = class(TCustomApplication)
  protected
    procedure DoRun; override;
    procedure Train;
    procedure Test;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ DQNMPPTController }

procedure DQNMPPTController.DoRun;
var
  ErrorMsg: String;
begin
  //
  WriteLn('Starting');

  // quick check parameters
  ErrorMsg:=CheckOptions('h', 'help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h', 'help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  { add your program here }

  Train;
  Test;

  // stop program loop
  WriteLn('Stop!');
  Terminate;
end;

//--------------------------------------------------

procedure DQNMPPTController.Train;
const
  max_episodes: integer = 10;
var
  QCritic, QTarget: TDQN;
  done: boolean;
  i, n : integer;
  Env : TDCDC;
  State, NextState : TState;
  QState, QNextState : TTensor;
  action: double;
  epsilon_init,
  epsilon,
  epsilon_step   : double; //training exploration to exploitation

  episode_reward : double;

  actrandom : double;

  QInput,
  QresultCritic, QResultTarget : TTensor;

  Experience : TExperience;

  episode_terminate : boolean;

  BatchExperience : array[1..32] of TExperience;

  ExpNum : integer; expok : boolean;
  BatchNum : integer;

begin
  Randomize;
  ExpNum := 1;
  ExpOk := False;

  // make the critic network
  QCritic := TDQN.Create(4,1,100);
  QTarget := TDQN.Create(4,1,100);
  Env := TDCDC.Create;

  //hyperparameter
  epsilon_init := 0.5;
  epsilon_step := 0.01;
  epsilon := epsilon_init;

  //===================================
  for n := 1 to max_episodes do
  begin
    Env.Reset();
    QState := CreateMultiArray([Env.vout, Env.iout, Env.dutycycle,
                                Env.deltadutycycle]).Reshape([1,4]);

    episode_reward := 0.0;
    epsilon := 0.01;
    action := 0.1;

    episode_terminate := false;

    while not episode_terminate do
    begin
      actrandom := random(100)/100;

      if actrandom<epsilon then
      begin
        actrandom := random(100)/10;
        while actrandom>7 do
          actrandom := random(100)/10;
         action := action_space[round(actrandom)];
      end
      else
         action := argmax(QCritic.NNforward(QState)).item;

      BatchExperience[expnum].state := Env.State;

      Env.step(action);

      episode_reward := episode_reward + Env.reward;

      QState := CreateMultiArray([Env.vout, Env.iout, Env.dutycycle,
                                Env.deltadutycycle]).Reshape([1,4]);

      episode_terminate := terminated;

      BatchExperience[expnum].nextstate := Env.State;
      BatchExperience[expnum].Reward:= Env.reward;
      BatchExperience[expnum].action := Env.action;
      BatchExperience[expnum].Terminated := Env.Terminated;

      inc(expnum); if expnum>32 then begin expnum := 1; expok:= true; end;

      if ExpOk then
      begin
        batchnum := random(32);
        Experience := BatchExperience[batchnum];




      end;




      //QInput := CreateMultiArray([1.0, 2.0, 2.0, 1.0]).Reshape([1,4]);
      //
      //
      //QResultCritic := QCritic.NNForward(QInput);
      //QResultTarget := QTarget.NNforward(QInput);
      //
      //QCritic.Target := QResultTarget;
      //QTarget.Target := QResultCritic;
      //
      //PrintTensor(QResultCritic);
      //PrintTensor(QResultTarget);
      //
      //QCritic.calcbackward();
      //QTarget.calcbackward();
    end;

   end;
  // make critic network: Q


end;


procedure DQNMPPTController.Test;
begin
  //
end;

//=======================================================

constructor DQNMPPTController.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor DQNMPPTController.Destroy;
begin
  inherited Destroy;
end;

procedure DQNMPPTController.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ', ExeName, ' -h');
end;

var
  Application: DQNMPPTController;
begin
  Application:=DQNMPPTController.Create(nil);
  Application.Title:='DQNMPPTController';
  Application.Run;
  Application.Free;
end.

