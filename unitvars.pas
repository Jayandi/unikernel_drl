unit unitVars;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

const
  action_space : array [1..7] of double = (-0.03, -0.02, -0.01, 0.0, 0.01, 0.02, 0.03);
  max_mini_batch : integer = 32;

type
  TState = record
    vpv,
    ipv,
    ddcycle,
    dcycle : double;
    dcnosat : boolean;
  end;

  TExperience = record
    State: TState;
    Action: Double;
    Reward: Double;
    NextState: TState;
    Terminated: Boolean;
  end;



implementation

end.

