open Context
open Types

let rec checkType = (ctx:context, x:term, t:ty) => switch(x) {
| TIf(t1,t2,t3) => {
    let i1 = checkType(ctx, t1, TyBool);
    let i2 = checkType(ctx, t2, t);
    let i3 = checkType(ctx, t3, t);
    switch (i1, i2, i3) {
      | (Some(TyBool), Some(_), Some(_)) => Some(t)
      | _ => None
    }
}
/* \l. ex : a -> b ? */
| TAbs(lam, expr) => switch(t) {
    | TyFn(a,b) => switch(checkType(extend(ctx,lam,a),expr,b)){
      | Some(_) => Some(t)
      | _ => None 
    }
    | _ => None
}
| _ => switch(inferTy(ctx,x)) {
    | Some(t2) => if (t == t2) { Some(t) } else { None }
    | _ => None
  }
}