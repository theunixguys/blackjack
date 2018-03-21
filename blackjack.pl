#!/usr/bin/perl -w
#
# blackjack program
# March 2009
#
#
# still left to do:
#
# implement splitting pairs
# you can cheat on double down, oops
#
##############################

$|=1;

use strict;

# cash tracking
my $money;
my $bet;

# hands etc
my @dealer_hand;
my $dealer_count;
my $dealer_Acount;

my @player_hand;
my $player_count;
my $player_Acount;

my $value;
my $card;
my $Acount;

# play control
my $player_done;
my $player_bust;
my $dealer_bust;
my $skip_play;
my $dealerturn;
my $dealer_blackjack;
my $player_blackjack;
my $insurance;
my $insurance_ans;
my $action;


# cards
my $decksize;
my @deck;



########## BEGIN MAIN ##########

shuffle();
get_prefs();

while (1) {
   $dealerturn = 0;
   $decksize = @deck;
   if ($decksize < 15) {
	shuffle( \@deck );
   }
   take_bets();
   deal();
   first_checks();
   play();
   payout();
}

########## END MAIN ##########


sub get_prefs {

   if ( -f "stats") {
	$money = `cat stats`;
	chomp $money;
   }

   unless ($money =~ m/^\d+$/) {
	$money = 1000;
   }

}

sub shuffle {
   @deck = qw(
	2S 3S 4S 5S 6S 7S 8S 9S 10S JS QS KS AS
	2H 3H 4H 5H 6H 7H 8H 9H 10H JH QH KH AH
	2D 3D 4D 5D 6D 7D 8D 9D 10D JD QD KD AD
	2C 3C 4C 5C 6C 7C 8C 9C 10C JC QC KC AC
	2S 3S 4S 5S 6S 7S 8S 9S 10S JS QS KS AS
	2H 3H 4H 5H 6H 7H 8H 9H 10H JH QH KH AH
	2D 3D 4D 5D 6D 7D 8D 9D 10D JD QD KD AD
	2C 3C 4C 5C 6C 7C 8C 9C 10C JC QC KC AC
	2S 3S 4S 5S 6S 7S 8S 9S 10S JS QS KS AS
	2H 3H 4H 5H 6H 7H 8H 9H 10H JH QH KH AH
	2D 3D 4D 5D 6D 7D 8D 9D 10D JD QD KD AD
	2C 3C 4C 5C 6C 7C 8C 9C 10C JC QC KC AC
	2S 3S 4S 5S 6S 7S 8S 9S 10S JS QS KS AS
	2H 3H 4H 5H 6H 7H 8H 9H 10H JH QH KH AH
	2D 3D 4D 5D 6D 7D 8D 9D 10D JD QD KD AD
	2C 3C 4C 5C 6C 7C 8C 9C 10C JC QC KC AC
	2S 3S 4S 5S 6S 7S 8S 9S 10S JS QS KS AS
	2H 3H 4H 5H 6H 7H 8H 9H 10H JH QH KH AH
	2D 3D 4D 5D 6D 7D 8D 9D 10D JD QD KD AD
	2C 3C 4C 5C 6C 7C 8C 9C 10C JC QC KC AC
   );
   system("clear");
   print "shuffling";
   my $array = \@deck;
   my $i;
   for ($i = @$array; --$i; ) {
        my $j = int rand ($i+1);
        next if $i == $j;
        @$array[$i,$j] = @$array[$j,$i];
        print "..";
   }
   sleep 1;
}

sub take_bets {

   $player_done = 0;
   $player_bust = 0;
   $dealer_bust = 0;

   system("clear");
   if ($money == 0) {
	print "\n\nyou are broke, get out\n\n\n";
	exit 1;
   }
   print "[CASH]: $money\n";
   print "\n\nhow much are you betting?  ";
   $bet = <STDIN>;
   chomp $bet;
   unless ($bet) { $bet = 100; }
   unless ($bet =~ m/^\d+$/) {
	print "\n\nhey dummy, you speak English?\n";
	print "here, lemme take one of those shiny dollar chips\n";
	$bet = 1;
	sleep 2;
   }
   if ($bet > $money) {
	$bet = $money;
	print "\n\nnice try funny guy, do I look like a bank?\n";
	print "your bet is $bet\n";
	sleep 2;
   }
}

sub deal {
   undef @dealer_hand;
   undef @player_hand;
   push @player_hand, (pop @deck);
   push @dealer_hand, (pop @deck);
   push @player_hand, (pop @deck);
   push @dealer_hand, (pop @deck);

### debug
#   undef @dealer_hand;
#   undef @player_hand;
#   push @player_hand, "AS";
#   push @dealer_hand, "JS";
#   push @player_hand, "JS";
#   push @dealer_hand, "AS";
}

sub print_hands {
   system("clear");
   print "[CASH]: $money\n";
   print "[BET]: $bet\n";
   print "\n\n--------------------------------\n";
   if ($dealerturn) {
	print "DEALER:   ", join("  ", @dealer_hand), "  ($dealer_count)\n";
   }
   else {
	print "DEALER:   $dealer_hand[0]  XX\n";
   }
   print "PLAYER:   ", join("  ", @player_hand), "  ($player_count)\n";
   print "--------------------------------\n";
}

sub play {
   if ($skip_play) { return; }
   until ($player_done) {
	playerturn();
   }
   unless ($player_bust) {
	dealerturn();
   }
}

sub zero {
   $dealer_blackjack = 0;
   $player_blackjack = 0;
   $player_done = 0;
   $insurance = 0;
   $skip_play = 0;
}

sub first_checks {


   zero();
   calc();
   print_hands();

   if ($dealer_hand[0] =~ /A/) { $insurance = 1; }

   if ( (! $insurance) && ($dealer_count == 21) && ( $player_count !=21 ) ) {
	   print "\ndealer blackjack, you LOSE\n";
	   sleep 2;
	   $dealer_blackjack = 1;
	   $skip_play = 1;
	   return;
   }
   elsif ( (! $insurance) && ($dealer_count == 21) && ( $player_count ==21 ) ) {
	   print "\ndealer blackjack,\n";
	   print "TIE\n";
	   sleep 2;
	   $skip_play = 1;
	   return;
   }
   else {
   }


   if ( ($player_count == 21) && (! $insurance ) ) {
	#print "DEBUG: player BJ no insurance\n";
	print "\n\nWINNER WINNER CHICKEN DINNER!\n\n";
	sleep 2;
	$player_blackjack = 1;
	$player_done = 1;
	$skip_play = 1;
	return;
   }

   if ( ($player_count == 21) && ( $insurance ) ) {
	#print "DEBUG: player BJ insurance\n";
	print "\n\nYou have blackjack, but dealer\n";
	print "is showing an Ace, Insurance? ";
	$insurance_ans = <STDIN>;
	chomp $insurance_ans;
	if (($dealer_count == 21) && ($insurance_ans =~ m/y/i)) {
	   $money += $bet;
	   print "\ndealer blackjack,\n";
	   print "TIE\n";
	   sleep 2;
	   $skip_play = 1;
	   return;
	}
	elsif (($dealer_count == 21) && ($insurance_ans =~ m/n/i)) {
	   print "\ndealer blackjack,\n";
	   print "TIE\n";
	   sleep 2;
	   $skip_play = 1;
	   return;
	}
	elsif (($dealer_count != 21) && ($insurance_ans =~ m/y/i)) {
	   $money -= ($bet / 2);
	   print "\nNO dealer blackjack\n";
	   print "\n\nWINNER WINNER CHICKEN DINNER!\n\n";
	   sleep 2;
	   $player_blackjack = 1;
	   $player_done = 1;
	   $skip_play = 1;
	   return;
	}
	elsif (($dealer_count != 21) && ($insurance_ans =~ m/n/i)) {
	   print "\nNO dealer blackjack\n";
	   print "\n\nWINNER WINNER CHICKEN DINNER!\n\n";
	   sleep 2;
	   $player_blackjack = 1;
	   $player_done = 1;
	   $skip_play = 1;
	   return;
	}
	else {
	}
   }


   if ($insurance) {
	#print "DEBUG: normal insurance\n";

	print "\n\nDealer is showing an Ace, Insurance? ";
	$insurance_ans = <STDIN>;
	chomp $insurance_ans;
	unless ( $insurance_ans =~ m/y|n/i ) {
	   print "no English, no Insurance\n";
	   $insurance_ans = "n";
	}

	if (($dealer_count == 21) && ($insurance_ans =~ m/y/i)) {
	   $money += $bet;
	   print "\ndealer blackjack, you LOSE\n";
	   sleep 2;
	   $dealer_blackjack = 1;
	   $skip_play = 1;
	   return;
	}
	elsif (($dealer_count == 21) && ($insurance_ans =~ m/n/i)) {
	   print "\ndealer blackjack, you LOSE\n";
	   sleep 2;
	   $dealer_blackjack = 1;
	   $skip_play = 1;
	   return;
	}
	elsif (($dealer_count != 21) && ($insurance_ans =~ m/y/i)) {
	   $money -= ($bet / 2);
	   print "\nNO dealer blackjack\n";
	   sleep 2;
	}
	elsif (($dealer_count != 21) && ($insurance_ans =~ m/n/i)) {
	   print "\nNO dealer blackjack\n";
	   sleep 2;
	}
	else {
	}
   }

   if ( ($player_count == 21) && ($dealer_count == 21) ) {
	#print "DEBUG: both BJ\n";
	$player_done = 1;
	$skip_play = 1;
   }

}

sub payout {
   if ($player_bust) {
	print "\n\nyou LOST $bet dollars\n";
	sleep 2;
	$money -= $bet;
   }
   elsif ($player_blackjack) {
	$bet *= 1.5;
	print "\n\nyou WON $bet dollars\n";
	sleep 2;
	$money += $bet;
   }
   elsif ($dealer_bust) {
	print "\n\nyou WON $bet dollars\n";
	sleep 2;
	$money += $bet;
   }
   else {
	if ($player_count > $dealer_count) {
	   print "\n\nyou WON $bet dollars\n";
	sleep 2;
	   $money += $bet;
	}
	elsif ($dealer_count > $player_count) {
	   print "\n\nyou LOST $bet dollars\n";
	sleep 2;
	   $money -= $bet;
	}
	elsif ($dealer_count == $player_count) {
	   print "\n\nTIE\n";
	sleep 2;
	}
	else {
	   print "\n\nscore error!!\n\n";
	sleep 5;
	}
   }

   open STATS, ">stats";
   print STATS "$money\n";
   close STATS;

}


sub playerturn {
   calc();
   print_hands();
   print "\n\nhit, stand, double-down [h,s,d]: ";
   $action = <STDIN>;
   chomp $action;
   if ($action =~ m/^s$/) {
	$player_done = 1;
	print "player STANDS on $player_count\n";
	sleep 2;
   }
   elsif ($action =~ m/^h$/) {
	push @player_hand, (pop @deck);
	calc();
	print_hands();
   }
   elsif ($action =~ m/^d$/) {
	$bet *= 2;
	push @player_hand, (pop @deck);
	$player_done = 1;
	calc();
	print_hands();
   }
   else {
	print "huh?\n";
	return;
   }
   calc();
   print_hands();
   if ($player_count > 21) {
	$player_bust = 1;
	print "player BUSTS\n";
	sleep 2;
	$player_done = 1;
   }
}

sub dealerturn {

   $dealerturn = 1;
   calc();
   if ( ($dealer_count > 16) && ($dealer_count <= 21) ) {
	print_hands();
	print "\n\ndealer stands on $dealer_count\n";
	sleep 1;
	return;
   }
   until ($dealer_count > 16) {
	print_hands();
	print "\n\ndealer has $dealer_count, hitting\n";
	push @dealer_hand, (pop @deck);
	sleep 1;
	calc();
	print_hands();
	if ($dealer_count > 21) {
	   print "\n\ndealer has $dealer_count, BUST\n";
	   $dealer_bust = 1;
	   sleep 1;
	   return;
	}
	if ( ($dealer_count > 16) && ($dealer_count <= 21) ) {
	   print "\n\ndealer stands on $dealer_count\n";
	   sleep 1;
	   return;
	}
   }

}

sub calc {
   $player_count = 0;
   $player_Acount = 0;
   $dealer_count = 0;
   $dealer_Acount = 0;


   foreach $card (@player_hand) {
	$card =~ m/(\w+)\w/;
	$value = $1;
	if ($value =~ m/J|Q|K/) { $player_count += 10; }
	elsif ($value =~ m/A/) { $player_Acount++; }
	else { $player_count += $value; }
   }
   foreach $card (@dealer_hand) {
	$card =~ m/(\w+)\w/;
	$value = $1;
	if ($value =~ m/J|Q|K/) { $dealer_count += 10; }
	elsif ($value =~ m/A/) { $dealer_Acount++; }
	else { $dealer_count += $value; }
   }

   # now handle aces
   if ($player_Acount) {
	$Acount = 1;
	while ($Acount <= $player_Acount) {
	   if ( (($player_count + 11) <= 21) && ($player_Acount > 1) ) {
		if ( ($player_count + 10 + ($player_Acount*1)) <= 21 ) {
		   $player_count += 11;
		}
		else {
		   $player_count += 1;
		}
	   }
	   elsif ( ($player_count + 11) <= 21 ) {
		$player_count += 11;
	   }
	   else {
		$player_count += 1;
	   }
	   $Acount++
	}
   }
   if ($dealer_Acount) {
	$Acount = 1;
	while ($Acount <= $dealer_Acount) {
	   if ( (($dealer_count + 11) <= 21) && ($dealer_Acount > 1) ) {
		if ( ($dealer_count + 10 + ($dealer_Acount*1)) <= 21 ) {
		   $dealer_count += 11;
		}
		else {
		   $dealer_count += 1;
		}
	   }
	   elsif ( ($dealer_count + 11) <= 21 ) {
		$dealer_count += 11;
	   }
	   else {
		$dealer_count += 1;
	   }
	   $Acount++
	}
   }

}
