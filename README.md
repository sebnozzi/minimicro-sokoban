
# Sokoban for the Mini Micro

This is a Sokoban implementation for the [Mini Micro](https://miniscript.org/MiniMicro/index.html) virtual computer, done for education purposes but mostly for fun.

It was done while learning to code for the Mini Micro and get familiar with the MiniScript language.

Whenever possible it tries to follow OOP principles.

<img alt="Sokoban screenshot" src="./screenshot.png" width="50%" height="50%"/>

## About Sokoban

From Wikipedia:

> Sokoban (倉庫番, Sōko-ban) is a puzzle video game genre in which the player pushes crates or boxes around in a warehouse, trying to get them to storage locations. 

It originated in Japan in the 80's and over the years became popular all over the world.

Since its release it has enjoyed numerous revisions and implementations for numerous platforms.

For more details see the Wikipedia article: https://en.wikipedia.org/wiki/Sokoban

## Running

Current working directory (`pwd`) should be the folder contaning these files.

Correct:

```
cd "/usr/sokoban"
load "sokoban" // loads "sokoban.ms"
run
```

INCORRECT:

```
load "/usr/sokoban/sokoban" // loads "sokoban.ms"
run
```

This is important because the main sokoban game loads an additional module for level-playing. It needs to be found in the current directory.

## Gameplay

Move the worker with the arrow keys.

The goal for each level is to bring all boxes into the designated target tiles.

IMPORTANT: During gameplay press "R" (key "r") to <b><u>R</u></b>estart the level if you get stuck.

Press "Q" to quit.

# Credits

Original levels by "Thinking Rabbit" (original game publisher)

> Taken from: http://sokoban-jd.blogspot.com/2014/05/the-original-collection.html

Microban levels by David W. Skinner

> Taken from http://www.abelmartin.com/rj/sokobanJS/Skinner/David%20W.%20Skinner%20-%20Sokoban.htm

Game assets by Kenney

> Taken from: https://www.kenney.nl/assets/sokoban
