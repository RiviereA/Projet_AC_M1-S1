open FAlphabeta;;
open FMain;;
open FSkeleton;;

module P4_rep = struct
	type cell = A | B | Empty 
	type game = cell array array 
	type move = int 
	let col = 7 and row = 6 
	let game_start () = Array.make_matrix row col Empty 

	let legal_moves b m =   
		let l = ref [] in 
		for c = 0 to col-1 do if m.(row-1).(c) = Empty then l := (c+1) :: !l done;
		!l

	let augment mat c =  
		let l = ref row 
		in while !l > 0 && mat.(!l-1).(c-1) = Empty do  decr l done ; !l + 1

	let player_gen cp m e =
		let mj = Array.map Array.copy  m 
		in  mj.((augment mj cp)-1).(cp-1) <- e ; mj

	let play b cp m = if b then player_gen cp m A else player_gen cp m B
end ;;


module P4_eval = struct open P4_rep type game = P4_rep.game 
	let value =
		Array.of_list [0; 2; 10; 50] 
	exception Four of int 
	exception Nil_Value 
	exception Arg_invalid 
	let lessI = -10000 
	let moreI = 10000
	let eval_four m l_dep c_dep delta_l delta_c =
		let n = ref 0 and e = ref Empty 
		and x = ref c_dep  and  y = ref l_dep 
		in try 
			for i = 1 to 4 do 
				if !y<0 || !y>=row || !x<0 || !x>=col then raise Arg_invalid ; 
				( match m.(!y).(!x) with 
				A    -> if !e = B then raise Nil_Value ;
					incr n ;
					if !n = 4 then raise (Four moreI) ;
					e := A
				| B    -> if !e = A then raise Nil_Value ;
					incr n ;
					if !n = 4 then raise (Four lessI);
					e := B; 
				| Empty -> () ) ;
					x := !x + delta_c ;
				y := !y + delta_l  
			done ; 
			value.(!n) * (if !e=A then 1 else -1)
		with 
			Nil_Value | Arg_invalid  -> 0

	let eval_bloc m e cmin cmax lmin lmax dx dy = 
		for c=cmin to cmax do for l=lmin to lmax do 
			e := !e + eval_four m l c dx dy
		done done

	let evaluate b m = 
		try let evaluation = ref 0 
		in (* evaluation of rows *)
		eval_bloc m evaluation 0 (row-1) 0 (col-4) 0 1 ;
		(* evaluation of columns *)
		eval_bloc m evaluation 0 (col-1) 0 (row-4) 1 0 ;
		(* diagonals coming from the first line (to the right) *)
		eval_bloc m evaluation 0 (col-4) 0 (row-4) 1 1 ;
		(* diagonals coming from the first line (to the left) *)
		eval_bloc m evaluation 1 (row-4) 0 (col-4) 1 1 ;
		(* diagonals coming from the last line (to the right) *)
		eval_bloc m evaluation 3 (col-1) 0 (row-4) 1 (-1) ;
		(* diagonals coming from the last line (to the left) *)
		eval_bloc m evaluation 1 (row-4) 3 (col-1) 1 (-1) ;
		!evaluation
		with Four v -> v

	let is_leaf b m = let v = evaluate b m 
	in v=moreI || v=lessI || legal_moves b m = []

	let is_stable b j = true

	type state = G | P | N | C 

	let state_of player m =
		let v = evaluate player m 
		in if v = moreI then if player then G else P
		else if v = lessI then if player then P else G
		else if legal_moves player m = [] then N else C
end ;;


module P4_disp = struct
	open P4_rep
	type game = P4_rep.game
	type move = P4_rep.move
	let r = 40          (* color of piece *)
	let ec = 20         (* distance between pieces *)
	let dec = r + ec    (* center of first piece *)
	let cote = 2*r + ec (* height of a piece looked at like a checker *)
	let htexte = 40     (* where to place text *)
	let width = col * cote + ec          (* width of the window *)
	let height = row * cote + ec + htexte (* height of the window *)
	let height_of_game = row * cote + ec   (* height of game space *)
	let hec = height_of_game + 10  (* line for messages *)
	let lec = 15                   (* columns for messages *)
	let margin = 5                 (* margin for buttons *)
	let xb1 = width / 3   (* position x of button1 *)
	let xb2 = xb1 + 40      (* position x of button2 *)
	let yb = hec - margin    (* position y of the buttons *)
	let wb = 30             (* width of the buttons *)
	let hb = 20             (* height of the buttons *)

(* Convert a matrix coordinate into a graphical coordinate *)
	let t2e i = dec + (i-1)*cote

(* The Colors *)
	let cN = Graphics.black
	let cC = Graphics.white
	let cA = Graphics.yellow
	let cB = Graphics.red
	let cF = Graphics.blue

	let draw_table () =
		Graphics.clear_graph();
		Graphics.set_color cF;
		Graphics.fill_rect 0 0 width height_of_game;
		Graphics.set_color cN;
		Graphics.moveto 0 height_of_game;
		Graphics.lineto width height_of_game;
		for l = 1 to row do
			for c = 1 to col do
				Graphics.set_color cC;
				Graphics.fill_circle (t2e c) (t2e l) r;
				Graphics.set_color cN;
				Graphics.draw_circle (t2e c) (t2e l) r;
			done
		done

(* draws a piece of color col at coordinates l c *)
	let draw_piece l c col =
		Graphics.set_color col;
		Graphics.fill_circle (t2e c) (t2e l) (r+1)

(* redoes the line || drops the piece for c in m *)
	let augment mat c =
		let l = ref row in
		while !l > 0 && mat.(!l-1).(c-1) = Empty do
			decr l
		done;
		!l

(* convert the region where player has clicked in controlling the game *)
	let conv st =
		(st.Graphics.mouse_x - 5) / (2*r + ec) + 1

(* wait for a mouse click *)
	let wait_click () = Graphics.wait_next_event [Graphics.Button_down]

(* give opportunity to the human player to choose a move *)
(* the function offers possible moves *)
	let rec choice player game  =
		let c = ref 0 in
		while not ( List.mem !c (legal_moves player game) ) do
			c := conv ( wait_click() )
		done;
		!c
		
	let home () =
		Graphics.open_graph
		(" " ^ (string_of_int width) ^ "x" ^ (string_of_int height) ^ "+50+50");
		Graphics.moveto (height/2) (width/2);
		Graphics.set_color cF;
		Graphics.draw_string "Puissance 4";
		ignore (wait_click ());
		Graphics.clear_graph()

	let exit () = Graphics.close_graph()

(* draws a rectangular button at coordinates *)
(* x,y with width w and height h and appearance s *)
	let draw_button x y w h s =
		Graphics.set_color cN;
		Graphics.moveto x y;
		Graphics.lineto x (y+h);
		Graphics.lineto (x+w) (y+h);
		Graphics.lineto (x+w) y;
		Graphics.lineto x y;
		Graphics.moveto (x+margin) (hec);
		Graphics.draw_string s

	let draw_message s =
		Graphics.set_color cN;
		Graphics.moveto lec hec;
		Graphics.draw_string s

	let erase_message () =
		Graphics.set_color Graphics.white;
		Graphics.fill_rect 0 (height_of_game+1) width htexte

(*  poses the question s, the response being obtained by *)
(*  selecting one of two buttons, 'yes' (=true) and 'no' (=false) *)
	let question s =
		let rec attente () =
			let e = wait_click () in
			if (e.Graphics.mouse_y < (yb+hb)) && (e.Graphics.mouse_y > yb) then
				if (e.Graphics.mouse_x > xb1) && (e.Graphics.mouse_x < (xb1+wb)) then
					true
				else
				if (e.Graphics.mouse_x > xb2) && (e.Graphics.mouse_x < (xb2+wb)) then
			 		false
				else
			 		attente()
			else
			attente () in
		draw_message s;
		draw_button xb1 yb wb hb "Oui";
		draw_button xb2 yb wb hb "Non";
		attente()

(* Ask, using function 'question', if the player wishes to start *)
(* (yes=true) *)
	let q_begin () =
		let b = question "Souhaitez-vous commencer ?" in
		erase_message();
		b

(* Ask, using function 'question', if the player wishes to play again *)
(* (yes=true) *)
	let q_continue () =
		let b = question "Une autre partie ?" in
		erase_message();
		b

	let q_player () = 
		let b = question "Ce joueur est-il un ordinateur ?" in 
		erase_message ();
		b
		
(* Three functions for these three cases *)
	let won () = 
		draw_message "J'ai gagne :-)" ; ignore (wait_click ()) ; erase_message()
	let lost () = 
		draw_message "Tu as gagne :-("; ignore (wait_click ()) ; erase_message()
	let nil () = 
		draw_message "Match nul" ; ignore (wait_click ()) ; erase_message()

(* This is called at every start of the game for the position *) 
	let init  = draw_table

	let position b c aj nj  = 
	if b then 
		draw_piece (augment nj c) c cA
	else 
		draw_piece (augment nj c) c cB

(* Position when the human player chooses move cp in situation j *)
	let drawH cp j =  draw_piece (augment j cp) cp cA

(* Position when the machine player chooses move cp in situation j *)
	let drawM cp j =  draw_piece (augment j cp) cp cB
end ;;

module P4_Alphabeta = FAlphabeta (P4_rep) (P4_eval) ;;

module P4_Skeleton = 
	FSkeleton (P4_rep) (P4_disp) (P4_eval) (P4_Alphabeta) ;;

module P4_Main = FMain(P4_Skeleton) ;;



P4_Main.main () ;;