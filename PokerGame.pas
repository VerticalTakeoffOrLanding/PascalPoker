unit PokerGame;

{$IFDEF FPC}
{$MODE Delphi}
{$ENDIF}

interface

uses math, UCardPackHand;

type
  TPoker = class
  private
    stage,currentBet,totalBet,score,count:integer;
    P1,P2,P3:TPokerHand;
    FlopHand:THand;
    Pack:TPack;


  public
    constructor Create;
    destructor Destroy; override;
    function RaiseOrFold:integer;
    procedure Round(cards:integer;MiddleHand:THand);
    procedure Play;
    procedure P2Play;
    procedure P3Play;
  end;

implementation

constructor TPoker.Create;
var
  i: Integer;

procedure CreateGame;
begin
  writeln('Creating Game...');
  //======================= CREATION ===============================
  inherited Create;
  Pack:= TPack.Create;
  writeln('Tpack made');
  P1:= TPokerHand.Create;
  writeln('P1 made');
  P2:=TPokerHand.Create;
  writeln('P2 made');
  P3:=TPokerHand.Create;
  writeln('[3 made');
  FlopHand := THand.Create;
  //================================================================
  writeln('Parts Created');
  for i := 1 to 100 do
  begin
    Pack.Shuffle; //SHUFFLE
  end;

  for i := 1 to 2 do //Unuseful loop for DEALING CARDS
  begin
    P1.AddCard(Pack.DealCard);
    P2.AddCard(Pack.DealCard);
    P3.AddCard(Pack.DealCard);
  end;

  for i := 1 to 6 do //Useful loop for DEALING CENTRE HAND
  begin
    FlopHand.AddCard(Pack.DealCard);
  end;

  P1.SetBank(100);
  P2.SetBank(100);
  P3.SetBank(100);

  writeln('Game Created');
end;

function TPoker.RaiseOrFold:integer;
var
  choice, bet:integer;
begin

  P1.ShowHand;

  totalBet:=P1.Getbet+P2.Getbet+P3.Getbet;

  writeln('===Raise Or Fold==== ');
  writeln('¦ 1) Raise or Call ¦');
  writeln('¦ 2) Fold          ¦');
  writeln('====================');
  write('1/2: ');
  readln(choice);

  if choice = 1 then
  begin
    writeln('Your total bet so far is: ',P1.Getbet);
    writeln('The total bet so far is: ',totalBet);
    write('How much extra would you like to bet?: ');
    readln(currentBet);
    P1.Setbet(currentBet);
  end;
end;

procedure TPoker.Round(cards:integer;MiddleHand: THand);
var
  i: integer;
begin
  for i := 1 to MiddleHand.Size do
  begin
    writeln('Center Card [',i,'] is : ' + MiddleHand.Cards[i].GetRankAsString + ' of ' + MiddleHand.Cards[i].GetSuitAsString)
  end;
end;

procedure TPoker.P2Play;
var
  RaiseOr, howMuch:integer;
begin
  if P2.GetRoF > 0 then
  begin
    if randomrange(0,10) <= 0 then
      P2.Fold;
    P2.Setbet(currentBet+randomrange(0,20));
  end;
end;

procedure TPoker.P3Play;
begin
  if P3.GetRoF > 0 then
  begin
    if randomrange(0,10) <= 0 then
      P3.Fold;
    P2.Setbet(currentBet+randomrange(0,20));
  end;
end;

destructor TPoker.Destroy;
begin
  writeln('destroyed');
end;

procedure TPoker.Play;
begin
P1.SetBet(P1.GetBet*-1);
P2.SetBet(P2.GetBet*-1);
P3.SetBet(P3.GetBet*-1);;
currentBet:=0;
totalBet:=0;

//Just your hand
RaiseOrFold;
P2Play;
P3Play;

//Next 3 cards
Round(3,FlopHand);
RaiseOrFold;

//Next Card
Round(4,FlopHand);
RaiseOrFold;

//Next Card and final bet
Round(5,FlopHand);
RaiseOrFold;

if (P1.GetScore > P2.GetScore) AND (P1.GetScore > P3.GetScore) then
begin
  if P1.GetRoF > 0 then
  begin
    writeln('You Win!');
    P1.SetBank(totalBet);
    P2.SetBank(P2.GetBet*-1);
    P3.SetBank(P3.GetBet*-1);
  end;
end;
if (P2.GetScore > P1.GetScore) AND (P2.GetScore > P3.GetScore) then
begin
  if P2.GetRoF > 0 then
  begin
    writeln('P2 Won');
    P2.SetBank(totalBet);
    P1.SetBank(P1.GetBet*-1);
    P3.SetBank(P3.GetBet*-1);
  end;
end;
if (P3.GetScore > P2.GetScore) AND (P3.GetScore > P1.GetScore) then
begin
  if P1.GetRoF > 0 then
  begin
    writeln('P3 Won');
    P3.SetBank(totalBet);
    P1.SetBank(P1.GetBet*-1);
    P2.SetBank(P2.GetBet*-1);
  end;
end;

end;

end.
