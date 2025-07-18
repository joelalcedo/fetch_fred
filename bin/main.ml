open Core
open Fred

let () =
  let api_key = Sys.getenv_exn "FRED_API_KEY" in
  let argv      = Sys.get_argv () in
  let series_id = if Array.length argv > 1 then argv.(1) else "UNRATE" in

  let observations = Lwt_main.run (fetch_series ~api_key ~series_id) in

  let latest10 = List.take observations 10 in 

  List.iter latest10 ~f:(fun { date; value } ->
      let value_str =
        match value with
        | Some v -> Float.to_string v
        | None   -> "NaN"
      in
      printf "%s : %s\n" date value_str)
