open Lwt.Infix

type observation = {
  date: string; 
  value: float option;
}

let parse_observation json = 
  let open Yojson.Safe.Util in {
    date = json |> member "date" |> to_string;
    value = 
      (match json |> member "value" |> to_string with 
        | "" | "." -> None
        | s -> Some (float_of_string s));
    
  }

let fetch_series ~api_key ~series_id =
  let uri =
    Uri.of_string
      (Printf.sprintf
         "https://api.stlouisfed.org/fred/series/observations?\
          series_id=%s&api_key=%s&file_type=json" series_id api_key)
  in
  Cohttp_lwt_unix.Client.get uri >>= fun (_, body) ->
  Cohttp_lwt.Body.to_string body >|= fun body_str ->
  let json = Yojson.Safe.from_string body_str in
  let open Yojson.Safe.Util in
  json |> member "observations" |> to_list |> List.rev_map parse_observation 