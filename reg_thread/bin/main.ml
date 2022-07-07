
let t_z3 () =
  let ctx = Z3.mk_context [] in

  let n = 1_000 in
  let ps = Array.init n (fun i -> Z3.Symbol.mk_int ctx i) in
  let qs = Array.init n (fun i -> Z3.Symbol.mk_int ctx (n+i)) in
  let solver = Z3.Solver.mk_simple_solver ctx in

  while true do
    Z3.Solver.reset solver;
    let p_prev = ref @@ Z3.Boolean.mk_const ctx ps.(0) in
    let q_prev = ref @@ Z3.Boolean.mk_const ctx qs.(0) in
    for i=1 to n-1 do
      let p = Z3.Boolean.mk_const ctx ps.(i) in
      let q = Z3.Boolean.mk_const ctx qs.(i) in
      Z3.Solver.add solver [Z3.Boolean.mk_xor ctx p q];
      Z3.Solver.add solver [Z3.Boolean.mk_implies ctx p !p_prev];
      Z3.Solver.add solver [Z3.Boolean.mk_implies ctx q !q_prev];
      p_prev := p;
      q_prev := q;
    done;

    Thread.yield();
    Printf.printf "t1: solve\n%!";
    let _st = Sys.opaque_identity (Z3.Solver.check solver [!p_prev]) in
    ()
  done;
  ()

let t_gc () =
  while true do
    for _i = 1 to 100 do
      let _a = Sys.opaque_identity (Array.make (2 * 1024 * 1024) 1.) in
    Thread.yield();
      ()
    done;
    Thread.yield();
    Printf.printf "t2: gc\n%!";
    Gc.compact();
  done

let () =
  let t1 = Thread.create t_z3 () in
  let trs = Array.init 1 (fun _ -> Thread.create t_gc ()) in

  Thread.join t1;
  Array.iter Thread.join trs
