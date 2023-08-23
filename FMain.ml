module type SKELETON = sig 
	val home: unit -> unit 
	val init: unit -> ((unit -> unit) * (unit -> unit)) 
	val again: unit -> bool 
	val exit: unit -> unit 
	val won: unit -> unit 
	val lost: unit -> unit 
	val nil: unit -> unit 
	exception Won 
	exception Lost 
	exception Nil 
end ;;

module FMain (P : SKELETON) = 
	struct 
		let play_game movements = while true do (fst movements) () ; 
			(snd movements) () done

		let main () = let finished = ref false 
		in P.home (); 
		while not !finished do 
			( try play_game (P.init ()) 
			with P.Won -> P.won ()
			| P.Lost -> P.lost () 
			| P.Nil -> P.nil () ); 
			finished := not (P.again ()) 
		done ;
		P.exit ()
end ;;