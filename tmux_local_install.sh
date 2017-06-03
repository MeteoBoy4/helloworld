#!/bin/bash

# Exit on error #
set -e
MYHOME=/vol-th/home/huzx/lcq

# Clean up #
rm -rf $MYHOME/local/libevent
rm -rf $MYHOME/local/ncurses
rm -rf $MYHOME/local/tmux

# Variable version #
TMUX_VERSION=2.2

# Create our directories #
mkdir -p $MYHOME/local/libevent
mkdir -p $MYHOME/local/ncurses
mkdir -p $MYHOME/local/tmux

############
# libevent #
############
cd $MYHOME/local/src
tar xvzf libevent-2.0.21-stable.tar.gz
cd libevent-*/
./configure --prefix=$MYHOME/local/libevent --disable-shared
make
make install

############
# ncurses  #
############
cd $MYHOME/local/src
tar xvzf ncurses-5.9.tar.gz
cd ncurses-5.9
./configure --prefix=$MYHOME/local/ncurses 
make
make install

############
# tmux     #
############
cd $MYHOME/local/src
tar xvzf tmux-${TMUX_VERSION}.tar.gz
cd tmux-${TMUX_VERSION}

# open configure and find the line that says:
# PKG_CONFIG="pkg-config --static"
# And comment it out:
# #PKG_CONFIG="pkg-config --static"

# Build #
./configure --prefix=$MYHOME/local/tmux CFLAGS="-I$MYHOME/local/libevent/include -I$MYHOME/local/ncurses/include/ncurses -I$MYHOME/local/ncurses/include/" LDFLAGS="-L$MYHOME/local/libevent/lib -L$MYHOME/local/libevent/include -L$MYHOME/local/ncurses/lib -L$MYHOME/local/ncurses/include -L$MYHOME/local/ncurses/include/ncurses" PKG_CONFIG=/bin/false
CPPFLAGS="-I$MYHOME/local/libevent/include -I$MYHOME/local/ncurses/include -I$MYHOME/local/ncurses/include/ncurses" LDFLAGS="-L$MYHOME/local/libevent/lib -L$MYHOME/local/libevent/include -L$MYHOME/local/ncurses/lib -L$MYHOME/local/ncurses/include -L$MYHOME/local/ncurses/include/ncurses" 
make
make install

echo "Ha! I am here!"
