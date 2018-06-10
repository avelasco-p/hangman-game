#!/usr/bin/env bash
DIR="$(dirname "$(readlink -f "$0")")";

source "$DIR/crud.sh"
source "$DIR/art.sh"
source "$DIR/util.sh"
source "$DIR/game.sh"

function user_menu {
	local opt, input;
	clear;
	draw_logo;
	echo -e "\nWelcome: $1"
	echo -e "1. Play";
	echo -e "2. See my scores (date)";
	echo -e "3. See my scores (high score)";
	echo -e "4. See all scores";
	echo -e "5. Add a word";
	echo -e "6. Remove a word";
	echo -e "0. Exit";
	echo -en "\tChoose an option: ";
	read -n2 opt;
	case $opt in
		2)
			get_user_scores "$1" "fecha";
			read -n1 -p "Press any key to continue...";
			;;
		3)
			get_user_scores "$1" "puntaje";
			read -n1 -p "Press any key to continue...";
			;;
		4)
			get_scores;
			read -n1 -p "Press any key to continue...";
			;;
		5)
			read -p "Insert a new word: " input;
			insert_word "$input" "$1";
			[[ "$?" -eq 0 ]] && echo "Word added successfully";
			sleep 1;
			;;
		6)
			echo "$(sql "SELECT id_palabra, palabra from palabra where usr='$1'")";
			read -p "Input the id to delete: " input;
			delete_word "$input" "$1";
			[[ "$?" -eq 0 ]] && echo "Word deleted successfully";
			sleep 1;
			;;
		0) exit 0 ;;
		*) echo "not a valid option" ;;
	esac
	user_menu "$1";
}

function menu {
	local opt;
	clear;
	draw_logo;
	echo -e "\n1. Login";
	echo -e "2. Register";
	echo -e "3. See Scores";
	echo -e "0. Exit";
	echo -en "\tChoose an option: ";
	read -n2 opt;
	case $opt in
		1)
			user="$(login_loop)";
			[[ ! -z "$user" ]] && user_menu "$user";
			;;
		2)
			register;
			if [[ "$?" -eq 0 ]]; then
				echo -e "\nregister complete!";
				sleep 1;
			else
				echo -e "\nregister unsuccessfull";
				sleep 1;
			fi
			;;
		3)
			get_scores;
			read -n1 -p "Press any key to continue...";
			;;
		0) exit 0 ;;
		*) echo "not a valid option" ;;
	esac
	menu;
}

#preparing game environment
# word_index=$(($RANDOM % $player_score))
# get_player_words "${user[0]}" 

#starting game
# hangman "${player_words[$word_index]}";
menu;
