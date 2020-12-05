#!/bin/sh -e

LIT_DIR=${LIT_DIR:"~/.lit"}
LIT_CONFIG_FILE=$LIT_DIR/lit.conf

HTTPS_LISTEN=${HTTPS_LISTEN:-0.0.0.0:443}
LETSENCRYPT=${LETSENCRYPT}
LETSENCRYPT_HOST=${LETSENCRYPT_HOST}
LND_MODE=${LND_MODE:-remote}
UIPASSWORD=${UIPASSWORD:-password}

REMOTE_LITDEBUGLEVEL=${REMOTE_LITDEBUGLEVEL:-debug}
REMOTE_LND_NETWORK=${REMOTE_LND_NETWORK:-mainnet}
REMOTE_LND_RPCSERVER=${REMOTE_LND_RPCSERVER}
REMOTE_LND_MACAROONDIR=${REMOTE_LND_MACAROONDIR:-"/root/.lnd/data/chain/bitcoin/${REMOTE_LND_NETWORK}/"}
REMOTE_LND_TLSCERTPATH=${REMOTE_LND_TLSCERTPATH:-"/root/.lnd/tls.cert"}

LND_LNDDIR=${LND_LNDDIR:-"/root/.lnd"}
LND_ALIAS=${LND_ALIAS}
LND_EXTERNALIP=${LND_EXTERNALIP}
LND_RPCLISTEN=${LND_RPCLISTEN-=0.0.0.0:10009}
LND_LISTEN=${LND_RPCLISTEN-=0.0.0.0:9735}
LND_DEBUGLEVEL=${LND_DEBUGLEVEL:-debug}

LND_BITCOIN_ACTIVE=${LND_BITCOIN_ACTIVE:-true}
LND_BITCOIN_TESTNET=${LND_BITCOIN_TESTNET:-false}
LND_BITCOIN_NODE=${LND_BITCOIN_NODE:-bitcoind}

LND_BITCOIND_RPCHOST=${LND_BITCOIND_RPCHOST:-localhost}
LND_BITCOIND_RPCUSER=${LND_BITCOIND_RPCUSER}
LND_BITCOIND_RPCPASS=${LND_BITCOIND_RPCPASS}
LND_BITCOIND_ZMQPUBRAWBLOCK=${LND_BITCOIND_ZMQPUBRAWBLOCK:-localhost:28332}
LND_BITCOIND_ZMQPUBRAWTX=${LND_BITCOIND_ZMQPUBRAWTX:-localhost:28333}

LOOP_LOOPOUTMAXPARTS=${LOOP_LOOPOUTMAXPARTS}
POOL_NEWNODESONLY=${POOL_NEWNODESONLY}

FARADAY_MIN_MONITORED=${FARADAY_MIN_MONITORED}
FARADAY_CONNECT_BITCOIN=${FARADAY_CONNECT_BITCOIN}
FARADAY_BITCOIN_HOST=${FARADAY_BITCOIN_HOST}
FARADAY_BITCOIN_USER=${FARADAY_BITCOIN_USER}
FARADAY_BITCOIN_PASSWORD=${FARADAY_BITCOIN_PASSWORD}

add_option_if_exists () {
  if [ ! -z "$2" ]; then echo $1=$2 >> $LIT_CONFIG_FILE; fi
}

mkdir -p ${LIT_DIR}

echo "## Application Options ##" > $LIT_CONFIG_FILE
add_option_if_exists uipassword $UIPASSWORD
add_option_if_exists httpslisten $HTTPS_LISTEN
add_option_if_exists lnd-mode $LND_MODE
add_option_if_exists letsencrypt $LETSENCRYPT
add_option_if_exists letsencrypthost $LETSENCRYPT_HOST

if [ $LND_MODE = "integrated" ];
then
  echo "\n## LND ##" >> $LIT_CONFIG_FILE
  add_option_if_exists lnd.lnddir $LND_LNDDIR
  add_option_if_exists lnd.alias $LND_ALIAS
  add_option_if_exists lnd.externalip $LND_EXTERNALIP
  add_option_if_exists lnd.rpclisten $LND_RPCLISTEN
  add_option_if_exists lnd.listen $LND_LISTEN
  add_option_if_exists lnd.debuglevel $LND_DEBUGLEVEL
  echo "\n## LND - Bitcoin ##" >> $LIT_CONFIG_FILE
  add_option_if_exists lnd.bitcoin.active $LND_BITCOIN_ACTIVE
  add_option_if_exists lnd.bitcoin.testnet $LND_BITCOIN_TESTNET
  add_option_if_exists lnd.bitcoin.node $LND_BITCOIN_NODE
  echo "\n## LND - Bitcoind ##" >> $LIT_CONFIG_FILE
  add_option_if_exists lnd.bitcoind.rpchost $LND_BITCOIND_RPCHOST
  add_option_if_exists lnd.bitcoind.rpcuser $LND_BITCOIND_RPCUSER
  add_option_if_exists lnd.bitcoind.rpcpass $LND_BITCOIND_RPCPASS
  add_option_if_exists lnd.bitcoind.zmqpubrawblock $LND_BITCOIND_ZMQPUBRAWBLOCK
  add_option_if_exists lnd.bitcoind.zmqpubrawtx $LND_BITCOIND_ZMQPUBRAWTX
elif [ $LND_MODE = "remote" ]
then
  echo "\n## Remote LND ##" >> $LIT_CONFIG_FILE
  add_option_if_exists remote.lnd.network $REMOTE_LND_NETWORK
  add_option_if_exists remote.lnd.rpcserver $REMOTE_LND_RPCSERVER
  add_option_if_exists remote.lnd.macaroondir $REMOTE_LND_MACAROONDIR
  add_option_if_exists remote.lnd.tlscertpath $REMOTE_LND_TLSCERTPATH
  add_option_if_exists remote.lit-debuglevel $REMOTE_LITDEBUGLEVEL
fi

if [ $LOOP_LOOPOUTMAXPARTS ]; then echo "\n## Loop ##" >> $LIT_CONFIG_FILE; fi
add_option_if_exists loop.loopoutmaxparts $LOOP_LOOPOUTMAXPARTS

if [ $POOL_NEWNODESONLY ]; then echo "\n## Pool ##" >> $LIT_CONFIG_FILE; fi
add_option_if_exists pool.newnodesonly $POOL_NEWNODESONLY

if [ $FARADAY_MIN_MONITORED ]; then echo "\n## Faraday ##" >> $LIT_CONFIG_FILE; fi
add_option_if_exists faraday.min_monitored $FARADAY_MIN_MONITORED

if [ $FARADAY_CONNECT_BITCOIN ];
then
  echo "\n## Faraday - Bitcoin ##" >> $LIT_CONFIG_FILE
  add_option_if_exists faraday.connect_bitcoin $FARADAY_CONNECT_BITCOIN
  add_option_if_exists faraday.bitcoin.host $FARADAY_BITCOIN_HOST
  add_option_if_exists faraday.bitcoin.user $FARADAY_BITCOIN_USER
  add_option_if_exists faraday.bitcoin.password $FARADAY_BITCOIN_PASSWORD
fi

litd --lit-dir=${LIT_DIR}


