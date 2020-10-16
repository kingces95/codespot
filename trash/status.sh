while [ : ]
do
    clear
    tput cup 5 5
    date
    tput cup 6 5
    echo "Hostname : $(hostname)"
    read input
done