function login_loop {
	local nickname passwd user;
	while [[ -z "$user" ]]; do
		read -p "enter your nickname: " nickname;
		read -s -p "enter your password: " passwd;
		user="$(get_player "$nickname" "$passwd")";
	done
	echo "$user";
}

function register {
	read -p "enter your nickname: " nickname;
	read -s -p "enter your password: " passwd;
	insert_player "$nickname" "$passwd";
	return $?;
}
