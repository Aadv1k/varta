if [ -n $VIRTUAL_ENV ]; then 
    pip3 freeze > ./server/requirements.txt
fi


