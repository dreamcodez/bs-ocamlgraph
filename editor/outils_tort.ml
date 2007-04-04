
open Graphics
open Outils_math

let debug =  ref true

let (w,h)= (600.,600.)

(*** Tortue Hyperbolique ***)


type coord = float * float 

type turtle =
    {
      pos : coord ;  (* with |pos| < 1 *)
      dir : coord    (* with |dir| = 1 *)
    } 

let make_turtle pos angle =
  { 
    pos = pos ;
    dir = expi angle 
  }

let make_turtle_dir pos dir =
  { 
    pos = pos ;
    dir = dir 
  }


let advance turt step =
   { pos = gamma turt.pos turt.dir step ;
     dir = delta turt.pos turt.dir step }
   

let turn turtle u =
  { turtle with dir = turtle.dir *& u }

let turn_left turtle angle =
  turn turtle (expi angle)       (*** a comprendre pourquoi je dois inverser + et - de l'angle ***)

let turn_right turtle angle =
  turn turtle (expi (-.angle))           (*** a comprendre pourquoi je dois inverser + et - de l'angle ***) 

let to_tortue(x,y)=
  ((float x*.(2./.w) -. 1.),(1. -. float y *.(2./.h)))
(*  ((float x*.(2./.w) ),(float y *.(2./.h) ))*)

let from_tortue (x,y) =
  let xzoom = (w/.2.)
  and yzoom = (h/.2.) in
  (truncate (x*.xzoom +. xzoom), truncate(yzoom -. y*.yzoom))

let origine =ref (to_tortue (truncate(w/.2.), truncate(h/.2.)))




(* GTK *)
let point_courant = ref (0,0)
(*let canvas = graphEdGTK.root *)

let moveto_gtk x y = point_courant := (x,y)

let tmoveto_gtk tor = 
  let (x,y)= from_tortue tor.pos in
  point_courant := (x,y)

let tlineto_gtk tor color canvas=
  let (x,y) = !point_courant in
  let (x',y')= from_tortue tor.pos in
  let p = [|(float x); (float y); (float x'); (float y') |] in
  (*Format.eprintf "tlineto %d,%d - %d,%d@." x y x' y';*)
  let l = GnoCanvas.line canvas ~props:[`POINTS p; `FILL_COLOR color ;`WIDTH_PIXELS 1; `SMOOTH true] in
  l#lower_to_bottom ();
  point_courant := (x',y')


let tdraw_string_gtk tor s canvas =
  let(w,h) = (40,15) in
  let (x,y)= from_tortue tor.pos in
  (*Format.eprintf "tdraw_string_gtk s=%s x=%d y=%d@." s x y;*)
  moveto_gtk x y;
  let noeud = GnoCanvas.group ~x: (float x) ~y: (float y)  canvas in
  let ellipse = GnoCanvas.ellipse 
    ~props:[ `X1  ( float (-w/2)); `Y1 (float (-h/2)); `X2  (float (w/2)) ; `Y2 ( float (h/2)) ;
	     `FILL_COLOR "grey" ; `OUTLINE_COLOR "black" ; `WIDTH_PIXELS 0 ] noeud  in
  let _ = GnoCanvas.text ~props:[`X 0.0; `Y 0.0 ; `TEXT s;  `FILL_COLOR "blue"] noeud in
  ellipse



(* avance la tortue en tra�ant, d'une distance d, en n pas, et retourne la nouvelle
   position de la tortue *)
let tdraw_edge_gtk tor d n couleur canvas=
  let d = d /. float n in
  let rec move t = function
    | 0 -> t
    | n -> let t = advance t d in tlineto_gtk t couleur canvas; move t (n-1)
  in
  tmoveto_gtk tor;
  move tor n





(*
(* graphics *)

let tmoveto tor =
  let (x,y)= from_tortue tor.pos in
  moveto x y

let tlineto tor =
  let (x,y)= from_tortue tor.pos in
  lineto x y
  
let tdraw_string tor s =
  let (x,y)= from_tortue tor.pos in
  moveto x y;
  draw_string s

(* avance la tortue en tra�ant, d'une distance d, en n pas, et retourne la nouvelle
   position de la tortue *)
let tdraw_edge tor d n =
  let d = d /. float n in
  let rec move t = function
    | 0 -> t
    | n -> let t = advance t d in tlineto t; move t (n-1)
  in
  tmoveto tor;
  move tor n
*)