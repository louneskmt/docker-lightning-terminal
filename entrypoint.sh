#!/bin/sh -e

LIT_DIR=${LIT_DIR:-"/lit"}
LIT_CONFIG_FILE=$(echo $LIT_DIR/lit.conf | sed "s|\/\/|\/|g")

UIPASSWORD=${UIPASSWORD:-${DEFAULT_UIPASSWORD:-password}}
HTTPSLISTEN=${HTTPSLISTEN:-0.0.0.0:443}
LND_LNDDIR=${LND_LNDDIR:-"/root/.lnd"}
REMOTE_LND_MACAROONDIR=${REMOTE_LND_MACAROONDIR:-"/root/.lnd/data/chain/bitcoin/${REMOTE_LND_NETWORK:-mainnet}/"}
REMOTE_LND_TLSCERTPATH=${REMOTE_LND_TLSCERTPATH:-"/root/.lnd/tls.cert"}

add_or_add_option_if_non_empty () {
  # Check if config file exists, else create it by adding the option
  if [ -e $LIT_CONFIG_FILE ];
  then
    ## If non-empty env variable + config file already contains the option $1 => edit the option with sed
    if [ ! -z "$2" ] && [ "$(cat $LIT_CONFIG_FILE | grep "$1")" != "" ]; 
    then sed -i '' -e "s|$1=.*|$1=$2|g" $LIT_CONFIG_FILE; 
    ## Else if non-empty env variable, add the option to the config file
    elif [ ! -z "$2" ]; then echo "$1=$2" >> $LIT_CONFIG_FILE;
    fi;
  else
    if [ ! -z "$2" ]; then echo "$1=$2" > $LIT_CONFIG_FILE; fi;
  fi;
}

# Make sure that the config dir exists
mkdir -p ${LIT_DIR}

## Application Options ##
add_or_add_option_if_non_empty uipassword $UIPASSWORD
add_or_add_option_if_non_empty httpslisten $HTTPSLISTEN
add_or_add_option_if_non_empty lnd-mode $LND_MODE
add_or_add_option_if_non_empty letsencrypt $LETSENCRYPT
add_or_add_option_if_non_empty letsencrypthost $LETSENCRYPT_HOST

if [ "$LND_MODE" = "integrated" ];
then
  ## LND ##
  add_or_add_option_if_non_empty lnd.lnddir $LND_LNDDIR
  add_or_add_option_if_non_empty lnd.alias $LND_ALIAS
  add_or_add_option_if_non_empty lnd.externalip $LND_EXTERNALIP
  add_or_add_option_if_non_empty lnd.rpclisten $LND_RPCLISTEN
  add_or_add_option_if_non_empty lnd.listen $LND_LISTEN
  add_or_add_option_if_non_empty lnd.debuglevel $LND_DEBUGLEVEL
  ## LND - Bitcoin ##
  add_or_add_option_if_non_empty lnd.bitcoin.active $LND_BITCOIN_ACTIVE
  add_or_add_option_if_non_empty lnd.bitcoin.testnet $LND_BITCOIN_TESTNET
  add_or_add_option_if_non_empty lnd.bitcoin.node $LND_BITCOIN_NODE
  ## LND - Bitcoind ##
  add_or_add_option_if_non_empty lnd.bitcoind.rpchost $LND_BITCOIND_RPCHOST
  add_or_add_option_if_non_empty lnd.bitcoind.rpcuser $LND_BITCOIND_RPCUSER
  add_or_add_option_if_non_empty lnd.bitcoind.rpcpass $LND_BITCOIND_RPCPASS
  add_or_add_option_if_non_empty lnd.bitcoind.zmqpubrawblock $LND_BITCOIND_ZMQPUBRAWBLOCK
  add_or_add_option_if_non_empty lnd.bitcoind.zmqpubrawtx $LND_BITCOIND_ZMQPUBRAWTX
else
  ## Remote LND ##
  add_or_add_option_if_non_empty remote.lnd.network $REMOTE_LND_NETWORK
  add_or_add_option_if_non_empty remote.lnd.rpcserver $REMOTE_LND_RPCSERVER
  add_or_add_option_if_non_empty remote.lnd.macaroondir $REMOTE_LND_MACAROONDIR
  add_or_add_option_if_non_empty remote.lnd.tlscertpath $REMOTE_LND_TLSCERTPATH
  add_or_add_option_if_non_empty remote.lit-debuglevel $REMOTE_LIT_DEBUGLEVEL
fi

add_or_add_option_if_non_empty loop.loopoutmaxparts $LOOP_LOOPOUTMAXPARTS
add_or_add_option_if_non_empty pool.newnodesonly $POOL_NEWNODESONLY
add_or_add_option_if_non_empty faraday.min_monitored $FARADAY_MIN_MONITORED

if [ $FARADAY_CONNECT_BITCOIN ];
then
  add_or_add_option_if_non_empty faraday.connect_bitcoin $FARADAY_CONNECT_BITCOIN
  add_or_add_option_if_non_empty faraday.bitcoin.host $FARADAY_BITCOIN_HOST
  add_or_add_option_if_non_empty faraday.bitcoin.user $FARADAY_BITCOIN_USER
  add_or_add_option_if_non_empty faraday.bitcoin.password $FARADAY_BITCOIN_PASSWORD
fi

# Start litd 
litd --lit-dir=${LIT_DIR}


