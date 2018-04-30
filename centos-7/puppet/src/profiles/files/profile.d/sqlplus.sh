if [[ -x /usr/bin/rlwrap ]]; then
 dict=$HOME/.oracle/sql.dict
 [ -d $HOME/.oracle ] || mkdir $HOME/.oracle
 [ -f $dict ] || touch $dict
 alias sqlplus='rlwrap -b "" -f $dict sqlplus'
fi

