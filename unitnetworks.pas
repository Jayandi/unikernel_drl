{*=================
  The Agent : DQN
======================*}

unit UnitNetworks;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Noe, Noe.neuralnet, Noe.Optimizer,
  Numerik, Multiarray, unitVars;

type

TDQN = class(Tobject)
      protected
      public
        model : TNNModel;
        state_dim, action_dim, hidden_dim: integer;
        opt : TOptAdam;
        Input, Output, Target : TTensor;
        Loss : TTensor;
        constructor create(sdimm, adimm, hdimm:integer);
        function NNforward(aInput: TTensor): TTensor;
        function calcloss(): TTensor;
        procedure calcbackward();
        destructor free;
      end;

implementation

constructor TDQN.create(sdimm, adimm, hdimm:integer);
begin
  state_dim := sdimm; action_dim := adimm; hidden_dim:= hdimm;

  model := TNNModel.Create;
  model.AddLayer(TLayerDense.Create(state_dim,hidden_dim));
  model.AddLayer(TLayerRelu.Create());
  model.AddLayer(TLayerDense.Create(hidden_dim,action_dim));
  model.AddLayer(TLayerSoftmax.Create(action_dim));

  opt := TOptAdam.Create(model.Params);
  opt.LearningRate := 0.01;


end;

function TDQN.NNforward(aInput: TTensor): TTensor;
begin
  output := model.Eval(aInput);
  result := output;
end;

function TDQN.calcloss(): TTensor;
begin
  WriteLn('Output');
  printtensor(output);
  WriteLn('Target');
  printtensor(target);
  WriteLn('Calc Loss');
  result := CrossEntropy(Output, Target);
  printtensor(result);
end;

procedure TDQN.calcbackward;
begin
  Loss := calcloss();
  Loss.Backward();
  opt.step;

end;

destructor TDQN.free;
begin
  model.free;
  opt.free;
end;

end.

