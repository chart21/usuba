open Usuba_AST

(* Returns the local vars of |f|, or nothing if |f| doesn't have local
   variables. *)
let get_vars (f : def) = match f.node with Single (vars, _) -> vars | _ -> []

module Usuba0 = struct
  let rec interp_expr env_fun (env_params : (ident, typ) Hashtbl.t)
      (env_var : (var, bool) Hashtbl.t) (e : expr) : bool list =
    let interp_expr_rec = interp_expr env_fun env_params env_var in
    match e with
    | Const (0, _) -> [ false ]
    | Const (1, _) -> [ true ]
    | ExpVar v -> [ Hashtbl.find env_var v ]
    | Not e' -> List.map not (interp_expr_rec e')
    | Log (op, x, y) -> (
        match op with
        | And -> List.map2 ( && ) (interp_expr_rec x) (interp_expr_rec y)
        | Or -> List.map2 ( || ) (interp_expr_rec x) (interp_expr_rec y)
        | Xor ->
            List.map2
              (fun x y -> (x && not y) || ((not x) && y))
              (interp_expr_rec x) (interp_expr_rec y)
        | Andn ->
            List.map2
              (fun x y -> (not x) && y)
              (interp_expr_rec x) (interp_expr_rec y)
        | _ -> assert false)
    | Fun (f, l) ->
        let l' = List.flatten (List.map interp_expr_rec l) in
        let f' = Hashtbl.find env_fun f in
        interp_node env_fun f' l'
    | _ ->
        raise
          (Errors.Error
             (Format.asprintf "Invalid expression: %a" (Usuba_print.pp_expr ())
                e))

  and interp_node env_fun (f : def) (l : bool list) : bool list =
    (* the function to evaluate an assignment *)
    let interp_asgn env_fun (env_params : (ident, typ) Hashtbl.t)
        (env_var : (var, bool) Hashtbl.t) (vars : var list) (expr : expr) : unit
        =
      let res = interp_expr env_fun env_params env_var expr in
      List.iter2
        (fun x y -> Hashtbl.replace env_var x y)
        (Basic_utils.flat_map (Utils.expand_var env_params) vars)
        res
    in
    (* creating a lexical environement *)
    let env_var : (var, bool) Hashtbl.t = Hashtbl.create 100 in
    (* adding the inputs in the environment *)
    let env_params = Utils.build_env_var f.p_in f.p_out (get_vars f) in
    List.iter2
      (fun v y -> Hashtbl.replace env_var v y)
      (Basic_utils.flat_map
         (Utils.expand_var env_params)
         (Utils.p_to_vars f.p_in))
      l;
    (* evaluating the instructions of the node *)
    (match f.node with
    | Single (_, deqs) ->
        List.iter
          (fun d ->
            match d.content with
            | Eqn (vars, e, _) -> interp_asgn env_fun env_params env_var vars e
            | _ -> raise (Errors.Error "Invalid 'Loop'"))
          deqs
    | _ ->
        raise
          (Errors.Error
             (Format.asprintf "Invalid node: %a" (Usuba_print.pp_def ()) f)));
    (* returning the values of the output variables *)
    List.map (Hashtbl.find env_var)
      (Basic_utils.flat_map
         (Utils.expand_var env_params)
         (Utils.p_to_vars f.p_out))

  let interp_prog (prog : prog) (input : bool list) : bool list =
    let env_fun = Hashtbl.create 100 in
    (* Collecting the list of nodes *)
    List.iter (fun f -> Hashtbl.replace env_fun f.id f) prog.nodes;
    (* Calling the last node (the entry point by convention) *)
    interp_node env_fun (Basic_utils.last prog.nodes) input
end

module Usuba = struct
  (* Note: node is a Table *)
  let interp_table (node : def) (l : bool list) : bool list =
    let idx = Basic_utils.boollist_to_int l in
    match node.node with
    | Table tbl ->
        Basic_utils.int_to_boollist (List.nth tbl idx) (Utils.p_size node.p_out)
    | _ -> assert false
end
