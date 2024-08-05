{*=================================

The environment
reset() reset everything in the env
step(action) send a step in environment (it's a deltadutycycle

state: vpv, ipv, deltadc, dc, dnosat

ver 0.0: simple vout calc

=======================*}
unit unitDCDC;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, unitVars;

type

  TDCDC = class(TObject)
    protected
      pin, pout : double;
      const pmpp: double = 1000.0;
      procedure calcreward;
      procedure calcvout;
    public
      deltadutycycle, dutycycle: double;
      state : TState;
      vin, vout, action, iin, iout, reward : double;
      terminated, trunc: boolean;
      dutycyclenosat: boolean;
      constructor create;
      procedure reset;
      procedure step(anaction: double);
      destructor free;
  end;


implementation

constructor TDCDC.create; //in: Vin, Iin, Freq
begin
  vin := 0.0;
  iin := 0.0;
  pin := vin*iin;
  pout := vout*iout;
  vout := 1.0;
  iout := 0.0;
  reward := 0.0;
  terminated := false;
  trunc := false;
  deltadutycycle := 0.0;
  dutycycle := 0.0;
  dutycyclenosat := true;
end;

procedure TDCDC.reset;
begin
  vin := 1.0;
  iin := 0.0;
  pin := vin*iin;
  pout := vout*iout;
  vout := 0.0;
  iout := 0.0;
  reward := 0.0;
  terminated := false;
  trunc := false;
  deltadutycycle := 0.01;
  dutycycle := 0.0;
  dutycyclenosat := true;
end;

procedure TDCDC.calcvout; //in: Vin, DCycle, out: Vout
begin
  //  Vout = Vin/(1-D)
  deltadutycycle := action;
  dutycycle := dutycycle+deltadutycycle;
  if dutycycle >= 1.0 then
  begin
    dutycyclenosat := false;
    dutycycle := 1.0;
  end
  else
    dutycyclenosat := true;
  if dutycycle>=1.0 then
     dutycycle := 0.99;
  vout := vin/(1 - dutycycle);
  iout := vin*iin/vout;
  pin := vin*iin;
  pout := vout*iout;
end;

procedure TDCDC.step(anaction: double);
begin
  action := anaction;
  calcvout;
  calcreward;
  with state do
  begin
    vpv := vin;
    ipv := iin;
    ddcycle := deltadutycycle;
    dcycle := dutycycle;
    dcnosat := dutycyclenosat;
  end;
  //
end;
procedure TDCDC.calcreward;
begin
  reward := pout/pmpp;
  if reward >= 1.0 then
    terminated := true;
end;

destructor TDCDC.free;
begin
  Free;
end;


end.

