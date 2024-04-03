# Make Project

Trisha Razdan (trazdan1@swarthmore.edu), Erebus Oh (eoh2@swarthmore.edu)

Collaboration statement: We worked together to complete the Make of NYT Connections.

12/4/23

CS 91S: Game Systems


**DUE Dec 18th at 11:59 PM**


We decided to port our demake to TIC-80 due to the fact that we both really enjoyed the NYT game Connections, and felt that the NES development environment limited what we could do in terms of a demake. While we were still able to capture the gist of the game and preserved almost all aspects of gameplay, we knew we could (de)make a better game on the TIC-80. Some of the things we struggled to incorporate on the NES demake were graphics, randomization, and the static size of sprites. We won't go too in depth to our NES struggles as we detailed them further in the README for the demake, however to sum our challenges:

- Graphics with so many tiles, words, and icons to designate correct answers were reallt difficult to manage with only name tables and sprites.
- We had trouble creating a randomization method as the seed we gave our random function would not work thus the same value(s) would get chosen for the groups
- The size of sprites is not able to be edited so we could only work with groups comprised of words with at most a length of 4 letters. This limited the difficultly of our game.

Thankfully, using TIC-80, we were able to address ALL these issues and even add a little more to our demake. For starters, we added a welcome screen that players are initially greeted with, and can press a key to move onto the actual game. Next, we also added the ability to play multiple rounds, once a player finds all correct groups, they are able to hit a key to reshuffle the board and play again with new groups. Additionally, since the TIC-80 development environment is overall more "friendly" than NES, our graphics look cleaner, and we were even able to change the entire color of a solved tile to correspond with its group. We also had a mechanism to select tiles and selected tiles' color were entirely changed to a dark grey as well. Since text can be small or large font, the 4 letter limit was not longer imposed, thus allowing us to expand the groups we had in our stockpile. Finally, Lua was far kinder for randomization so we were able to randomly select 4 groups rather than hard coding them in. 

As with the guidelines of the project, we also implemented some of the design patterns we learned throughout the semester: State, Dirty Flag, and Game Loop. First, State is what allowed us to easily transition between Welcome (the opening screen), Game (where players play Connections), and GameOver (when players have solved all groups). The use of states made it easier to implement a welcome screen as well as a restart feature to play the game again. Next, using a variation of Dirty Flag, we were able to keep track of whether tiles on the board were selected or solved, which then triggered either a color change to dark grey (selected) or to their group color (solved). We left these as attributes of the tile class, which made it convenient to update the tiles on gameplay. Finally, we used Game Loop less purposefully, but as we learned all games will have some sort of game loop. We process input real time but the game is not waiting on player input to run any aspect of the game. We use variable time steps since we leave it up to the player as to when they will provide input.

Overall, we found the porting process to be very enjoyable and very much enjoyed recreating Connections on the TIC-80!


You will develop your own 8-bit game for the final project. You can
use TIC-80, NES, or the VCS. You can work alone or with a partner. You
can create an original game, or mash-up existing games, but your game
should be more than simply a remake; be creative!

One of the key outcomes of this assignment is to reflect on the design
of the game from a software point of view. Use some of the game
programming patterns we covered in class. 

## Alternative Options

- improve upon your REMAKE;
- improve upon your DEMAKE;
- port your DEMAKE to TIC-80.


## Learning Objectives

- develop a novel video game;
- more practice with Lua (C or 6502-ASM);
- employ programming patterns;
- think and write critically about games.

## Deliverable

Submit your make study on GitHub (as a markdown document),
specifically reflecting on the design of your game and which patterns
you employed (or tried to employ). Your TIC-80 game should be exported
to HTML like we did in the earlier TIC-80 assignment. Your write-up
should be clear and look nice.  You will present your work during the
final exam period.

Collaboration Statement: Ere & Trisha collaborated on this assignment.
We decided to port our demake from the NES to TIC80.
