if [ -n $VIRTUAL_ENV ]; then 
    exit 0
fi

pip3 freeze > ./server/requirements.txt
