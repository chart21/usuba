exception Error

open Array
open Int64

 
let int_to_bin n =
  let rec aux n acc =
    if n == 0 then acc
    else aux (n/2) ((string_of_int (n mod 2)) ^ acc)
  in aux n ""

let permut64 x p =
  let res = ref zero in
  (*  let len = Array.length p - 1 in *)
  for i = 0 to Array.length p - 1 do
    res := logor !res (shift_left (logand (shift_right x p.(i)) one) i)
  done;
  !res
   

(* initial_permutation *)
let init_p_left =
  Array.of_list
    (List.rev
       (Array.to_list
          (Array.map (fun x -> 63 - x) [|
	                   57; 49; 41; 33; 25; 17; 9; 1; 59; 51; 43; 35; 27; 19; 11; 3;
	                   61; 53; 45; 37; 29; 21; 13; 5; 63; 55; 47; 39; 31; 23; 15; 7 |] )))

let init_p_right =
  Array.of_list
    (List.rev
       (Array.to_list
          (Array.map (fun x -> 63 - x)  [|
	                   56; 48; 40; 32; 24; 16; 8; 0; 58; 50; 42; 34; 26; 18; 10; 2;
	                   60; 52; 44; 36; 28; 20; 12; 4; 62; 54; 46; 38; 30; 22; 14; 6
                      |] )))

(* final permutation *)
let final_p =
  Array.of_list
    (List.rev
        (Array.to_list
           (Array.map (fun x -> 63 - x) 
  [|
	39; 7; 47; 15; 55; 23; 63; 31; 38; 6; 46; 14; 54; 22; 62; 30;
	37; 5; 45; 13; 53; 21; 61; 29; 36; 4; 44; 12; 52; 20; 60; 28;
	35; 3; 43; 11; 51; 19; 59; 27; 34; 2; 42; 10; 50; 18; 58; 26;
	33; 1; 41; 9; 49; 17; 57; 25; 32; 0; 40; 8; 48; 16; 56; 24
   |] )))


let permut x table =
  let res = ref 0 in
  for i = 0 to Array.length table - 1 do
    res := !res lor (((x lsr table.(i)) land 1) lsl i)
  done;
  !res  
                
(* permutation P *)
let permut_p x =
  let table =
    Array.of_list
      (List.rev
         (Array.to_list
            (Array.map (fun x -> 31 - x) [|
	                     15; 6; 19; 20; 28; 11; 27; 16; 0; 14; 22; 25; 4; 17; 30; 9;
	                     1; 7; 23; 13; 31; 26; 2; 8; 18; 12; 29; 5; 21; 10; 3; 24
                        |] ))) in
  permut x table

   
(* expansion function *)
let expand x =
  let table = [|
	31; 0; 1; 2; 3; 4; 3; 4; 5; 6; 7; 8; 7; 8; 9; 10; 11; 12;
	11; 12; 13; 14; 15; 16; 15; 16; 17; 18; 19; 20; 19; 20;
	21; 22; 23; 24; 23; 24; 25; 26; 27; 28; 27; 28; 29; 30; 31; 0
    |] in
  permut x table

let sbox x s =
  let row = (x lsr 4 land 2) lor (x land 1) in
  let col = (x lsr 1 land 15) in
  s.(row*16+col)

(* The s-boxes*)
let s1 = [|
    14; 4; 13; 1; 2; 15; 11; 8; 3; 10; 6; 12; 5; 9; 0; 7; 
    0; 15; 7; 4; 14; 2; 13; 1; 10; 6; 12; 11; 9; 5; 3; 8; 
    4; 1; 14; 8; 13; 6; 2; 11; 15; 12; 9; 7; 3; 10; 5; 0; 
    15; 12; 8; 2; 4; 9; 1; 7; 5; 11; 3; 14; 10; 0; 6; 13; 
   |]

let s2 = [|
    15; 1; 8; 14; 6; 11; 3; 4; 9; 7; 2; 13; 12; 0; 5; 10; 
    3; 13; 4; 7; 15; 2; 8; 14; 12; 0; 1; 10; 6; 9; 11; 5; 
    0; 14; 7; 11; 10; 4; 13; 1; 5; 8; 12; 6; 9; 3; 2; 15; 
    13; 8; 10; 1; 3; 15; 4; 2; 11; 6; 7; 12; 0; 5; 14; 9; 
   |]

let s3 = [|
    10; 0; 9; 14; 6; 3; 15; 5; 1; 13; 12; 7; 11; 4; 2; 8; 
    13; 7; 0; 9; 3; 4; 6; 10; 2; 8; 5; 14; 12; 11; 15; 1; 
    13; 6; 4; 9; 8; 15; 3; 0; 11; 1; 2; 12; 5; 10; 14; 7; 
    1; 10; 13; 0; 6; 9; 8; 7; 4; 15; 14; 3; 11; 5; 2; 12
   |]

let s4 = [|
    7; 13; 14; 3; 0; 6; 9; 10; 1; 2; 8; 5; 11; 12; 4; 15; 
    13; 8; 11; 5; 6; 15; 0; 3; 4; 7; 2; 12; 1; 10; 14; 9; 
    10; 6; 9; 0; 12; 11; 7; 13; 15; 1; 3; 14; 5; 2; 8; 4; 
    3; 15; 0; 6; 10; 1; 13; 8; 9; 4; 5; 11; 12; 7; 2; 14
   |]

let s5 = [|
    2; 12; 4; 1; 7; 10; 11; 6; 8; 5; 3; 15; 13; 0; 14; 9; 
    14; 11; 2; 12; 4; 7; 13; 1; 5; 0; 15; 10; 3; 9; 8; 6; 
    4; 2; 1; 11; 10; 13; 7; 8; 15; 9; 12; 5; 6; 3; 0; 14; 
    11; 8; 12; 7; 1; 14; 2; 13; 6; 15; 0; 9; 10; 4; 5; 3
   |]

let s6 = [|
    12; 1; 10; 15; 9; 2; 6; 8; 0; 13; 3; 4; 14; 7; 5; 11; 
    10; 15; 4; 2; 7; 12; 9; 5; 6; 1; 13; 14; 0; 11; 3; 8; 
    9; 14; 15; 5; 2; 8; 12; 3; 7; 0; 4; 10; 1; 13; 11; 6; 
    4; 3; 2; 12; 9; 5; 15; 10; 11; 14; 1; 7; 6; 0; 8; 13
   |]
let s7 = [|
    4; 11; 2; 14; 15; 0; 8; 13; 3; 12; 9; 7; 5; 10; 6; 1; 
    13; 0; 11; 7; 4; 9; 1; 10; 14; 3; 5; 12; 2; 15; 8; 6; 
    1; 4; 11; 13; 12; 3; 7; 14; 10; 15; 6; 8; 0; 5; 9; 2; 
    6; 11; 13; 8; 1; 4; 10; 7; 9; 5; 0; 15; 14; 2; 3; 12
   |]

let s8 = [|
    13; 2; 8; 4; 6; 15; 11; 1; 10; 9; 3; 14; 5; 0; 12; 7; 
    1; 15; 13; 8; 10; 3; 7; 4; 12; 5; 6; 11; 0; 14; 9; 2; 
    7; 11; 4; 1; 9; 12; 14; 2; 0; 6; 10; 13; 15; 3; 5; 8; 
    2; 1; 14; 7; 4; 10; 8; 13; 15; 12; 9; 0; 3; 5; 6; 11
   |]

(* the key permutations *)
let round_key k r =
  let table = Array.map (fun a ->
                         (Array.of_list
                            (List.rev
                               (Array.to_list
                                  (Array.map (fun x -> 63 - x) a)))))
                        [|
      [|
	    9; 50; 33; 59; 48; 16; 32; 56; 1; 8; 18; 41; 2; 34; 25; 24;
	    43; 57; 58; 0; 35; 26; 17; 40; 21; 27; 38; 53; 36; 3; 46; 29;
	    4; 52; 22; 28; 60; 20; 37; 62; 14; 19; 44; 13; 12; 61; 54; 30
       |];
      [|
	    1; 42; 25; 51; 40; 8; 24; 48; 58; 0; 10; 33; 59; 26; 17; 16;
	    35; 49; 50; 57; 56; 18; 9; 32; 13; 19; 30; 45; 28; 62; 38; 21;
	    27; 44; 14; 20; 52; 12; 29; 54; 6; 11; 36; 5; 4; 53; 46; 22
       |];
      [|
	    50; 26; 9; 35; 24; 57; 8; 32; 42; 49; 59; 17; 43; 10; 1; 0;
	    48; 33; 34; 41; 40; 2; 58; 16; 60; 3; 14; 29; 12; 46; 22; 5;
	    11; 28; 61; 4; 36; 27; 13; 38; 53; 62; 20; 52; 19; 37; 30; 6
       |];
      [|
	    34; 10; 58; 48; 8; 41; 57; 16; 26; 33; 43; 1; 56; 59; 50; 49;
	    32; 17; 18; 25; 24; 51; 42; 0; 44; 54; 61; 13; 27; 30; 6; 52;
	    62; 12; 45; 19; 20; 11; 60; 22; 37; 46; 4; 36; 3; 21; 14; 53
       |];
      [|
	    18; 59; 42; 32; 57; 25; 41; 0; 10; 17; 56; 50; 40; 43; 34; 33;
	    16; 1; 2; 9; 8; 35; 26; 49; 28; 38; 45; 60; 11; 14; 53; 36;
	    46; 27; 29; 3; 4; 62; 44; 6; 21; 30; 19; 20; 54; 5; 61; 37
       |];
      [|
	    2; 43; 26; 16; 41; 9; 25; 49; 59; 1; 40; 34; 24; 56; 18; 17;
	    0; 50; 51; 58; 57; 48; 10; 33; 12; 22; 29; 44; 62; 61; 37; 20;
	    30; 11; 13; 54; 19; 46; 28; 53; 5; 14; 3; 4; 38; 52; 45; 21
       |];
      [|
	    51; 56; 10; 0; 25; 58; 9; 33; 43; 50; 24; 18; 8; 40; 2; 1;
	    49; 34; 35; 42; 41; 32; 59; 17; 27; 6; 13; 28; 46; 45; 21; 4;
	    14; 62; 60; 38; 3; 30; 12; 37; 52; 61; 54; 19; 22; 36; 29; 5
       |];
      [|
	    35; 40; 59; 49; 9; 42; 58; 17; 56; 34; 8; 2; 57; 24; 51; 50;
	    33; 18; 48; 26; 25; 16; 43; 1; 11; 53; 60; 12; 30; 29; 5; 19;
	    61; 46; 44; 22; 54; 14; 27; 21; 36; 45; 38; 3; 6; 20; 13; 52
       |];
      [|
	    56; 32; 51; 41; 1; 34; 50; 9; 48; 26; 0; 59; 49; 16; 43; 42;
	    25; 10; 40; 18; 17; 8; 35; 58; 3; 45; 52; 4; 22; 21; 60; 11;
	    53; 38; 36; 14; 46; 6; 19; 13; 28; 37; 30; 62; 61; 12; 5; 44
       |];
      [|
	    40; 16; 35; 25; 50; 18; 34; 58; 32; 10; 49; 43; 33; 0; 56; 26;
	    9; 59; 24; 2; 1; 57; 48; 42; 54; 29; 36; 19; 6; 5; 44; 62;
	    37; 22; 20; 61; 30; 53; 3; 60; 12; 21; 14; 46; 45; 27; 52; 28
       |];
      [|
	    24; 0; 48; 9; 34; 2; 18; 42; 16; 59; 33; 56; 17; 49; 40; 10;
	    58; 43; 8; 51; 50; 41; 32; 26; 38; 13; 20; 3; 53; 52; 28; 46;
	    21; 6; 4; 45; 14; 37; 54; 44; 27; 5; 61; 30; 29; 11; 36; 12
       |];
      [|
	    8; 49; 32; 58; 18; 51; 2; 26; 0; 43; 17; 40; 1; 33; 24; 59;
	    42; 56; 57; 35; 34; 25; 16; 10; 22; 60; 4; 54; 37; 36; 12; 30;
	    5; 53; 19; 29; 61; 21; 38; 28; 11; 52; 45; 14; 13; 62; 20; 27
       |];
      [|
	    57; 33; 16; 42; 2; 35; 51; 10; 49; 56; 1; 24; 50; 17; 8; 43;
	    26; 40; 41; 48; 18; 9; 0; 59; 6; 44; 19; 38; 21; 20; 27; 14;
	    52; 37; 3; 13; 45; 5; 22; 12; 62; 36; 29; 61; 60; 46; 4; 11
       |];
      [|
	    41; 17; 0; 26; 51; 48; 35; 59; 33; 40; 50; 8; 34; 1; 57; 56;
	    10; 24; 25; 32; 2; 58; 49; 43; 53; 28; 3; 22; 5; 4; 11; 61;
	    36; 21; 54; 60; 29; 52; 6; 27; 46; 20; 13; 45; 44; 30; 19; 62
       |];
      [|
	    25; 1; 49; 10; 35; 32; 48; 43; 17; 24; 34; 57; 18; 50; 41; 40;
	    59; 8; 9; 16; 51; 42; 33; 56; 37; 12; 54; 6; 52; 19; 62; 45;
	    20; 5; 38; 44; 13; 36; 53; 11; 30; 4; 60; 29; 28; 14; 3; 46
       |];
      [|
	    17; 58; 41; 2; 56; 24; 40; 35; 9; 16; 26; 49; 10; 42; 33; 32;
	    51; 0; 1; 8; 43; 34; 25; 48; 29; 4; 46; 61; 44; 11; 54; 37;
	    12; 60; 30; 36; 5; 28; 45; 3; 22; 27; 52; 21; 20; 6; 62; 38
       |];
     |] in
  permut64 k table.(r)
                      
(* crypt: true for encryption, false for decryption *)
let des_single (plaintext: int64) (key: int64) (crypt: bool) : int64 =
  let left  = ref (Int64.to_int (permut64 plaintext init_p_left)) in
  let right = ref (Int64.to_int (permut64 plaintext init_p_right)) in
  
  for i = 0 to 15 do
    
    let tmp = expand !right in
    let k   = Int64.to_int (round_key key (if crypt then i else (15-i))) in
    let xored = tmp lxor k in
    let c1 = sbox ((xored lsr 0 ) land 63) s8 in
    let c2 = sbox ((xored lsr 6 ) land 63) s7 in
    let c3 = sbox ((xored lsr 12) land 63) s6 in
    let c4 = sbox ((xored lsr 18) land 63) s5 in
    let c5 = sbox ((xored lsr 24) land 63) s4 in
    let c6 = sbox ((xored lsr 30) land 63) s3 in
    let c7 = sbox ((xored lsr 36) land 63) s2 in
    let c8 = sbox ((xored lsr 42) land 63) s1 in
    let c  = c1 lor (c2 lsl 4) lor (c3 lsl 8) lor (c4 lsl 12) lor
               (c5 lsl 16) lor (c6 lsl 20) lor (c7 lsl 24) lor (c8 lsl 28) in
    let tmp2 = !left lxor (permut_p c) in
    left  := !right;
    right := tmp2
    
  done;
  let pre_ciphered = Int64.logor (Int64.shift_left (Int64.of_int !right) 32)
                                 (Int64.of_int !left) in
  permut64 pre_ciphered final_p



           
(* Multiple blocks encrypting/decrypting *)
           
           
let test_int64  = Int64.of_string "0x0123456789ABCDEF"
let test_key    = Int64.of_string "0x133457799BBCDFF1"
let test_res    = Int64.of_string "0x85E813540F0AB405"
let test_stream_ecb = Stream.of_list [ test_int64; test_res ]
let test_stream_cbc = Stream.of_list [ test_int64; test_res ]
let test_stream_cfb = Stream.of_list [ test_int64; test_res ]
let test_stream_ofb = Stream.of_list [ test_int64; test_res ]                                
let test_iv     = Int64.of_string "0xABCDEF123456789"

let hex_print x = 
  let _ = Sys.command ("perl -e 'printf\"%X\n\"," ^ x ^ "'") in ()
                                                                  

(* *********************** ECB *********************** *)
let des_ecb_encrypt (plaintext: int64 Stream.t) (key: int64) : int64 Stream.t =
  Stream.from (fun _ ->
               try
                 let x = Stream.next plaintext in        
                 Some (des_single x key true)
               with
                 Stream.Failure -> None )

let des_ecb_decrypt (ciphered: int64 Stream.t) (key: int64) : int64 Stream.t =
  Stream.from (fun _ ->
               try
                 let x = Stream.next ciphered in        
                 Some (des_single x key false)
               with
                 Stream.Failure -> None )

let test_ecb () =
  let ciphered = des_ecb_encrypt test_stream_ecb test_key in
  let decrypted = des_ecb_decrypt ciphered test_key in
  Stream.iter (fun x -> hex_print (Int64.to_string x)) decrypted

(* *********************** CBC *********************** *)
let des_cbc_encrypt (plaintext: int64 Stream.t) (key: int64) (iv: int64)
    : int64 Stream.t =
  let prev = ref iv in
  Stream.from (fun _ ->
               try
                 let x = Stream.next plaintext in
                 (let v = des_single (Int64.logxor iv x) key true in
                  prev := v;
                  Some v )
               with
                 Stream.Failure -> None )

let des_cbc_decrypt (ciphered: int64 Stream.t) (key: int64) (iv: int64)
    : int64 Stream.t =
  let prev = ref iv in
  Stream.from (fun _ ->
               try
                 let x = Stream.next ciphered in
                 let v = (Int64.logxor (des_single x key false) !prev) in
                 (prev := x;
                  Some v )
               with
                 Stream.Failure -> None )
              
let test_cbc () =
  let ciphered = des_cbc_encrypt test_stream_cbc test_key test_iv in
  let decrypted = des_cbc_decrypt ciphered test_key test_iv in
  Stream.iter (fun x -> hex_print (Int64.to_string x)) decrypted


(* *********************** CFB *********************** *)                            
let des_cfb_encrypt (plaintext: int64 Stream.t) (key: int64) (iv: int64)
    : int64 Stream.t =
  let prev = ref iv in
  Stream.from (fun _ ->
               try
                 let x = Stream.next plaintext in
                 (let v = Int64.logxor (des_single !prev key true) x in
                  prev := v;
                  Some v)
               with
                 Stream.Failure -> None )
              

let des_cfb_decrypt (ciphered: int64 Stream.t) (key: int64) (iv: int64)
    : int64 Stream.t =
  let prev = ref (des_single iv key true) in
  Stream.from (fun _ ->
               try
                 let x = Stream.next ciphered in
                 (let v = (Int64.logxor x !prev) in
                  prev := des_single x key true;
                  Some v)
               with
                 Stream.Failure -> None )

let test_cfb () =
  let ciphered = des_cfb_encrypt test_stream_cfb test_key test_iv in
  let decrypted = des_cfb_decrypt ciphered test_key test_iv in
  Stream.iter (fun x -> hex_print (Int64.to_string x)) decrypted
              
(* *********************** OFB *********************** *)
let des_ofb_encrypt (plaintext: int64 Stream.t) (key: int64) (iv: int64)
    : int64 Stream.t =
  let prev = ref (des_single iv key true) in
  Stream.from (fun _ ->
               try
                 let x = Stream.next plaintext in
                 (let v = Int64.logxor !prev x in
                  prev := des_single !prev key true;
                  Some v)
               with
                 Stream.Failure -> None )

let des_ofb_decrypt (ciphered: int64 Stream.t) (key: int64) (iv: int64)
    : int64 Stream.t =
  let prev = ref (des_single iv key true) in
  Stream.from (fun _ ->
               try
                 let x = Stream.next ciphered in
                 let v = Int64.logxor !prev x in
                 (prev := des_single !prev key true;
                  Some v)
               with
                 Stream.Failure -> None )

let test_ofb () =
  let ciphered = des_ofb_encrypt test_stream_ofb test_key test_iv in
  let decrypted = des_ofb_decrypt ciphered test_key test_iv in
  Stream.iter (fun x -> hex_print (Int64.to_string x)) decrypted              

let () = 
         print_endline "Test ECB:";
         test_ecb ();
         print_endline "Test CBC:";
         test_cbc ();
         print_endline "Test CFB:";
         test_cfb ();
         print_endline "Test OFB:";
         test_ofb ()
