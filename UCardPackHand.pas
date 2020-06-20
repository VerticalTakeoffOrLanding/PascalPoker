unit UCardPackHand;


{$IFDEF FPC}
{$MODE Delphi}
{$ENDIF}

interface

uses sysutils, math, Generics.Collections;

type
  TCard = class
  private
    Rank: 1 .. 13;
    Suit: 0 .. 3;
  public
    constructor Create(r: integer; s: integer);
    function GetRank: integer;
    function GetSuit: integer;
    function GetRankAsString: string;
    function GetSuitAsString: string;
  end;

  TCards = array [0 .. 51] of TCard;

  TPack = class
   //TPack creates and contains 52 TCards in the form of a circular queue
  private
    FCards: TCards;
    Ffront, Frear, FSize: integer;
    // FSize is number of cards currently in pack
  public
    constructor Create; // creates cards and fills array with them
    destructor Destroy; override; // frees cards
    procedure Shuffle; // rearranges cards randomly
    procedure Show;
    function DealCard: TCard; // removes top card and increments top pointer
    procedure AddCard(card: TCard);
    // adds card to bottom and increments bottom pointer
    function IsEmpty: boolean;
    function IsFull: boolean;
    property Top: integer read Ffront write Ffront; // points to top card
    property Bottom: integer read Frear write Frear; // points to bottom card
    property Size: integer read FSize write FSize;
    // number of cards currently in pack

  end;

  THand = class
    // THand is a collection of previously-created cards, typically contained
    // in TPack.Cards
    // THand does not create any TCards itself
  protected    //list of references to TCards
    FCards: TList<TCard>;
    function GetCard(i: integer): TCard;
    function GetSize: integer;

  public
    constructor Create;
    destructor Destroy; override;
    procedure AddCard(card: TCard);
    procedure ShowHand;
    property Size: integer read GetSize;
    property Cards[i: integer]: TCard read GetCard;
  end;

  TPokerHand = class(THand)
  protected
    RoF, bet,bank:integer;
  public
    procedure SetRof;
    function GetScore:integer;
    function GetBet:integer;
    procedure SetBet(plusBet:integer);
    function GetBank:integer;
    procedure SetBank(cash:integer);
    procedure Sort;
    function GetRoF:integer;
    procedure Fold;
  end;


implementation

{ TCard }

constructor TCard.Create(r: integer; s: integer);
begin
  Rank := r;
  Suit := s;
end;

function TCard.GetRank: integer;
begin
  result := Rank;
end;

function TCard.GetRankAsString: string;
begin
  case Rank of
    1:
      result := 'Ace';
    2:
      result := 'Two';
    3:
      result := 'Three';
    4:
      result := 'Four';
    5:
      result := 'Five';
    6:
      result := 'Six';
    7:
      result := 'Seven';
    8:
      result := 'Eight';
    9:
      result := 'Nine';
    10:
      result := 'Ten';
    11:
      result := 'Jack';
    12:
      result := 'Queen';
    13:
      result := 'King';
  end;
end;



function TCard.GetSuit: integer;
begin
  result := Suit;
end;

function TCard.GetSuitAsString: string;
begin
  case Suit of
    0:
      result := 'Clubs';
    1:
      result := 'Diamonds';
    2:
      result := 'Hearts';
    3:
      result := 'Spades';
  end;
end;

{ TPack
 }

procedure TPack.AddCard(card: TCard);
//the card is returned to the queue
//FCards[Bottom+1] is overwritten by this procedure
//so it relies on it being referenced elsewhere (usually in a THand object)
begin
  if not IsFull then
  begin
    if (Bottom = 51) then
      Bottom := 0
    else
      Bottom := Bottom + 1;
    FCards[Bottom] := card;
    Size := Size + 1;

  end;
end;

constructor TPack.Create;
var
  I: integer;
begin
  inherited Create;
  //writeln('erw]oinrw[ofnrgnrgfounrfonrfgoinrfiu');
  for I := 0 to 51 do
    FCards[I] := TCard.Create((I mod 13) + 1, I div 13);
  Top := 0;
  Bottom := 51;
  Size := 52;
  //writeln('yy coming up');
end;

destructor TPack.Destroy;
var
  I: integer;
begin
  for I := 0 to 51 do
    FCards[I].Free;
  inherited Destroy;
end;

function TPack.IsEmpty: boolean;
begin
  result := Size = 0;
end;

function TPack.IsFull: boolean;
begin
  result := Size = 52;
end;

procedure TPack.Shuffle;
var
  I, r: integer;
  temp: TCard;
begin
  for I := Top to Bottom do
  begin
    Randomize;
    r := randomrange(I, Bottom + 1);
    temp := FCards[I];
    FCards[I] := FCards[r];
    FCards[r] := temp;
  end;

end;

function TPack.DealCard: TCard;
//the card removed remains in the Cards array
//removal just involves incrementing the Top pointer to remove it from the queue
begin
  if not IsEmpty then // NB if empty, return value is undefined
  begin
    result := FCards[Top];
    if Top = 51 then
      Top := 0
    else
      Top := Top + 1;
    Size := Size - 1;
  end;
end;

{ THand }

procedure THand.AddCard(card: TCard);
//add card to hand, using Add method of TList<>
begin
  FCards.Add(card);
end;

procedure THand.ShowHand;
var
  i:integer;
begin
  for i := 0 to Size-1 do
  begin
    writeln('Card[',i+1,'] is the: ', Cards[i].GetRankAsString, ' of ', Cards[i].GetSuitAsString);
  end;
  writeln;
end;

function TPokerHand.GetScore:integer;
var
  score,i,count:integer;
  straight,triple,double,flush:boolean;
begin
  score:=0;
  flush:=false; //If they have a flush
  straight:=false; //If they have a straight
  triple:=false; //If they have three of a kind
  double:=false; //If they have two of a kind

  //Check for two of a kind
  for i := 0 to Size-2 do
  begin
    if Cards[i].GetRank = Cards[i+1].GetRank then
    begin
      score:=1;
      double:=true;
    end;
    if i <> 0 then
    begin
    if (Cards[i].GetRank = Cards[i+1].GetRank) AND (Cards[i].GetRank = Cards[i-1].GetRank) then
      begin
        //In case it is actually three of a kind
        score:=0;
        double:=false;
      end;
    end;
  end;

  //Check for two pairs
  count:=0;
  for i := 0 to Size-2 do
  begin
    if (Cards[i].GetRank = Cards[i+1].GetRank) then
    begin
      if i = 0 then
      begin
        count := count + 1;
      end
      else if Cards[i].GetRank <> Cards[i-1].GetRank then
      begin
        count:=count+1;
      end;
    end;
  end;
  if count >= 2 then
  begin
    score:=2;
  end;
  count:=0; //resets count

  //Check for three of a kind
  for i := 0 to Size-3 do
  begin
    if Cards[i].GetRank = Cards[i+1].GetRank then
    begin
      count:=count+1;
    end
    else
      count:=0;
    if count >= 2 then
    begin
      score:=3;
      triple:=true;
    end;
  end;

  //Find a straight
  count:=0;
  for i := 0 to Size-2 do
  begin
    if Cards[i].GetRank+1 = Cards[i+1].GetRank then
      count:=count+1
    else if Cards[i].GetRank = Cards[i+1].GetRank then
      count:=count
    else
      count:=0;
  end;
  if count >= 4 then
  begin
    score:=4;
    straight:=true;
  end;

  //Finding a flush
  count:=0;
  for i := 0 to Size-2 do
  begin
  if Cards[i].GetSuit = Cards[i+1].GetSuit then
    count:=count+1;
  end;
  if count >= 4 then
  begin
    score:=5;
    flush:=true;
  end;

  //Finding a full house
  if (double = true) AND (triple = true) then
  begin
    score:=6;
  end;

  //Finding four of a kind
  count:=0;
  for i := 0 to Size-2 do
  begin
    if Cards[i].GetRank=Cards[i+1].GetRank then
      count:=count+1
    else
      count:=0;
  end;
  if count = 3  then
  begin
    score := 7;
  end;

  //Finding a straight Flush
  if (flush) AND (straight) then
  begin
    score:=8;
  end;

  //Finding a royal flush
  if flush=true then
  begin
    //Couldn't get working
  end;

  writeln;
  case score of //Display what hand the player had
  1: writeln('Two of a kind');
  2: writeln('Two pair');
  3: writeln('Three of a kind');
  4: writeln('Straight');
  5: writeln('Flush');
  6: writeln('Full House');
  7: writeln('Four of a kind');
  8: writeln('Straight flush');
  9: writeln('Royal Flush');
  0: writeln('peepe');
  end;

  result:=score;
end;

constructor THand.Create;
begin
  inherited;
  FCards := TList<TCard>.Create; //create the list
  //writeln(':(');
end;

destructor THand.Destroy;
begin
  FCards.Free; //free the list
  inherited;
end;




function THand.GetSize: integer;
begin
  result := FCards.Count;
end;


function THand.GetCard(i: integer): TCard;
begin
  result := FCards[i];
end;

procedure TPack.Show;
var
  z:integer;
begin
  for z := 0 to 51 do
  begin
    writeln('Card ',z,' is the: ',FCards[z].Rank, ' of ', FCards[z].Suit);
  end;
end;

procedure TPokerHand.Sort;
var
  o,tempRank,tempSuit:integer;
  swapped:boolean;
begin
  repeat
    swapped:=false;
    for o := 0 to Size-2 do
    begin
      if Cards[o].Rank > Cards[o+1].Rank then
      begin
        //writeln('Swapping Cards');
        tempRank:= Cards[o].GetRank;
        tempSuit := Cards[o].GetSuit;
        //writeln('Temp card is set');
        Cards[o].Rank:=Cards[o+1].GetRank;
        Cards[o].Suit:=Cards[o+1].GetSuit;
        //writeln('First card is set');
        Cards[o+1].Rank:=tempRank;
        Cards[o+1].Suit:=tempSuit;
        //writeln('Second card is set');
        swapped:=true;
        //writeln('Cards Swapped');
      end;
    end;
  until swapped=false;
end;

procedure TPokerHand.SetRof;
begin
  RoF:=10;
end;

function TPokerHand.GetRoF:integer;
begin
result:=RoF;
end;

procedure TPokerHand.Fold;
begin
  RoF:=0;
  writeln('I Fold');
end;

function TPokerHand.GetBank:integer;
begin
  result:=bank;
end;

function TPokerHand.GetBet:integer;
begin
  result:=Bet;
end;

procedure TPokerHand.SetBet(plusBet: Integer);
begin
  bet:=bet+plusBet;
end;

procedure TPokerHand.SetBank(cash: Integer);
begin
  bank:=bank+cash;
end;
end.
