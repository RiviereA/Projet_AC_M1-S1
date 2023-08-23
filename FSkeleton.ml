open FAlphabeta;;

module type DISPLAY = sig 
	type game 
	type move 
	val home: unit -> unit 
	val exit: unit -> unit 
	val won: unit -> unit 
	val lost: unit -> unit 
	val nil: unit -> unit 
	val init: unit -> unit 
	val position : bool -> move -> game -> game -> unit 
	val choice : bool -> game -> move 
	val q_player : unit -> bool 
	val q_begin : unit -> bool 
	val q_continue : unit -> bool
end;; 

module FSkeleton 
		(Rep : REPRESENTATION) 
		(Disp : DISPLAY with type game = Rep.game and type move = Rep.move) 
		(Eval : EVAL with type game = Rep.game) 
		(Alpha : ALPHABETA with type game = Rep.game and type move = Rep.move) = 
	struct 
		let depth = ref 4 
		exception Won 
		exception Lost 
		exception Nil 
		let won = Disp.won 
		let lost = Disp.lost 
		let nil = Disp.nil 
		let again = Disp.q_continue 
		let play_game = ref (Rep.game_start()) 
		let exit = Disp.exit 
		let home = Disp.home
		
		let playH player () = 
			let choice = Disp.choice player !play_game in 
			let old_game = !play_game 
			in play_game := Rep.play player choice !play_game ; 
			Disp.position player choice old_game !play_game ; 
			match Eval.state_of player !play_game with 
				Eval.P -> raise Lost
				| Eval.G -> raise Won
				| Eval.N -> raise Nil
				| _ -> () 
				
		let playM player () = 
			let choice = Alpha.alphabeta !depth player !play_game in 
			let old_game = !play_game 
			in play_game := Rep.play player choice !play_game ; 
			Disp.position player choice old_game !play_game ; 
			match Eval.state_of player !play_game with 
				Eval.G -> raise Won
				| Eval.P -> raise Lost
				| Eval.N -> raise Nil
				| _ -> ()
				
		let init () = 
			let a = Disp.q_player () in 
			let b = Disp.q_player () 
			in play_game := Rep.game_start () ; 
			Disp.init () ; 
			match (a,b) with 
				true,true -> playM true, playM false
				| true,false -> playM true, playH false
				| false,true -> playH true, playM false
				| false,false -> playH true, playH false
end;;
