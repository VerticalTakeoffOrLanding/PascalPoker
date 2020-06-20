program Poker;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, math,
  UCardPackHand in 'UCardPackHand.pas';

var
  stage,currentBet,totalBet,score,count,i,P3Score,P2Score,P1Score:integer;
  P1,P2,P3:TPokerHand; //TPokerHand has the GetScore method and Bank/Bet properties
  FlopHand,FlopHand2,FlopHand3:THand;
  Pack:TPack;
  playing:string;

procedure CreateGame;
begin
  Randomize; //Used for random actions of Dud AI
  //======================= CREATION ===============================
  Pack := TPack.Create;  // Deck
  P1:=TPokerHand.Create; // Player
  P2:=TPokerHand.Create; // Dud AI
  P3:=TPokerHand.Create; // Dud AI

  FlopHand := THand.Create; //Centre cards to be revealed
  FlopHand2:=FlopHand;  //Centre cards copy
  FlopHand3:=FlopHand;  //Centre cards copy
  //================================================================
  for i := 1 to 100 do //Shuffle 100 times
  begin
    Pack.Shuffle;
  end;

  for i := 1 to 2 do //Deal 2 cards to each player from the pack
  begin
    P1.AddCard(Pack.DealCard);
    P2.AddCard(Pack.DealCard);
    P3.AddCard(Pack.DealCard);
  end;

  for i := 1 to 6 do //Deals 5 cards from the pack to the centre hand
  begin
    FlopHand.AddCard(Pack.DealCard);
  end;

  P1.SetBank(100); //Each player has a balance of 100
  P2.SetBank(100); //but this limit can be exceeded
  P3.SetBank(100);

end;

function RaiseOrFold:integer;
var
  choice, bet:integer;
begin
  P1.ShowHand; //Show the player their hand so they can decide if they want to bet or fold.

  totalBet:=P1.Getbet+P2.Getbet+P3.Getbet; //This is the value of the pot (How much you will gain if you win)

  writeln('===Raise Or Fold==== ');
  writeln('¦ 1) Raise         ¦');
  writeln('¦ 2) Fold          ¦');
  writeln('====================');
  write('1/2: ');
  readln(choice);

  if choice = 1 then
  begin
    writeln;
    writeln('Your current balance is: ',P1.GetBank); //Bank is a players score, carries across hand
    writeln('Your total bet so far is: ',P1.Getbet); //The total possible loss currently
    writeln('The total bet so far is: ',totalBet);   //The total winning available
    write('How much extra would you like to bet?: ');
    readln(currentBet);
    writeln;
    P1.Setbet(currentBet);
  end;
end;

procedure Round(cards:integer;MiddleHand: THand);
var
  i: integer;
begin
  for i := 1 to cards do //Display a set number of the centre cards, increasing after every round of bets
  begin
    writeln('Center Card [',i,'] is : ' + MiddleHand.Cards[i].GetRankAsString + ' of ' + MiddleHand.Cards[i].GetSuitAsString)
  end;
end;

procedure P2Play;
var
  RaiseOr, howMuch:integer;
begin
  if P2.GetRoF > 0 then //Check if they have already folded
  begin
    if randomrange(0,10) = 0 then //1 out of 10 chance to randomly fold
      P2.Fold
    else
      P2.Setbet(currentBet+randomrange(0,20)); //If they don't fold, randomly bet an amount between 0 and 20
  end;
end;

procedure P3Play; // Identical to P2Play but for P3
begin
  if P3.GetRoF > 0 then
  begin
    if randomrange(0,10) <= 0 then
      P3.Fold;
    P2.Setbet(currentBet+randomrange(0,20));
  end;
end;

procedure Play;
begin
P1.SetRof; //Make sure no players have 'folded' already
P2.SetRof;
P3.SetRof;

P1.SetBet(P1.GetBet*-1); //Set each players bet to zero
P2.SetBet(P2.GetBet*-1);
P3.SetBet(P3.GetBet*-1);

currentBet:=0; //currentBet is similar to P1.Bet but is local
totalBet:=0; //the total available winnings

//First betting round with only your hand visible
RaiseOrFold;
P2Play;
P3Play;

//Second betting round with your hand and three centre cards visible
Round(3,FlopHand);
RaiseOrFold;
P2Play;
P3Play;

//Third betting round with your hand and four centre cards visible
Round(4,FlopHand);
RaiseOrFold;
P2Play;
P3Play;

//Fourth betting round with your hand and all five centre cards visible
Round(5,FlopHand);
RaiseOrFold;
P2Play;
P3Play;

//Combines each players hand with a respective instance of the centre hand
for i := 0 to 4 do
begin
  P1.AddCard(FlopHand.Cards[i]);
  P2.AddCard(FlopHand2.Cards[i]);
  P3.AddCard(FlopHand3.Cards[i]);
end;

//Sorts each hands cards in order of lowest rank to highest
P1.Sort;
P2.Sort;
P3.Sort;

//Shows each players hand
writeln('Your Hand');
P1.ShowHand;
writeln('Player 2s Hand');;
P2.ShowHand;
writeln('Player 3s card');
P3.ShowHand;
writeln;

//Gets the score for each hand
P1Score:=P1.GetScore;
P2Score:=P2.GetScore;
P3Score:=P3.GetScore;

//If a player has folded then their score becomes -1
if P1.GetRoF < 0 then
  P1Score:=-1;
if P2.GetRoF < 0 then
  P2Score:=-1;
if P3.GetRoF < 0 then
  P3Score:=-1;

writeln('P1Score is: ',P1Score,' P2Score is: ',P2Score,' P3Score is: ',P3Score);//Displays each players score

if (P1Score > P2Score) AND (P1Score > P3Score) then //If player 1 wins
begin
  writeln('You Win!');
  P1.SetBank(totalBet); //add the total winningsd to the players bank
  P2.SetBank(P2.GetBet*-1); //subtract the opposing players bets from their banks
  P3.SetBank(P3.GetBet*-1);
end
else if (P2Score > P1Score) AND (P2Score > P3Score) then //If player 2 wins
begin
  writeln('P2 Won');
  P2.SetBank(totalBet);
  P1.SetBank(P1.GetBet*-1);
  P3.SetBank(P3.GetBet*-1);
end
else if (P3Score > P2Score) AND (P3Score > P1Score) then //If player 3 wins
begin
    writeln('P3 Won');
    P3.SetBank(totalBet);
    P1.SetBank(P1.GetBet*-1);
    P2.SetBank(P2.GetBet*-1);
end
else if (P1Score < P2Score) AND (P1Score<P3Score) then //If player 1 has a lower score than P1 and P2 it  assumes P3 won
begin
    writeln('You Lose');
    P3.SetBank(totalBet);
    P1.SetBank(P1.GetBet*-1);
    P2.SetBank(P2.GetBet*-1);
end
else if (P1Score = P2Score) AND (P1Score=P3Score) then //If no one wins
begin
  writeln('A Draw');
end;
end;


//==========MAIN=========
begin
playing:='Y'; //loop condition
CreateGame;
while playing='Y' do //play hands until the player wants to stop
begin
  Play;
  writeln('Your balance is now: ',P1.GetBank); //Tells player their new balance
  writeln('Would you like to play again?(Y/N): '); //Asks if they want to play again
  readln(playing);
end;
pack.Destroy; //Frees everything
P1.Destroy;
P2.Destroy;
P3.Destroy;
flopHand.Destroy;
flopHand2.Destroy;
flopHand3.Destroy;
end.







