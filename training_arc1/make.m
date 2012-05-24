%make script

mcc -R -singleCompThread -v -m mcc_wrapper -a '../random_forest/' -d deployment
